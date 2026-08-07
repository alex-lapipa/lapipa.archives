---
document_id: LP-DOC-ARCH-024
title: Backblaze preservation ingest and restore evidence
document_type: preservation_evidence_report
status: final
evidence_classes:
  - workspace_verified
  - live_connector_verified
created_at: 2026-08-07
last_reviewed_at: 2026-08-07
next_fixity_due_at: 2026-11-05T16:30:52Z
accession_id: LP-ACC-2026-0001
package_id: LP-BAG-2026-0001
item_id: LP-ITEM-2026-0001
storage_location_id: LP-LOC-B2-EUC3-001
access_scope: restricted
rights_holders:
  - Alex Lawton
  - Miramonte, S.L.
rag_topics:
  - La Pipa Documentary Archive
  - Backblaze B2
  - BagIt
  - digital preservation
  - fixity
  - restore testing
  - PREMIS events
---

# Backblaze preservation ingest and restore evidence — LP-DOC-ARCH-024

Official Notion record: [LP-DOC-ARCH-024](https://app.notion.com/p/3b5425866bb58100a4fcec83e5f49e67?pvs=204)

## Outcome

On 7 August 2026, the La Pipa Documentary Archive completed the first end-to-end preservation ingest for `LP-BAG-2026-0001`. Five BagIt objects totaling 194,032,057 bytes were copied directly from the owner-controlled Mac to the private Backblaze B2 bucket `miramonte-lapipa-preservation-pilot` under:

`preservation/LP-ACC-2026-0001/LP-BAG-2026-0001`

Backblaze reported AES-256 server-side encryption and a distinct version identifier for every object. Local source SHA-256, remote archival checksum metadata, restored-object SHA-256, byte counts, and the restored BagIt manifests all agreed. The received PDF was not modified.

The transfer began at `2026-08-07T16:30:18Z` and completed at `2026-08-07T16:30:52Z`. Upload time totaled 14 seconds and restore downloads totaled 15 seconds.

## Controlled records

| Record layer | Stable records |
| --- | --- |
| Accession | `LP-ACC-2026-0001` |
| Submission package | `LP-BAG-2026-0001` |
| Archival item | `LP-ITEM-2026-0001` |
| Representations | `LP-REP-2026-0001`, `LP-REP-2026-0002` |
| File objects | `LP-FILE-2026-0001` through `LP-FILE-2026-0005` |
| Storage location | `LP-LOC-B2-EUC3-001` |
| Preservation copies | `LP-COPY-B2-2026-0001` through `LP-COPY-B2-2026-0005` |
| Fixity checks | `LP-FIXITY-2026-0001` through `LP-FIXITY-2026-0005` |
| Preservation events | `LP-PRESEVENT-2026-0006` through `LP-PRESEVENT-2026-0009` |

`LP-REP-2026-0001` represents the original received PDF. `LP-REP-2026-0002` represents the BagIt package-control metadata. The item remains restricted and at review lifecycle status; preservation success does not grant public access.

## Object evidence

| File ID | Relative path | Bytes | SHA-256 | ETag | Backblaze version ID |
| --- | --- | ---: | --- | --- | --- |
| `LP-FILE-2026-0002` | `bag-info.txt` | 189 | `4c224fa076bb5fbfaaa5889d9d5e80a382ce670f9379b4fd8271981e96a18ad3` | `"ab3bd23ef5cc90154cb703b851e5f984"` | `4_zd6822b1cb3b9caff90f40c13_f108ab1040fc3df28_d20260807_m163018_c003_v0312039_t0029_u01786120218804` |
| `LP-FILE-2026-0003` | `bagit.txt` | 54 | `1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9` | `"eaa2c609ff6371712f623f5531945b44"` | `4_zd6822b1cb3b9caff90f40c13_f1139981bf7a82617_d20260807_m163019_c003_v0312027_t0000_u01786120219645` |
| `LP-FILE-2026-0001` | `data/LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf` | 194,031,448 | `c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e` | `"25474bcc1555a5a0af82df717ca691cc"` | `4_zd6822b1cb3b9caff90f40c13_f11206326a93b616a_d20260807_m163021_c003_v0312010_t0002_u01786120221442` |
| `LP-FILE-2026-0004` | `manifest-sha256.txt` | 125 | `ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf` | `"3752a83d58ef715b5ef6dfa16cc4e65b"` | `4_zd6822b1cb3b9caff90f40c13_f109567b3a82d75a3_d20260807_m163048_c003_v0312019_t0001_u01786120248667` |
| `LP-FILE-2026-0005` | `tagmanifest-sha256.txt` | 241 | `4f7d305e432109062e4208cc67559a1d16e02666b8664658981f2d653c1e50f3` | `"c2a7a944eb68035d3ac3ba89db025a7b"` | `4_zd6822b1cb3b9caff90f40c13_f10512a812a234949_d20260807_m163049_c003_v0312041_t0003_u01786120249704` |

Every copy record has `replica_state = verified`, identical expected and observed SHA-256 values, an exact Backblaze version ID, and `restore_verified = true`.

## Validation chain

1. The archive re-read each local package object and compared its byte count and SHA-256 with the controlled manifest.
2. A disposable, package-scoped Supabase Edge Function issued 20-minute AWS SigV4 PUT, HEAD, and GET URLs for the exact bucket, prefix, object names, sizes, content types, and archival SHA-256 metadata.
3. Each object was uploaded directly from the owner-controlled Mac to Backblaze. The PDF did not pass through the Edge Function runtime.
4. Backblaze object headers were read and reconciled to the expected byte count and SHA-256 metadata.
5. Every object was downloaded into a new temporary restore tree.
6. Restored byte counts and SHA-256 digests were recalculated and matched for five of five objects.
7. The restored BagIt package validated with one payload file, three counted tag files, and zero failures.
8. qpdf 12.3.2 rechecked the restored PDF. Exit status 3 reproduced only the five already documented recoverable offset warnings for objects 48, 50, 184, 221, and 236.

## Preservation events

| Event ID | Type | Outcome | Evidence |
| --- | --- | --- | --- |
| `LP-PRESEVENT-2026-0006` | replication | success | Five objects copied; AES-256 encryption and exact version IDs observed |
| `LP-PRESEVENT-2026-0007` | fixity check | success | Source, remote metadata, restored objects, and BagIt manifests agreed |
| `LP-PRESEVENT-2026-0008` | restore | success | Clean-directory full restore and qpdf check completed |
| `LP-PRESEVENT-2026-0009` | ingest | success | One item, two representations, five file objects, and five copies registered |

## Credential and cleanup evidence

- Permanent Backblaze credentials remained in Supabase Edge Function secrets.
- No credential value was written to GitHub, Notion, the database ledger, RAG text, or task output.
- The disposable transfer function was restricted to the exact pilot package and required a fixed intent string.
- The disposable function was deleted immediately after transfer and confirmed absent.
- Time-limited signed URLs and the temporary local restore tree were deleted after validation.
- The permanent `b2-preservation-status` function remains deployed with Supabase JWT verification and archive owner/editor authorization.

The disposable transfer function is not recoverable, by design. An equivalent restricted bridge can be regenerated for a later controlled batch.

## Preservation decision

`LP-BAG-2026-0001` now has status `ingested`. Backblaze B2 location `LP-LOC-B2-EUC3-001` counts as the first tested independent online preservation location for this pilot scope. The initial assessment is updated from no operating evidence to partial operating evidence.

The next verification is due at `2026-11-05T16:30:52Z`.

## Remaining controls

1. Decide and approve Backblaze Object Lock and retention policy. Object Lock is currently disabled.
2. Replace the broad setup credential with separate least-privilege replication, verification, and deletion identities before routine unattended automation.
3. Establish an offline or logically isolated third copy.
4. Complete sensitivity, privacy, consent, accessibility, citation, and owner-approved publication review.
5. Designate and test a backup administrator.

## Evidence boundaries

- `workspace_verified`: local source hashes, BagIt validation, restored-object hashes, and restored PDF validation.
- `live_connector_verified`: Supabase ledger state, Edge Function inventory, Backblaze S3 object responses, server-side encryption headers, version IDs, and ETags.
- `user_supplied`: Alex Lawton and Miramonte, S.L. rights ownership declaration and the deliberate temporary decision to retain broad setup capability.

No claim is made that Object Lock is enabled, that the setup key is least-privilege, that three independent copies exist, that public release is approved, or that the repository is certified.

## Canonical implementation

- Supabase migration: `20260807163819_record_backblaze_pilot_ingest_and_restore.sql`
- RAG registration migration: `20260807165019_register_backblaze_pilot_rag_document.sql`
- RAG finalization migration: `20260807165205_finalize_backblaze_pilot_rag_embedding.sql`
- Knowledge source: `LP-SRC-039`
- RAG document: `lp-backblaze-pilot-ingest-restore-2026-08-07-v1`
- RAG chunks: `LP-RAG-021` through `LP-RAG-024`
- Voyage job: `LP-EMBED-PRESERVATION-2026-08-07`, succeeded with four current embeddings and zero pending
- Official Notion evidence: [LP-DOC-ARCH-024](https://app.notion.com/p/3b5425866bb58100a4fcec83e5f49e67?pvs=204)
- Prior configuration evidence: [LP-DOC-ARCH-022](backblaze-preservation-verification-2026-08-07.md)
- Prior malware and format evidence: [LP-DOC-ARCH-023](pilot-malware-and-format-validation-2026-08-07.md)
- First accession report: [LP-DOC-ARCH-019](first-accession-report.md)

## Technical references

- [Backblaze S3-Compatible API](https://www.backblaze.com/docs/cloud-storage-s3-compatible-api)
- [Backblaze application keys for the S3-Compatible API](https://www.backblaze.com/docs/cloud-storage-s3-compatible-app-keys)
- [Supabase Edge Function secrets](https://supabase.com/docs/guides/functions/secrets)
