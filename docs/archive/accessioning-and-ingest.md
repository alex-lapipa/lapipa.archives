# Accessioning and ingest runbook

## Before transfer

1. Confirm the offeror, authority to transfer, physical and intellectual-property status, privacy and consent conditions, expected extent, file formats, encryption, and known hazards.
2. Assign an accession ID and create an accession record before copying content into managed storage.
3. Request a file inventory and existing checksums. Prefer a BagIt 1.0 package with UTF-8 tags and SHA-256 or SHA-512 manifests.
4. Prepare a quarantined landing area that is not the preservation-master bucket.

## Capture and quarantine

1. Preserve the received directory structure and filenames in the accession manifest.
2. Capture file system timestamps and transfer metadata without treating them as authoritative creation dates.
3. Compute SHA-256, count bytes and files, and reconcile the transfer manifest.
4. Run malware scanning and record the tool, version, signatures, timestamp, and result.
5. Do not open untrusted active content on a production workstation.

## Characterization and appraisal

1. Identify formats and extract technical metadata with versioned tools.
2. Preserve raw characterization output as a derivative or metadata export.
3. Detect exact duplicates by digest, but review provenance before deduplicating storage.
4. Identify encrypted, damaged, empty, unsupported, or password-protected objects.
5. Confirm the appraisal decision and document exclusions.

## Ingest

1. Create or link collection, item, agent, subject, rights, and accession records.
2. Create an `original` representation and file record for every accepted bitstream.
3. Store accepted originals under `la-pipa/<collection-id>/<item-id>/<representation-id>/` in `source-originals` or `preservation-masters`.
4. Verify the stored object against the pre-transfer SHA-256.
5. Create the capture, virus-check, metadata-extraction, ingest, and fixity events.
6. Generate preservation masters or derivatives only after original ingest succeeds.
7. Place access media in `access-media` and text/renders in `source-derivatives`.
8. Mark the accession complete only when counts, bytes, fixity, metadata, rights, and storage locations reconcile.

## Quality gates

An ingest cannot pass when a managed file lacks a digest, byte count, stable ID, representation, storage path, malware status, or provenance. An item cannot be published when rights or sensitivity review is unresolved. A transcript cannot be called verbatim and approved unless a human has reviewed it against the media.

## RAG handoff

Approved descriptive text, OCR, and transcripts are normalized, content-hashed, segmented on semantic and time boundaries, linked to archival identifiers and sources, embedded with `voyage-context-4`, and evaluated before activation. Re-ingestion first compares content hashes to avoid unnecessary paid processing.

## Reconciliation report

Every batch records offered, received, accepted, excluded, duplicate, failed, quarantined, and ingested file and byte counts. Totals must reconcile or the job is `partially_succeeded` or `failed`; discrepancies are never hidden in a success note.

