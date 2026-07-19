# Governance

The single canonical source for two things every agent file used to restate
independently: **who approves what**, and **what no AI agent may ever finalize
alone**. If an agent file's Forbidden Decisions section conflicts with this file,
this file wins — update the agent file.

## Decision Authority Table

Every row has exactly one **Approves** entry. That entry is always
`scientific-coordinator` — uniform on purpose, so authority is never ambiguous.
What varies is whether `scientific-coordinator` may close the decision itself or
must route it to the Human PI first (see Non-Negotiables below).

| Decision | Proposes | Reviews | Approves | Implements |
|---|---|---|---|---|
| Adding a benchmark tool | `literature-surveillance` or `tool-integration-engineer` | `pipeline-integrity-auditor` (validation) + `hla-benchmark-scientist` (scientific fit) | `scientific-coordinator` → **Human PI required** | `tool-integration-engineer` |
| Changing benchmark methodology / scoring contract | `hla-benchmark-scientist` | `statistics-reviewer` + `devils-advocate` | `scientific-coordinator` → **Human PI required** | `hla-benchmark-scientist` |
| Adding a dataset | `dataset-curator` | `hla-benchmark-scientist` (scoring fit) + `statistics-reviewer` (power/quality) | `scientific-coordinator` → **Human PI required** | `dataset-curator` |
| Changing evaluation metrics | `hla-benchmark-scientist` | `statistics-reviewer` | `scientific-coordinator` → **Human PI required** | `hla-benchmark-scientist` |
| Changing statistical analysis method | `statistics-reviewer` | `devils-advocate` | `scientific-coordinator` (routine robustness improvement) → **Human PI required if it changes any already-reported number or claim** | `statistics-reviewer` |
| Changing figures | `figure-designer` | `scientific-writer` (narrative fit) + `statistics-reviewer` (if underlying data changed) | `scientific-coordinator` | `figure-designer` |
| Changing manuscript text | `scientific-writer` | `devils-advocate` + domain reviewer (`clinical-and-equity-reviewer` for clinical/ancestry claims, `statistics-reviewer` for numbers) | `scientific-coordinator` (routine number-sync) → **Human PI required for any ranking, recommendation, ancestry, or clinical claim** | `scientific-writer` |
| Changing documentation | any agent | `scientific-coordinator` | `scientific-coordinator` | authoring agent |
| Changing the benchmark pipeline (code) | `tool-integration-engineer` or `hla-benchmark-scientist` | `pipeline-integrity-auditor` | `scientific-coordinator` | `tool-integration-engineer` |
| Changing the project roadmap | `scientific-coordinator` (synthesizes) / `literature-surveillance` (proposes triggers) | `devils-advocate` | `scientific-coordinator` → **Human PI required for any change to what gets worked on this cycle** | `scientific-coordinator` |
| Changing the release process | `reproducibility-manager` | `pipeline-integrity-auditor` + `devils-advocate` | `scientific-coordinator` → **Human PI required** | `reproducibility-manager` |

## Non-Negotiables

`scientific-coordinator` may **never** close these out itself, regardless of how
routine they appear — always route to the Human PI:

1. Any `git push`, `git tag`, or public data/code deposition (SRA, Zenodo).
2. Any change to the novel-allele definition, the ambiguous-match convention, or
   the monoallelic-duplication convention (the scoring contract's core choices).
3. Official inclusion or exclusion of a tool or dataset in the benchmark.
4. Any ranking or recommendation claim ("we recommend arcasHLA").
5. Any wording of the ancestry-disparity finding, anywhere it's cited.
6. Any clinical-applicability claim.
7. Manuscript submission itself.

## Independence

Two agents report outside the normal chain specifically so they can check the
people above them without a conflict of interest:

- **`devils-advocate`** reports directly to the Human PI, not to
  `scientific-coordinator` — it must be able to challenge the coordinator's own
  roadmap and priority calls.
- **`pipeline-integrity-auditor`** and **`statistics-reviewer`** report to
  `scientific-coordinator`, never to `hla-benchmark-scientist` — they exist to
  independently check that agent's output, so they cannot report into it.

## Escalation Rule

If two agents disagree and neither's file resolves it, escalate to
`scientific-coordinator`. If the disagreement involves `scientific-coordinator`
itself, escalate to `devils-advocate`, who reports independently to the Human PI.
No decision waits indefinitely — every escalation must reach a named owner within
one hop.
