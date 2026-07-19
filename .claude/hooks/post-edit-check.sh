#!/bin/bash
# PostToolUse hook (Write|Edit matcher). Single dispatcher for all post-edit gates
# - merged from the former pre-benchmark-check.sh + pre-paper-update-check.sh so
# every file write/edit only pays one JSON-parse cost, not two, and both checks
# share the same FILE_PATH extraction. Warns only, never blocks.

set -uo pipefail

PAYLOAD="$(cat)"
FILE_PATH="$(printf '%s' "$PAYLOAD" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"

[ -n "$FILE_PATH" ] || exit 0

REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$REPO_ROOT"

WARN=""

# ─────────────────────────────────────────────────────────────────────────────
# Check A: benchmark completeness (fires on notebooks/ or results/standard/)
# ─────────────────────────────────────────────────────────────────────────────
case "$FILE_PATH" in
  *notebooks/*|*results/standard/*)
    if [ -d results/standard ]; then
      for f in results/standard/*_d*.csv; do
        [ -e "$f" ] || continue
        base="$(basename "$f")"
        tool="${base%%_d*}"
        if ! ls scripts/environmental_files/ 2>/dev/null | grep -qi "$tool"; then
          WARN="${WARN}- No conda env file found under scripts/environmental_files/ matching tool '$tool'.\n"
        fi
        if ! ls scripts/standardization_scripts/ 2>/dev/null | grep -qi "$tool"; then
          WARN="${WARN}- No standardization script found under scripts/standardization_scripts/ for tool '$tool' (may have been converted manually - see reproducibility-manager).\n"
        fi
        dsnum="$(basename "$f" | grep -oE 'd[0-9]+' | grep -oE '[0-9]+' | head -1)"
        if [ -n "$dsnum" ] && [ ! -f "datasets/${dsnum}_gs.csv" ]; then
          WARN="${WARN}- results/standard/$(basename "$f") references dataset $dsnum but datasets/${dsnum}_gs.csv is missing.\n"
        fi
      done
    fi
    ;;
esac

# ─────────────────────────────────────────────────────────────────────────────
# Check B: manuscript hygiene (fires on results_summary.md, BACKLOG.md, notebooks/)
# ─────────────────────────────────────────────────────────────────────────────
case "$FILE_PATH" in
  *results_summary.md|*BACKLOG.md|*notebooks/*)
    if [ -f "$FILE_PATH" ]; then
      if grep -nE '\*\* include|MORE FIGURES TO BE ADDED|TODO|TBD|\[citation needed\]' "$FILE_PATH" > /tmp/paper_markers.$$ 2>/dev/null; then
        WARN="${WARN}Unfinished markers found in $FILE_PATH:\n$(cat /tmp/paper_markers.$$)\n"
      fi
      rm -f /tmp/paper_markers.$$

      for num in $(grep -oE '[Ff]ig(ure)?\.?[[:space:]]*[0-9]+' "$FILE_PATH" 2>/dev/null | grep -oE '[0-9]+' | sort -u); do
        if ! find "$REPO_ROOT/figures" "$REPO_ROOT/Figures" -iname "*${num}*" 2>/dev/null | grep -q .; then
          WARN="${WARN}- Figure ${num} is referenced in $FILE_PATH but no matching file was found under figures/ or Figures/.\n"
        fi
      done
    fi
    ;;
esac

if [ -n "$WARN" ]; then
  echo -e "post-edit-check warnings (non-blocking):\n${WARN}" >&2
fi

exit 0
