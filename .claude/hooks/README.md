# Hooks

Deterministic, mechanical gates. Agents provide judgment; hooks provide the thing
judgment is bad at under context pressure — never forgetting to check.

Wired into `.claude/settings.json` as two dispatcher scripts, one per event type.
Each script reads the incoming tool-call payload **once** and branches internally
on command/file-path content, rather than registering multiple separate scripts
under the same matcher — an earlier revision of this system had four scripts (two
per event) that each independently re-parsed the same JSON payload via a fresh
`python3` process, meaning every single `Bash` call and every single `Write`/`Edit`
call paid multiple interpreter-startup costs just to be told "not relevant, exit
0." Consolidating to one dispatcher per event halves that fixed overhead with no
loss of detection coverage.

| Script | Fires on | Branches | Blocks (exit 2) or warns (exit 0 + message) | Detects |
|---|---|---|---|---|
| `pre-git-action-check.sh` | `Bash` calls | Branch 1: `git commit`. Branch 2: `git tag` / `git push` / SRA / Zenodo-looking upload commands. Anything else: no-op. | **Blocks** | Branch 1: committed `.DS_Store`/cache files; staged notebook with unresolved JSON error output; `results_summary.md` older than the `results/standard/*.csv` it depends on. Branch 2: uncommitted changes under `results/`, `notebooks/`, or `datasets/`; missing reproducibility checklist; duplicate/ambiguous figure directories without a documented canonical mapping. |
| `post-edit-check.sh` | `Write`/`Edit` calls | Check A: path under `notebooks/` or `results/standard/`. Check B: path is `results_summary.md`, `BACKLOG.md`, or under `notebooks/` (both checks run independently — a `notebooks/` edit triggers both). | **Warns** | Check A: missing standardization script or conda env file for a tool referenced in `results/standard/`; missing gold-standard file for a referenced dataset. Check B: known unfinished markers (`** include`, `MORE FIGURES TO BE ADDED`, `TODO`, `TBD`, `[citation needed]`) still present; a figure referenced by number with no corresponding file in the canonical figure directory. |

## Design Notes

- **Blocking hooks are reserved for irreversible or public actions** (commit,
  tag, push, upload) — consistent with every agent file's "Forbidden Decisions"
  sections never permitting these autonomously.
- **Non-blocking hooks warn into the transcript** so an agent or human sees the
  issue immediately without being hard-stopped mid-edit; the corresponding
  checklist (`checklists/`) is the authoritative gate before anything ships.
- Every check here is intentionally mechanical (`grep`, `find`, file-mtime
  comparison) — anything requiring judgment (is this discrepancy acceptable?) stays
  with the owning agent, never a hook.
- These scripts assume a POSIX shell and `python3` (for JSON parsing of the hook
  payload). No other dependency is required.
- **Why two scripts instead of four:** `PreToolUse`/`PostToolUse` matchers filter
  on tool *name* only, not command content — every `Bash` call fires whatever is
  registered under the `Bash` matcher regardless of what that call actually does.
  One dispatcher per event type means that cost is paid once per call, not once
  per registered script.
