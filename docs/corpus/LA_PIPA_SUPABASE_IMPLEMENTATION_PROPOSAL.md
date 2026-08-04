---
document_id: lp-supabase-implementation-proposal-2026-08-05-v1
entity_id: entity:la-pipa
document_type: approval_proposal
prepared_at: 2026-08-05
target_project_ref: jxilnxchvdeiazmopslf
target_project_name: LA PIPA ARCHIVE
status: proposed_not_implemented
---

# La Pipa Supabase implementation proposal

## Decision requested

Approve an **internal-first, provenance-first knowledge platform** in the existing Supabase project `jxilnxchvdeiazmopslf` (`LA PIPA ARCHIVE`).

This proposal does **not** authorize public access, paid embedding generation, large-file ingestion, destructive changes, or deployment. No Supabase changes were made while preparing it.

### Recommended approval

Approve **Phase 1 — Foundation and controlled seed**:

1. Add version-controlled migrations and data contracts to `alex-lapipa/lapipa.archives`.
2. Create private schemas, normalized tables, indexes, constraints, RLS, grants, and audit tables.
3. Create three private Storage buckets and their policies.
4. Import the reviewed La Pipa Markdown corpus and the current Notion seed records without embeddings.
5. Validate counts, provenance, permissions, checksums, and rollback instructions.

Voyage embedding generation, automated Notion sync, heavy media processing, public endpoints, and Vercel deployment should remain separate approval gates.

## Current live baseline

Verified read-only on 5 August 2026:

| Item | Current state |
|---|---|
| Supabase project | `LA PIPA ARCHIVE`, ref `jxilnxchvdeiazmopslf` |
| Organization | `oqhewhyzsnmrojwajxde` |
| Region | `eu-west-1` |
| Health | `ACTIVE_HEALTHY` |
| PostgreSQL | `17.6.1.155` |
| Public tables | 0 |
| Migrations | 0 |
| Edge Functions | 0 |
| Security-advisor findings | 0; this is not proof of readiness because no application schema exists |
| Performance-advisor findings | One informational Auth connection-allocation notice |
| `vector` extension | Available at `0.8.2`, not installed |

The project is therefore a clean target. Supabase supplies one Postgres database per project; the recommendation is to organize it with schemas rather than create multiple logical databases. If isolated testing is required, use a Supabase development branch only after its recurring cost is shown and approved.

## System-of-record model

| Platform | Responsibility | Must not become |
|---|---|---|
| Notion | Official human-readable knowledge base, review queues, editorial status, ownership, decisions | The only machine-readable archive or the only provenance ledger |
| GitHub | Canonical SQL migrations, schema documentation, seed manifests, validation scripts, RAG contracts | A store for credentials or unreviewed binary archives |
| Supabase Database | Normalized knowledge records, provenance, graph, retrieval, access control, audit history | A dumping ground for opaque JSON or duplicated untraceable claims |
| Supabase Storage | Immutable originals, generated derivatives, export snapshots | The source of database truth or a public file share by default |

Every imported object should preserve a stable La Pipa ID, source ID, verification class, source date, ingestion date, content hash, and pointer back to the original artifact or Notion record.

## Recommended database architecture

Use lowercase `snake_case`, `bigint generated always as identity` internal primary keys, stable human-facing text IDs with unique constraints, `timestamptz`, indexed foreign keys, and explicit check constraints. Avoid random UUIDv4 primary keys and avoid using JSONB for core relationships.

### `kb` — normalized knowledge and provenance

