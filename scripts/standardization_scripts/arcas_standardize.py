#!/usr/bin/env python3
"""
arcasHLA standardization script.

EXPECTED INPUT DIRECTORY STRUCTURE
-----------------------------------
    <input_dir>/
        <sample1>.genotype.json
        <sample2>.genotype.json
        ...

This matches the default output of `arcasHLA genotype` (and `arcasHLA merge`),
which writes one `<sample>.genotype.json` file per sample into the run's
output directory. The sample name is derived by stripping the suffix
'.genotype.json' (preferred) or, failing that, just '.json' from the
filename. Any other file extension is ignored.

NATIVE FORMAT
-------------
Each JSON file is a flat, single-level dict, e.g. (this is the actual
worked example at results/raw_outputs/arcas.json):

    {"A": ["A*03:01:119", "A*03:01:119"], "B": ["B*27:05:07", "B*27:05:07"],
     "C": ["C*02:141", "C*02:141"], "DQB1": ["DQB1*05:01:48", "DQB1*05:45"],
     "DRB1": ["DRB1*01:115", "DRB1*11:01:01"]}

mapping HLA gene name -> a list of called alleles for that gene. arcasHLA
omits a gene from the dict entirely if it cannot resolve it (e.g. read
depth too low), and can return a 1-element list when only one haplotype's
allele can be resolved (homozygous or partial call).

VALIDATION AGAINST results/standard/
-------------------------------------
results/raw_outputs/arcas.json is confirmed (by exact byte-for-byte allele
match) to be the arcasHLA call for sample SRR7881399, dataset 7:
see results/standard/arcas_d7.csv row 2:
    SRR7881399,A*03:01:119,A*03:01:119,B*27:05:07,B*27:05:07,C*02:141,
    C*02:141,DQB1*05:01:48,DQB1*05:45,DRB1*01:115,DRB1*11:01:01
Running this script's logic by hand on the one available example
(list index 0 -> first allele column, index 1 -> second allele column,
gene absent -> blank,blank) reproduces that row exactly, with the caveat
that arcas_d7.csv orders its columns DQB1,DQB1.1,DRB1,DRB1.1 (this script
follows the canonical task-specified order A,A.1,B,B.1,C,C.1,DRB1,DRB1.1,
DQB1,DQB1.1 instead -- values are identical, only column order in the
header differs from arcas_d7.csv specifically; see note below).

IMPORTANT SCOPE NOTE -- please read before trusting arcas_d1..d6.csv
---------------------------------------------------------------------
results/standard/arcas_d1.csv through arcas_d6.csv are PRE-EXISTING files
NOT produced by this script. They were (presumably) produced by some
other, undocumented process using an extended arcasHLA reference that
also types DMA, DMB, DPA1, DPB1, DQA1, DRA, E, F, G, H, K. Inspection
shows these six files use at least THREE different, mutually
inconsistent column-naming/ordering schemes (e.g. arcas_d1.csv uses
"DQB1,DQB1.1"; arcas_d2.csv/d3.csv use "DQB11,DQB12" for the same pair;
arcas_d4.csv drops the DMB1/DQB1 pairing entirely and uses different gene
order again; arcas_d5.csv is missing A/B columns altogether). This script
deliberately does NOT try to reproduce those six legacy files. It targets
ONLY the canonical 10-column schema specified for this benchmark:
    Sample,A,A.1,B,B.1,C,C.1,DRB1,DRB1.1,DQB1,DQB1.1
verified end-to-end only against arcas_d7.csv (the one internally
consistent, canonical-schema file, and the one that matches the single
raw JSON example available). Flag the arcas_d1..d6.csv inconsistency to
pipeline-integrity-auditor / hla-benchmark-scientist -- those files may
need to be regenerated with this script once real multi-sample JSON
output is available, or kept separately as an "extended" arcas schema.

ASSUMPTION (unverified): if a gene's allele list has length 1, the single
allele is duplicated into both allele columns for that locus. No
length-1 example was available in the one worked JSON to confirm this;
flag if a real run contradicts it.

USAGE
-----
    python3 arcas_standardize.py <input_dir> <output_csv>

Idempotent: reading the same input directory always regenerates the same
output_csv from scratch (the output file is overwritten, not appended to).
"""
import sys
import os
import json
import glob
import csv

LOCI = ["A", "B", "C", "DRB1", "DQB1"]
HEADER = ["Sample"]
for locus in LOCI:
    HEADER.append(locus)
    HEADER.append(locus + ".1")


def sample_name_from_path(path):
    base = os.path.basename(path)
    if base.endswith(".genotype.json"):
        return base[: -len(".genotype.json")]
    if base.endswith(".json"):
        return base[: -len(".json")]
    return base


def alleles_for_locus(genotype, locus):
    calls = genotype.get(locus)
    if not calls:
        return "", ""
    if len(calls) == 1:
        return calls[0], calls[0]
    # arcasHLA lists are already in a stable [allele1, allele2] order;
    # preserve it as-is (confirmed against the SRR7881399 example above).
    return calls[0], calls[1]


def main():
    if len(sys.argv) != 3:
        sys.stderr.write(
            "Usage: python3 arcas_standardize.py <input_dir> <output_csv>\n"
        )
        sys.exit(1)

    input_dir, output_csv = sys.argv[1], sys.argv[2]

    json_files = sorted(glob.glob(os.path.join(input_dir, "*.genotype.json")))
    if not json_files:
        # fall back to any *.json in the directory
        json_files = sorted(glob.glob(os.path.join(input_dir, "*.json")))

    if not json_files:
        sys.stderr.write(
            "No *.genotype.json / *.json files found under %s\n" % input_dir
        )
        sys.exit(1)

    rows = []
    for jf in json_files:
        sample = sample_name_from_path(jf)
        with open(jf) as fh:
            genotype = json.load(fh)
        row = [sample]
        for locus in LOCI:
            a1, a2 = alleles_for_locus(genotype, locus)
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
