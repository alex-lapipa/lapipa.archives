# Vimeo preservation pilot — 8 August 2026

## Outcome

The La Pipa Vimeo integration is authenticated and the first controlled
preservation/transcription batch is complete. The pilot establishes a
repeatable flow:

1. Reconcile only Vimeo IDs already evidenced by a La Pipa source.
2. Select the preservation original and, where useful, a smaller transcription
   mezzanine.
3. Download to checksum-controlled staging.
4. Upload through short-lived, accession-restricted Backblaze URLs.
5. Verify remote object size and register expected SHA-256.
6. Preserve provider captions separately from machine transcripts.
7. Transcribe locally, reject hallucination-prone outputs, and retain selected
   passes as provisional.
8. Generate time-coded RAG chunks and contextual Voyage embeddings.
9. Test retrieval while preserving verification and provenance labels.
10. Remove all temporary audit, signing, and embedding functions.

## Reconciled Vimeo inventory

| Measure | Result |
|---|---:|
| Vimeo account videos | 749 |
| Videos referenced by lapipa.io | 78 |
| Referenced videos found in the owner account | 78 |
| Referenced videos downloadable | 78 |
| Referenced videos with source originals | 70 |
| Referenced videos with Vimeo text tracks | 53 |
| Referenced-video runtime | 268,911 seconds (74 h 41 m 51 s) |
| Largest/source variants for the 78-video scope | 268,274,503,954 bytes |

The 749-video account inventory is not an archive scope. It contains unrelated
material and must never be bulk-ingested without an evidence-based allowlist.

## Pilot records

| Vimeo ID | Preserved media | Bytes | Transcript status |
|---|---|---:|---|
| 454577632 | Source original | 115,314,540 | Provisional pass |
| 806187133 | Source original | 589,312,087 | Provisional pass; terms require review |
| 668249621 | 1080p transcription mezzanine | 255,621,406 | Provisional pass; names require review |

The 668249621 Vimeo source master is 19,803,696,412 bytes and remains
scheduled as a separate preservation transfer. The 1080p object is not a
replacement for that master.

## Live Supabase state

- Accession: LP-ACC-2026-0004
- 6 archive representations
- 18 registered Backblaze file objects and copies
- 3 machine transcript records
- 104 time-coded transcript segments
- 3 transcript documents
- 4 time-coded RAG chunks
- 4 active Voyage voyage-context-4 embeddings
- 3 open human-review tasks
- Ingestion job: LP-INGEST-VIMEO-PILOT-2026-08-08 — succeeded

## Next controlled batch

The next batch should preserve and transcribe five to ten additional videos
from the same 78-video allowlist, prioritising:

- short source originals to validate throughput at low storage cost;
- La Pipa history and founder testimony;
- Subterranea interviews;
- Futures sessions with missing or poor provider captions;
- the deferred 668249621 source master as an overnight transfer.

Each new record must retain the same fail-closed scope, hash-before-embed
deduplication, provisional transcript status, and human-review queue.
