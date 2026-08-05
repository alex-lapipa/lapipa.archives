# Digital preservation policy

## Preservation intent

The archive preserves authenticity, integrity, provenance, usability, and meaningful context for as long as La Pipa accepts stewardship. Preservation masters are managed independently from access derivatives and application caches.

## Storage and copies

The target operating state is at least three complete copies, on at least two storage technologies, with at least one copy in a separate geographic and administrative failure domain. Supabase Storage is an operational repository, not by itself the full preservation strategy. A second controlled preservation copy and an offline or logically isolated copy must be established before claiming NDSA Level 3 storage maturity.

## Fixity

- Compute SHA-256 during acquisition before any transformation.
- Recompute after transfer and ingest; compare against the recorded value.
- Run scheduled fixity checks at least quarterly for preservation masters and annually for lower-risk derivatives.
- Record every check as an event and a check result, including failures and missing objects.
- On failure, quarantine the object, suspend derivative generation, compare independent copies, document recovery, and never replace the failed object without an event trail.

SHA-512 manifests may be added to BagIt packages. MD5 and SHA-1 may be retained only as legacy evidence, never as the sole preservation digest.

## Format policy

Retain the original bitstream even when normalization is required. Prefer well-documented, widely adopted, non-encrypted formats with robust tool support. Format choice is risk-based and reviewed against the Library of Congress Sustainability of Digital Formats factors. A format migration produces a new representation and preservation event; it does not overwrite the source.

## Recommended working targets

These are starting profiles, not universal mandates:

| Content | Preservation or high-quality managed target | Access target |
|---|---|---|
| Still image | TIFF, lossless and embedded-profile aware; retain camera original | JPEG or WebP |
| Scanned text | TIFF masters plus PDF/A where appropriate; OCR as separate UTF-8 text/ALTO when available | PDF and responsive images |
| Video | Retain original; lossless FFV1/MKV or institutionally approved high-quality mezzanine after testing | H.264 or H.265 MP4, with captions |
| Audio | Broadcast WAV or WAV, linear PCM, with embedded or sidecar metadata | AAC or MP3; lossless download when authorized |
| Transcript | UTF-8 plain text plus structured segments; WebVTT for timed access | HTML/WebVTT |
| Tabular data | CSV plus schema/data dictionary; retain source workbook | CSV/JSON |

## Preservation planning

Maintain a format and dependency register. Review format obsolescence, codec support, encryption, external services, storage costs, and representation completeness annually. Record decisions, not only actions.

## Integrity of metadata and code

Policies, schemas, migrations, controlled vocabularies, exports, and fixity manifests are versioned in GitHub. Release exports include content hashes and a machine-readable manifest. Database backups and code version control do not replace object-level preservation copies.

## Preservation maturity evidence

An annual NDSA Levels assessment records the achieved level and evidence for storage, integrity, control, metadata, and content. Aspirational controls are labeled as targets until operating evidence exists.

