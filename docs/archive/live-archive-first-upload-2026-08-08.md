---
document_id: LP-DOC-ARCH-029
title: First Live Archive Upload and Restore
status: in_review
evidence_class:
  - workspace_verified
  - live_connector_verified
date: 2026-08-08
access_scope: restricted
---

# First live archive upload and restore

## Outcome

The first simplified La Pipa live-archive batch is online. Eight objects were uploaded to the private Backblaze B2 bucket `miramonte-lapipa-archive`, downloaded into a clean restore directory, compared by SHA-256, and registered in Supabase project `jxilnxchvdeiazmopslf`.

The bucket is private, uses AES-256 server-side encryption, and has no Object Lock or default retention period. The temporary exact-path transfer function was deleted after the transfer. No credential value was copied into the repository, database, documentation, or task output.

## Content

Accession `LP-ACC-2026-0003` contains four payload files:

- two PNG La Pipa logo files;
- `LA PIPA _ V001B_BEDROCK LOGO.mp4`;
- `MASTER_LA PIPA _ Video_001_HD1080.mp4`.

The payload is 162,933,571 bytes. Four small checksum and transfer-control files bring the complete stored batch to eight objects and 162,934,529 bytes.

The two videos are distinct MPEG-4 files with H.264 video and AAC stereo audio at 1920 × 1080. Their durations are 66.125 and 67.625 seconds. The source-folder description says “first video”; the archive preserves this as a filename claim rather than treating it as independently verified chronology.

## Verification

- Eight uploads returned success.
- Eight remote metadata checks returned success.
- Backblaze returned eight distinct object version IDs.
- AES-256 server-side encryption was observed on every object.
- All eight objects were downloaded into a clean restore tree.
- All eight restored SHA-256 digests matched the local source digests.
- The restored BagIt package validated with four payload files, 162,933,571 payload bytes, and zero failures.
- Supabase records eight package files, eight linked canonical file objects, eight verified copies, eight passing fixity checks, and four successful preservation events.
- Supabase records four provenance-linked RAG chunks and four active 1,024-dimensional `voyage-context-4` embeddings.
- A live semantic query about storage, Object Lock, and forced retention ranked `LP-RAG-029` (“Outcome and storage configuration”) first.
- The knowledge graph contains three new entities and four source-linked relationships for the archive item, Backblaze B2, and the live bucket.

One `bagit.txt` object reused the canonical file record from the earlier pilot because its SHA-256 and byte count were identical. The new Backblaze occurrence retains its own storage path and version ID. This demonstrates content-level deduplication without losing provenance.

## Operating model

Backblaze stores the files. Supabase stores their catalogue, provenance, checksums, RAG content, embeddings, knowledge graph, and ingestion state. Notion stores curated human documentation. Vercel provides the archive interface.

Future batches should use the same simple sequence: add a folder, scope-check it, hash it, avoid redundant payload transfer where practical, upload originals, restore-verify, register metadata, extract searchable content, embed with Voyage, and update the graph.

The one-time embedding and retrieval controls were removed after successful verification. The permanent result is the provenance-linked document, chunks, embeddings, graph records, and ingestion audit trail.

## Boundaries

- Vumi is unrelated to La Pipa and remains categorically excluded before hashing or copying.
- No source file was moved, renamed, rewritten, or deleted.
- Public release was not granted by this storage operation.
- Source-folder and filename statements remain attributed claims until independently corroborated.
- Full speech transcription and deeper audiovisual description remain a separate content-enrichment step.

## Stable records

- Accession: `LP-ACC-2026-0003`
- Item: `LP-ITEM-2026-0002`
- Package: `LP-BAG-2026-0003`
- Storage location: `LP-LOC-B2-EUC3-002`
- Bucket: `miramonte-lapipa-archive`
- Source-scope policy: `LP-SCOPE-2026-08-08-001`
- Supabase: `jxilnxchvdeiazmopslf`
- GitHub: `alex-lapipa/lapipa.archives`
- Vercel: `prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k`
- RAG source: `LP-SRC-041`
- RAG document: `lp-live-archive-first-upload-2026-08-08-v1`
- RAG chunks: `LP-RAG-029` through `LP-RAG-032`
- Embedding job: `LP-EMBED-LIVE-ARCHIVE-0003`
- Graph relationships: `LP-REL-014` through `LP-REL-017`
