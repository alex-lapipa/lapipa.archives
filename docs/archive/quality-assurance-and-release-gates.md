# Quality assurance and release gates

## Principle

Quality is a chain of independently evidenced decisions. A successful upload, database row, embedding, deployment, or checksum is never sufficient by itself.

## Gate A — accession integrity

- transfer authority and accession ID exist;
- source inventory is captured before transformation;
- BagIt declaration and SHA-256 manifest validate;
- file and byte counts reconcile;
- malware and hazardous-content handling is recorded;
- exclusions and duplicates retain decisions and provenance;
- received originals are unchanged.

## Gate B — preservation integrity

- file ID, representation, MIME type, byte count, format, storage path, and SHA-256 exist;
- the stored digest matches the received digest;
- derivative lineage identifies source, target, event, tool, and profile;
- required copies exist in recorded storage locations;
- restore, not merely list or download, has been tested;
- failures remain visible after remediation.

## Gate C — descriptive and evidential integrity

- title, type, date or date text, language, description, collection context, and provenance are present;
- names, places, subjects, roles, and dates follow the application profile;
- uncertain identity or dates remain explicitly uncertain;
- every factual claim or graph relationship has supporting or contradicting evidence;
- automated extraction is labeled until reviewed.

## Gate D — rights, consent, privacy, and ethics

- rights basis, holder, evidence, jurisdiction, conditions, and access decision are recorded;
- participant consent covers the intended use, media, territory, and duration;
- privacy, minors, confidential material, cultural sensitivity, and present-day harm have been reviewed;
- credit line and required statement are approved;
- a takedown and correction route is visible.

## Gate E — audiovisual and accessibility

- image and sound pass technical QC against the named representation;
- duration, frame rate, dimensions, color, sample rate, bit depth, channel layout, and timecode are recorded when applicable;
- captions, transcript, translation, audio description, alt text, keyboard behavior, focus order, contrast, and reduced motion are reviewed according to content needs;
- captions and transcripts are synchronized and identify their review status;
- no accessibility claim exceeds tested evidence.

## Gate F — documentary editorial integrity

- script claims cite sources or claim IDs;
- quoted speech is checked against media and time range;
- images, music, artwork, and archival clips have item and rights IDs;
- disputed evidence and material omissions are reviewed;
- picture lock, credits, subtitles, music cue sheet, fact-check, and rights log share a versioned release ID.

## Gate G — RAG and graph integrity

- access is enforced before retrieval;
- chunks retain item, representation or transcript, source, verification, language, access, and content-hash metadata;
- embeddings match the current content hash and approved Voyage model;
- evaluation covers origin, chronology, people, activities, contradictions, rights, and abstention;
- restricted-content leakage is zero in the acceptance suite;
- answers cite stable evidence and abstain when support is insufficient.

## Gate H — release engineering

- database migrations replay in the Supabase preview branch;
- advisors show no unresolved archive schema warnings;
- repository validation, tests, dependency audit, and build pass;
- protected Vercel preview passes page, health, unauthorized-access, accessibility, and responsive checks;
- release manifest and SHA-256 verify;
- named owner approves the exact preview artifact;
- rollback, withdrawal, and correction paths are known.

## Decision vocabulary

Each gate outcome is `pass`, `pass_with_warnings`, `fail`, or `not_applicable`. Warnings need an owner and remediation date. A later pass supersedes but does not delete a prior failure. Public release requires passes for all applicable gates; `pass_with_warnings` requires an explicit owner exception recorded in the release decision.
