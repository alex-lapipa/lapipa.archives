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

Alex Lawton is the active archive owner. Both authorized email identities are bound by immutable confirmed Auth UUID rather than editable profile metadata; authorization and actual sign-in remain separately evidenced. Database authorization acceptance has passed. The first controlled submission package, `LP-ACC-2026-0001` / `LP-BAG-2026-0001`, contains the 2019 origin-deck PDF and validates with zero BagIt failures; managed-storage ingest and preservation completion remain separate pending gates.

Edge Functions:

- `kb-search`: authenticated Voyage query embedding plus hybrid retrieval.
- `kb-embed`: owner/editor-only contextual embedding of approved chunks.

`VOYAGE_API_KEY` is a server-side Supabase secret. Never copy it into Vercel, a browser, GitHub, Notion, or logs.

## Local checks

```sh
npm run check
npm run validate
npm test
npm run build
supabase functions serve kb-search --env-file .env.local
```

Archive package tools:

```sh
npm run archive:inventory -- /path/to/source /path/to/inventory.json
npm run archive:create-bag -- /path/to/source /path/to/LP-ACC-2026-0001
npm run archive:validate-bag -- /path/to/LP-ACC-2026-0001
npm run archive:validate-website -- data/accessions/LP-WEB-2026-08-05
```

Use `.env.example` as the list of required Vercel configuration names. The Vercel proxy needs only the Supabase project URL; it forwards the caller's short-lived access token and does not hold a Supabase API key. Local secret values belong only in ignored `.env.*.local` files.

## Deployment sequence

1. Review and apply migrations in timestamp order.
2. Run Supabase security and performance advisors.
3. Deploy authenticated Edge Functions with JWT verification enabled.
4. Configure Vercel `SUPABASE_URL` per environment.
5. Deploy and verify a Vercel preview.
6. Promote only after authentication, RLS, retrieval, and citation checks pass.

See [docs/architecture.md](docs/architecture.md), [docs/operations.md](docs/operations.md), and the [Documentary Archive handbook](docs/archive/README.md).
