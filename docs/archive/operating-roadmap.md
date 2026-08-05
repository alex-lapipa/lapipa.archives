# Operating roadmap — from foundation to trusted archive

Version: 1.0
Status: approved implementation sequence
Date: 2026-08-05

## Outcome

La Pipa should become an archive that can demonstrate—not merely assert—that it knows what it holds, where every managed copy is, whether the bytes remain intact, why material may be accessed, which evidence supports each public statement, and how to recover from failure.

## Phase 0 — accountable control

**Current state:** Alex Lawton's confirmed Auth UUID is assigned the active `owner` role. Database authorization tests are implemented. Interactive sign-in, recovery and session tests, a second trusted administrator, and leaked-password protection remain pending.

**Exit criteria:** the intended human owner authenticates; their exact `auth.users.id` is assigned the `owner` role; a second trusted administrator is documented; short-lived session and incident procedures are tested; leaked-password protection is enabled if the Supabase plan supports it.

No public release, irreversible disposal, rights approval, or production promotion precedes this gate.

## Phase 1 — pilot accession

Accession the 2019 origin deck and its immediate contextual records as the first controlled package.

1. Create accession `LP-ACC-2026-0001` and record transfer authority.
2. Inventory without changing source files.
3. Create and validate a BagIt 1.0 submission package using SHA-256.
4. Capture original filenames, bytes, digests, timestamps, and format characterization.
5. Create the archival item, original representation, file objects, package records, custody events, and rights-review tasks.
6. Reconcile offered, accepted, duplicate, excluded, quarantined, and failed counts and bytes.
7. Embed only approved descriptive text; do not embed rights-restricted payloads by default.

**Exit criteria:** package validation passes, all accepted files have provenance and fixity, rights state is explicit, and the accession report reconciles to zero unexplained differences.

## Phase 2 — audiovisual and oral-history pilot

Select one representative video, one audio recording, and one interview. Preserve received originals, extract technical metadata, establish preservation/mezzanine/access profiles through listening and visual QC, and create reviewed time-aligned transcripts. Capture participant consent as structured evidence rather than a note.

**Exit criteria:** original-to-derivative lineage is complete; timecodes name the representation; accessibility assets exist; machine transcription remains distinguishable from human review; every release candidate passes technical, rights, consent, privacy, citation, and editorial checks.

## Phase 3 — independent preservation copies

Configure at least two additional preservation locations outside the Supabase operational failure domain: one geographically and administratively independent online or cold replica, and one offline or logically isolated copy. Use a provider selected through a documented durability, lock, egress, jurisdiction, recovery, and cost assessment.

**Exit criteria:** three verified copies exist; at least two technologies or service domains are represented; one copy is isolated; sample restore and fixity checks pass; copy evidence is recorded in `archive.file_copies` and `archive.storage_locations`.

## Phase 4 — controlled research access

Deliver item-level catalog pages and mediated access for approved readers. Authentication and archive membership precede retrieval. Signed URLs are short lived. The answer layer filters access before retrieval, provides stable citations, and distinguishes verified fact, attributed recollection, inference, contradiction, and unresolved uncertainty.

**Exit criteria:** owner, editor, reviewer, reader, and unauthorized-user acceptance tests pass; takedown and correction exercises pass; access logs avoid sensitive payload content; RAG evaluation meets the approved citation and retrieval thresholds.

## Phase 5 — public documentary archive

Publish only approved items and representations through a release record. Use IIIF Presentation 3.0 where it materially improves compound image, audio, video, or transcript access. Provide captions, transcripts, alt text, credit lines, rights statements, citations, correction routes, and durable identifiers.

**Exit criteria:** a named owner approves the release; every included item has rights and access evidence; accessibility review passes; the release manifest and files verify; production promotion uses the exact tested preview artifact; rollback and withdrawal have been rehearsed.

## Phase 6 — sustained stewardship

- Quarterly: preservation-master fixity sample, restore sample, open takedown and remediation review.
- Semi-annually: access-role review, dependency review, format-risk review, retrieval evaluation.
- Annually: full NDSA Levels 2.1 assessment, disaster-recovery exercise, policy review, designated-community review, and preservation-cost forecast.
- On every release: manifest, checksums, schema versions, corpus evaluation, rights audit, accessibility audit, and immutable release note.

## Programme measures

Measure evidence, not vanity totals:

- percentage of accessioned files with verified SHA-256, characterized format, provenance, rights state, and two independent preservation copies;
- overdue fixity checks and failed restorations;
- unresolved ingest reconciliation differences;
- transcript segments reviewed by a human;
- release items with complete rights, consent, accessibility, and citation gates;
- retrieval citation precision, source recall, unsupported-answer rate, and restricted-content leakage rate;
- median takedown acknowledgement and decision time;
- policy, risk, dependency, and format reviews completed by due date.

## Explicit approval gates

The following require the archive owner: adding the first owner or changing roles; purchasing or configuring external preservation storage; importing the 2.3 TB source archive; publishing identifiable people or restricted material; promoting Vercel production; selecting legal rights statements; changing retention or disposal policy; and approving a public documentary release.
