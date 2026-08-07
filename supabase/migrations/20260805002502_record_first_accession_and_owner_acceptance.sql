begin;

do $$
declare
  owner_user_id constant uuid := '827fa26f-df7f-4d24-9521-0e44bcf37696';
  owner_agent_id bigint;
  repository_agent_id bigint;
  collection_key bigint;
  source_key bigint;
  accession_key bigint;
  package_key bigint;
begin
  -- Accession and preservation evidence must replay independently of production
  -- Auth data. A preview or recovery database may legitimately have no Auth
  -- users; environment-specific authorization evidence remains conditional.
  select id into owner_agent_id
  from archive.agents where agent_id = 'LP-AGENT-ALEX-LAWTON';
  select id into collection_key
  from archive.collections where collection_id = 'LP-ARCHIVE-001';
  select id into source_key
  from kb.sources where source_id = 'LP-SRC-001';

  if owner_agent_id is null or collection_key is null or source_key is null then
    raise exception 'Required owner, collection, or source authority record is missing';
  end if;

  insert into archive.agents (
    agent_id, agent_type, authorized_name, biography_or_history, metadata
  ) values (
    'LP-AGENT-LA-PIPA-REPOSITORY', 'organization', 'La Pipa Documentary Archive',
    'The governed archival repository receiving, preserving, and providing controlled access to La Pipa records.',
    jsonb_build_object('governance_role','repository','evidence_class','system_control_record')
  )
  on conflict (agent_id) do update
  set authorized_name = excluded.authorized_name,
      biography_or_history = excluded.biography_or_history,
      metadata = archive.agents.metadata || excluded.metadata,
      updated_at = now()
  returning id into repository_agent_id;

  insert into archive.accessions (
    accession_id, collection_id, accessioned_at, source_agent_id,
    transfer_method, agreement_reference, extent_statement, appraisal_decision,
    restrictions_note, receipt_confirmed, manifest_sha256, metadata
  ) values (
    'LP-ACC-2026-0001', collection_key, '2026-08-05', owner_agent_id,
    'Owner-designated internal transfer; source inventoried read-only and copied without modification.',
    'Alex Lawton archive-owner directive, 2026-08-05',
    '1 PDF file; 194,031,448 bytes',
    'Accepted as the first pilot submission package because it is the earliest strongly documented La Pipa origin presentation.',
    'Restricted pending rights, sensitivity, malware, managed-storage, and release review.',
    true,
    'ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf',
    jsonb_build_object(
      'source_id','LP-SRC-001',
      'source_filename','LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf',
      'source_modified_at','2020-03-11T02:12:53.000Z',
      'received_state_inventory_sha256','6284c2325f2bf864b853919839b3173686311fd5e3bbd0352d71c100539e245b',
      'stage','submission_package_valid_managed_storage_pending'
    )
  )
  on conflict (accession_id) do update
  set collection_id = excluded.collection_id,
      source_agent_id = excluded.source_agent_id,
      extent_statement = excluded.extent_statement,
      restrictions_note = excluded.restrictions_note,
      receipt_confirmed = excluded.receipt_confirmed,
      manifest_sha256 = excluded.manifest_sha256,
      metadata = archive.accessions.metadata || excluded.metadata
  returning id into accession_key;

  insert into archive.transfer_packages (
    package_id, accession_id, package_type, bagit_version, tag_file_encoding,
    manifest_algorithm, payload_file_count, payload_byte_count, status,
    validation_tool, validated_at, validation_detail
  ) values (
    'LP-BAG-2026-0001', accession_key, 'submission', '1.0', 'UTF-8',
    'sha256', 1, 194031448, 'valid',
    'lapipa-archives validate-bag/1.0', '2026-08-05T00:23:25.348Z',
    jsonb_build_object(
      'valid',true,
      'failures',jsonb_build_array(),
      'payload_oxum','194031448.1',
      'manifest_file_sha256','ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf',
      'managed_storage_status','pending'
    )
  )
  on conflict (package_id) do update
  set accession_id = excluded.accession_id,
      status = excluded.status,
      validated_at = excluded.validated_at,
      validation_detail = excluded.validation_detail,
      updated_at = now()
  returning id into package_key;

  insert into archive.transfer_package_files (
    transfer_package_id, relative_path, payload, byte_count,
    digest_algorithm, digest, ingest_decision, note
  ) values (
    package_key,
    'data/LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf',
    true, 194031448, 'sha256',
    'c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e',
    'accepted',
    'Accepted into the pilot submission package; file-object registration awaits verified managed-storage ingest and malware scan.'
  )
  on conflict (transfer_package_id, relative_path) do update
  set byte_count = excluded.byte_count,
      digest_algorithm = excluded.digest_algorithm,
      digest = excluded.digest,
      ingest_decision = excluded.ingest_decision,
      note = excluded.note;

  insert into archive.custody_events (
    custody_event_id, accession_id, event_at, event_type,
    from_agent_id, to_agent_id, location, note
  ) values (
    'LP-CUSTODY-2026-0001', accession_key, '2026-08-05T00:23:25.348Z', 'received',
    owner_agent_id, repository_agent_id, 'Owner-controlled local accession workspace',
    'Source was inventoried read-only and copied into a validated BagIt submission package. Managed preservation storage is pending.'
  )
  on conflict (custody_event_id) do nothing;

  insert into archive.preservation_events (
    event_id, event_type, event_at, outcome, outcome_detail,
    agent_id, software_agent, command_or_process, event_detail
  ) values (
    'LP-PRESEVENT-2026-0001', 'validation', '2026-08-05T00:23:25.348Z', 'success',
    'BagIt payload, tag manifests, Payload-Oxum, SHA-256, and path-safety checks passed with zero failures.',
    owner_agent_id, 'lapipa-archives validate-bag/1.0',
    'npm run archive:validate-bag -- <controlled-package-path>',
    jsonb_build_object(
      'package_id','LP-BAG-2026-0001',
      'payload_file_count',1,
      'payload_byte_count',194031448,
      'failure_count',0
    )
  )
  on conflict (event_id) do nothing;

  insert into ops.audit_log (
    actor_user_id, actor_role, action, record_type, stable_record_id, details
  )
  select owner_user_id, 'owner', 'owner_database_authorization_accepted',
         'workspace_member', owner_user_id::text,
         jsonb_build_object(
           'owner_role_resolved',true,
           'unknown_subject_denied',true,
           'anonymous_protected_functions_denied',true,
           'authenticated_direct_table_grants',0,
           'archive_tables_with_rls',32,
           'test_date','2026-08-05'
         )
  where not exists (
    select 1 from ops.audit_log
    where action = 'owner_database_authorization_accepted'
      and stable_record_id = owner_user_id::text
  )
    and exists (
      select 1 from kb.workspace_members
      where user_id = owner_user_id and role = 'owner' and active
    );

  insert into ops.audit_log (
    actor_user_id, actor_role, action, record_type, stable_record_id, details
  )
  select (select id from auth.users where id = owner_user_id),
         'owner', 'submission_package_validated',
         'transfer_package', 'LP-BAG-2026-0001',
         jsonb_build_object(
           'accession_id','LP-ACC-2026-0001',
           'source_id','LP-SRC-001',
           'valid',true,
           'managed_storage_pending',true,
           'auth_actor_present', exists (
             select 1 from auth.users where id = owner_user_id
           )
         )
  where not exists (
    select 1 from ops.audit_log
    where action = 'submission_package_validated'
      and stable_record_id = 'LP-BAG-2026-0001'
  );

  update ops.review_tasks
  set reason = 'Validated submission package LP-BAG-2026-0001 is complete. Upload to verified managed storage, run malware and format identification, register file objects, complete rights review, and perform restore validation.',
      status = 'open'
  where review_id = 'LP-REV-FIRST-ACCESSION-2026-001';

  update archive.preservation_assessments
  set results = jsonb_set(
        results, '{integrity}',
        '"pilot_submission_package_valid_managed_copy_pending"'::jsonb, true
      ),
      evidence = evidence || jsonb_build_object(
        'owner_database_authorization_tests_passed',true,
        'pilot_accession_id','LP-ACC-2026-0001',
        'pilot_package_id','LP-BAG-2026-0001',
        'pilot_payload_file_count',1,
        'pilot_payload_byte_count',194031448,
        'pilot_package_validation_failures',0
      ),
      gaps = (
        select coalesce(jsonb_agg(value), '[]'::jsonb)
        from jsonb_array_elements(gaps) value
        where value <> to_jsonb('No archival payload has completed a controlled accession.'::text)
      ) || jsonb_build_array(
        'The pilot submission package is valid, but managed-storage ingest, malware scan, file-object registration, rights review, and restore testing remain pending.'
      )
  where assessment_id = 'LP-ASSESS-2026-0001'
    and not (evidence @> '{"pilot_package_id":"LP-BAG-2026-0001"}'::jsonb);
end $$;

insert into ops.schema_versions (version, description)
values (
  '2026-08-05-accession-v1',
  'First real submission package evidence for LP-ACC-2026-0001 plus database authorization acceptance evidence.'
)
on conflict (version) do nothing;

commit;
