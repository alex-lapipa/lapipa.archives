begin;

insert into archive.preservation_assessments (
  assessment_id, framework, framework_version, assessment_date, scope, assessor,
  results, evidence, gaps, next_assessment_due
) values (
  'LP-ASSESS-2026-0001',
  'NDSA Levels of Digital Preservation',
  '2.1',
  '2026-08-05',
  'La Pipa Documentary Archive foundation and operating controls; no archival payload accessioned yet.',
  'Codex evidence audit',
  jsonb_build_object(
    'overall','not_yet_demonstrated',
    'storage','not_yet_demonstrated',
    'integrity','controls_implemented_no_holdings_evidence',
    'control','controls_implemented_owner_bootstrap_pending',
    'metadata','schema_implemented_item_level_evidence_pending',
    'content','format_policy_documented_operating_evidence_pending'
  ),
  jsonb_build_object(
    'archive_tables',32,
    'archive_tables_with_rls',32,
    'authenticated_archive_table_grants',0,
    'operational_storage_locations',1,
    'tested_independent_preservation_locations',0,
    'private_storage_buckets',5,
    'reviewed_sources',35,
    'contextual_embeddings',19,
    'repository_commit_status','draft_pull_request'
  ),
  jsonb_build_array(
    'No archival payload has completed a controlled accession.',
    'No intended owner identity is present in kb.workspace_members.',
    'No geographically and administratively independent preservation replica is configured and tested.',
    'No offline or logically isolated preservation copy is configured and tested.',
    'No restoration exercise has produced operating evidence.',
    'No public release has completed rights, consent, accessibility, citation, and withdrawal gates.'
  ),
  '2026-11-05'
)
on conflict (assessment_id) do nothing;

insert into ops.schema_versions (version, description)
values ('2026-08-05-assessment-v1', 'Initial conservative NDSA Levels 2.1 evidence baseline; no maturity level claimed without operating evidence.');

commit;
