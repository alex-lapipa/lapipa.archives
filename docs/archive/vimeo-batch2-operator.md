---
document_id: LP-DOC-ARCH-032
title: Vimeo Batch 2 Preservation Operator
status: in_review
evidence_class: workspace_verified
reviewed_on: 2026-08-08
owner: Alex Lawton / Miramonte, S.L.
---

# Vimeo Batch 2 preservation operator

## Outcome

This release prepares a single-accession operator for the five Vimeo recordings approved in `LP-DOC-ARCH-031`. It does not itself download, upload, embed, publish, or delete media. Production use begins only after the migration and Edge Function have passed review, merged, and been deployed.

## Fixed accession registry

| Order | Accession | Vimeo | Appraised title |
|---:|---|---:|---|
| 1 | `LP-ACC-2026-0006` | `727814369` | Data Clean Rooms: Remotive@LA PIPA with Habu, Infosum, Privacy Cloud, and Crimtan: Spring 2022 |
| 2 | `LP-ACC-2026-0007` | `727847829` | Future of Strategic Design / ReMotive Media |
| 3 | `LP-ACC-2026-0008` | `729180279` | Future of Circular Economies: ReMotive Media |
| 4 | `LP-ACC-2026-0009` | `730068690` | Future Innovation Ecosystems 2022 |
| 5 | `LP-ACC-2026-0010` | `732187995` | Industry-Automation-whats-next? LA PIPA |

Vimeo `726116068` remains held for owner scope review and is absent from every operator allowlist. Vumi remains categorically excluded.

## One-accession workflow

1. The signed-in archive owner selects one reviewed accession in Owner Access.
2. Supabase issues a ten-minute, single-exchange code bound to that exact Vimeo identifier.
3. The Mac launcher requires the same accession selection, a matching code, and the exact confirmation `YES`.
4. The runner requests Vimeo's source-quality download metadata without exposing the Vimeo token.
5. It refuses an unknown ID, mismatched accession, unsafe URL, unsupported media type, invalid byte count, insufficient disk reserve, or a source over the reviewed 5 GB standard-file path before download.
6. It downloads directly to G-DRIVE 02, resumes only from an exact byte range, validates byte count and provider MD5 when supplied, computes SHA-256, and writes a stable capability-free manifest.
7. Local MLX Whisper 0.4.3 uses the pinned offline `whisper-large-v3-turbo` snapshot with automatic language detection. JSON, SRT, TSV, TXT, and VTT outputs remain provisional and restricted pending human review.
8. FFprobe records stream and container metadata. The runner recomputes the fixity inventory for the preservation master, transcript artifacts, and manifests.
9. Supabase returns two-hour, exact-path Backblaze PUT, HEAD, and GET capabilities for only that inventory. Credential values never reach the Mac, browser, GitHub, Notion, manifests, or logs.
10. An absent object is uploaded. An exact remote byte-count and SHA-256 metadata match is reused. A differing existing object stops the accession and is never overwritten.
11. Every object is downloaded into a new clean restore directory, byte-counted, and recomputed with SHA-256. The transfer report is then uploaded and restored under the same controls.
12. The accession result records the verified object set and leaves Supabase catalogue registration, Voyage embedding, retrieval acceptance, and human transcript review as explicit later gates.

## Resumption and failure behavior

- A complete local preservation master is reused only when its provider byte count and local digest checks pass.
- A complete five-file transcript set is validated and reused. A partial set is not overwritten.
- Stable manifests are reused only when identity and fixity match. Conflicting evidence is not rewritten.
- A completed local result is trusted only after every clean-restored file is found beneath the accession restore boundary and re-passes byte-count and SHA-256 verification.
- A code or session that expires during a long transcription stops cloud work safely. A fresh matching code resumes the already verified local stages.
- Each accession is independent. One failure does not invalidate prior verified accessions.

## Storage and size boundary

The normal Backblaze path is limited to a 5,000,000,000-byte single object. The operator also requires space for the preservation master, a clean restored copy, and a 20 GB safety reserve. If Vimeo exposes a source above the standard-file limit, the operator reports the exact size and stops before download. A reviewed multipart path must then be added; the operator never silently substitutes a lower-quality derivative.

## Security and rights boundaries

- The database can issue codes only to a confirmed archive owner and only for the accepted one-video accession or the five reviewed Batch 2 IDs.
- Runner sessions are stored with SHA-256 digests of codes and bearer capabilities, restrictive RLS, short expiry, and audited use counts.
- The new Edge Function deliberately uses custom capability authentication because code exchange and Mac transfer do not carry a Supabase user JWT. Owner code creation still requires the signed-in bearer session.
- No source deletion, remote deletion, public release, verified quotation, or automatic rights conclusion is authorized.
- Alex Lawton and Miramonte, S.L. ownership remains owner-supplied evidence, not an independent legal opinion about every participant or recording.

## Operator file

After the reviewed release is deployed, use `Run La Pipa Vimeo Batch 2.command` from the repository folder. Select the same numbered accession in Owner Access and in the launcher. Do not paste the launcher source into Terminal.

## Acceptance requirements

- Node static checks, repository validation, archive tests, Edge tests and type checks, production build, and dependency audit pass.
- Migration replay preserves the existing `LP-ACC-2026-0005` acceptance route and adds only the five appraised Batch 2 video IDs.
- The front end exposes only the fixed registry and does not expose credentials.
- The first production use is accession `LP-ACC-2026-0006`; its provider-reported source size is the next live evidence gate.