| Table | Purpose | Important fields |
|---|---|---|
| `collections` | Named corpora and releases | stable ID, title, status, version |
| `sources` | Evidence ledger | `source_id`, title, source type, evidence class, origin URL/path, captured date, access scope, verification status |
| `documents` | Logical documents | `document_id`, primary source, title, language, document type, lifecycle status |
| `document_versions` | Immutable document revisions | version, SHA-256, MIME type, byte count, Storage object, extracted text, effective dates |
| `chunks` | Deterministic retrieval units | `chunk_id`, document version, ordinal, heading path, text, token count, content hash, language, verification status, generated `tsvector` |
| `claims` | Atomic statements | `claim_id`, statement, verification status, confidence, valid dates, review status |
| `claim_sources` | Claim-to-source provenance | claim, source, locator, support type, quotation flag |
| `entities` | People, places, organizations, projects, programs, concepts, artifacts | `entity_id`, canonical name, entity type, description, verification status |
| `entity_aliases` | Multilingual names and variants | entity, alias, language, alias type |
| `events` | Activities and dated occurrences | `event_id`, title, event type, start/end, location, status, description |
| `event_sources` | Event provenance | event, source, locator, support type |
| `event_entities` | Participants, hosts, places, artifacts | event, entity, role |
| `collection_items` | Release membership | collection, record type, stable record ID, ordinal |

### `kg` — provenance-aware relational knowledge graph

| Table | Purpose | Important fields |
|---|---|---|
| `relationships` | Directed graph edges | `relationship_id`, subject entity, predicate, object entity, valid dates, confidence, verification status |
| `relationship_sources` | Evidence for every edge | relationship, source, locator, support type |
| `predicate_registry` | Controlled relationship vocabulary | predicate, inverse predicate, domain/range guidance, description |

Start with a relational graph in Postgres. It supports indexed adjacency queries and bounded recursive CTEs while preserving referential integrity. Do not introduce a separate graph database until measured query complexity or scale demonstrates the need.

### `rag` — embeddings, retrieval configuration, and evaluation

| Table | Purpose | Important fields |
|---|---|---|
| `embedding_models` | Model registry | provider, model, dimensions, distance metric, status, cost metadata |
| `chunk_embeddings` | Versioned vectors separated from content | chunk, model, embedding, content hash, embedded date, status |
| `retrieval_profiles` | Search behavior as configuration | keyword/vector weights, candidate counts, filters, reranker, version |
| `evaluation_questions` | Golden questions and expected evidence | question, expected source IDs, required/forbidden concepts |
| `evaluation_runs` | Reproducible retrieval tests | profile, model, metrics, result snapshot, run date |
| `query_audit` | Optional privacy-reviewed retrieval telemetry | hashed/session-safe query identity, filters, cited records, latency |

Keep embeddings outside `kb.chunks`. Re-embedding then creates a new model-specific record without altering the canonical text. A unique constraint on `(chunk_id, embedding_model_id, content_hash)` makes ingestion idempotent.

### `ops` — ingestion and governance

| Table | Purpose |
|---|---|
| `ingestion_jobs` | Batch identity, status, initiator, input manifest, counts, error summary |
| `ingestion_items` | Per-file/per-record result, checksum, deduplication decision, error |
| `sync_runs` | Notion/GitHub sync checkpoints and cursors |
| `review_tasks` | Human approval queue for claims, conflicts, dates, entities, and publish state |
| `audit_log` | Append-only material data changes and administrative actions |
| `schema_versions` | Data-contract and corpus-release compatibility |

### `private` — security helpers only

Membership and authorization helper functions may live here. Any `security definer` helper must set an empty search path, explicitly check the caller, remain outside exposed schemas, and have execution revoked from roles that do not need it.

### `public` — minimal API surface

Do not place canonical archive tables in `public`. Keep `public` limited to deliberately exposed, RLS-aware functions or `security_invoker` views, for example:

- `public.search_knowledge(...)`
- `public.get_entity_context(...)`
- `public.get_source_citation(...)`
- later, approved `public.published_documents` views

Only `public` should be exposed to the Data API initially. Private schemas should not be added to the exposed-schema list.

## Storage design

Create three **private** buckets. Do not create a public bucket in Phase 1.

