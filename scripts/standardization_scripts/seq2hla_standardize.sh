#!/bin/bash
#
# seq2HLA standardization script.
#
# EXPECTED INPUT DIRECTORY STRUCTURE
# -----------------------------------
# seq2HLA's own convention writes TWO files per sample, using a shared
# sample prefix and a "ClassI"/"ClassII" infix, e.g.:
#   <prefix>-ClassI.HLAgenotype4digits.txt
#   <prefix>-ClassII.HLAgenotype4digits.txt
#
# The one worked example in this repo uses simplified generic names
# without a sample prefix:
#   results/raw_outputs/seq2HLA.classI.txt
#   results/raw_outputs/seq2HLA.classII.txt
#
# This script therefore expects, per sample, a pair of files somewhere
# under <input_dir> (recursively) whose names both contain "classI" /
# "classII" (case-insensitive, optionally separated by '-', '_' or '.'
# from the rest of the name) and which are IDENTICAL except for that
# infix -- e.g.:
#   <input_dir>/<sample>-ClassI.HLAgenotype4digits.txt
#   <input_dir>/<sample>-ClassII.HLAgenotype4digits.txt
# or, matching the one available example, one subdirectory per sample:
#   <input_dir>/<sample>/seq2HLA.classI.txt
#   <input_dir>/<sample>/seq2HLA.classII.txt
# (in the latter case, since the filename itself carries no sample info,
# the sample name is taken from the immediate parent directory).
#
# Files are paired by identical "stem" (filename with the classI/classII
# token removed). If no directory/filename-based pairing can be inferred,
# the pair is skipped with a warning printed to stderr -- this script
# intentionally does not guess a sample name pairing it cannot support.
#
# NATIVE FORMAT (verified against results/raw_outputs/seq2HLA.classI.txt
# and seq2HLA.classII.txt)
# -------------------------------------------------------------------------
# classI file, tab-delimited, one row per locus:
#   #Locus	Allele 1	Confidence	Allele 2	Confidence
#   A	A*01:01	0.003438512	A*24:02	0.01144903
#   B	B*41:02	0.05046965	B*57:01	1.804829e-05
#   C	C*06:02	0.0001440336	C*17:01	0.004424371
#
# classII file, same tab-delimited layout, more loci:
#   DQA1 / DQB1 / DRB1 / DRA / DPA1 / DPB1
#
# Only A, B, C (from classI) and DRB1, DQB1 (from classII) are extracted
# -- DQA1/DRA/DPA1/DPB1 are out of the canonical schema's scope (seq2HLA
# does call them, they are just not part of the 10-column common schema
# tracked benchmark-wide, so this is not a silent drop of unsupported
# data).
#
# Allele values sometimes carry a trailing apostrophe ' in seq2HLA's own
# output (e.g. "DQA1*03:02'"), seen for low-confidence/questionable
# calls. This script STRIPS a single trailing apostrophe from each
# allele. ASSUMPTION / CAVEAT: this was confirmed for ONE row
# (ERR188021's DQA1/DRB1/DPA1 values in results/standard/seq2hla_d1.csv
# have apostrophes removed relative to the raw file) but CONTRADICTED by
# another existing legacy file (results/standard/seq2hla_d3.csv keeps
# the apostrophe, e.g. "C*07:01',C*07:01"). Since results/standard's own
# legacy files disagree with each other on this point, we picked
# "strip" as the cleaner canonical representation, consistent with the
# one row we can fully validate below. Flag to pipeline-integrity-auditor
# to confirm which convention the benchmark actually wants.
#
# ALSO ASSUMED (unverified from data, inferred from seq2HLA/RNA2HLA
# sharing a common codebase lineage -- RNA2HLA is a rewrite of seq2HLA):
# a literal "no" allele token (RNA2HLA's own no-call marker) is passed
# through unchanged if seq2HLA ever emits it for one of the five tracked
# loci. No no-call example was available among the seq2hla_d*.csv rows
# inspected to confirm this for seq2HLA specifically.
#
# VALIDATED END-TO-END for the four tracked class-I loci pairs + DRB1 +
# DQB1: results/raw_outputs/seq2HLA.classI.txt + .classII.txt are
# confirmed (after apostrophe-stripping) to be the exact seq2HLA call for
# sample ERR188021 -- compare against results/standard/seq2hla_d1.csv:
#   ERR188021,A*01:01,A*24:02,B*41:02,B*57:01,C*06:02,C*17:01, DQA1*03:02,
#   DQA1*05:01,DQB1*03:01,DQB1*03:01,DRB1*04:07,DRB1*13:03,DRA*01:01,...
# (A/B/C/DQB1/DRB1 fields match exactly what this script produces).
#
# Output: Sample,A,A.1,B,B.1,C,C.1,DRB1,DRB1.1,DQB1,DQB1.1
#
# USAGE
# -----
#   ./seq2hla_standardize.sh <input_dir> <output_csv>
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

