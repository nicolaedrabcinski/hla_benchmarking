# Workflow: Adding a New HLA Typing Tool

The canonical end-to-end path from "a new caller exists" to "the benchmark and
manuscript reflect it." This is the concrete implementation of the example
lifecycle diagram this operating system was designed against.

```
New tool identified
        │
        ▼
Environment + install  ──────────────  tool-integration-engineer
        │
        ▼
Smoke test (3-5 samples) ────────────  tool-integration-engineer
        │
        ▼
Standardization script ──────────────  tool-integration-engineer
        │
        ▼
Schema + spot-check validation ──────  pipeline-integrity-auditor
        │
        ▼
Downloading/confirming full dataset ─  dataset-curator
        │
        ▼
Full-cohort run (D1-D6, +D7/D8 if in scope)
        │
        ▼
Standardizing outputs (results/standard/<tool>_d{N}.csv)
        │
        ▼
Scoring under canonical contract ────  hla-benchmark-scientist
        │
        ▼
Cross-implementation check (Julia) ──  pipeline-integrity-auditor
        │
        ▼
Independent statistical re-derivation ─  statistics-reviewer
        │
        ▼
Ancestry re-test (if population data available) ─ statistics-reviewer
        │
        ▼
Generating figures (all 14, tool added) ─  figure-designer
        │
        ▼
Updating manuscript text ────────────  scientific-writer
        │
        ▼
Clinical framing check ──────────────  clinical-and-equity-reviewer
        │
        ▼
Adversarial review ──────────────────  devils-advocate
        │
        ▼
Updating supplementary tables ───────  scientific-writer + hla-benchmark-scientist
        │
        ▼
Reproducibility + release checklist ─  reproducibility-manager
        │
        ▼
Human decision: official inclusion?
        │
   ┌────┴────┐
  YES        NO
   │          │
   ▼          ▼
Prepare release        Archive candidate evaluation,
(/prepare-release)     document reason for exclusion
```

## Step Detail

1. **Identification.** A new tool surfaces via literature/GitHub watch (manual
   today; see `AUTOMATION_OPPORTUNITIES.md` for automating this). File a candidate
   note.
2. **Environment + install.** `tool-integration-engineer` builds
   `scripts/environmental_files/<tool>.yml` and confirms clean install.
3. **Smoke test.** Run on 3-5 samples spanning at least one Class I and one Class II
   locus if the tool claims to support both.
4. **Standardization script.** Written against the common schema, derived by
   diffing native output against an existing `results/standard/` example.
5. **Validation.** `pipeline-integrity-auditor` schema-checks and hand-verifies a
   handful of samples before any full run is authorized.
6. **Dataset confirmation.** `dataset-curator` confirms target accessions
   (`accession/d{N}_list.txt`) still resolve before committing compute.
7. **Full run.** Executed per `commands/run-benchmark.md`'s scope conventions.
8. **Scoring.** `hla-benchmark-scientist` runs the canonical engine; the new tool's
   locus coverage (full 5-locus vs. Class I-only, like OptiType) is determined here,
   not assumed from documentation.
9. **Cross-check + statistics.** `pipeline-integrity-auditor` and
   `statistics-reviewer` independently confirm the numbers before anything moves
   downstream.
10. **Ancestry.** Only re-run if the new tool was scored on Dataset 1 (the only
    dataset with population labels today).
11. **Figures.** `figure-designer` regenerates every figure that enumerates all
    tools (bulk accuracy, no-call/novel panels, CPU/RAM boxplots, read-length lines).
12. **Manuscript.** `scientific-writer` updates tool counts, accuracy ranges, and
    ranking language — flagging any change to the "recommend arcasHLA"-style claim
    for human decision rather than resolving it unilaterally.
13. **Review.** `clinical-and-equity-reviewer` and `devils-advocate` pass
    before the update is considered draft-complete.
14. **Release.** Only on explicit human approval of official inclusion; otherwise the
    tool's evaluation is archived as a candidate report, not merged into headline
    tables.
