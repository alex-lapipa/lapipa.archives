# Continuity and disaster recovery

## Recovery priorities

1. Human safety and legal obligations.
2. Preservation masters, originals, accession evidence, rights and consent records.
3. Database records, identifiers, provenance, fixity, and audit history.
4. Policies, migrations, functions, configuration, and controlled vocabularies.
5. Access derivatives, embeddings, caches, and the public interface.

Embeddings and thumbnails are reproducible. Originals, consent evidence, undocumented custody context, and unique descriptive knowledge may not be.

## Required backups

- Automated database backups with a retention period appropriate to the project plan.
- Version-controlled code and documentation in GitHub with protected main branch and reviewed releases.
- Exported metadata and manifests in a separate storage failure domain.
- At least two additional preservation copies outside the operational object store, one geographically separate and one offline or logically isolated.
- Secure recovery information for platform ownership that does not place secret values in the archive.

## Testing

Test database restoration, object recovery, checksum verification, application redeployment, identity and role recovery, and domain recovery at least annually. Sample object restores occur quarterly once preservation masters are ingested. Record test scope, sample, elapsed time, errors, fixes, and approver.

## Recovery objectives

Targets must be approved after holdings and operating needs are known. Initial planning targets are 24-hour recovery time for catalog and restricted discovery, 72 hours for priority access derivatives, and zero accepted data loss for accessioned preservation masters after ingest confirmation. These are targets, not proven service levels, until tests demonstrate them.

## Incident response

On suspected corruption, unauthorized access, credential exposure, accidental deletion, or rights breach: contain without destroying evidence; record the incident time and scope; preserve relevant logs; rotate or revoke affected credentials through the owning platform; assess affected records and people; restore only from verified copies; document decisions and notifications; and complete a post-incident review.

## Exit and portability

The archive must remain exportable without a proprietary application. Periodic exports use open formats, stable identifiers, checksums, and documented relationships. A platform exit plan covers Supabase database and Storage export, Notion editorial export, Git repository transfer, Vercel domain and deployment handoff, and Voyage-derived data regeneration.

