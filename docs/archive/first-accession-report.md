# First accession report — LP-DOC-ARCH-019

Accession: `LP-ACC-2026-0001`
Submission package: `LP-BAG-2026-0001`
Source record: `LP-SRC-001`
Owner: Alex Lawton
Date: 2026-08-05
Status: valid submission package; malware pass and format validation complete with warnings; managed preservation ingest pending

## Object

The package contains the earliest strongly documented La Pipa origin presentation:

`LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf`

The source record identifies a 36-page, image-based presentation created on 10 June 2019 and modified on 11 March 2020. Historical statements inside the presentation remain project claims rather than current audited facts.

## Received-state evidence

| Measure | Value |
| --- | --- |
| Files | 1 |
| Bytes | 194,031,448 |
| Source modified time | 2020-03-11T02:12:53.000Z |
| Payload SHA-256 | `c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e` |
| Inventory JSON SHA-256 | `6284c2325f2bf864b853919839b3173686311fd5e3bbd0352d71c100539e245b` |
| Payload-Oxum | `194031448.1` |
| Manifest file SHA-256 | `ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf` |

The source was inventoried directly at its original owner-controlled Dropbox path. The tooling read and hashed the source, created a separate package, preserved timestamps during copying, and verified the copied bytes. It did not rename, rewrite, transcode, or reorganize the source.

## Package validation

BagIt version 1.0, UTF-8 tag files, SHA-256 payload manifest, tag manifest, path-safety checks, completeness checks, and Payload-Oxum validation passed. Result: **valid**, with zero failures.

Automated tests also prove that the validator detects changed payload bytes and changed tag metadata. Single-file accession is covered without requiring an artificial staging directory.

## Technical characterization

Read-only inspection identifies a 36-page, unencrypted PDF created from PowerPoint on 10 June 2019 and modified on 11 March 2020. It contains no embedded JavaScript. It is not tagged for accessibility and is not optimized.

On 7 August 2026, ClamAV 1.5.3 scanned the complete payload using official, digitally verified databases current on the scan date and found zero infected files. qpdf 12.3.2 completed its check with five recoverable object-offset warnings and no fatal structural error. qpdf and `file` report PDF 1.3, while ExifTool 13.55 and Poppler `pdfinfo` 26.05.0 report PDF 1.4 metadata. The original remains unchanged; the discrepancy and warnings are retained as preservation evidence. See [LP-DOC-ARCH-023](pilot-malware-and-format-validation-2026-08-07.md).

Characterization evidence SHA-256: `2c3a4d28cb4fcae9739c199a5b417164f2b19be6517ef0d6c499938cd7c9e588`.

## Database evidence

The database records the accession, source and repository agents, transfer package, payload disposition, custody event, package validation, malware result, format validation, owner audit event, and outstanding work. The payload is accepted into the valid submission package but is not yet represented as a managed `archive.file_objects` object because it has not been uploaded to verified archive storage.

## Restrictions and remaining gates

The object remains restricted. The following must precede file-object registration or release:

1. Upload to a private managed archive bucket without exposing a service credential. The standard CLI upload was attempted and returned HTTP 413 for the 194 MB payload; three partial tag objects were removed and the remote prefix was verified empty. Use TUS resumable upload or S3 multipart upload next.
2. Recalculate SHA-256 after upload and reconcile it to the received-state digest.
3. Register the original representation, file object, operational copy, and fixity event.
4. Complete copyright, privacy, sensitivity, and publication review.
5. Create an independent preservation copy and perform a clean restore test.
6. Approve only eligible descriptive text for Voyage ingestion; keep payload access restricted by default.

This report does not claim a complete preservation accession, independent redundancy, cleared rights, or public-release readiness.
