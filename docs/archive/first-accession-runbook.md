# First accession runbook — LP-DOC-ARCH-017

Status: approved procedure; source selection pending
Pilot accession: `LP-ACC-2026-0001`
Target material: 2019 La Pipa origin deck and immediate contextual records

## Non-negotiable rule

Inventory is read-only. Do not rename, normalize, reorganize, transcode, deduplicate, or modify source material before the received-state inventory and SHA-256 manifest exist. The source directory and package destination must be different locations.

## Batch A — authority and scope

1. Alex Lawton identifies the exact source directory and confirms that it may be inventoried.
2. Record source custodian, transfer basis, known restrictions, expected extent, and whether hidden or system files belong to the transfer.
3. Freeze the accession scope. Later discoveries receive a new package or documented package version.
4. Create the accession only after source custody and scope are explicit; `receipt_confirmed` remains false until reconciliation passes.

## Batch B — received-state evidence

1. Run `npm run archive:inventory -- <source-file-or-directory> <outside-source>/inventory.json`.
2. Record tool version, start/end time, filesystem, operator, file count, byte count, unreadable files, symlinks, and errors.
3. Preserve the JSON inventory and its SHA-256 digest.
4. Investigate unreadable, unstable, encrypted, password-protected, or suspicious objects without altering originals.

## Batch C — transfer package

1. Run `npm run archive:create-bag -- <source-file-or-directory> <new-bag-directory>`.
2. Validate independently with `npm run archive:validate-bag -- <bag-directory>`.
3. Quarantine the package on any payload, tag-manifest, path-safety, count, byte, or checksum failure.
4. Record the package ID, manifest digest, payload count, payload bytes, validator result, and operator.

## Batch D — appraisal and reconciliation

Every offered file receives exactly one outcome: accepted, duplicate, excluded, quarantined, or failed. Counts and bytes must reconcile to the received-state inventory with zero unexplained difference. Exclusion and duplicate decisions retain evidence and never delete the received-state record.

## Batch E — archival records

Create or reconcile the accession, transfer package, archival item, original representation, file objects, custody event, preservation event, fixity check, rights review, consent evidence where applicable, and source links. Stable IDs precede embeddings and public URLs.

## Batch F — characterization and derivatives

Identify formats and technical properties with recorded tool versions. Preserve originals. Derivatives require explicit source relationships, purpose, parameters, software, date, operator, and validation. Machine-generated text remains labeled as machine generated until human review.

## Batch G — RAG eligibility

Only approved descriptive or extracted text enters the retrieval corpus. Each chunk must retain source IDs, document version, content hash, access scope, verification status, locator, embedding model, dimensions, and supersession state. Restricted payload text is excluded by default.

## Exit criteria

- Source and package manifests validate.
- Offered and disposition counts and bytes reconcile exactly.
- Every accepted file has provenance, SHA-256, format evidence, rights state, and a managed-copy record.
- The package can be restored into a clean destination and revalidated.
- Review tasks contain no unresolved blocking failure.
- Alex Lawton approves completion as archive owner.
