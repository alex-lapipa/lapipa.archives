# Implementation status — 5 August 2026

## Supabase

- Project: `jxilnxchvdeiazmopslf` (`LA PIPA ARCHIVE`)
- Schemas: `archive` (21 preservation and documentary-control tables), `kb` (15), `kg` (3), `rag` (5), `ops` (6), plus private authorization helpers.
- Reviewed seed: 35 sources, 9 claims, 14 entities, 9 events, 11 relationships, 19 chunks, and 8 evaluation questions.
- Voyage: 19 contextual embeddings using `voyage-context-4` at 1,024 dimensions.
- Storage: `source-originals`, `source-derivatives`, `knowledge-exports`, `preservation-masters`, and `access-media`; all private.
- Provenance validation: zero chunks without sources and zero claims without sources.
- RLS validation: enabled on every archive table.
- Direct authenticated table grants: zero; access is through a minimal checked RPC surface.
- Edge Functions: `kb-search` and `kb-embed`, both active with JWT verification.
- Temporary bootstrap function and temporary bootstrap secret: removed after the controlled embedding seed.
- Documentary archive: LP-MAP 1.0 collection hierarchy, item, representation, file, AV track, transcript, rights, PREMIS-style event, fixity, accession, and custody structures are implemented. The root archival control record is `LP-ARCHIVE-001`.

The remaining security-advisor warning is Supabase Auth leaked-password protection. It is a plan/dashboard setting and should be enabled before password-based user onboarding if the project plan supports it. New-database unused-index notices are expected until representative workloads exercise the indexes. The Auth connection-allocation notice matters only when scaling compute.

## Vercel

- Project: `prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k` (`lapipa-archives`).
- Team: `team_mNSOnF2OglXKmaAA6GfrQ489` (`LA PIPA IS LA PIPA`).
- The project retains only `SUPABASE_URL` in Production and Development.
- Automatically provisioned database passwords, service-role keys, secret keys, JWT secrets, anonymous/publishable keys, and browser-prefixed copies were removed because this proxy does not need them.
- Voyage remains configured only in Supabase.
- Preview is deployed from the implementation branch and must not be promoted until authentication and membership are established.

## Access bootstrap

No user identity was guessed or silently granted ownership. After the intended owner signs into Supabase Auth, an authorized database administrator must insert that exact `auth.users.id` into `kb.workspace_members` with role `owner`. Thereafter, owner/editor users can run embeddings and owner/editor/reviewer/reader users can search.