| Bucket | Content | Mutability |
|---|---|---|
| `source-originals` | PDFs, office files, CSV/XML exports, images, audio/video masters, Notion/GitHub exports | Immutable; new revision creates a new hash-addressed object |
| `source-derivatives` | OCR, transcripts, rendered pages, thumbnails, normalized text, media proxies | Regenerable and versioned |
| `knowledge-exports` | Markdown, JSONL, manifests, checksums, evaluation snapshots, corpus releases | Versioned releases; private until specifically published |

Recommended object path:

```text
la-pipa/{source_id}/{sha256}/original.{ext}
la-pipa/{source_id}/{sha256}/derivatives/{processor_version}/{artifact}
la-pipa/releases/{release_id}/{manifest_or_export}
```

All Storage writes, moves, copies, and deletes must go through the Storage API. Treat the `storage` database schema as read-only. Database rows should store bucket, object path, MIME type, bytes, SHA-256, version, and processing status.

## Security and access model

### Default posture

- Internal-only and deny-by-default.
- No anonymous reads or writes in Phase 1.
- RLS enabled on every table reachable by application roles, including membership tables.
- Table privileges and Data API exposure kept separate from RLS.
- Service-role credentials restricted to trusted server-side ingestion; never sent to a browser, committed to GitHub, written into Notion, or printed in logs.
- Do not authorize from mutable user metadata. Use database membership records or trusted app metadata.

### Roles

Create `kb.workspace_members` keyed to `auth.users.id`, with roles:

- `owner`: governance, memberships, schema-level administrative workflows.
- `editor`: ingest and edit records; cannot manage memberships or publish automatically.
- `reviewer`: approve/reject claims, conflicts, releases, and publication status.
- `reader`: retrieve approved internal knowledge only.

Policies must check both authenticated identity and membership role. Use `(select auth.uid())` so the value is evaluated once, and index every membership and ownership column used by RLS. UPDATE policies require compatible SELECT access plus both `using` and `with check` conditions.

Storage policies should mirror database roles and constrain both bucket and path. Upsert needs SELECT, INSERT, and UPDATE permissions; do not grant it implicitly.

## RAG design

### Retrieval strategy

Use **hybrid retrieval**:

1. Postgres full-text search for exact names, dates, event titles, filenames, and phrases.
2. Semantic vector search for meaning across English and Spanish wording.
3. Metadata filters for access scope, publication state, evidence class, verification status, language, date, entity, and collection.
4. Reciprocal-rank fusion or a versioned weighted fusion profile.
5. Optional reranking only after baseline evaluation demonstrates value.

Every result must return `chunk_id`, `document_id`, `source_ids`, evidence class, verification status, locator, and similarity/rank components. The answer layer should cite these IDs and visibly distinguish verified, user-supplied, filename-only, historical, secondary, and unresolved evidence.

### Voyage AI provider decision

The approved provider is **Voyage AI**. The user states that `VOYAGE_API_KEY` already exists in Supabase secrets. Treat that as user-supplied configuration until a server-side function confirms only that the secret is present; never retrieve, print, compare, copy, return, or commit its value.

Recommended first production model stack:

| Function | Model | Configuration | Reason |
|---|---|---|---|
| Contextual chunk embeddings | `voyage-context-4` | 1,024 dimensions, float output, `input_type=document` | Current multilingual, context-aware retrieval model; 1,024 dimensions fit a normal pgvector HNSW index |
| Query embeddings | `voyage-context-4` | 1,024 dimensions, `input_type=query` | Keeps query and document embeddings compatible |
| Candidate reranking | `rerank-2.5` | Top hybrid candidates only | Current multilingual generalist reranker; use only if evaluation shows a quality gain worth the latency/cost |
| Rich visual archive, later option | `voyage-multimodal-3.5` | Separate collection/index and approval gate | Appropriate for image-rich PDFs, slides, figures, images, and video frames; not needed for the text-first seed |

Keep the schema model-provider-neutral even though Voyage is selected. Store provider, exact model, dimensions, output type, API mode, chunker version, and embedding date on every embedding record. Do not mix vectors from different model families in one index.

