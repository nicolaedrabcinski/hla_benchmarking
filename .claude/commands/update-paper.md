---
description: Update manuscript text to match current, approved results - closes stale statistics, placeholders, and BACKLOG.md category-A items
argument-hint: [section-name-or-backlog-id]
---

# /update-paper

## Purpose
Bring manuscript prose into agreement with current pipeline output, or work a
specific `BACKLOG.md` item. This command edits the manuscript; it never changes
underlying data or scoring.

## Inputs
- `$1` (optional): a section name ("Discussion", "Methods") or a specific
  `BACKLOG.md` item to work.
- Implicit inputs: `results_summary.md`, `BACKLOG.md`, the manuscript `.docx`, any
  propagation report from `/update-results`.

## Workflow
1. If invoked after `/update-results`, start from its propagation report; otherwise,
   invoke **scientific-writer** to scan the requested section/item.
2. For every number to be written or changed, **scientific-writer** confirms the
   source in `results_summary.md` and, for anything statistical, confirms
   **statistics-reviewer** sign-off exists.
3. For ancestry-related content, confirm **statistics-reviewer**'s statistical
   scope verdict first, then route through **clinical-and-equity-reviewer** for
   framing before drafting.
4. For clinical-recommendation content, route through
   **clinical-and-equity-reviewer** before drafting.
5. Draft the text change.
6. If the section is now draft-complete, invoke **devils-advocate** for
   adversarial review and attach the report.
7. Update `BACKLOG.md`: mark the worked item resolved (with a one-line resolution
   note) or leave open with a status update — never silently drop an item.

## Expected Outputs
- Edited manuscript section(s), each traceable to a specific data source.
- An updated `BACKLOG.md`.
- A devils-advocate report attached for any newly draft-complete section.
- An explicit list of anything requiring human decision (ranking/recommendation
  language, ancestry framing, category-C backlog items) rather than a silent guess.
