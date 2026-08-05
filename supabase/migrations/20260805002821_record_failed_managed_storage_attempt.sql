begin;

do $$
declare
  owner_user_id constant uuid := '827fa26f-df7f-4d24-9521-0e44bcf37696';
  owner_agent_id bigint;
begin
  if not exists (
    select 1 from kb.workspace_members
    where user_id = owner_user_id and role = 'owner' and active
  ) then
    raise notice 'Archive owner is absent in this environment; upload-attempt evidence skipped.';
    return;
  end if;

  select id into owner_agent_id
  from archive.agents where agent_id = 'LP-AGENT-ALEX-LAWTON';

  insert into archive.preservation_events (
    event_id, event_type, event_at, outcome, outcome_detail,
    agent_id, software_agent, command_or_process, event_detail
  ) values (
    'LP-PRESEVENT-2026-0002', 'ingest', '2026-08-05T00:27:00Z', 'failure',
    'Standard Storage upload rejected the 194,031,448-byte payload with HTTP 413 EntityTooLarge. Three partial tag objects were enumerated and removed; the remote accession prefix was verified empty. The local validated package remains intact.',
    owner_agent_id, 'Supabase CLI 2.106.0 storage cp',
    'Credential-safe linked-project upload attempt; no credential values handled.',
    jsonb_build_object(
      'package_id','LP-BAG-2026-0001',
      'bucket','preservation-masters',
      'http_status',413,
      'error_code','EntityTooLarge',
      'cleanup_complete',true,
      'remote_prefix_empty_after_cleanup',true,
      'required_next_method','tus_resumable_or_s3_multipart'
    )
  )
  on conflict (event_id) do nothing;

  update archive.transfer_packages
  set validation_detail = validation_detail || jsonb_build_object(
        'managed_upload_attempt','failed_entity_too_large',
        'failed_upload_cleanup_complete',true,
        'remote_prefix_empty_after_cleanup',true,
        'required_upload_method','tus_resumable_or_s3_multipart'
      ),
      updated_at = now()
  where package_id = 'LP-BAG-2026-0001';

  insert into ops.audit_log (
    actor_user_id, actor_role, action, record_type, stable_record_id, details
  )
  select owner_user_id, 'owner', 'managed_upload_failed_and_cleaned',
         'transfer_package', 'LP-BAG-2026-0001',
         jsonb_build_object(
           'error_code','EntityTooLarge',
           'partial_tag_objects_removed',3,
           'remote_prefix_empty_after_cleanup',true,
           'local_package_intact',true,
           'credential_values_handled',false
         )
  where not exists (
    select 1 from ops.audit_log
    where action = 'managed_upload_failed_and_cleaned'
      and stable_record_id = 'LP-BAG-2026-0001'
  );

  update ops.review_tasks
  set reason = 'Validated package LP-BAG-2026-0001 requires a TUS resumable or S3 multipart upload because the standard CLI upload returned HTTP 413 for the 194 MB payload. Use a real owner session or securely provisioned storage credential; never expose credential values. Then run post-upload SHA-256, malware, format, rights, and restore checks.'
  where review_id = 'LP-REV-FIRST-ACCESSION-2026-001';

  update archive.preservation_assessments
  set evidence = evidence || jsonb_build_object(
        'pilot_standard_upload_attempt','failed_entity_too_large',
        'pilot_failed_upload_cleanup_complete',true,
        'pilot_remote_prefix_empty_after_cleanup',true
      )
  where assessment_id = 'LP-ASSESS-2026-0001';
end $$;

insert into ops.schema_versions (version, description)
values (
  '2026-08-05-accession-upload-attempt-v1',
  'Evidence for the failed standard upload, exact cleanup, intact local package, and required resumable or multipart next path.'
)
on conflict (version) do nothing;

commit;
