#!/usr/bin/env python3
"""
T1K standardization script.

EXPECTED INPUT DIRECTORY STRUCTURE
-----------------------------------
    <input_dir>/
        <sample1>.txt          (one per-sample ranked-allele-list file), OR
        <sample1>/t1k.txt      (one subdir per sample containing the file)

This script processes every *.txt file found recursively under
<input_dir>. If a found file's basename (minus .txt) looks generic
(t1k / report / result / results / output / genotype), the sample name is
taken from the immediate parent directory instead of the filename -- this
matches the one worked example in this repo, which uses the generic
filename "t1k.txt" with no sample id embedded.

NATIVE FORMAT -- IMPORTANT CAVEAT, PLEASE READ
-------------------------------------------------------------------------
The one available raw example (results/raw_outputs/t1k.txt) is a flat,
headerless list, one allele candidate per line, of the form:

    HLA-A*03:01:72 60
    HLA-B*07:02:01:01 60
    HLA-B*08:178 60
    HLA-E*01:03:02:11 60
    ...
    HLA-DRB1*15:01:01:01 60
    HLA-DRB1*03:01:01:01 60
    ...
    HLA-DQB1*06:02:01:01 60
    HLA-DQB1*02:01:01:01 60
    ...
    MICA*008:01:01 9

i.e. "<[HLA-]Gene>*<allele-suffix> <count>", where <count> looks like a
per-allele supporting read count. Genes are NOT grouped/blocked in the
file (a gene's two candidate lines are not always adjacent), so this
script groups every line by its gene prefix FIRST, then reduces per gene
-- it does NOT rely on line adjacency or order.

THIS IS NOT T1K's OWN DOCUMENTED NATIVE OUTPUT FORMAT. T1K's real
genotype.tsv is tab-delimited, one row per gene, with columns:
    gene_name, num_distinct_alleles, allele_1, abundance_1, quality_1,
    allele_2, abundance_2, quality_2
Neither the "HLA-" allele prefix, nor a single bare trailing count with no
gene_name/num_alleles/quality columns, matches that documented layout.
Structurally, this raw example's format (a flat, unblocked, all-genes-
mixed list of "<allele> <count>" pairs) is instead a much closer match to
HLA-VBSeq's documented parse_result.pl output. See
hlavbseq_standardize.py's -- sorry, hlavbseq_standardize.sh's -- header
comment for the full cross-check: this raises a real possibility that
results/raw_outputs/hlavbseq.txt and results/raw_outputs/t1k.txt were
saved under swapped/mislabeled tool names. This script parses the file
that currently carries the "t1k.txt" name (per the task's file
assignment) as faithfully as possible; it does NOT guess-swap the tool
identity. Flag to pipeline-integrity-auditor / hla-benchmark-scientist to
confirm before trusting this script (or hlavbseq_standardize.sh) for a
real cohort run.

PARSING LOGIC
-------------
1. Strip an optional leading "HLA-" (case-insensitive) from each line's
   allele token.
2. The gene name is everything before the first "*".
3. Only A, B, C, DRB1, DQB1 are kept (E/F/S/DRA/DRB3/DRB5/DQA1/DPA1/DPB1/
   DMA/DMB/DOA/DOB/MICA -- all present in the native file -- are out of
   the canonical schema's scope, not a silent drop of unsupported data).
4. Within each kept gene, lines are sorted by their trailing count,
   HIGHEST FIRST (explicit numeric sort -- NOT "take the first two lines
   as they appear in the file", per this task's instruction, since ranked
   entries for one gene are not guaranteed contiguous in this file and
   this format has no explicit "rank" field the way hisat.txt does).
   Exact-duplicate 2-field-truncated alleles are collapsed (kept once).
5. Each allele string is truncated to its first two ':'-separated fields
   (e.g. "A*03:01:72" -> "A*03:01"; "B*08:178" already has only two
   fields and is left as-is).
6. Only the top 2 (by count) are kept per gene. If a gene has fewer than
   2 distinct candidate lines in the file, the missing allele-copy slot
   is left BLANK (not a guessed duplicate) -- see no-call convention note
   below. If a gene has NO candidate lines at all (as happened for C in
   the one available example -- see below), both slots are left blank.

VALIDATION STATUS -- COULD NOT CONFIRM END-TO-END, AND THE RAW EXAMPLE IS
INCOMPLETE FOR THIS PURPOSE
-------------------------------------------------------------------------
Applying the above logic to results/raw_outputs/t1k.txt yields:
    A: A*03:01, <blank>          (only ONE A candidate line exists at all)
    B: B*07:02, B*08:178
    C: <blank>, <blank>          (NO C candidate lines exist in the file)
    DRB1: DRB1*15:01, DRB1*03:01
    DQB1: DQB1*06:02, DQB1*02:01
A search of every row in results/standard/T1K_d1.csv through d7.csv (and,
as a cross-check, hlavbseq_d1.csv through d7.csv) for a row whose
2-field-truncated B/DRB1/DQB1 values match B*07:02/B*08:178,
DRB1*15:01/DRB1*03:01, DQB1*06:02/DQB1*02:01 found NO match at all (not
even a partial one) -- unlike hlavbseq_standardize.sh's search using the
OTHER raw file's calls, which at least found two 4-of-5-locus partial
matches. This strongly suggests results/raw_outputs/t1k.txt is either an
INCOMPLETE excerpt (the file may simply not include the true top candidate
lines for every gene -- note A has only 1 line and C has 0, which is
itself suspicious for a diploid locus) or is not attributable to any
sample currently in results/standard/T1K_d*.csv. Flagged for
pipeline-integrity-auditor to check against a real multi-sample T1K run
before trusting this script for a full cohort -- do not treat the parsing
LOGIC above as wrong just because this one example doesn't validate; the
logic follows directly from the file's own documented-by-inspection
structure, but end-to-end correctness is UNCONFIRMED.

NO-CALL CONVENTION: results/standard/T1K_d1.csv through d7.csv
consistently use a BLANK field (not literal "NA") for a missing allele
call (e.g. T1K_d1.csv row for ERR188083: "...,DQB1*03:02:01,,DRB1*04:01:01,...").
This script matches that convention.

Output header uses the canonical task-specified column order
(Sample,A,A.1,B,B.1,C,C.1,DRB1,DRB1.1,DQB1,DQB1.1), NOT the
T1K_d1.csv-specific header ("ERR,A,...,DQB1,DQB1.1,DRB1,DRB1.1") --
consistent with the pass-1 scripts' approach of targeting only the
canonical schema.

USAGE
-----
    python3 t1k_standardize.py <input_dir> <output_csv>

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

LINE_RE = re.compile(
    r"^(?:HLA-)?([A-Za-z0-9]+)\*([0-9A-Za-z:]+)\s+([0-9.]+)\s*$", re.IGNORECASE
)


def sample_name_from_path(path):
    base = os.path.basename(path)
    stem = re.sub(r"\.txt$", "", base, flags=re.IGNORECASE)
    if stem.lower() in ("t1k", "report", "result", "results", "output", "genotype"):
        return os.path.basename(os.path.dirname(path))
    return stem


def truncate2(allele_suffix):
    parts = allele_suffix.split(":")
    return ":".join(parts[:2])


def find_files(input_dir):
    matches = []
    for root, _dirs, files in os.walk(input_dir):
        for fn in files:
            if fn.lower().endswith(".txt"):
                matches.append(os.path.join(root, fn))
    return sorted(matches)


def parse_t1k_file(path):
    """Return {gene: [(count_float, truncated_allele), ...]} unsorted-by-gene lists."""
    by_gene = {}
    with open(path) as fh:
        for raw_line in fh:
            line = raw_line.strip()
            if not line:
                continue
            m = LINE_RE.match(line)
            if not m:
                continue
            gene, allele_suffix, count_str = m.groups()
            gene = gene.upper()
            if gene not in LOCI:
                continue
            try:
                count = float(count_str)
            except ValueError:
                continue
            allele = "%s*%s" % (gene, truncate2(allele_suffix))
            by_gene.setdefault(gene, []).append((count, allele))
    return by_gene


def top2_per_gene(by_gene):
    result = {}
    for gene, entries in by_gene.items():
        # explicit sort by count descending (NOT file order) -- de-dupe
        # identical (post-truncation) alleles, keeping the highest count
        # seen for each.
        best_count = {}
        for count, allele in entries:
            if allele not in best_count or count > best_count[allele]:
                best_count[allele] = count
        ranked = sorted(best_count.items(), key=lambda kv: kv[1], reverse=True)
        top_alleles = [allele for allele, _count in ranked[:2]]
        while len(top_alleles) < 2:
            top_alleles.append("")
        result[gene] = tuple(top_alleles)
    return result


def main():
    if len(sys.argv) != 3:
        sys.stderr.write("Usage: python3 t1k_standardize.py <input_dir> <output_csv>\n")
        sys.exit(1)

    input_dir, output_csv = sys.argv[1], sys.argv[2]
    files = find_files(input_dir)
    if not files:
        sys.stderr.write("No *.txt files found under %s\n" % input_dir)
        sys.exit(1)

    rows = []
    for f in files:
        sample = sample_name_from_path(f)
        by_gene = parse_t1k_file(f)
        top2 = top2_per_gene(by_gene)
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
