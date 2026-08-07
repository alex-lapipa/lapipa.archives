# Storage and replication plan

## Current truth — 7 August 2026

Supabase in `eu-west-1` is the configured operational object store. Backblaze B2 in `eu-central-003` is now a separately provided, private, encrypted, S3-compatible location whose credential pair, exact bucket, endpoint, privacy mode, encryption metadata, and Object Lock metadata have passed a read-only connection test.

No archive object has yet been copied to Backblaze, fixity-verified there, or restored from it. The B2 location therefore does not yet count as a verified independent preservation copy. Object Lock is disabled and the current broad application key includes delete authority; those controls must be addressed before routine replication.

## Target topology

1. **Operational copy:** Supabase private Storage for managed originals, preservation masters, derivatives, and access workflows.
2. **Independent preservation replica:** geographically separate object or cold storage under a different provider or administrative account, with versioning and object lock where feasible.
3. **Offline or logically isolated copy:** encrypted offline media or isolated cold archive whose credentials and deletion path do not share the operational compromise domain.

The archive records each copy separately. A replicated provider service is not automatically an independent archive copy unless the archive can identify, test, recover, and govern it independently.

## Provider selection criteria

- published durability and availability design;
- geographic region and data-protection jurisdiction;
- immutability or object-lock capability;
- versioning, lifecycle, inventory, checksum, and restore behavior;
- independent identity, credential, billing, and deletion domains;
- egress and bulk-restore time and cost;
- API portability and support for open tooling;
- audit logs and notification capability;
- credible exit path with hashes and metadata intact;
- environmental and cost sustainability over at least five years.

Backblaze B2 is selected for the first independent online preservation pilot because it is outside the Supabase provider domain, exposes interoperable S3 and native APIs, supports open tooling, and can support versioning and Object Lock when configured appropriately. Selection does not by itself establish preservation success.

## Copy evidence

`archive.storage_locations` records the provider, role, administrative domain, region, medium, lock state, encryption state, evidence state, last test, and recovery notes. `archive.file_copies` records each file’s location, storage version, expected and observed SHA-256, bytes, copy state, and next verification date.

## Verification schedule

- At copy: verify every file against the source SHA-256.
- Quarterly: verify a risk-weighted sample of preservation masters from each location.
- Annually: verify all preservation masters when cost and scale permit, otherwise document a statistically and risk-based coverage plan.
- After any migration, provider incident, unexpected restore, credential event, or lifecycle-policy change: verify affected scope.
- Every quarter: restore a sample into quarantine and compare bytes and usability; a metadata listing is not a restore test.

## Key management

Provider credentials remain in the owning platform’s secrets facility, never Notion, GitHub, Vercel browser code, RAG chunks, logs, or release packages. Use distinct scoped identities for copying, verification, restoration, and deletion where supported. Deletion authority should require stronger control than read or replication authority.

The current Backblaze credential is stored only in Supabase Edge Function secrets. The old Database Vault copies were deleted after replacement. The retained connection-status function never returns credential material and is protected by both Supabase JWT verification and the La Pipa workspace role check.

## Approved pilot and pending preservation decisions

The archive owner approved proceeding with Backblaze B2 as the initial independent-storage pilot. The sanitized verification record is [Backblaze preservation-storage verification — 7 August 2026](backblaze-preservation-verification-2026-08-07.md).

Before production replication, the owner must still approve the final bucket, versioning and Object Lock design, retention period, annual cost ceiling, recovery owner, and break-glass process. The routine replication and verification keys should be bucket-scoped and should not have delete authority. The pilot must complete upload, fixity, restore, and evidence-recording gates before it is counted toward the three-copy target.
