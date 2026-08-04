# Architecture

## Principles

The system is private by default, provenance-first, idempotent, and reviewable. Stable La Pipa IDs survive imports and platform changes. Internal numeric identities provide efficient database keys; unique text IDs provide durable references for Notion, GitHub, exports, citations, and RAG answers.

Canonical records live in normalized Postgres tables. Flexible metadata may use JSONB, but entities, sources, events, claims, relationships, document versions, chunks, and embeddings remain relational. Each retrieved chunk preserves its evidence class and source links.

## Retrieval

`public.search_knowledge` combines Postgres full-text search with pgvector cosine search using reciprocal-rank fusion. `kb-search` creates a query embedding with Voyage `voyage-context-4` at 1,024 dimensions. The response includes stable chunk/document/source IDs and verification status.

Embeddings are separated from canonical chunks. The unique combination of chunk, model, and content hash prevents duplication and makes re-embedding explicit. `rerank-2.5` is registered in the retrieval profile but remains off by default until evaluation demonstrates a worthwhile quality gain.

## Access

Canonical schemas are not exposed through the Data API. Only deliberately designed functions live in `public`. Authenticated users must also appear in `kb.workspace_members` as `owner`, `editor`, `reviewer`, or `reader`. Anonymous access to data and Storage is denied.

The first owner must be added by an authorized database administrator after that user has authenticated. The migration intentionally does not guess a user ID or authorize by email/user metadata.

## Storage

- `source-originals`: immutable, hash-addressed originals.
- `source-derivatives`: OCR, transcripts, renders, and previews.
- `knowledge-exports`: manifests, Markdown/JSONL, checksums, evaluations, and releases.

Object paths begin `la-pipa/`. Database records preserve bucket, object path, MIME type, byte count, SHA-256, processor version, and provenance.

