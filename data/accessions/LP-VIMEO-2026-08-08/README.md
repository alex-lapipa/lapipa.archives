# La Pipa Vimeo preservation and transcription pilot

Accession LP-ACC-2026-0004 proves the controlled path from the authenticated
La Pipa Vimeo account to local staging, independent Backblaze preservation,
time-coded transcription, deterministic RAG chunks, Voyage contextual
embeddings, and retrieval.

## Scope

The authenticated account contains 749 videos, including unrelated business
and client material. This accession is deliberately limited to three of the 78
Vimeo videos already evidenced on lapipa.io:

- 454577632 — Javier / Los inicios
- 668249621 — La Diáspora / Cierre 2021
- 806187133 — Subterranea / Miguina

Unrelated client, Remotive, and Vumi material is excluded. No source deletion
is authorized.

## Preserved objects

- Two Vimeo source originals
- One 1080p transcription mezzanine
- Fifteen selected MLX Whisper transcript artifacts
- One provider-generated caption retained as non-authoritative evidence
- Two accession/transcription manifests

The Backblaze object root is
lapipa/vimeo/LP-ACC-2026-0004/. Every uploaded object in the pilot was
checked against its expected remote byte count. Local SHA-256 digests are
recorded in the manifests; the remote copies remain flagged for a future
download-and-rehash audit.

## Transcript quality

The selected Spanish transcripts use
mlx-community/whisper-large-v3-turbo. The first runs for two videos exhibited
repetition during music or silence and were rejected from ingestion. Their
second pass disabled previous-text conditioning and applied hallucination and
no-speech thresholds.

All three accepted transcripts remain
machine_generated_unreviewed. They may be searched with that provenance
label, but they must not be represented as human-verified quotations.
Supabase contains three open review tasks for proper names, speaker
attribution, and quotation approval.

## RAG package

- sources.jsonl: 3 transcript source/document records
- segments.jsonl: 104 time-coded speech segments
- chunks.jsonl: 4 deterministic time-range chunks
- rag-manifest.json: hashes, counts, model, and embedding status
- transcripts/*.md: Markdown documents ready for retrieval and human review

The four chunks are embedded with Voyage voyage-context-4 at 1,024
dimensions. A semantic test about La Pipa generating value and synergies
ranked the two La Diáspora chunks first.

## Rebuild

~~~sh
node scripts/archive/build-vimeo-pilot-accession.mjs \
  --input="/path/to/verified/LP-ACC-2026-0004"
~~~

The builder produces the RAG package and the idempotent Supabase registration
migration. Media binaries and credential values are never committed to Git.
