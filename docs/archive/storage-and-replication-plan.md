# Storage and replication plan

## Current truth

Supabase in `eu-west-1` is the configured operational object store. It is private and access-controlled, but it is one provider and one administrative failure domain. It must not be described as a complete preservation strategy.

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

No provider is selected merely because it is convenient or already connected.

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

## Pending owner decision

An external preservation location will create cost and a new security relationship. The archive owner must approve the provider, region, retention, object-lock period, annual cost ceiling, responsible account, and recovery owner before configuration.
