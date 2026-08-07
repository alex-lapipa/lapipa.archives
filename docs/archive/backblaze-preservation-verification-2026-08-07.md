# Backblaze preservation-storage verification — 7 August 2026

- Record ID: `LP-EVENT-B2-CONNECTION-2026-08-07-001`
- Storage location: `LP-LOC-B2-EUC3-001`
- Document ID: `LP-DOC-ARCH-022`
- Outcome: connection and bucket-control validation passed; preservation-copy acceptance remains pending

## Purpose

This record documents the first non-destructive verification of Backblaze B2 as an independent online preservation location for the La Pipa Documentary Archive. It separates proof that the account, key, endpoint, and bucket configuration work from later proof that archive bytes have been replicated, fixity-checked, and restored.

## Verified evidence

At `2026-08-07T14:37:34.225Z`, a disposable Supabase Edge Function used the current server-side secrets to perform two read-only Backblaze Native API v4 operations: account authorization and an exact-name bucket lookup. The response was sanitized before it left the function. Account IDs, bucket IDs, application-key identifiers, application-key values, authorization tokens, and object listings were neither returned nor recorded.

The check established:

- the replacement application-key ID and application-key value form a valid credential pair;
- the configured bucket `miramonte-lapipa-preservation-pilot` exists and is visible to the key;
- the configured and provider-reported S3 endpoint hosts match at `s3.eu-central-003.backblazeb2.com`;
- the provider region identifier is `eu-central-003`;
- the bucket is `allPrivate` and S3-compatible;
- default server-side encryption is enabled with `AES256` / `SSE-B2`;
- Object Lock metadata was readable and Object Lock is disabled;
- the current key is not restricted to a bucket or filename prefix and includes read, write, and delete capabilities.

The discovery and bootstrap functions were randomly named, invoked once for their bounded purpose, and deleted immediately. The retained `b2-preservation-status` function requires Supabase JWT verification and an active La Pipa `owner` or `editor` workspace role.

## Evidence boundary

This is a successful configuration and connectivity test, not a successful replication or recovery test. No archive object was listed, read, uploaded, overwritten, deleted, fixity-checked, or restored. No `archive.file_copies` row should be created until a named object has been copied and its observed SHA-256 matches the source digest.

The location is therefore recorded as a tested preservation *location*, but it does not yet count as a verified preservation *copy*. Geographic and provider separation have been established at the service level; deletion-domain independence has not, because the active key currently has delete authority and Object Lock is disabled.

## Required next controls

Before routine transfer automation:

1. create separate bucket-scoped application keys for replication and verification;
2. omit `deleteFiles` from the routine replication and verification identities;
3. decide whether to enable Object Lock on the existing bucket and configure an approved default retention policy; enabling the bucket feature is irreversible even though retention is configured separately;
4. preserve a separately controlled break-glass recovery identity;
5. upload one approved pilot object under a deterministic archive key;
6. compare source and replica SHA-256 digests and record the result in `archive.file_copies` and `archive.fixity_checks`;
7. restore the pilot into quarantine, validate its digest and usability, and record a `restore` preservation event;
8. only then promote the location from connection-ready to an accepted preservation replica in operational reporting.

## Authoritative provider references

- [Backblaze B2 v4 account authorization](https://www.backblaze.com/apidocs/b2-authorize-account)
- [Backblaze B2 v4 bucket listing](https://www.backblaze.com/apidocs/b2-list-buckets)
- [Backblaze application-key capabilities](https://www.backblaze.com/docs/cloud-storage-application-key-capabilities)
- [Backblaze B2 Object Lock](https://www.backblaze.com/docs/cloud-storage-object-lock)
