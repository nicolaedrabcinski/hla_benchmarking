#!/bin/bash
#
# HLA-VBSeq standardization script.
#
# EXPECTED INPUT DIRECTORY STRUCTURE
# -----------------------------------
#   <input_dir>/
#       <sample1>.txt          (one per-sample genotype table), OR
#       <sample1>/hlavbseq.txt (one subdir per sample containing the table)
#
# This script processes every *.txt file found recursively under
# <input_dir>. If a found file's basename (minus .txt) looks generic
# (hlavbseq / report / result / results / output / genotype), the sample
# name is taken from the immediate parent directory instead of the
# filename -- this matches the one worked example in this repo, which
# uses the generic filename "hlavbseq.txt" with no sample id in the name.
#
# NATIVE FORMAT -- IMPORTANT CAVEAT, PLEASE READ
# -------------------------------------------------------------------------
# The one available raw example (results/raw_outputs/hlavbseq.txt) is a
# clean, tab-delimited "Gene / Allele1 / Allele2" table, one row per gene,
# already at 2-field resolution, with NO per-allele score/read-count
# column:
#   Gene	Allele1	Allele2
#   A	A*02:01	A*02:01
#   B	B*07:02	B*40:01
#   C	C*03:04	C*07:02
#   ...
#   DQB1	DQB1*06:02	DQB1*06:04
#   DRB1	DRB1*13:02	DRB1*15:01
#   ...
#
# This is NOT what HLA-VBSeq's own documented pipeline emits natively.
# HLA-VBSeq's real raw output (from HLAVBSeq.jar, after running
# parse_result.pl) is a flat, per-allele RANKED LIST with a read-count/
# abundance score per line, covering many genes intermixed, e.g.
# "A*24:02:01:01<TAB>145.32" -- i.e. a scored list that a caller must
# itself group by gene and reduce to top-2. This script's input format
# (a pre-reduced, already-diploid, score-less table) looks instead like a
# POST-PROCESSED summary -- plausibly already-finalized genotype calls
# with the per-allele scores stripped out for brevity when this repo's
# example was saved.
#
# CROSS-CHECK PERFORMED (2026-07-20, tool-integration-engineer, second
# pass): a scored ranked-list-style raw file also exists in this repo at
# results/raw_outputs/t1k.txt (see t1k_standardize.py's header for the
# matching caveat there) -- structurally, THAT file's format (flat list of
# "HLA-<gene>*<allele> <count>" lines spanning many genes) is a much
# closer structural match to HLA-VBSeq's documented parse_result.pl
# output than to T1K's own documented tabular genotype.tsv format
# (gene_name / num_alleles / allele_1 / abundance_1 / quality_1 /
# allele_2 / abundance_2 / quality_2). This raises a real possibility that
# the two raw example files under results/raw_outputs/ were saved under
# swapped/mislabeled tool names. This script and t1k_standardize.py were
# EACH written to faithfully parse the file that currently carries their
# tool's name (per the task's file assignment), NOT to guess-swap them.
# Flagging this explicitly for pipeline-integrity-auditor /
# hla-benchmark-scientist to confirm file identity before either script is
# trusted for a real cohort run -- this is the same category of bug this
# project has already been burned by once (see KNOWN_BUGS.md's resolved
# "HLA-VBSeq DRB1/DQB1 column swap" entry).
#
# Only A, B, C, DRB1, DQB1 rows are extracted (E/F/DQA1/DPA1/DPB1/DMA/DMB/
# DOA/DOB/DRA/MICB present in the native file are out of the canonical
# schema's scope, not a silent drop of unsupported data -- HLA-VBSeq does
# call these, there's just no column for them here).
#
# VALIDATION STATUS -- COULD NOT CONFIRM END-TO-END
# -------------------------------------------------------------------------
# Searched every row of results/standard/hlavbseq_d1.csv through d7.csv
# (and, as a cross-check, T1K_d1.csv through d7.csv) for a row whose
# 2-field-truncated A/B/C/DRB1/DQB1 allele sets exactly match this raw
# example's calls (A*02:01/A*02:01, B*07:02/B*40:01, C*03:04/C*07:02,
# DRB1*13:02/DRB1*15:01, DQB1*06:02/DQB1*06:04). NO exact 5/5-locus match
# was found in either file set. The closest partial matches (4 of 5 loci
# -- B, C, DRB1, DQB1 all match exactly; only A differs) were
# hlavbseq_d1.csv rows for ERR188073 and ERR188266 -- but since A does NOT
# match for either (raw example is homozygous A*02:01/A*02:01; neither
# candidate sample is), sample identity is NOT confirmed. Flagged for
# pipeline-integrity-auditor to check against a real multi-sample
# HLA-VBSeq run before trusting this script for a full cohort, same as
# the already-flagged HLAminer script from pass 1.
#
# NO-CALL CONVENTION: results/standard/hlavbseq_d1..d7.csv are internally
# INCONSISTENT on how a missing call is represented: hlavbseq_d6.csv uses
# literal "NA" (uppercase), hlavbseq_d7.csv uses literal "na" (lowercase),
# and hlavbseq_d1/d3/d4/d5.csv leave the field blank. This script emits a
# BLANK field for any locus/allele-copy it cannot find in the native file
# (majority convention, and the simplest to reproduce deterministically).
# Flag to pipeline-integrity-auditor to confirm which convention the
# benchmark actually wants long-term.
#
# Output header uses the canonical task-specified column order
# (Sample,A,A.1,B,B.1,C,C.1,DRB1,DRB1.1,DQB1,DQB1.1), NOT the
# hlavbseq_d1.csv-specific header ("ERR,A,...") -- consistent with the
# pass-1 scripts' approach of targeting only the canonical schema.
#
# USAGE
# -----
#   ./hlavbseq_standardize.sh <input_dir> <output_csv>
#
# Idempotent: output_csv is overwritten (not appended to) on each run.

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_dir> <output_csv>" >&2
    exit 1
fi

input_dir="$1"
output_csv="$2"

echo "Sample,A,A.1,B,B.1,C,C.1,DRB1,DRB1.1,DQB1,DQB1.1" > "${output_csv}"

mapfile -t files < <(find "${input_dir}" -type f -name "*.txt" | sort)

if [ "${#files[@]}" -eq 0 ]; then
    echo "No *.txt files found under ${input_dir}" >&2
    exit 1
fi

for input_file in "${files[@]}"; do
    base="$(basename "${input_file}" .txt)"
    case "$(echo "${base}" | tr '[:upper:]' '[:lower:]')" in
        hlavbseq|report|result|results|output|genotype)
            sample="$(basename "$(dirname "${input_file}")")"
            ;;
        *)
            sample="${base}"
            ;;
    esac

    declare -A a1=() a2=()
    while IFS=$'\t' read -r locus allele1 allele2; do
        case "${locus}" in
            A|B|C|DRB1|DQB1)
                a1["${locus}"]="${allele1:-}"
                a2["${locus}"]="${allele2:-}"
                ;;
        esac
    done < <(grep -E $'^(A|B|C|DRB1|DQB1)\t' "${input_file}" || true)

    echo "${sample},${a1[A]:-},${a2[A]:-},${a1[B]:-},${a2[B]:-},${a1[C]:-},${a2[C]:-},${a1[DRB1]:-},${a2[DRB1]:-},${a1[DQB1]:-},${a2[DQB1]:-}" >> "${output_csv}"

    unset a1 a2
    echo "Processed ${input_file} -> ${sample}"
done

echo "Wrote ${#files[@]} sample(s) to ${output_csv}"
