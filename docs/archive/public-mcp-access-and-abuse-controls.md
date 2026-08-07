# LP-DOC-ARCH-025 — Public MCP access and abuse controls

Version: 1.0

Status: controlled implementation

Owner: Alex Lawton

Effective date: 7 August 2026

Review cycle: quarterly and after any public-scope, model, credential, rate-limit, or publication-policy change

## Decision

`pipa-mcp` is the deliberately anonymous, read-only Model Context Protocol interface to the owner-approved public portion of the La Pipa Documentary Archive. Anonymous availability does not make the archive public by default. PostgreSQL is the final publication boundary, and the Edge Function is a defense-in-depth application layer.

The function may expose only records that have an affirmative `public` scope or an equivalent approved release state. Internal, restricted, unresolved, unreviewed, or merely present records are not public because a client asks for them.

## Root cause and corrective action

The first live MCP implementation existed only as deployed Supabase code. Its Edge layer asked the search RPC for public chunks and filtered entity and document rows after retrieval, but its database functions could still read broader scopes with a server credential. The event RPC had no publication field and returned every event. A public entity could also carry a relationship to an internal entity. Public semantic searches could create unbounded Voyage requests.

The controlled implementation corrects those defects by:

1. versioning the Edge Function and every supporting database function in GitHub;
2. adding `kb.events.access_scope`, defaulting every pre-existing event to `internal`;
3. enforcing public document, chunk, source, entity, relationship-object, event, and related-entity scope in SQL;
4. changing the content RPCs from `SECURITY DEFINER` to `SECURITY INVOKER`;
5. revoking every MCP RPC from `PUBLIC`, `anon`, and `authenticated`, then granting only `service_role`;
6. adding database-atomic request limits and a daily Voyage-attempt budget;
7. caching search results by a one-way query hash for one hour;
8. limiting request bodies, query length, result counts, filter counts, and upstream timeouts; and
9. recording privacy-preserving audit evidence without query text, IP addresses, credentials, or response content.

## Public-data contract

| Tool | Required database controls |
|---|---|
| `search_archive` | Document and active chunk are public; provenance arrays include only public sources; active embedding hash matches the current chunk. |
| `get_entities` | Subject entity is public; relationship is approved; relationship object entity is public. |
| `get_events` | Event is explicitly public; locations and participants are independently public. |
| `get_document` | Document and returned chunks are public; returned primary provenance is public. |
| `archive_status` | Counts only the approved public corpus and does not disclose non-public scope totals. |

Client-supplied scope parameters can narrow public retrieval but can never widen it. Application filtering remains in place for document and entity rows, but it is not the primary security boundary.

## Event release workflow

All events that existed before this control were assigned `internal` scope. Review task `LP-REV-PUBLIC-EVENTS-2026-001` controls their future release.

An owner or editor must, for each event:

1. attach at least one appropriate source in `kb.event_sources`;
2. verify title, date precision, description, status, location, and participant references;
3. confirm that related entities are themselves approved for public access;
4. complete privacy, consent, contractual, moral-rights, and harm review as applicable;
5. record the approval decision; and
6. change `kb.events.access_scope` to `public` only after the decision is complete.

The empty public-event result is intentional until this review occurs.

## Abuse and cost controls

- Maximum request body: 65,536 bytes.
- Maximum public search query: 1,000 characters.
- General per-client request limit: 60 requests per minute.
- Search limit: 12 requests per client per minute.
- Entity, event, and document lookup limit: 30 requests per client per minute per tool.
- Public status limit: 60 requests per client per minute.
- Search result limit: 20 passages.
- Search-cache lifetime: one hour.
- Default Voyage query-embedding budget: 250 attempts per UTC day.
- When the daily budget is exhausted or Voyage is unavailable, search falls back to keyword retrieval rather than failing open or exceeding the budget.

The daily limit can be changed through the server-only `MCP_DAILY_VOYAGE_LIMIT` Edge Function secret. A change is an operational decision and must be recorded; no limit value belongs in browser or Vercel configuration.

## Privacy and logs

The client limiter derives a one-way SHA-256 identifier from the source network address and a server credential. The raw address is never stored. Rotating the server credential changes future identifiers.

`ops.public_mcp_audit_log` records request UUID, derived client identifier, tool, outcome, duration, whether a paid embedding was attempted, whether a cache was used, and small controlled metrics such as result count. It must never contain query text, response content, credentials, source IP addresses, authorization headers, personal-data extracts, or unrestricted exception bodies.

Operational retention is:

- rate-limit rows: two days;
- daily-budget rows: 31 days;
- expired search-cache rows: removable immediately; and
- audit rows: 90 days.

Pruning is performed by the server-only `mcp_prune_operational_state` function under an approved scheduled or manual operation.

## Credential boundary

The public caller supplies no Supabase service credential. The Edge Function uses the platform-provided server secret, preferring the rotatable `SUPABASE_SECRET_KEYS` dictionary and retaining legacy service-role compatibility during migration. Server credentials remain in Supabase only and are never returned, logged, documented as values, or copied to Vercel.

## Release and rollback

The implementation is released through an additive database migration, a versioned Edge Function, automated Deno tests, repository validation, Supabase advisors, a public behavior suite, and production log inspection.

If a release test detects non-public output:

1. disable or redeploy `pipa-mcp` immediately;
2. preserve sanitized logs and the request ID;
3. set affected records to `internal` or `restricted` without deleting evidence;
4. invalidate relevant cache entries;
5. document the incident and release decision; and
6. restore public access only after database-level negative tests pass.

## Acceptance tests

- The repository can recreate all MCP tables, functions, grants, and Edge code.
- `anon` and `authenticated` cannot execute any MCP database function directly.
- Content RPCs are `SECURITY INVOKER` and executable only by `service_role`.
- Public search returns only public documents, chunks, and source URIs.
- Public document retrieval returns no restricted document and no non-public chunk.
- Public entity retrieval returns no internal relationship object.
- Public event retrieval returns only explicitly public events; the initial expected count is zero.
- Archive status contains only public aggregate counts.
- Oversized and malformed requests are rejected.
- Per-client limits return a controlled rate-limit response.
- Repeated identical searches use the cache and avoid a second Voyage request.
- Daily-budget exhaustion produces keyword-only search.
- Audit rows contain no plaintext query or network address.

## Evidence classification

This document combines `live_connector_verified` evidence from the 7 August 2026 review with `workspace_verified` implementation and test evidence. It is an operational security and publication-control record, not a declaration that every public archive item has completed documentary release review.
