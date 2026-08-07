# Initial preservation assessment — LP-ASSESS-2026-0001

Framework: NDSA Levels of Digital Preservation 2.1
Assessment date: 2026-08-05
Next assessment due: 2026-11-05
Scope: La Pipa Documentary Archive foundation and operating controls

## Overall finding

Preservation maturity is **not yet demonstrated** because no archival payload has completed the controlled accession workflow. The project has strong policy, schema, access-control, provenance, package, and quality-gate foundations, but controls without operating evidence are not counted as achieved preservation levels.

## Evidence established

- 32 private documentary archive tables; RLS enabled on all 32.
- Zero direct `authenticated` table grants in the archive schema.
- Zero archive foreign-key indexing gaps reported by the live performance advisor.
- Five private Storage buckets with membership policies.
- One configured Supabase operational storage location.
- Zero tested independent preservation locations, recorded explicitly.
- A BagIt 1.0 SHA-256 package creator, payload/tag validator, and read-only source inventory tool with automated tests.
- A valid first submission package, `LP-BAG-2026-0001`: one 2019 origin-deck PDF, 194,031,448 bytes, with zero validation failures.
- Transfer-package, file-copy, derivative-lineage, consent, takedown, quality-control, release, and assessment records.
- Twenty-three controlled documentary archive documents synchronized across GitHub and the official Notion knowledge base.
- Thirty-five reviewed knowledge sources and nineteen contextual Voyage embeddings with provenance links.

## Category findings

### Storage

Not yet demonstrated. One operational storage service is configured. No geographically and administratively independent replica or isolated copy has been configured, copied, verified, and restored.

### Integrity

Pilot package, malware, and format evidence established; managed-copy evidence pending. SHA-256, fixity checks, package manifests, preservation events, copy verification, and failure states are modeled and tested. One real source file has been inventoried read-only, packaged successfully, scanned with current official malware signatures, and structurally validated with documented recoverable warnings; managed-storage ingest, file-object registration, independent copying, and restoration remain outstanding.

### Control

Owner bootstrap complete; interactive acceptance pending. Alex Lawton is bound by immutable confirmed Auth UUID to the active `owner` role. Roles, private schemas, RLS, restricted functions, private buckets, release approval, and takedown records exist. Database-level role tests are required for every authorization change; interactive sign-in, recovery, and session tests remain incomplete.

### Metadata

Schema implemented; item-level evidence pending. PREMIS-aligned preservation metadata, PBCore-aligned audiovisual metadata, descriptive records, provenance, rights, and RAG metadata exist structurally. Real archival items have not yet passed completeness review.

### Content

Policy documented; operating evidence pending. Format characterization, original retention, derivative lineage, accessibility, migration, and risk review are specified. Representative image, audio, video, transcript, and compound objects have not yet been processed and restored.

## Priority gaps

1. Complete Alex Lawton's interactive sign-in, recovery, and session acceptance tests; designate a backup administrator.
2. Ingest validated `LP-BAG-2026-0001` into managed storage, register its file object, and complete rights and restore review.
3. Select and configure an independent preservation replica with owner-approved cost and jurisdiction.
4. Establish an offline or logically isolated copy.
5. Run and record sample restore tests.
6. Complete one audiovisual/oral-history pilot with consent and accessibility evidence.
7. Complete a controlled research release and takedown exercise before public release.

## Assessment rule

The next assessment may credit only controls supported by dated records, verified copies, fixity results, restore results, reviewed metadata, access tests, or approved releases. Documentation of intent is valuable evidence of governance but is not treated as evidence that an operational preservation level has been achieved.

## Reference

- [NDSA Levels of Digital Preservation 2.1](https://www.ndsa.org/publications/levels-of-digital-preservation/)