Supabase currently recommends HNSW for changing corpora; the project has pgvector `0.8.2` available but not installed. The 1,024-dimensional Voyage default avoids the normal HNSW `vector` limit of 2,000 dimensions.

### Voyage-aware chunking

- Preserve the authored RAG records already present in `LA_PIPA_RAG_MASTER.md` as atomic units, then submit the pre-chunked document groups to `voyage-context-4` so each chunk is embedded with its document context.
- For unstructured long documents, pilot Voyage contextual auto-chunking at 512 tokens and record the exact returned chunk text. Compare it against a heading-aware 350–700-token local chunker before standardizing. Use overlap only when evaluation demonstrates that it improves retrieval.
- Never allow automatic chunking to separate a source ID, date, evidence label, table row, speaker attribution, or verification qualifier from the statement it governs.
- Store chunker name/version, ordinal, parent heading path, token count, and content hash.
- Reuse an existing embedding only when both model/version and content hash match.
- Do not OCR, transcribe, recrawl, or re-embed unchanged content.

### Indexes

- GIN index on the generated full-text `tsvector`.
- HNSW cosine index on active embeddings after the corpus is large enough to justify approximate search.
- For the initial small seed, benchmark exact search first; it is fully accurate and may be simpler.
- B-tree indexes on all foreign keys and common filters.
- Composite indexes with equality columns first and range columns last.
- Partial indexes for active/current/approved records.
- GIN indexes on JSONB only for genuinely queried flexible metadata, not by default.

### Evaluation gates

Before calling the system “RAG ready”:

1. Build at least 25 golden questions spanning history, start date conflict, activities, people, organizations, places, governance, and connected platforms.
2. Include English/Spanish paraphrases, exact-name tests, conflict tests, and “not enough evidence” tests.
3. Record Recall@k, MRR/nDCG, citation correctness, access-control correctness, latency, and cost.
4. Require every answer claim to map to at least one retrieved source ID.
5. Fail the release if restricted content appears to an unauthorized test user.

## Ingestion and synchronization

### Initial seed

Import the existing reviewed package first:

- `LA_PIPA_RAG_MASTER.md`
- `LA_PIPA_SOURCE_INVENTORY.md`
- `LA_PIPA_CONNECTED_PLATFORMS.md`
- current Notion seed: 5 documents, 33 sources, 9 claims, 14 entities, 9 events, 11 graph edges, and 5 RAG chunks

The import should be manifest-driven, batched, transactional where practical, and idempotent through stable IDs and content hashes. Use atomic upserts only on explicit unique keys. Produce a reconciliation report showing inserted, unchanged, updated, rejected, duplicated, and unresolved records.

### Notion relationship

Use Notion as an editorial surface, not a blind two-way database replica. Recommended flow:

```text
Notion approved records -> normalized export -> validation -> Supabase staging -> reconciliation -> commit
Supabase release status and stable IDs -> Notion status fields
```

The first implementation should be a manually triggered sync with a dry-run report. Automatic sync comes later, after field ownership and conflict resolution are defined. The historical Notion pages that remain inaccessible must stay marked as access boundaries, not missing/deleted content.

### Large archive and media

Do not process a large Dropbox/media archive inside a single Edge Function. Use a resumable external worker or controlled local/CI process for hashing, upload, OCR, transcription, and derivative generation. Edge Functions can authenticate requests, create jobs, and expose small retrieval endpoints, but long-running media work should be queued and resumable.

## Migration and verification plan

### Phase 0 — repository contract

- Confirm the local checkout maps to `alex-lapipa/lapipa.archives` before editing.
- Add architecture decision record, SQL migration plan, data dictionary, manifests, RAG contract, and test plan.
- No Supabase write.

### Phase 1 — foundation and controlled seed

