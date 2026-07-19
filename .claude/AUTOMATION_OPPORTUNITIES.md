# Automation Opportunities — Ranked by Impact

*Owner: `scientific-coordinator` — deciding when a proposed automation is worth
building is a roadmap-prioritization call, not an orphaned wishlist.*

Everything in this system that could eventually run with zero human-in-the-loop
judgment, ranked by (impact of automating) × (safety of automating). Items lower
on this list either have lower payoff or touch decisions this system's agent files
deliberately keep human-gated (see each agent's "Forbidden Decisions") — automating
those would mean removing a safeguard, not adding a capability.

## Tier 1 — High Impact, Safe to Fully Automate Now

1. **Cross-implementation diffing** (`pipeline-integrity-auditor`'s core job).
   Comparing Python vs. Julia scoring output is purely mechanical — this should be
   a scheduled/triggered job with zero agent reasoning required, firing on every
   change to either implementation.
2. **Schema validation of `results/standard/*.csv`** — deterministic, rule-based,
   already scripted in `hooks/post-edit-check.sh` (Check A). Extending this from a
   warn-only hook to a full scheduled sweep (nightly, or on every file change) is
   pure upside.
3. **Repo hygiene enforcement** (`.gitignore`, tracked `.DS_Store`/cache files,
   stale `.bak` detection) — zero judgment required, already partially covered by
   `hooks/pre-git-action-check.sh` (commit branch).
4. **`results_summary.md` freshness checking** relative to `results/standard/`
   file mtimes — already implemented as a commit-blocking hook; could be extended
   to a standing CI-style check independent of any commit action.
5. **Unfinished-marker grep** (`** include`, `TODO`, `TBD`, etc.) — already
   implemented in `hooks/post-edit-check.sh` (Check B); trivially extensible to a
   full pre-submission sweep.

## Tier 2 — High Impact, Needs External Tooling But Low Risk to Automate

6. **New-tool-release literature/GitHub watch.** Now `literature-surveillance`'s
   standing job rather than a manual trigger. A scheduled poll (GitHub search API,
   bioRxiv API, PubMed) that files a candidate note to `scientific-coordinator`
   automatically is safe to fully automate — it only *proposes*, never adds.
7. **Accession-liveness checking** (`dataset-curator`). A scheduled job hitting
   SRA/ENA for every accession in `accession/*.txt` and flagging dead links is
   safe, mechanical, and currently unautomated.
8. **Environment file installability testing.** A CI job that actually attempts
   `conda env create` for every `.yml` in `scripts/environmental_files/` on a
   schedule would catch environment rot before it's discovered mid-experiment.
9. **Figure regeneration on data change.** Once `figure-designer`'s consolidation
   pass establishes one canonical output location and a clean regeneration script
   per figure, regeneration itself (not the design judgment) is a mechanical CI job.
10. **Reproducibility clean-checkout test** (`/reproduce-results`). Currently
    agent-invoked; this is a strong candidate for a scheduled CI job that runs
    against a genuinely fresh environment (not just a fresh working tree) on every
    merge to the main branch.

## Tier 3 — Partial Automation, Human Judgment Still Required on the Output

11. **Statistical re-derivation** (`statistics-reviewer`). The re-computation
    itself is automatable; the judgment of "is this adequately powered / correctly
    scoped" is not, and should remain an explicit review step even once the
    computation is instant.
12. **Adversarial review** (`devils-advocate`). Generating a first-pass
    critique is automatable and cheap to run on every draft-complete section; a
    human should still triage which critiques are worth acting on.
13. **Manuscript number-sourcing checks** (`scientific-writer`). Grepping for
    numbers and checking they match a source table is automatable; deciding how to
    rephrase a sentence around a corrected number is not.

## Never Fully Automate (by design, not by current limitation)

- Any `git push`/`git tag`/public data deposition action.
- Ranking/recommendation language in the manuscript.
- Ancestry-disparity claim wording.
- Official tool/dataset inclusion decisions.
- Scoring-contract changes (novel-allele definition, ambiguous-match convention).

These stay human-gated regardless of how mature the surrounding automation gets —
see the "Forbidden Decisions" section of every relevant agent file. The point of
automating Tiers 1-3 is to make the human's decision *faster and better-informed*,
not to remove the human from decisions that carry scientific or reputational
consequence.
