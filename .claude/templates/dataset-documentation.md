# Dataset Documentation Template

One of these per dataset (`D1`-`D8` today; use for any future addition). Owned by
`dataset-curator`.

---

**Dataset ID:** `D<N>`
**Short name:**
**Source study / citation:**
**Accession list:** `accession/d<N>_list.txt`
**Gold standard file:** `datasets/<N>_gs.csv`

## Sample Composition
- Sample count:
- Tissue source:
- Sequencing platform / read length:
- Population/ancestry metadata available? If yes, where
  (e.g., `datasets/archive/SraRunTableD1.txt`):

## Gold Standard Provenance
- Typing method (PCR-SSP / PCR-SSOP / SBT-equivalent / long-read / trio-derived):
- Resolution achieved (1-field / 2-field / higher):
- Known limitations of this typing method (false positive/negative rate, phase
  ambiguity):
- **Scoring consequence**: state plainly how this dataset's gold-standard quality
  affects how its accuracy numbers should be interpreted relative to other
  datasets (per `agents/dataset-curator.md`'s operating instructions — a
  provenance note without its scoring consequence is incomplete).

## Inclusion Status
- [ ] Included in main analysis (D1-D6 currently)
- [ ] Excluded from main analysis — reason:
- [ ] Used for a specific sub-analysis only (e.g., ancestry, read-length) — which:

## Known Issues
<!-- e.g., "8_gs.csv has empty rows for sample_1-sample_10 as of the last audit -
     status unresolved, see memory/KNOWN_BUGS.md" -->

## Data Availability
- [ ] Public (SRA/ENA accession, resolves as of last check on `<date>`)
- [ ] In-house, not yet deposited — tracked in `BACKLOG.md` item D3
- [ ] In-house, deposited — accession:
