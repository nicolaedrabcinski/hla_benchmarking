#!/bin/bash
#
# RNA2HLA standardization script.
#
# EXPECTED INPUT DIRECTORY STRUCTURE
# -----------------------------------
#   <input_dir>/
#       <sample1>.txt      (one RNA2HLA combined genotype report per sample), OR
#       <sample1>/rna2hla.txt   (one subdir per sample containing the report)
#
# RNA2HLA writes a single combined class-I + class-II report per sample.
# The one worked example in this repo (results/raw_outputs/rna2hla.txt) uses
# the generic filename "rna2hla.txt" with no sample name embedded, so this
# script supports both a flat "<sample>.txt" layout and a
# "<sample>/rna2hla.txt" (or any *.txt inside a per-sample subdir) layout:
# if the found file's basename (minus .txt) looks generic
# (rna2hla / report / result / output / genotype), the sample name is taken
# from the immediate parent directory instead of the filename.
#
# This script accepts a single input_dir argument and processes every *.txt
# file found (recursively).
#
# NATIVE FORMAT (verified against results/raw_outputs/rna2hla.txt)
# -------------------------------------------------------------------------
#   ----------HLA class I------------
#   #Locus	Allele 1	Confidence	Allele 2	Confidence
#   A	A*03:01	0.02144055	A*03:01	0.0574801
#   B	B*07:02	0.8407581	B*27:05	0.3281453
#   C	C*02:02	0.9997497	C*02:02	0.0574801
#   ----------HLA class II-----------
#   #Locus	Allele 1	Confidence	Allele 2	Confidence
#   DQB1	DQB1*05:01	0.0	DQB1*05:01	1.0
#   DRB1	DRB1*11:30	0.5440214	DRB1*01:01	0.3432853
#   DPB1	no	NA	no	NA
#
# Tab-delimited: locus, allele1, confidence1, allele2, confidence2. Only
# A, B, C, DRB1, DQB1 rows are extracted (DPB1 is out of the canonical
# schema's scope, not silently dropped unsupported data -- RNA2HLA *does*
# call it, we just don't have a column for it). The literal token "no"
# (RNA2HLA's own no-call marker, seen for DPB1 above) is passed through
# unchanged if it ever appears for one of the five tracked loci -- this
# already matches the convention seen in results/standard/rna2hla_d4.csv
# and rna2hla_d7.csv (e.g. "SRR5252844,...,no,no,no,no" and
# "SRR7881400,no,no,B*67:02,...").
#
# VALIDATED END-TO-END: results/raw_outputs/rna2hla.txt is confirmed to be
# the exact RNA2HLA call for sample SRR7881399 (dataset 7) -- its row in
# results/standard/rna2hla_d7.csv is:
#   SRR7881399,A*03:01,A*03:01,B*07:02,B*27:05,C*02:02,C*02:02,DRB1*11:30,
#   DRB1*01:01,DQB1*05:01,DQB1*05:01
# which is reproduced exactly (values and order) by running this script's
# logic on the example file placed at <input_dir>/SRR7881399.txt.
#
# Output: Sample,A,A.1,B,B.1,C,C.1,DRB1,DRB1.1,DQB1,DQB1.1
#
# USAGE
# -----
#   ./rna2hla_standardize.sh <input_dir> <output_csv>
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

# find every *.txt file under input_dir, deterministic order
mapfile -t files < <(find "${input_dir}" -type f -name "*.txt" | sort)

if [ "${#files[@]}" -eq 0 ]; then
    echo "No *.txt files found under ${input_dir}" >&2
    exit 1
fi

for input_file in "${files[@]}"; do
    base="$(basename "${input_file}" .txt)"
    case "$(echo "${base}" | tr '[:upper:]' '[:lower:]')" in
        rna2hla|report|result|results|output|genotype)
            sample="$(basename "$(dirname "${input_file}")")"
            ;;
        *)
            sample="${base}"
            ;;
    esac

    # pull out the tab-delimited rows for the five tracked loci, in file order
    declare -A a1=() a2=()
    while IFS=$'\t' read -r locus allele1 _conf1 allele2 _conf2; do
        case "${locus}" in
            A|B|C|DRB1|DQB1)
                a1["${locus}"]="${allele1}"
                a2["${locus}"]="${allele2}"
                ;;
        esac
    done < <(grep -E '^(A|B|C|DRB1|DQB1)[[:space:]]' "${input_file}")

    echo "${sample},${a1[A]:-},${a2[A]:-},${a1[B]:-},${a2[B]:-},${a1[C]:-},${a2[C]:-},${a1[DRB1]:-},${a2[DRB1]:-},${a1[DQB1]:-},${a2[DQB1]:-}" >> "${output_csv}"

    unset a1 a2
    echo "Processed ${input_file} -> ${sample}"
done

echo "Wrote ${#files[@]} sample(s) to ${output_csv}"
