# HLA Benchmark Lab — AI Research Operating System (v2)

This is not a prompt library. It is the operating system for an AI research
organization built for one purpose: producing the strongest possible HLA
typing-tool benchmark, the highest-quality manuscript, and a publication that can
become the reference benchmark in the field. Every component below exists because
it closes a real gap this project has already hit — not because it seemed useful
in the abstract. Nothing here is designed for reuse on a future project; see
"What This Deliberately Isn't" below.

**If you have one hour:** read this file, then `GOVERNANCE.md`, then
`agents/scientific-coordinator.md`. That's the whole system's shape.

## Version History

- **v1** (first build): 11 flat specialist agents, no management layer, decision
  authority implicit and restated per-file.
- **v2** (this version): added an Executive layer (`scientific-coordinator`,
  `devils-advocate`, `literature-surveillance`) to fix the missing-synthesis
  problem; dissolved `ancestry-equity-analyst` (its work was fully decomposable
  into `statistics-reviewer` + `clinical-and-equity-reviewer` — one owner per
  responsibility, not one owner per sensitive topic); merged `reviewer2-simulator`
  into `devils-advocate` and expanded its scope from manuscript text to
  decisions generally; fixed a real dual-ownership bug on
  `scripts/environmental_files/`; deleted 3 generic-knowledge skill files and 2
  workflow-mismatched templates that existed for hypothetical reuse rather than
  this project. 12 agents, net fewer files than v1.

## The Organization

```
                    Human PI (Serghei) & Project Owner (Nick)
                     — the only holders of final authority —
                              │                    │
                    (routes routine work)  (independent challenge,
                              │             bypasses the coordinator)
                    ┌─────────▼─────────┐          │
                    │ scientific-        │◄─────────┘
                    │ coordinator        │  devils-advocate
                    │ [EXECUTIVE]        │  [EXECUTIVE, independent]
                    └──┬──────┬──────────┘
                       │      │
              literature-  pipeline-integrity-auditor
              surveillance  [independent QA — audits Research
              [EXECUTIVE]    + Statistics, reports here not to them]

  ┌─────────────────────┬─────────────────────┬─────────────────────┐
  │ RESEARCH             │ STATISTICS          │ PUBLICATIONS         │ INFRASTRUCTURE
  │ Lead:                │ Lead:                │ Lead:                 │ Lead:
  │ hla-benchmark-        │ statistics-reviewer  │ scientific-writer     │ reproducibility-
  │ scientist             │ (independent —       │                       │ manager
  │  ├─ dataset-curator   │  no reports)          │  ├─ figure-designer  │ (no reports)
  │  └─ tool-integration- │                       │  └─ clinical-and-    │
  │      engineer         │                       │      equity-reviewer │
  └─────────────────────┴─────────────────────┴─────────────────────┴─────────────────────
```

**Every agent has exactly one manager.** `devils-advocate`,
`pipeline-integrity-auditor`, and `statistics-reviewer` report outside the normal
line specifically so they can check the people whose work they audit without a
conflict of interest — see `GOVERNANCE.md`'s Independence section for why that
matters and isn't just org-chart decoration.

## The Pipeline

Information moves in one direction, not as a mesh of everyone-talks-to-everyone:

```
literature-surveillance → scientific-coordinator (roadmap) →
hla-benchmark-scientist (methodology) → tool-integration-engineer (build) →
dataset-curator (data readiness) → [pipeline execution] →
pipeline-integrity-auditor (QC gate) → statistics-reviewer (validation) →
figure-designer → scientific-writer → clinical-and-equity-reviewer +
devils-advocate (review gate) → Human PI (approval) →
reproducibility-manager (release) → [impact monitoring: dormant until submission]
```

If you find yourself wanting to route information some other way, that's a signal
to update this diagram deliberately — not to add an ad hoc side-channel between
two agents.

## Decision Authority

Every important decision type (adding a tool, changing methodology, changing
figures, changing the manuscript, ...) has an explicit Propose → Review → Approve
→ Implement chain, and a single non-negotiable list of what
`scientific-coordinator` can never approve without the Human PI. **All of it lives
in one place: `GOVERNANCE.md`.** Agent files reference it; they do not restate it.
If you're ever unsure who can approve something, that file has the answer — if it
doesn't, that's a gap to fix in `GOVERNANCE.md`, not to resolve ad hoc.

## Directory Map

| Path | What it is | Why it exists |
|---|---|---|
| `GOVERNANCE.md` | The single decision-authority table and non-negotiables list | Prevents the same policy being restated 12 different ways across 12 agent files and drifting. |
| `agents/` | 12 specialist subagents — 3 Executive, 9 delivery-layer across 4 teams | See the org chart above. |
| `commands/` | 10 slash commands wrapping this project's actual recurring workflows | `/run-benchmark`, `/add-tool`, etc. map directly to steps already in `scripts/data_generation/` and `notebooks/accuracy_fixed_executed.ipynb`. |
| `workflows/` | Multi-agent processes spanning more than one command | Adding a tool or updating the manuscript touches most of the org in sequence; workflows document the handoff order. |
| `hooks/` | Automatic, deterministic gates before risky actions | Two dispatcher scripts (`pre-git-action-check.sh`, `post-edit-check.sh`) — mechanical checks judgment shouldn't have to remember. |
| `skills/` | Reusable *project-specific* expert knowledge — `hla-nomenclature`, `benchmark-methodology`, `scientific-writing` | Deliberately narrow: generic textbook knowledge (statistics 101, generic figure-design advice) was cut in v2 and folded into the owning agent instead — this project doesn't need reusable frameworks, it needs this benchmark done well. |
| `templates/` | Boilerplate for documents this project actually produces | Every one matches an artifact type that exists in this repo today — no template for a workflow (PRs, GitHub Issues) this project doesn't use. |
| `memory/` | Persistent facts that must survive context resets and handovers | Supported tools, known bugs, publication status, project history. |
| `checklists/` | Deterministic gates for high-stakes actions | Adding a tool, submitting a paper, cutting a release. |
| `AUTOMATION_OPPORTUNITIES.md` | Ranked list of what should eventually be fully automated | Owned by `scientific-coordinator` as a living roadmap input, not an orphan document. |

## What This Deliberately Isn't

This is not reusable infrastructure, and it isn't trying to be. Every agent,
skill, and template here is scoped to this specific benchmark — its 12 tools, its
8 datasets, its scoring contract, its manuscript. If a future, unrelated project
wants something like this, it should be designed fresh for that project's actual
shape, not inherited from this one. Optimizing for hypothetical reuse here would
have meant keeping generic content this project doesn't need — v1 had some of
that; v2 removed it.

## Reading Order for a New Maintainer

1. This file.
2. `GOVERNANCE.md` — who can decide what.
3. `agents/scientific-coordinator.md` — the synthesis point everything routes
   through.
4. `agents/hla-benchmark-scientist.md` — the most scientifically load-bearing
   agent; understand it before touching any scoring code.
5. `workflows/add-new-tool.md` — see the whole org actually collaborate on one
   task end to end.
6. `checklists/` — the gates you'll hit immediately when you try to do anything.