- Enable required extensions (`vector` only if embeddings are included in the approved scope; `unaccent` only if search testing justifies it).
- Create schemas, tables, constraints, indexed foreign keys, grants, RLS, policies, buckets, and Storage policies.
- Seed controlled vocabularies, then the reviewed corpus without paid embeddings.
- Generate a clean migration and commit it to GitHub.
- Verify as owner, editor, reviewer, reader, unauthenticated user, and service-side worker.
- Run Supabase security and performance advisors and resolve or document every finding.

### Phase 2 — Voyage retrieval pilot, separately approved

- Use `voyage-context-4` at 1,024 dimensions for the initial multilingual evaluation.
- Compare pre-chunked contextual embeddings with Voyage auto-chunking on representative La Pipa documents.
- Embed only approved current chunks, using `input_type=document`; use `input_type=query` for searches.
- Implement hybrid retrieval and citation output.
- Evaluate `rerank-2.5` against the non-reranked baseline before enabling it by default.
- Run golden-set evaluation and cost report.

### Phase 3 — automation, separately approved

- Add resumable ingestion jobs and manual Notion synchronization.
- Add queue/worker orchestration only when volume requires it.
- Add Edge Functions with JWT verification for authenticated operations.

### Phase 4 — publication/deployment, separately approved

- Define the public corpus and rights review.
- Create curated publication views/endpoints and a public Storage policy only if needed.
- Resolve the Vercel project/team identity boundary before deployment.

## Acceptance criteria for Phase 1

- The approved migration applies cleanly to a disposable branch or fresh database and can be reproduced from GitHub.
- No canonical knowledge table is directly exposed from a private schema.
- Anonymous access returns no private records or files.
- RLS role tests pass for database and Storage operations.
- All foreign keys are indexed; stable IDs and checksums are unique where required.
- Seed counts reconcile exactly to the approved manifest, with no orphan provenance.
- Every claim, event, relationship, chunk, and version resolves to at least one source where the data contract requires it.
- Re-running the import creates no duplicates and avoids unchanged processing.
- Security and performance advisors are rerun; findings are fixed or explicitly accepted.
- A rollback and backup/export procedure is documented before the production migration.

## Explicit exclusions until separately approved

- No deletion or alteration of source files.
- No public bucket or anonymous archive access.
- No Voyage API spend or bulk transcription/OCR spend until the Phase 2 token estimate and pilot are approved.
- No automatic two-way Notion sync.
- No deployment to the unresolved Vercel project.
- No credential creation, exposure, rotation, or client-side service role.
- No claim that the archive is complete merely because the seed imports successfully.

## Approval choices

### Recommended: approve Phase 1

Build the secure foundation, private buckets, normalized knowledge/graph schemas, governance layer, and controlled non-embedded seed. Return for approval with the exact migration, policy matrix, dry-run reconciliation, and expected impact before applying it to production.

### Approve Phase 0 only

Prepare the GitHub architecture, migrations, manifests, and tests without writing to Supabase. This is the lowest-risk choice if you want to inspect SQL and policies line by line first.

### Revise the design

Specify any required changes to roles, schema names, public access, embedding provider, Notion ownership rules, data-retention policy, or deployment scope before implementation.

## Current official references

- [Using custom schemas](https://supabase.com/docs/guides/api/using-custom-schemas)
- [Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Storage access control](https://supabase.com/docs/guides/storage/security/access-control)
- [Storage schema design](https://supabase.com/docs/guides/storage/schema/design)
- [Hybrid search](https://supabase.com/docs/guides/ai/hybrid-search)
- [HNSW indexes](https://supabase.com/docs/guides/ai/vector-indexes/hnsw-indexes)
- [AI production guidance](https://supabase.com/docs/guides/ai/going-to-prod)
- [Production readiness](https://supabase.com/docs/guides/deployment/going-into-prod)
- [Voyage contextualized chunk embeddings](https://docs.voyageai.com/docs/contextualized-chunk-embeddings)
- [Voyage text embeddings](https://docs.voyageai.com/docs/embeddings)
- [Voyage rerankers](https://docs.voyageai.com/docs/reranker)
