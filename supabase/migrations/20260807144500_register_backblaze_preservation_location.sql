begin;

insert into archive.storage_locations (
  location_id,
  name,
  provider,
  service_type,
  role,
  administrative_domain,
  geographic_region,
  media_or_storage_class,
  online,
  immutable_or_object_locked,
  encrypted_at_rest,
  active,
  evidence_status,
  last_tested_at,
  recovery_notes,
  metadata
) values (
  'LP-LOC-B2-EUC3-001',
  'Backblaze B2 independent preservation replica',
  'Backblaze',
  'object_storage',
  'replica',
  'Backblaze B2 account external to the Supabase operational domain',
  'eu-central-003',
  'B2 always-hot object storage',
  true,
  false,
  true,
  true,
  'tested',
  '2026-08-07T14:37:34.225Z'::timestamptz,
  'Credential authorization, exact-bucket visibility, endpoint agreement, privacy mode, S3 compatibility, encryption metadata, and Object Lock metadata were tested without reading or changing objects. No archive object has yet been copied, fixity-verified, or restored here. Object Lock is disabled, and the current application key has delete authority; use separate least-privilege replication and verification identities before routine automation.',
  jsonb_build_object(
    'bucket_name', 'miramonte-lapipa-preservation-pilot',
    'bucket_type', 'allPrivate',
    's3_compatible', true,
    's3_endpoint_host', 's3.eu-central-003.backblazeb2.com',
    'default_server_side_encryption', jsonb_build_object(
      'readable', true,
      'enabled', true,
      'algorithm', 'AES256',
      'mode', 'SSE-B2'
    ),
    'object_lock', jsonb_build_object(
      'readable', true,
      'enabled', false,
      'default_retention_mode', null,
      'default_retention_period', null
    ),
    'credential_store', 'Supabase Edge Function secrets',
    'credential_scope', jsonb_build_object(
      'bucket_restricted', false,
      'name_prefix_restricted', false,
      'delete_capability', true
    ),
    'verification_scope', jsonb_build_array(
      'b2_authorize_account_v4',
      'b2_list_buckets_v4_exact_name',
      'endpoint_host_comparison',
      'bucket_control_metadata'
    ),
    'object_operations_performed', false,
    'fixity_test_performed', false,
    'restore_test_performed', false,
    'verification_date', '2026-08-07'
  )
)
on conflict (location_id) do update set
  name = excluded.name,
  provider = excluded.provider,
  service_type = excluded.service_type,
  role = excluded.role,
  administrative_domain = excluded.administrative_domain,
  geographic_region = excluded.geographic_region,
  media_or_storage_class = excluded.media_or_storage_class,
  online = excluded.online,
  immutable_or_object_locked = excluded.immutable_or_object_locked,
  encrypted_at_rest = excluded.encrypted_at_rest,
  active = excluded.active,
  evidence_status = excluded.evidence_status,
  last_tested_at = excluded.last_tested_at,
  recovery_notes = excluded.recovery_notes,
  metadata = excluded.metadata,
  updated_at = now();

insert into archive.preservation_events (
  event_id,
  event_type,
  event_at,
  outcome,
  outcome_detail,
  agent_id,
  software_agent,
  command_or_process,
  event_detail
) values (
  'LP-EVENT-B2-CONNECTION-2026-08-07-001',
  'validation',
  '2026-08-07T14:37:34.225Z'::timestamptz,
  'success',
  'Read-only provider authorization and exact-bucket metadata validation succeeded. This event does not assert that an archival object was replicated, fixity-checked, or restored.',
  (select id from archive.agents where agent_id = 'LP-AGENT-LA-PIPA-REPOSITORY' limit 1),
  'b2-preservation-status/1.0',
  'Backblaze B2 Native API v4 authorization and exact-name bucket lookup',
  jsonb_build_object(
    'storage_location_id', 'LP-LOC-B2-EUC3-001',
    'result', 'connection_and_bucket_controls_verified',
    'private_bucket', true,
    's3_endpoint_match', true,
    'server_side_encryption_enabled', true,
    'object_lock_enabled', false,
    'broad_delete_capability_observed', true,
    'objects_read', false,
    'objects_written', false,
    'temporary_bootstrap_functions_removed', true
  )
)
on conflict (event_id) do update set
  event_at = excluded.event_at,
  outcome = excluded.outcome,
  outcome_detail = excluded.outcome_detail,
  agent_id = excluded.agent_id,
  software_agent = excluded.software_agent,
  command_or_process = excluded.command_or_process,
  event_detail = excluded.event_detail;

commit;
