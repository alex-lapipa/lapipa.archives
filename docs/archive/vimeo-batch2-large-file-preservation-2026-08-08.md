---
document_id: LP-DOC-ARCH-033
title: Vimeo Batch 2 Large-File Preservation Path
status: final
evidence_class: live_connector_verified
reviewed_on: 2026-08-08
owner: Alex Lawton / Miramonte, S.L.
---

# Vimeo Batch 2 large-file preservation path

## Decision and live evidence

The first production appraisal of `LP-ACC-2026-0006`, Vimeo `727814369`, succeeded through owner authorization and Vimeo source inspection. Vimeo reported a 9,591,214,398-byte source master. The existing 5,000,000,000-byte single-PUT boundary stopped the run before any download or Backblaze write. No Vimeo source, local master, remote object, transcript, catalogue record, embedding, or publication was created, changed, or deleted by that attempt.

The approved implementation keeps the established path for smaller objects and adds S3 multipart transfer only for a reviewed preservation master above 5,000,000,000 bytes and no larger than 25 GB.

## Transfer profile

| Control | Reviewed value |
|---|---|
| S3 part size | 536,870,912 bytes (512 MiB) |
| `LP-ACC-2026-0006` part count | 18 |
| Final part size for the observed source | 464,408,894 bytes |
| Signed multipart capability life | 12 hours, issued only after initiation |
| Upload concurrency | Sequential |
| Per-part retries | Maximum three |
| Existing-object behavior | Reuse only exact byte-count and SHA-256 metadata match; otherwise stop |
| Completion evidence | Remote HEAD, full clean restore, byte count, and locally recomputed SHA-256 |
| Source deletion | Not authorized |
| Public release | Not authorized |

Backblaze credentials remain only in Supabase Edge Function secrets. Supabase signs the exact accession path, multipart upload identifier, action, and part number. The Mac receives only expiring requests for that object; it never receives the Backblaze application key.

## Resumability and failure handling

The runner writes a mode-restricted `multipart-upload-state.json` beside the accession manifests. It contains the stable accession and Vimeo identifiers, exact object path, byte count, SHA-256, upload identifier, and creation time. It does not retain credentials or signed URLs.

On retry, a fresh owner code revalidates the accession and fixity inventory. The runner lists Backblaze's accepted parts, rejects any part whose number or size differs from the deterministic plan, and uploads only missing parts. A completed and exact remote object is reused. A different existing object is never overwritten. The state file is removed only after successful completion and a clean restore has re-passed SHA-256.

Handled transfer interruption deliberately leaves the incomplete multipart state available for a controlled retry. It does not delete the local master. Multipart abort authority is restricted to the in-progress upload identifier; it cannot delete a completed archive object.

Before bulk operation, Backblaze should also carry an `AbortIncompleteMultipartUpload` lifecycle rule with a seven-day threshold. That is a cost-control safety net for the narrow case in which the Mac stops after Backblaze accepts parts but before the runner can complete or resume them; it does not affect completed objects.

## Daily-cap interruption recovery

The first multipart run completed the 9,591,214,398-byte Backblaze object and a full clean restore with matching local SHA-256. A later read request was rejected with Backblaze `AccessDenied` because the account's download-bandwidth or Class B daily cap had been reached. This response is a cost-control state, not evidence that the object is absent or different. The runner must stop; it must never reinterpret this `403` as `404`, upload another version, or bypass the remote-object check.

After the Backblaze daily counter resets, or after the owner explicitly changes the cap, a fresh owner capability resumes the accession. For a completed multipart object, the runner first requires a matching remote HEAD. It then discovers only regular, non-symlink files under the accession's restore-verification boundary, canonicalizes the real path, confirms the exact byte count, and recomputes SHA-256. A matching prior clean restore is reused without another 9.59 GB download. A missing or mismatched local restore retains the full clean-download path. No source or remote deletion is introduced.

Backblaze documents that cap counters reset daily at 00:00 GMT and that cap changes may take up to ten minutes. See [Data Caps and Alerts](https://www.backblaze.com/docs/en/cloud-storage-data-caps-and-alerts) and [Create and Manage Caps and Alerts](https://www.backblaze.com/docs/cloud-storage-create-and-manage-caps-and-alerts).

## Acceptance gates

Before production deployment:

1. Node syntax, archive tests, Edge tests and type checks, repository validation, production build, and dependency audit must pass.
2. Migration replay must add only the audited `backblaze_multipart_bundle` session action while retaining the existing five-use session ceiling and fixed Vimeo allowlist.
3. The 44 Node tests and 18 Edge/security tests must pass, proving deterministic 18-part planning for the observed source, resumption from an accepted part, verified clean-restore reuse, exact restore SHA-256, held-item exclusion, path confinement, and the 25 GB ceiling.
4. Every pull request must be ready for review, not draft, and must merge before its corresponding production release.

The live run remains one accession only. Final success requires a complete local master, provisional transcript artifacts, exact Backblaze object set, clean-restore evidence, and matching SHA-256 evidence for every object. Supabase catalogue registration, Voyage embedding, retrieval acceptance, human transcript review, and any public release remain later controlled stages.

## Standards note

This is a preservation workflow control, not a claim of repository certification. The part transfer provides operational resumability; the authoritative integrity result remains the cryptographic digest of the complete restored object.

## Authoritative references

- [Backblaze S3-Compatible API](https://www.backblaze.com/docs/cloud-storage-s3-compatible-api)
- [Create Multipart Upload](https://www.backblaze.com/apidocs/s3-create-multipart-upload)
- [Upload Part](https://www.backblaze.com/apidocs/s3-upload-part)
- [List Parts](https://www.backblaze.com/apidocs/s3-list-parts)
- [Complete Multipart Upload](https://www.backblaze.com/apidocs/s3-complete-multipart-upload)
- [Abort Multipart Upload](https://www.backblaze.com/apidocs/s3-abort-multipart-upload)