# strip a single trailing apostrophe from an allele call
strip_apo() {
    local v="$1"
    echo "${v%\'}"
}

n_written=0

mapfile -t classI_files < <(find "${input_dir}" -type f -iname "*classi*" ! -iname "*classii*" | sort)

if [ "${#classI_files[@]}" -eq 0 ]; then
    echo "No *classI* files found under ${input_dir}" >&2
    exit 1
fi

for classI_file in "${classI_files[@]}"; do
    dir="$(dirname "${classI_file}")"
    base="$(basename "${classI_file}")"

    # derive the matching classII filename by swapping the classI token
    # (case-insensitive) for classII, trying the most common separators/casings
    classII_file=""
    for candidate in \
        "${base/ClassI/ClassII}" \
        "${base/classI/classII}" \
        "${base/CLASSI/CLASSII}" \
        "${base/Classi/Classii}"; do
        if [ -f "${dir}/${candidate}" ] && [ "${candidate}" != "${base}" ]; then
            classII_file="${dir}/${candidate}"
            break
        fi
    done

    if [ -z "${classII_file}" ]; then
        echo "WARNING: no matching classII file found for ${classI_file}; skipping" >&2
        continue
    fi

    # generic filename (no sample info) -> use parent directory as sample name.
    # Strip the .txt extension, the classI infix, and seq2HLA's own
    # "HLAgenotype<N>digits" report-type suffix (any digit count), leaving
    # just the sample-id prefix, e.g.
    # "ERR188021-ClassI.HLAgenotype4digits.txt" -> "ERR188021".
    stem_norm="$(echo "${base}" | sed -E 's/\.[Tt][Xx][Tt]$//')"
    stem_norm="$(echo "${stem_norm}" | sed -E 's/[-_.]?[Hh][Ll][Aa][Gg]enotype[0-9]*digits?[-_.]?//')"
    stem_norm="$(echo "${stem_norm}" | sed -E 's/[-_.]?[Cc]lass-?[Ii][-_.]?//')"
    stem_norm="$(echo "${stem_norm}" | sed -E 's/^[-_.]+//; s/[-_.]+$//')"
    if [ -z "${stem_norm}" ] || [ "$(echo "${stem_norm}" | tr '[:upper:]' '[:lower:]')" = "seq2hla" ]; then
        sample="$(basename "${dir}")"
    else
        sample="${stem_norm}"
    fi

    read -r a1_A a2_A < <(awk -F'\t' '$1=="A"{print $2, $4}' "${classI_file}")
    read -r a1_B a2_B < <(awk -F'\t' '$1=="B"{print $2, $4}' "${classI_file}")
    read -r a1_C a2_C < <(awk -F'\t' '$1=="C"{print $2, $4}' "${classI_file}")
    read -r a1_DRB1 a2_DRB1 < <(awk -F'\t' '$1=="DRB1"{print $2, $4}' "${classII_file}")
    read -r a1_DQB1 a2_DQB1 < <(awk -F'\t' '$1=="DQB1"{print $2, $4}' "${classII_file}")

    a1_A="$(strip_apo "${a1_A:-}")"; a2_A="$(strip_apo "${a2_A:-}")"
    a1_B="$(strip_apo "${a1_B:-}")"; a2_B="$(strip_apo "${a2_B:-}")"
    a1_C="$(strip_apo "${a1_C:-}")"; a2_C="$(strip_apo "${a2_C:-}")"
    a1_DRB1="$(strip_apo "${a1_DRB1:-}")"; a2_DRB1="$(strip_apo "${a2_DRB1:-}")"
    a1_DQB1="$(strip_apo "${a1_DQB1:-}")"; a2_DQB1="$(strip_apo "${a2_DQB1:-}")"

    echo "${sample},${a1_A},${a2_A},${a1_B},${a2_B},${a1_C},${a2_C},${a1_DRB1},${a2_DRB1},${a1_DQB1},${a2_DQB1}" >> "${output_csv}"

    n_written=$((n_written + 1))
    echo "Processed ${classI_file} + ${classII_file} -> ${sample}"
done

echo "Wrote ${n_written} sample(s) to ${output_csv}"
