# Implementation status — 7 August 2026

## Supabase

- Project: `jxilnxchvdeiazmopslf` (`LA PIPA ARCHIVE`)
- Schemas: `archive` (32 preservation and documentary-control tables), `kb` (15), `kg` (3), `rag` (5), `ops` (6), plus private authorization helpers.
- Reviewed seed: 35 sources, 9 claims, 14 entities, 9 events, 11 relationships, 19 chunks, and 8 evaluation questions.
- Voyage: 19 contextual embeddings using `voyage-context-4` at 1,024 dimensions.
- Website accession `LP-ACC-2026-0002` is live and reconciled: 52 current pages, 55 legacy export records, 117 external-media records, 26 captured YouTube transcripts, 224 archive items, and 327 deterministic chunks. All 327 chunks have content-hash-matching `voyage-context-4` embeddings at 1,024 dimensions; zero are missing or stale. The tightly bounded one-time trigger was deleted immediately after success, and the accession-specific service-role RPCs are removed by the finalization migration.
- Storage: `source-originals`, `source-derivatives`, `knowledge-exports`, `preservation-masters`, and `access-media`; all private.
- Provenance validation: zero chunks without sources and zero claims without sources.
- RLS validation: enabled on every archive table.
- Direct authenticated table grants: zero; access is through a minimal checked RPC surface.
- Edge Functions: `kb-search`, `kb-embed`, and `b2-preservation-status`, all active with JWT verification. The Backblaze function also requires an active La Pipa `owner` or `editor` role and returns only sanitized control metadata.
- Identity governance: `kb.authorized_identities` privately records pre-authorization, immutable Auth binding, and sign-in evidence as separate states. Both Alex Lawton identities are confirmed, active owners and currently `bound_confirmed`; neither had signed in at verification.
- Temporary bootstrap function and temporary bootstrap secret: removed after the controlled embedding seed.
- Documentary archive: LP-MAP 1.0 collection hierarchy, item, representation, file, AV track, transcript, rights, PREMIS-style event, fixity, accession, and custody structures are implemented. The root archival control record is `LP-ARCHIVE-001`.
- Operating controls: BagIt transfer packages, preservation-copy locations, source-to-derivative lineage, consent, takedown, quality gates, approved releases, and preservation assessments are implemented. Supabase is registered as the operational location. Backblaze B2 location `LP-LOC-B2-EUC3-001` passed read-only credential, exact-bucket, endpoint, privacy, S3, encryption, and Object Lock metadata checks on 7 August 2026. No object has yet been copied, fixity-verified, or restored there, so it is not yet counted as a verified preservation copy.
- Backblaze controls: bucket `miramonte-lapipa-preservation-pilot` is private and encrypted at rest in `eu-central-003`; Object Lock is disabled. The current deliberately broad key is unrestricted and includes delete authority. Production replication requires bucket-scoped non-delete identities plus a recorded pilot copy, fixity check, and restore.
- First accession evidence: `LP-ACC-2026-0001` and valid BagIt submission package `LP-BAG-2026-0001` contain the 2019 origin-deck PDF (1 file; 194,031,448 bytes). Managed-storage ingest, malware scanning, file-object registration, rights review, independent replication, and restore testing remain pending.
- Repository assurance: locked Node 24 build, dependency audit, archive tooling tests, local-link and migration validation, pinned GitHub Actions, Dependabot, and a preservation-aware pull-request checklist.
- Preservation assessment: `LP-ASSESS-2026-0001` records a conservative NDSA Levels 2.1 baseline. No maturity level is claimed because no real archival payload, independent replica, isolated copy, or restore test has yet completed the workflow.

The remaining security-advisor warning is Supabase Auth leaked-password protection. It is a plan/dashboard setting and should be enabled before password-based user onboarding if the project plan supports it. New-database unused-index notices are expected until representative workloads exercise the indexes. The Auth connection-allocation notice matters only when scaling compute.

## Vercel

- Project: `prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k` (`lapipa-archives`).
- Team: `team_mNSOnF2OglXKmaAA6GfrQ489` (`LA PIPA IS LA PIPA`).
- The project retains only `SUPABASE_URL` in Production and Development.
- Automatically provisioned database passwords, service-role keys, secret keys, JWT secrets, anonymous/publishable keys, and browser-prefixed copies were removed because this proxy does not need them.
- Voyage remains configured only in Supabase.
- The archive interface now presents the La Pipa Documentary Archive itself—identity, place, origin evidence, activities, chronology, collection scale, first accession, and method—rather than inherited website-mock-up content.
- Preview is deployed from the implementation branch and must not be promoted until interactive authentication and release acceptance are complete.

## Access bootstrap

Alex Lawton explicitly declared archive ownership. Both `alex@rmtv.io` and `lawton.alex@gmail.com` are confirmed Auth identities, reconciled by immutable `auth.users.id`, privately pre-authorized, and assigned the active `owner` role in `kb.workspace_members`; editable user metadata is not used for authorization. Both had zero sessions and no `last_sign_in_at` at verification, so the archive does not claim either is signed in. Owner/editor users can run embeddings and owner/editor/reviewer/reader users can search. Interactive sign-in, recovery, session refresh, and client acceptance tests remain pending.
