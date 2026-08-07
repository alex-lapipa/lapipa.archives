# Source boundary and deduplication control

Document ID: LP-DOC-ARCH-027  
Effective date: 8 August 2026  
Owner: Alex Lawton  
Status: controlled draft

## Purpose

The La Pipa Documentary Archive may receive material from mixed personal, company, client, cloud, and removable-storage environments. Physical proximity does not establish archival relevance. Every source must pass an explicit scope decision before hashing, copying, preservation ingest, RAG processing, or deletion review.

## Authoritative platform boundary

- GitHub: `alex-lapipa/lapipa.archives`
- Supabase: `jxilnxchvdeiazmopslf`
- Vercel: `prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k`

The committed policy at `config/archive-scope-policy.json` is loaded automatically by the inventory and BagIt packaging tools. A platform-identity mismatch or excluded path causes the operation to fail closed.

## Explicit Vumi exclusion

Vumi is an unrelated Remotive Media client and is not part of La Pipa. Any path containing `vumi`, case-insensitively, is rejected before file hashing or copying. It must not enter an accession manifest, BagIt package, Backblaze object, Supabase record, Voyage embedding, RAG chunk, Notion page, Vercel deployment, or space-reclamation proposal.

The exclusion is an archive-scope decision, not a disposition authority. No Vumi source is renamed, moved, altered, or deleted by the La Pipa workflow.

## Deduplication model

Deduplication is content-addressed and provenance-preserving:

1. record the offered source occurrence and its original location;
2. calculate SHA-256 only after scope acceptance;
3. resolve an exact digest and byte-count match to one canonical file object;
4. retain every source occurrence as a separate custody/provenance record;
5. store one canonical preservation payload per preservation location unless an intentional independent safety copy is required;
6. preserve meaningful versions, encodings, resolutions, edits, and derivatives as related but distinct representations;
7. send perceptual or semantic similarity matches to owner review rather than deleting them automatically.

Filename equality is never sufficient for deduplication. A different digest is a different file. An identical digest does not erase the evidence that the same bytes existed in multiple folders, devices, accounts, or provider versions.

Inventory manifests record the original input path and the controlling platform scope. `npm run archive:reconcile` compares two or more inventories, preserves every occurrence, selects a deterministic canonical occurrence for reporting, and calculates potential space recovery. Its reports always set `source_deletion_authorized` to `false`.

## Space reclamation gate

No source copy is eligible for removal merely because it was identified as a duplicate. A future disposition report must identify the exact source occurrence, canonical preserved object, independent verified copies, latest fixity result, successful restore evidence, rights and retention constraints, expected space recovered, and owner decision. Deletion remains prohibited until Alex Lawton approves the specific disposition.
