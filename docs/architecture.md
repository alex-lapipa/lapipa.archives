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
- `preservation-masters`: managed high-fidelity representations and preservation packages.
- `access-media`: rights-cleared streaming and research derivatives.

Object paths begin `la-pipa/`. Database records preserve bucket, object path, MIME type, byte count, SHA-256, processor version, and provenance.

## Documentary archive layer

The private `archive` schema implements LP-MAP 1.0. It separates collection hierarchy, intellectual items, representations, files, audiovisual essence tracks, transcripts, rights statements, preservation events, fixity checks, accessions, and custody events. Links to `kb.sources` and `kb.entities` keep archival description connected to the existing provenance graph without treating generated knowledge records as replacements for original objects.

The model is aligned to PREMIS 3.0 and PBCore 2.1, with future IIIF Presentation 3.0 exports. This is an application profile and preservation foundation, not a claim of repository certification.

Operational controls model submission, archival, and dissemination packages; independently testable storage locations and file copies; source-to-derivative lineage; consent and withdrawal; takedown triage; typed quality-control checks; accountable release approval; and periodic preservation-maturity assessments. The configured Supabase location is explicitly an operational copy, not evidence of an independent preservation replica.
