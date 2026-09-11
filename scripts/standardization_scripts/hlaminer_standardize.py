#!/usr/bin/env python3
"""
HLAminer standardization script.

EXPECTED INPUT DIRECTORY STRUCTURE
-----------------------------------
HLAminer (HPRA method) writes one summary CSV per sample, conventionally
named "HLAminer_HPRA.csv" (name unchanged run-to-run), so per-sample runs
are normally kept apart either as one subdirectory per sample or via a
sample-prefixed filename. This script accepts EITHER layout, searched
recursively under <input_dir>:

    <input_dir>/<sample>/HLAminer_HPRA.csv        (one subdir per sample), OR
    <input_dir>/<sample>_HLAminer_HPRA.csv         (flat, sample-prefixed), OR
    <input_dir>/<sample>.HLAminer_HPRA.csv

Any file matching *HLAminer*.csv (case-insensitive) is picked up. If the
matched filename itself is the generic "HLAminer_HPRA.csv" (no sample
info in the name), the sample is taken from the immediate parent
directory name. Otherwise the sample is the filename with the
"HLAminer_HPRA"/".csv" part stripped.

NATIVE FORMAT (see results/raw_outputs/hlaminer.csv for the one worked
example available in this repo)
-------------------------------------------------------------------------
The file has two "SUMMARY" blocks: class I, then class II. Within each
block, each gene appears as a bare header line ("HLA-A", "HLA-DQB1",
etc.) followed by up to two "Prediction #N - <2-digit-group>" lines, each
followed by one or more candidate allele lines (comma-separated:
allele,score,expect,confidence), sorted best (highest score) first.

This script takes the FIRST (highest-scoring) allele line under
"Prediction #1" as allele-copy-1, and the first allele line under
"Prediction #2" as allele-copy-2, for each of HLA-A, HLA-B, HLA-C
(class I block), and DQB1, DRB1 (class II block) -- these five genes are
the only ones in the canonical schema; DPA1/DPB1/DQA1/DRA/DRB2-9/E/F/G
are present in native HLAminer output but intentionally not emitted
(out of schema scope, not a silent drop of unsupported data).

If a gene section is missing entirely, or has no "Prediction #1"/"#2"
line, "NA" is written for that allele copy -- this matches the literal
"NA" no-call convention already used throughout
results/standard/hlaminer_d1.csv..d7.csv.

VALIDATION CAVEAT (please read)
--------------------------------
We could NOT find an exact-matching row for the one worked example
(results/raw_outputs/hlaminer.csv -- A*24:02/A*11:02, B*57:01/B*41:29,
C*06:02/C*17:07) in any of results/standard/hlaminer_d1.csv..d7.csv: a
grep for those allele combinations across all seven files turned up no
matching row. So while the parsing LOGIC above follows directly from the
documented HLAminer_HPRA.csv layout and matches the "Prediction #1 /
Prediction #2 -> allele copy 1 / allele copy 2" structure evident in the
file, this script's output could not be validated end-to-end against a
known sample row the way the arcasHLA/RNA2HLA/seq2HLA scripts could.
Flag to pipeline-integrity-auditor to confirm against a real multi-sample
HLAminer run before trusting this for a full cohort.

ALSO NOTE: allele strings are emitted exactly as HLAminer prints them,
including any trailing "P" (P-group) suffix (e.g. "A*24:02P"). No
existing hlaminer_d*.csv row was found containing a "P" suffix to
confirm whether it should be stripped, so it is intentionally left as-is
rather than guessed away.

USAGE
-----
    python3 hlaminer_standardize.py <input_dir> <output_csv>
"""
import sys
import os
import re
import csv

LOCI = ["A", "B", "C", "DQB1", "DRB1"]
HEADER = ["Sample"]
for locus in LOCI:
    HEADER.append(locus)
    HEADER.append(locus + ".1")

GENE_HEADER_RE = re.compile(r"^HLA-([A-Za-z0-9]+)\s*$")
PRED_RE = re.compile(r"Prediction\s*#\s*([12])")


def find_hlaminer_files(input_dir):
    matches = []
    for root, _dirs, files in os.walk(input_dir):
        for fn in files:
            if "hlaminer" in fn.lower() and fn.lower().endswith(".csv"):
                matches.append(os.path.join(root, fn))
    return sorted(matches)


def sample_name_from_path(path):
    fn = os.path.basename(path)
    stem = re.sub(r"\.csv$", "", fn, flags=re.IGNORECASE)
    # generic filename -> use parent directory as sample name
    if re.fullmatch(r"HLAminer[_.]?HPRA", stem, flags=re.IGNORECASE):
        return os.path.basename(os.path.dirname(path))
    # otherwise strip a HLAminer[_.]HPRA suffix/prefix if present
    stem = re.sub(r"[_.]?HLAminer[_.]?HPRA", "", stem, flags=re.IGNORECASE)
    stem = stem.strip("._-")
    return stem if stem else os.path.basename(os.path.dirname(path))


def parse_hlaminer_csv(path):
    """Return {gene: (allele_copy1_or_None, allele_copy2_or_None)}."""
    result = {}
    gene = None
    pred = None
    captured = {1: None, 2: None}

    def flush_gene():
        if gene is not None:
            result[gene] = (captured[1], captured[2])

    with open(path) as fh:
        for raw_line in fh:
            line = raw_line.rstrip("\n").rstrip("\r")
            gene_match = GENE_HEADER_RE.match(line.strip())
            if gene_match:
                flush_gene()
                gene = gene_match.group(1)
                pred = None
                captured = {1: None, 2: None}
                continue

            pred_match = PRED_RE.search(line)
            if pred_match:
                pred = int(pred_match.group(1))
                continue

            stripped = line.strip()
            if not stripped or stripped.startswith("-") or stripped.startswith("SUMMARY"):
                continue
            if stripped.startswith("Allele,Score") or stripped.startswith("*restricting"):
                continue

            # a candidate allele data line, e.g. "A*24:02P,13812.90,4.94e-324,3233.1"
            if "*" in stripped and pred in (1, 2) and captured[pred] is None:
                allele = stripped.split(",")[0].strip()
                captured[pred] = allele

        flush_gene()

    return result


def main():
    if len(sys.argv) != 3:
        sys.stderr.write(
            "Usage: python3 hlaminer_standardize.py <input_dir> <output_csv>\n"
        )
        sys.exit(1)

    input_dir, output_csv = sys.argv[1], sys.argv[2]
    files = find_hlaminer_files(input_dir)
    if not files:
        sys.stderr.write("No *HLAminer*.csv files found under %s\n" % input_dir)
        sys.exit(1)

    rows = []
    for f in files:
        sample = sample_name_from_path(f)
        parsed = parse_hlaminer_csv(f)
        row = [sample]
        for locus in LOCI:
            a1, a2 = parsed.get(locus, (None, None))
            row.append(a1 if a1 else "NA")
            row.append(a2 if a2 else "NA")
        rows.append(row)

    with open(output_csv, "w", newline="") as out:
        writer = csv.writer(out)
        writer.writerow(HEADER)
        writer.writerows(rows)

    print("Wrote %d sample(s) to %s" % (len(rows), output_csv))


if __name__ == "__main__":
    main()
