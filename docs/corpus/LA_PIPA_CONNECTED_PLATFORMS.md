---
document_id: lp-connected-platforms-2026-08-05-v1
entity_id: entity:la-pipa
document_type: connected_platform_inventory
compiled_at: 2026-08-05
verification_status: mixed
---

# La Pipa connected platforms

## Snapshot summary

This is a read-only snapshot of the GitHub, Supabase, Notion, and Vercel connections supplied or explicitly enabled on 5 August 2026. No files, data, schemas, deployments, settings, or permissions were changed.

| Platform | Supplied or discovered identifier | Current finding | Status |
|---|---|---|---|
| GitHub | `alex-lapipa/lapipa.archives` | Repository and default-branch README readable; README is currently minimal | `confirmed` |
| Supabase | `jxilnxchvdeiazmopslf` | Project resolves to `LA PIPA ARCHIVE`; healthy project metadata, but no public tables, migrations, or Edge Functions | `confirmed_but_unpopulated` |
| Notion | Workspace `MIRAMONTE`; La Pipa Surface hub `34d425866bb581aa908de6c72f4a3113` | Workspace and four relevant portfolio pages readable; dedicated La Pipa hub, Operations Hub, and Platform IP page return 404 to this integration | `partially_accessible` |
| Vercel | `prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k` | Exact project returns 404 under the connected La Pipa team and is absent from its visible project list | `unresolved_access_or_identity_boundary` |

## GitHub

- Repository: [alex-lapipa/lapipa.archives](https://github.com/alex-lapipa/lapipa.archives)
- Default-branch README: [README.md](https://github.com/alex-lapipa/lapipa.archives/blob/main/README.md)
- README blob SHA: `00acd71a5224d7bd580e290e515b94c85009fcab`
- README content: title `lapipa.archives`; description `lapipa archives`.
- Repository search for `LA PIPA` and `archive` returned no additional indexed files.

The connection is confirmed, but the currently visible repository content does not yet constitute a RAG corpus or archive manifest.

## Supabase

### Project metadata

| Field | Value |
|---|---|
| Project ref | `jxilnxchvdeiazmopslf` |
| Project name | `LA PIPA ARCHIVE` |
| Organization ID | `oqhewhyzsnmrojwajxde` |
| Region | `eu-west-1` |
| Created | `2026-08-04T22:51:50.221882Z` |
| Project status at lookup | `ACTIVE_HEALTHY` |
| PostgreSQL engine | 17 |
| Database version | `17.6.1.155` |

### Read-only structure audit

- Public tables: **0**.
- Database migrations: **0**.
- Edge Functions: **0**.
- Security-advisor findings: **0**.
- Performance-advisor findings: one informational notice that Auth uses an absolute ten-connection allocation rather than a percentage-based strategy. Remediation reference: [Supabase production guidance](https://supabase.com/docs/guides/deployment/going-into-prod).

The absence of security findings does not establish security readiness: there is no public application schema for the advisor to evaluate. Likewise, `ACTIVE_HEALTHY` confirms project-level availability, not archive ingestion, data quality, RLS, retrieval, or end-to-end RAG operation.

## Notion

### Official project knowledge base

- [LA PIPA ARCHIVES — Official Knowledge Base](https://app.notion.com/p/3b2425866bb581f08befc9f930417991)
- Created 5 August 2026 at the MIRAMONTE workspace level because the historical La Pipa and Operations hubs remain outside the integration's fetch scope.
- Seven structured collections: Documentation, Sources & Provenance, Claims & Facts, Entities, Events & Activities, Knowledge Graph Relationships, and RAG Chunks.
- Verified seed counts: 5 documents, 33 sources, 9 claims, 14 entities, 9 events, 11 graph edges, and 5 retrieval-ready chunks.
- Working views include status/evidence/verification boards, an activity calendar, a graph edge ledger, and an embedding pipeline.

### Connection identity

- Workspace: `MIRAMONTE`.
- Workspace ID: `495d6263-bcfe-4753-b478-4141eab8ca4c`.
- The authenticated integration reports search and fetch access as available.

### Accessible La Pipa-related sources

1. [Onboarding and welcoming New Joiners](https://app.notion.com/p/2fd06caea3004de0b9704e93c141a3f7)
   - Updated 25 April 2026.
   - Classifies La Pipa as one of the portfolio’s operating `Surfaces`.
   - Links a dedicated La Pipa Surface hub.
   - Requires Vercel, Supabase, and GitHub access where applicable.
   - Preserves an earlier onboarding routine that included coffee at La Pipa, daily standups, and collective workshops.

2. [Vision and Strategy](https://app.notion.com/p/1100416cf8464dd382a74cdba3532379)
   - States that `build to learn` and `share for impact` are La Pipa’s founding spirit.
   - Identifies documented sessions and a `Humanized Intelligence` library as artifacts.
   - Frames documentation, corpora, engagement records, and people relationships as part of a cross-portfolio knowledge model.

3. [Diversity and Inclusion](https://app.notion.com/p/61aadc4b536049f4b548cc63a2fead92)
   - Contains an Equality Plan explicitly labelled for La Pipa.
   - Says the 2023–2028 plan originated in the ReMotive Media + La Pipa scope.
   - Covers inclusion, equality, diversity, gender mainstreaming, prevention, participation, diagnostics, monitoring, and deliverables.
   - States that the diagnostic and evaluation phase had not yet been documented in Notion as of 25 April 2026.

4. [The What If, Why Not, and How About of Our Company Culture](https://app.notion.com/p/d69871f914ff4eb9b7835560345f98f6)
   - Applies care, trust, transparency, and continuous improvement across portfolio Surfaces.
   - Interprets care at La Pipa as care for the wider Asturian community.
   - Recommends a La Pipa culture sub-page covering hackspace etiquette, studio booking norms, and community contribution expectations.

### Notion access boundaries

The following pages are linked by accessible sources but return `object_not_found` to the current Notion integration:

- La Pipa Surface hub: `34d425866bb581aa908de6c72f4a3113`.
- Operations Hub: `30c425866bb581d4aef1d96cda3cec67`.
- Platform IP page: `34d425866bb581dd91bdceb93976bb6a`.

These 404 responses mean the integration cannot fetch the pages in its present workspace/share scope. They do not prove the pages were deleted.

## Vercel

- Connected team: `LA PIPA IS LA PIPA`.
- Team ID: `team_mNSOnF2OglXKmaAA6GfrQ489`.
- Supplied project ID: `prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k`.
- Exact project lookup under the connected team: `404 Not Found`.
- The supplied ID was not among the four projects visible to the connector under that team.

No project metadata, deployment, domain, log, framework, or environment-variable conclusion can be made from this Vercel connection. The likely explanations are a different team/account, missing connector access, a stale identifier, or an incorrect identifier.

## Readiness conclusion

The archive project has confirmed GitHub and Supabase identities, but neither currently exposes an implemented archive corpus through the inspected surfaces. Notion contains meaningful La Pipa operational and governance history, although the dedicated Surface hub is outside the current integration’s fetch scope. Vercel remains unresolved.

Recommended next steps:

1. Share the La Pipa Surface hub, Operations Hub, and Platform IP page with the connected Notion integration.
2. Confirm the Vercel team or personal account that owns `prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k`.
3. Define and version the archive schema before ingestion: sources, documents, chunks, entities, claims, events, people, organizations, relationships, embeddings, and provenance.
4. Commit migrations and corpus specifications to `alex-lapipa/lapipa.archives` before populating Supabase.
5. Preserve the evidence classes used in the RAG master so first-party documents, user statements, filename-only artifacts, and inferred claims remain distinguishable.
