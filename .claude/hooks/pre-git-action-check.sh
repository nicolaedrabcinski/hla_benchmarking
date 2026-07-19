#!/bin/bash
# PreToolUse hook (Bash matcher). Single dispatcher for all git action gates -
# merged from the former pre-commit-check.sh + pre-release-check.sh so a plain
# `ls` or `find` only pays one python3 startup cost, not two, to be told "not a
# git command, exit 0."
#
# Exit 2 = block the tool call. Exit 0 = allow.

set -uo pipefail

PAYLOAD="$(cat)"
CMD="$(printf '%s' "$PAYLOAD" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("command",""))' 2>/dev/null || true)"

REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$REPO_ROOT"

# ─────────────────────────────────────────────────────────────────────────────
# Branch 1: git commit
# ─────────────────────────────────────────────────────────────────────────────
if printf '%s' "$CMD" | grep -qE 'git[[:space:]]+commit'; then
  FAIL=0
  MSG=""

  STAGED="$(git diff --cached --name-only 2>/dev/null || true)"
  if printf '%s\n' "$STAGED" | grep -qE '(^|/)\.DS_Store$|__pycache__|\.ipynb_checkpoints'; then
    FAIL=1
    MSG="${MSG}- Staged OS/cache cruft (.DS_Store, __pycache__, .ipynb_checkpoints). Unstage before committing.\n"
  fi

  for nb in $(printf '%s\n' "$STAGED" | grep -E '\.ipynb$' || true); do
    if [ -f "$nb" ] && python3 -c "
import json,sys
try:
    nb=json.load(open('$nb'))
except Exception:
    sys.exit(0)
for c in nb.get('cells', []):
    for o in c.get('outputs', []):
        if o.get('output_type') == 'error':
            sys.exit(1)
sys.exit(0)
"; then
      :
    else
      FAIL=1
      MSG="${MSG}- $nb contains an unresolved error output cell.\n"
    fi
  done

  if [ -f results_summary.md ] && [ -d results/standard ]; then
    NEWEST_CSV="$(find results/standard -name '*.csv' -newer results_summary.md 2>/dev/null | head -1 || true)"
    if [ -n "$NEWEST_CSV" ]; then
      FAIL=1
      MSG="${MSG}- results_summary.md is older than $NEWEST_CSV. Run /run-benchmark before committing.\n"
    fi
  fi

  if [ "$FAIL" -eq 1 ]; then
    echo -e "pre-git-action-check blocked this commit:\n${MSG}" >&2
    exit 2
  fi
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Branch 2: git tag / git push / public data upload
# ─────────────────────────────────────────────────────────────────────────────
if printf '%s' "$CMD" | grep -qE 'git[[:space:]]+(tag|push)|sra-tools|ascp|zenodo|prefetch.*--upload'; then
  FAIL=0
  MSG=""

  DIRTY="$(git status --porcelain -- results notebooks datasets 2>/dev/null || true)"
  if [ -n "$DIRTY" ]; then
    FAIL=1
    MSG="${MSG}- Uncommitted changes under results/, notebooks/, or datasets/:\n${DIRTY}\n"
  fi

  if [ ! -f .claude/checklists/reproducibility-checklist.md ]; then
    FAIL=1
    MSG="${MSG}- checklists/reproducibility-checklist.md is missing.\n"
  fi

  if [ -d figures ] && [ -d Figures ] && [ ! -f .claude/memory/FIGURE_CANONICAL_MAP.md ]; then
    FAIL=1
    MSG="${MSG}- Both figures/ and Figures/ exist with no .claude/memory/FIGURE_CANONICAL_MAP.md documenting which is canonical. Run figure-designer's consolidation pass first.\n"
  fi

  if [ "$FAIL" -eq 1 ]; then
    echo -e "pre-git-action-check BLOCKED this action (irreversible/public command detected):\n${MSG}\nResolve the above, or have a human confirm and re-run with explicit override." >&2
    exit 2
  fi
  exit 0
fi

# Not a recognized git/upload action - no-op.
exit 0
