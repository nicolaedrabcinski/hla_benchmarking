#!/usr/bin/env python3
"""
HISAT-genotype standardization script.

EXPECTED INPUT DIRECTORY STRUCTURE
-----------------------------------
    <input_dir>/
        <sample1>.txt          (one per-sample hisatgenotype report file), OR
        <sample1>/hisat.txt    (one subdir per sample containing the file)

This script processes every *.txt file found recursively under
<input_dir>. Sample name resolution (in priority order):
  1. Parsed directly out of the report's own "# COMMAND:" line, which
     embeds the original input FASTQ names, e.g.
       .../hisatgenotype --base hla -z ../ --in-dir ... \
         -1 SRR5252843Aligned.sortedByCoord.out.extracted.1.fq \
         -2 SRR5252843Aligned.sortedByCoord.out.extracted.2.fq --out-dir d4
     -> sample = "SRR5252843" (text before "Aligned", falling back to
     stripping a trailing ".1.fq"/".1.fastq"/".fastq.gz" etc. if "Aligned"
     is not present). This is the preferred method since it is embedded
     in the file itself and does not depend on how the file was saved to
     disk.
  2. If no COMMAND line / no recognizable -1 FASTQ token is found, falls
     back to the filename (minus .txt), or -- if that stem looks generic
     (hisat / report / result / results / output / genotype) -- the
     immediate parent directory name. This matches the one worked example
     in this repo, which is saved as the generic "hisat.txt".

NATIVE FORMAT (verified against results/raw_outputs/hisat.txt)
-------------------------------------------------------------------------
For each gene, hisatgenotype prints a block like:
    <N> reads and <M> pairs are aligned
        1 <allele> (count: <reads>)
        2 <allele> (count: <reads>)
        ... (up to 10 top-count candidates; NOT used by this script)


        1 ranked <allele> (abundance: <pct>%)
        2 ranked <allele> (abundance: <pct>%)
        3 ranked <allele> (abundance: <pct>%)   <- can go beyond 2!
        4 ranked <allele> (abundance: <pct>%)
The gene name is NOT printed as a standalone header anywhere in this
report format -- it must be read off the allele name's own prefix (the
text before "*"), e.g. "A*03:01:01:01" -> gene "A", "DRB1*15:01:01:01" ->
gene "DRB1".

As already documented in KNOWN_BUGS.md's "Over-calling ... claim
inaccurate" finding, the "ranked ... (abundance: X%)" block for a single
gene CAN legitimately list MORE than 2 alleles (e.g. this repo's own
hisat.txt: HLA-B has 4 ranked entries: 49.71 / 35.51 / 8.75 / 6.03%).
Per this task's explicit instruction, this script does NOT simply take
the file's first two "ranked" lines for a gene (which happens to also be
correct here, since hisatgenotype already prints them in descending-
abundance order) -- it explicitly re-groups every "ranked" line by gene
and EXPLICITLY re-sorts by the parsed abundance percentage, descending,
before taking the top 2. This guards against any input where ranked
lines for one gene are not contiguous, or are not already sorted, neither
of which this script assumes.

Only A, B, C, DRB1, DQB1 "ranked" lines are extracted and reduced to
top-2-by-abundance (2-field-truncated, e.g. "A*03:01:01:01" ->
"A*03:01"). DMA/DMB/DOA/DOB/DPA1/DPB1/DQA1/DRA/DRB3/DRB5/S/MICA/MICB
(also present in native hisatgenotype output) are out of the canonical
schema's scope -- not a silent drop of unsupported data, hisatgenotype
does call them, there's just no column for them here.

VALIDATION STATUS
-------------------------------------------------------------------------
results/raw_outputs/hisat.txt's own "# COMMAND:" line names
"SRR5252843Aligned.sortedByCoord.out.extracted.1.fq" as input 1, i.e. the
report is for sample SRR5252843. Its row in results/standard/hisat_d4.csv
is:
    SRR5252843,A*03:01,A*01:01,B*35:01,B*08:01,C*04:01,C*07:01,DQB1*02:01,
    DQB1*02:01,,
Running this script's logic on the raw file reproduces the A, B, and C
calls EXACTLY:
    A: ranked 1 A*03:01:01:01 (56.71%), ranked 2 A*01:01:01:01 (43.29%)
       -> A*03:01, A*01:01   [matches]
    B: ranked 1 B*35:01:01:02 (49.71%), ranked 2 B*08:01:01:02 (35.51%)
       (ranks 3-4 correctly excluded by top-2-by-abundance)
       -> B*35:01, B*08:01   [matches]
    C: ranked 1 C*04:01:01:04 (34.54%), ranked 2 C*07:01:01:02 (33.43%)
       (ranks 3-4 correctly excluded)
       -> C*04:01, C*07:01   [matches]
HOWEVER: results/raw_outputs/hisat.txt is CUT OFF mid-file -- it ends
partway through the DPA1 candidate-count block (line 130, "10
DPA1*02:02:03 (count: 12)"), BEFORE ever reaching a DQB1 or DRB1 "ranked"
block. DQB1/DRB1 could therefore NOT be validated end-to-end against this
example (the hisat_d4.csv row shows DQB1*02:01/DQB1*02:01 called and
DRB1 blank/no-call for this sample, which is at least consistent with,
but not provable from, the truncated raw file). The parsing LOGIC for
DQB1/DRB1 is identical to the validated A/B/C logic (same "ranked ...
(abundance: %)" pattern, same gene-prefix grouping), so it is expected to
work the same way on a complete file -- flag to pipeline-integrity-auditor
to confirm against a complete, non-truncated hisatgenotype report before
trusting DQB1/DRB1 output for a full cohort run.

NO-CALL CONVENTION: results/standard/hisat_d1.csv through d6.csv
consistently use a BLANK field (not literal "NA") for a missing call
(e.g. hisat_d4.csv row for SRR5252839: "...,B*15:01,...,DRB1*12:01,"
with A.1 blank). This script matches that convention.

Output header uses the canonical task-specified column order
(Sample,A,A.1,B,B.1,C,C.1,DRB1,DRB1.1,DQB1,DQB1.1), NOT the
hisat_d*.csv-specific header ("ERR,A,...,DQB1,DQB1.1,DRB1,DRB1.1") --
consistent with the pass-1 scripts' approach of targeting only the
canonical schema.

USAGE
-----
    python3 hisat_standardize.py <input_dir> <output_csv>

Idempotent: reading the same input directory always regenerates the same
output_csv from scratch (the output file is overwritten, not appended to).
"""
import sys
import os
import re
import csv

