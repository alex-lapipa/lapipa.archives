# Operations

## Ingestion

1. Hash and inventory the source before upload or processing.
2. Reuse an unchanged original, derivative, chunk, or embedding when its content hash and processor/model version match.
3. Upload originals through the Storage API; never manipulate `storage.objects` as a file-management shortcut.
4. Validate stable IDs, evidence classes, dates, rights/access scope, and source links.
5. Import in batches and reconcile inserted, updated, unchanged, duplicate, rejected, and failed records.
6. Embed only approved active chunks.
7. Run golden retrieval and access-control tests before release.

## Secrets

- `VOYAGE_API_KEY`: Supabase Edge Function secret only.
- `MCP_DAILY_VOYAGE_LIMIT`: optional Supabase-only override for the public MCP's UTC daily query-embedding attempt budget; default 250.
- `SUPABASE_URL`: Vercel server configuration.
- Supabase API and service-role keys must never be placed in Vercel or browser code. The proxy forwards the authenticated caller's access token instead.

## Public MCP

1. Treat database scope as the publication boundary; Edge filtering is defense in depth.
2. Do not publish an event until its source, people, place, dates, rights, privacy, and harm review are complete.
3. Review rate-limit, budget, cache, and audit aggregates without retrieving credential values or storing query text.
4. Prune operational MCP state through `mcp_prune_operational_state` under a documented manual or scheduled run.
5. Run negative-scope tests after every migration affecting documents, chunks, sources, entities, relationships, or events.
6. Follow [LP-DOC-ARCH-025](archive/public-mcp-access-and-abuse-controls.md) for the data contract, limits, audit fields, rollback, and acceptance suite.

## Release checks

- Migration history matches GitHub.
- Security and performance advisors are reviewed.
- Anonymous database and Storage access is denied.
- Each membership role passes its expected allow/deny matrix.
- Seed counts and orphan checks reconcile.
- Embedding counts match current content hashes.
- Hybrid search returns source IDs and evidence status.
- Vercel preview health and authenticated proxy behavior are verified before promotion.
- Public MCP negative-scope, rate-limit, cache, budget-fallback, and sanitized-audit behavior are verified before promotion.

## Recovery

Migrations are additive. Before a material corpus import, export the affected stable IDs and hashes. Do not delete originals as part of deduplication. A failed ingestion job should be marked failed or partially succeeded and safely re-run through unique keys and hashes.
