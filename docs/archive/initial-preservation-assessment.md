# Initial preservation assessment — LP-ASSESS-2026-0001

Framework: NDSA Levels of Digital Preservation 2.1
Assessment date: 2026-08-05
Next assessment due: 2026-11-05
Scope: La Pipa Documentary Archive foundation and operating controls, including one fixity-controlled accession replicated to and restored from independent object storage

## Overall finding

Preservation maturity is **partially demonstrated**. One real archival payload has completed controlled packaging, malware and format validation, managed ingest, independent online replication, five SHA-256 checks, and a clean restore. This is operating evidence for the pilot scope, not a claim of repository certification or full collection-wide preservation maturity.

## Evidence established

- 32 private documentary archive tables; RLS enabled on all 32.
- Zero direct `authenticated` table grants in the archive schema.
- Zero archive foreign-key indexing gaps reported by the live performance advisor.
- Five private Storage buckets with membership policies.
- One configured Supabase operational storage location.
- One tested independent online preservation location: Backblaze B2 `LP-LOC-B2-EUC3-001` in `eu-central-003`.
- A BagIt 1.0 SHA-256 package creator, payload/tag validator, and read-only source inventory tool with automated tests.
- An ingested first submission package, `LP-BAG-2026-0001`: one 2019 origin-deck PDF plus four BagIt control files, 194,032,057 bytes total, with zero BagIt failures.
- One restricted review-stage item, two representations, five file objects, five encrypted Backblaze versions, and five verified copy records.
- Five passing SHA-256 records plus successful replication, restore, and ingest events dated 7 August 2026.
- Transfer-package, file-copy, derivative-lineage, consent, takedown, quality-control, release, and assessment records.
- Twenty-four controlled documentary archive documents synchronized across GitHub and the official Notion knowledge base.
- 261 knowledge sources and 351 active contextual Voyage embeddings with zero chunk-source gaps, including four restricted preservation-evidence chunks for this ingest.

## Category findings

### Storage

Partially demonstrated. The first independent online replica has been copied, versioned, fixity-checked, and restored from Backblaze B2. Every pilot object reported AES-256 server-side encryption and a distinct version ID. An offline or logically isolated third copy is not yet configured; Object Lock is disabled; and the broad setup credential must be replaced with separated least-privilege identities before routine automation.

### Integrity

Pilot ingest, fixity, and restore evidence established. One real source file was inventoried read-only, packaged, scanned with current official malware signatures, structurally validated with documented recoverable warnings, copied to Backblaze, downloaded completely, SHA-256 verified, and BagIt-validated after restoration. The next verification is due 5 November 2026. Collection-wide sampling, automated alerting, and a logically isolated copy remain outstanding.

### Control

Owner bootstrap complete; interactive acceptance pending. Alex Lawton is bound by immutable confirmed Auth UUID to the active `owner` role. Roles, private schemas, RLS, restricted functions, private buckets, release approval, and takedown records exist. Database-level role tests are required for every authorization change; interactive sign-in, recovery, and session tests remain incomplete.

### Metadata

Item, representation, file, copy, fixity, event, rights, and source records are operational for the first pilot item. PREMIS-aligned preservation metadata, PBCore-aligned audiovisual metadata, descriptive records, provenance, rights, and RAG metadata exist structurally. The pilot item remains at review status because sensitivity, accessibility, privacy, consent, citation, and publication checks are not complete.

### Content

PDF operating evidence exists for original retention, format characterization, malware validation, independent copying, fixity, and restoration. Representative image, audio, video, transcript, and compound objects have not yet completed the same workflow. Accessibility, migration, and format-risk responses remain documented controls rather than collection-wide operating evidence.

## Priority gaps

1. Complete Alex Lawton's interactive sign-in, recovery, and session acceptance tests; designate a backup administrator.
2. Approve Object Lock and retention policy, then replace the broad setup credential with separated least-privilege replication, verification, and deletion identities.
3. Establish an offline or logically isolated third copy.
4. Run the next recorded Backblaze fixity and restore sample by 5 November 2026.
5. Complete one audiovisual/oral-history pilot with consent and accessibility evidence.
6. Complete sensitivity, privacy, consent, accessibility, citation, and owner-approved publication review for `LP-ITEM-2026-0001`.
7. Complete a controlled research release and takedown exercise before public release.

## Assessment rule

The next assessment may credit only controls supported by dated records, verified copies, fixity results, restore results, reviewed metadata, access tests, or approved releases. Documentation of intent is valuable evidence of governance but is not treated as evidence that an operational preservation level has been achieved.

## Reference

- [NDSA Levels of Digital Preservation 2.1](https://www.ndsa.org/publications/levels-of-digital-preservation/)