LOCI = ["A", "B", "C", "DRB1", "DQB1"]
HEADER = ["Sample"]
for locus in LOCI:
    HEADER.append(locus)
    HEADER.append(locus + ".1")

RANKED_RE = re.compile(
    r"ranked\s+([A-Za-z0-9]+)\*([0-9A-Za-z:]+)\s*\(abundance:\s*([0-9.]+)%\)"
)
COMMAND_R1_RE = re.compile(r"-1\s+(\S+)")


def find_files(input_dir):
    matches = []
    for root, _dirs, files in os.walk(input_dir):
        for fn in files:
            if fn.lower().endswith(".txt"):
                matches.append(os.path.join(root, fn))
    return sorted(matches)


def sample_from_command_line(text):
    """Try to pull a sample id out of the '# COMMAND:' line's -1 FASTQ arg."""
    m = COMMAND_R1_RE.search(text)
    if not m:
        return None
    token = m.group(1)
    # strip typical STAR/HISAT extracted-fastq suffixing
    m2 = re.match(r"^(.*?)Aligned", token)
    if m2 and m2.group(1):
        return m2.group(1)
    # fallback: strip common fastq extensions / .1/.2 read markers
    stripped = re.sub(r"(\.[12])?\.(fq|fastq)(\.gz)?$", "", token, flags=re.IGNORECASE)
    return stripped or None


def sample_name_from_path(path):
    base = os.path.basename(path)
    stem = re.sub(r"\.txt$", "", base, flags=re.IGNORECASE)
    if stem.lower() in ("hisat", "report", "result", "results", "output", "genotype"):
        return os.path.basename(os.path.dirname(path))
    return stem


def truncate2(allele_suffix):
    parts = allele_suffix.split(":")
    return ":".join(parts[:2])


def parse_hisat_file(path):
    with open(path) as fh:
        text = fh.read()

    sample = sample_from_command_line(text)
    if not sample:
        sample = sample_name_from_path(path)

    by_gene = {}
    for gene, allele_suffix, pct_str in RANKED_RE.findall(text):
        gene = gene.upper()
        if gene not in LOCI:
            continue
        try:
            pct = float(pct_str)
        except ValueError:
            continue
        allele = "%s*%s" % (gene, truncate2(allele_suffix))
        by_gene.setdefault(gene, []).append((pct, allele))

    top2 = {}
    for gene, entries in by_gene.items():
        best_pct = {}
        for pct, allele in entries:
            if allele not in best_pct or pct > best_pct[allele]:
                best_pct[allele] = pct
        ranked = sorted(best_pct.items(), key=lambda kv: kv[1], reverse=True)
        top_alleles = [allele for allele, _pct in ranked[:2]]
        while len(top_alleles) < 2:
            top_alleles.append("")
        top2[gene] = tuple(top_alleles)

    return sample, top2


def main():
    if len(sys.argv) != 3:
        sys.stderr.write("Usage: python3 hisat_standardize.py <input_dir> <output_csv>\n")
        sys.exit(1)

    input_dir, output_csv = sys.argv[1], sys.argv[2]
    files = find_files(input_dir)
    if not files:
        sys.stderr.write("No *.txt files found under %s\n" % input_dir)
        sys.exit(1)

    rows = []
    for f in files:
        sample, top2 = parse_hisat_file(f)
        row = [sample]
        for locus in LOCI:
            a1, a2 = top2.get(locus, ("", ""))
            row.append(a1)
            row.append(a2)
        rows.append(row)

    with open(output_csv, "w", newline="") as out:
        writer = csv.writer(out)
        writer.writerow(HEADER)
        writer.writerows(rows)

    print("Wrote %d sample(s) to %s" % (len(rows), output_csv))


if __name__ == "__main__":
    main()
