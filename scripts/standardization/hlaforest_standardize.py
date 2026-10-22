#!/usr/bin/env python3
"""
HLAforest standardization script.

Replaces the old `HLAforest_convert.ipynb`, which only ran in Google Colab
(it `drive.mount()`s a Google Drive folder and hardcodes
`/content/gdrive/Shared drives/HLA/results/hlaforest/d3/` as its input and
`/content/gdrive/MyDrive/hlaforest_d1/d1results` as its output) -- it could
not be run locally at all. This script reads HLAforest's native per-sample
`haplotypes.txt` directly off disk.

EXPECTED INPUT DIRECTORY STRUCTURE
-----------------------------------
    <input_dir>/
        <sample1>/haplotypes.txt
        <sample2>/haplotypes.txt
        ...
(one subdirectory per sample, named after the sample -- matches
data/input/raw/d1_spotcheck_hlaforest/<ERR...>/haplotypes.txt,
data/input/raw/d8_hlaforest/<mother|father|daughter>/haplotypes.txt, etc.)

NATIVE FORMAT
-------------
Tab-separated, one row per candidate allele (usually 2 rows per locus, for
a diploid call), with a leading row-number column:

    1	ROOT:A	ROOT:A:32	ROOT:A:32:01	ROOT:A:32:01:01
    2	ROOT:A	ROOT:A:11	ROOT:A:11:110
    3	ROOT:B	ROOT:B:44	ROOT:B:44:03	ROOT:B:44:03:01
    ...
    21	ROOT:DQB1	ROOT:DQB1:05	ROOT:DQB1:05:03	ROOT:DQB1:05:03:01	ROOT:DQB1:05:03:01:01
    22	ROOT:DQB1	ROOT:DQB1:02	ROOT:DQB1:02:02

i.e. a tree path "ROOT:<gene>:<field1>:<field2>:...", one column per tree
depth, with fields after "ROOT:<gene>" getting progressively more specific.
The 2-field resolution this project scores at is the "ROOT:<gene>:<f1>:<f2>"
depth -- NOT a fixed character offset into one fixed column index like the
old notebook used (`fields[2][7:]`, which only coincidentally worked
because it hardcoded `loc`/column position for the single-character loci
A/B/C it was written for, and did not handle DRB1/DQB1, multi-row files
with a leading row-number column, or depth ever being less than 2 fields).
This script instead scans every tab field in the row and picks the one
whose colon-split form is exactly "ROOT:<gene>:<num>:<num>" (falling back
to "ROOT:<gene>:<num>" -- 1-field resolution -- if no 2-field-depth column
exists for that row), so it is robust to a leading row-number column,
column-count drift between HLAforest runs, and loci of any name length.

VALIDATION
----------
Ran against all 14 samples under data/input/raw/d1_spotcheck_hlaforest/ and
compared (locus-by-locus, as an unordered pair -- this project's scoring
never distinguishes "first" vs "second" allele of a diploid call) against
the already-published data/interim/standard/hlaforest_d1.csv:
  - 3 samples (ERR188368/448/475) have a 0-byte haplotypes.txt in this
    2026-10-14 spot-check re-run (the tool run itself produced nothing
    that day), vs. real published values from whatever run originally
    produced hlaforest_d1.csv -- not a parsing question, nothing for this
    script to extract either way.
  - Of the remaining 11: 6 match the published row EXACTLY on all 5 loci
    (ERR188144, ERR188237, ERR188249, ERR204846, ERR204929, ERR204932).
    The other 5 each differ on 1-2 of the 5 loci (e.g. ERR188177: B*44:03
    vs published B*44:02; ERR188161: B*44:02 vs published B*44:150;
    ERR204874: one DQB1 copy 02:01 vs published 06:02). No consistent
    pattern across which locus/slot differs -- a systematic parsing bug
    (e.g. a column-offset or locus-prefix error) would be expected to fail
    the same way every time, not match exactly on some samples and differ
    on an inconsistent subset of loci on others. Most likely explanation:
    run-to-run drift between this spot-check re-run and whatever produced
    the original (2024) published file -- same category of drift already
    disclosed for other tools in this directory (see t1k_standardize.py).
  - (A/A.1, etc. order within a pair is not guaranteed to match row order
    in the published file -- harmless, since this project's scoring treats
    each locus's two calls as an unordered pair.)

This script does NOT regenerate or overwrite any already-published
data/interim/standard/hlaforest_d*.csv -- it is a replacement for the Colab
notebook's local-reproducibility gap, not a re-run of the full cohort.

NO-CALL CONVENTION: a locus with no candidate rows at all in a sample's
haplotypes.txt gets blank fields for both copies, matching the other
standardize scripts in this directory.

USAGE
-----
    python3 hlaforest_standardize.py <input_dir> <output_csv>

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

DEPTH2_RE = re.compile(r"^ROOT:([A-Za-z0-9]+):(\d+):(\d+)$")
DEPTH1_RE = re.compile(r"^ROOT:([A-Za-z0-9]+):(\d+)$")


def find_sample_dirs(input_dir):
    """One subdirectory per sample, each containing haplotypes.txt."""
    samples = []
    for entry in sorted(os.listdir(input_dir)):
        path = os.path.join(input_dir, entry)
        hap = os.path.join(path, "haplotypes.txt")
        if os.path.isdir(path) and os.path.isfile(hap):
            samples.append((entry, hap))
    return samples


def best_field_for_row(fields):
    """Among a row's tab fields, return (gene, '<f1>:<f2>') at 2-field
    depth if any field has it, else (gene, '<f1>') at 1-field depth, else
    None."""
    depth1 = None
    for field in fields:
        field = field.strip()
        m = DEPTH2_RE.match(field)
        if m:
            gene, f1, f2 = m.groups()
            return gene, "%s:%s" % (f1, f2)
        if depth1 is None:
            m1 = DEPTH1_RE.match(field)
            if m1:
                gene, f1 = m1.groups()
                depth1 = (gene, f1)
    return depth1


def parse_haplotypes_file(path):
    """Return {gene: [allele_suffix, ...]} in file order (usually 2 per gene)."""
    by_gene = {}
    with open(path) as fh:
        for raw_line in fh:
            fields = raw_line.rstrip("\n").split("\t")
            result = best_field_for_row(fields)
            if result is None:
                continue
            gene, suffix = result
            if gene not in LOCI:
                continue
            by_gene.setdefault(gene, []).append(suffix)
    return by_gene


def two_calls_per_gene(by_gene):
    result = {}
    for gene in LOCI:
        suffixes = by_gene.get(gene, [])[:2]
        alleles = ["%s*%s" % (gene, s) for s in suffixes]
        while len(alleles) < 2:
            alleles.append("")
        result[gene] = tuple(alleles)
    return result


def main():
    if len(sys.argv) != 3:
        sys.stderr.write("Usage: python3 hlaforest_standardize.py <input_dir> <output_csv>\n")
        sys.exit(1)

    input_dir, output_csv = sys.argv[1], sys.argv[2]
    samples = find_sample_dirs(input_dir)
    if not samples:
        sys.stderr.write("No <sample>/haplotypes.txt found under %s\n" % input_dir)
        sys.exit(1)

    rows = []
    for sample, hap_path in samples:
        by_gene = parse_haplotypes_file(hap_path)
        calls = two_calls_per_gene(by_gene)
        row = [sample]
        for locus in LOCI:
            a1, a2 = calls[locus]
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
