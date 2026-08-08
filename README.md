# La Pipa Archives

The version-controlled implementation for the La Pipa archive, knowledge base, provenance graph, and RAG system.

## Platform responsibilities

- **Notion:** official editorial knowledge base and review workflow.
- **GitHub:** migrations, data contracts, functions, documentation, and release history.
- **Supabase:** private structured records, Storage, provenance, graph relationships, hybrid retrieval, and audit data.
- **Vercel:** internal archive entry point and authenticated search proxy. Voyage credentials remain in Supabase only.

## Supabase

Target project: `jxilnxchvdeiazmopslf` (`LA PIPA ARCHIVE`).

The migrations create private `archive`, `kb`, `kg`, `rag`, `ops`, and `private` schemas; preservation and access Storage buckets; row-level security; a relational knowledge graph; Voyage-compatible 1,024-dimensional embeddings; hybrid full-text/vector search; evaluation records; and ingestion governance. The documentary layer covers archival hierarchy, intellectual items, representations, file objects, audiovisual tracks, transcripts, rights, preservation events, fixity, accessions, custody, transfer packages, preservation copies, consent, takedown, quality control, and controlled releases.

Alex Lawton is the active archive owner. Alex Lawton declares that he and his holding company, Miramonte, S.L., collectively own 100% of the intellectual-property and related rights in La Pipa and its associated project materials; the statement is preserved as owner-supplied evidence rather than an independent legal opinion. Both authorized email identities are bound by immutable confirmed Auth UUID rather than editable profile metadata; authorization and actual sign-in remain separately evidenced. Database authorization acceptance has passed. The first controlled submission package, `LP-ACC-2026-0001` / `LP-BAG-2026-0001`, contains the 2019 origin-deck PDF and validates with zero BagIt failures. Its complete five-object BagIt package is now registered in private Backblaze B2 storage with five distinct encrypted versions, five passing SHA-256 checks, and a successful clean-directory restore. Public release remains separately gated.

Edge Functions:

- `kb-search`: authenticated Voyage query embedding plus hybrid retrieval.
- `kb-embed`: owner/editor-only contextual embedding of approved chunks.
- `b2-preservation-status`: owner/editor-only, read-only verification of the configured Backblaze credential pair, exact bucket, endpoint, and preservation controls; responses are sanitized and object operations are excluded.
- `vimeo-archive-session`: custom-authenticated, exact-scope capability broker for the completed one-video acceptance accession.
- `vimeo-batch2-session`: custom-authenticated, owner-issued capability broker restricted to the five appraised Batch 2 accessions; it supports exact-path single-PUT and reviewed multipart preservation while provider and Backblaze credentials remain server-side.

`VOYAGE_API_KEY` and the Backblaze integration credentials are server-side Supabase Edge Function secrets. Never copy them into Vercel, a browser, GitHub, Notion, Database Vault, RAG chunks, or logs.

## Local checks

```sh
npm run check
npm run validate
npm test
npm run test:edge
npm run build
supabase functions serve kb-search --env-file .env.local
```

Archive package tools:

```sh
npm run archive:inventory -- /path/to/source /path/to/inventory.json
npm run archive:reconcile -- /path/to/reconciliation.json /path/to/inventory-1.json /path/to/inventory-2.json
npm run archive:create-bag -- /path/to/source /path/to/LP-ACC-2026-0001
npm run archive:validate-bag -- /path/to/LP-ACC-2026-0001
npm run archive:validate-website -- data/accessions/LP-WEB-2026-08-05
npm run archive:vimeo -- --batch-size 5
```

The reviewed live Batch 2 workflow is intentionally launched from Finder with `Run La Pipa Vimeo Batch 2.command`. It processes one chosen accession at a time and requires a matching ten-minute code from the signed-in Owner Access panel. The operator never deletes a source, never overwrites a differing Backblaze object, and does not silently downgrade an oversized Vimeo source. Preservation masters above 5 GB and no larger than 25 GB use deterministic, resumable 512 MiB S3 multipart uploads followed by a full clean restore and SHA-256 verification.

Use `.env.example` as the list of required Vercel configuration names. The Vercel proxy needs only the Supabase project URL; it forwards the caller's short-lived access token and does not hold a Supabase API key. Local secret values belong only in ignored `.env.*.local` files.

## Deployment sequence

1. Review and apply migrations in timestamp order.
2. Run Supabase security and performance advisors.
3. Deploy authenticated Edge Functions with JWT verification enabled.
4. Configure Vercel `SUPABASE_URL` per environment.
5. Deploy and verify a Vercel preview.
6. Promote only after authentication, RLS, retrieval, and citation checks pass.

See [docs/architecture.md](docs/architecture.md), [docs/operations.md](docs/operations.md), the [Documentary Archive handbook](docs/archive/README.md), and the [first live archive upload report](docs/archive/live-archive-first-upload-2026-08-08.md).
