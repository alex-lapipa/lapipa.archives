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
- `SUPABASE_URL`: Vercel server configuration.
- Supabase API and service-role keys must never be placed in Vercel or browser code. The proxy forwards the authenticated caller's access token instead.

## Release checks

- Migration history matches GitHub.
- Security and performance advisors are reviewed.
- Anonymous database and Storage access is denied.
- Each membership role passes its expected allow/deny matrix.
- Seed counts and orphan checks reconcile.
- Embedding counts match current content hashes.
- Hybrid search returns source IDs and evidence status.
- Vercel preview health and authenticated proxy behavior are verified before promotion.

## Recovery

Migrations are additive. Before a material corpus import, export the affected stable IDs and hashes. Do not delete originals as part of deduplication. A failed ingestion job should be marked failed or partially succeeded and safely re-run through unique keys and hashes.
