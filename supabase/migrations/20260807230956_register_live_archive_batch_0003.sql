begin;

do $$
declare
  owner_agent_key bigint;
  repository_agent_key bigint;
  collection_key bigint;
  accession_key bigint;
  package_key bigint;
  item_key bigint;
  original_representation_key bigint;
  metadata_representation_key bigint;
  location_key bigint;
  fixity_event_key bigint;
begin
  select id into owner_agent_key
  from archive.agents
  where agent_id = 'LP-AGENT-ALEX-LAWTON';

  select id into repository_agent_key
  from archive.agents
  where agent_id = 'LP-AGENT-LA-PIPA-REPOSITORY';

  select id into collection_key
  from archive.collections
  where collection_id = 'LP-ARCHIVE-001';

  if owner_agent_key is null or repository_agent_key is null or collection_key is null then
    raise exception 'Required La Pipa owner, repository, or collection record is absent';
  end if;

  insert into archive.storage_locations (
    location_id, name, provider, service_type, role,
    administrative_domain, geographic_region, media_or_storage_class,
    online, immutable_or_object_locked, encrypted_at_rest, active,
    evidence_status, last_tested_at, recovery_notes, metadata
  ) values (
    'LP-LOC-B2-EUC3-002',
    'Backblaze B2 live La Pipa archive',
    'Backblaze',
    'object_storage',
    'operational',
    'Miramonte, S.L. Backblaze account',
    'eu-central-003',
    'B2 hot object storage',
    true,
    false,
    true,
    true,
    'tested',
    '2026-08-07T23:08:30Z',
    'Eight objects were uploaded, read back, SHA-256 compared, and restored successfully. The bucket is private and AES-256 encrypted. Object Lock and default retention are disabled.',
    jsonb_build_object(
      'bucket', 'miramonte-lapipa-archive',
      'endpoint_host', 's3.eu-central-003.backblazeb2.com',
      'access_model', 'private',
      'default_server_side_encryption', 'AES256',
      'object_lock_enabled', false,
      'default_retention_mode', null,
      'default_retention_period', null,
      'tested_accession_id', 'LP-ACC-2026-0003',
      'tested_package_id', 'LP-BAG-2026-0003',
      'tested_object_count', 8,
      'tested_total_byte_count', 162934529,
      'temporary_transfer_function_deleted', true,
      'live_archive_model', true
    )
  )
  on conflict (location_id) do update set
    name = excluded.name,
    role = excluded.role,
    online = excluded.online,
    immutable_or_object_locked = excluded.immutable_or_object_locked,
    encrypted_at_rest = excluded.encrypted_at_rest,
    active = excluded.active,
    evidence_status = excluded.evidence_status,
    last_tested_at = excluded.last_tested_at,
    recovery_notes = excluded.recovery_notes,
    metadata = archive.storage_locations.metadata || excluded.metadata,
    updated_at = now()
  returning id into location_key;

  insert into archive.accessions (
    accession_id, collection_id, accessioned_at, source_agent_id,
    transfer_method, agreement_reference, extent_statement, appraisal_decision,
    restrictions_note, receipt_confirmed, manifest_sha256, metadata
  ) values (
    'LP-ACC-2026-0003',
    collection_key,
    '2026-08-08',
    owner_agent_key,
    'Owner-controlled local files copied directly to a private Backblaze B2 live archive bucket over signed HTTPS, then completely restored and SHA-256 verified.',
    'Alex Lawton live-archive directive, 2026-08-08',
    '4 payload files plus 4 verification files; 162,934,529 total bytes',
    'Accepted as the first simplified live-archive batch after exact-digest deduplication and scope review.',
    'Restricted pending descriptive, rights, sensitivity, and public-release review.',
    true,
    'a2c8ae2e9f641017f17f60e11d08025054dd13c6565f84a814dd931a9eeb13fe',
    jsonb_build_object(
      'stage', 'uploaded_restored_verified_and_registered',
      'transfer_package_id', 'LP-BAG-2026-0003',
      'storage_location_id', 'LP-LOC-B2-EUC3-002',
      'source_scope_policy_id', 'LP-SCOPE-2026-08-08-001',
      'inventory_sha256', '21123885078437634db38fdc70463d51b7531a43e7da7054709d18887584ecd7',
      'deduplication_reconciliation_sha256', '038295b0994cac304141d2129a07dfd3a4ada7a85dfe40248ea88a2638e2c2d1',
      'source_deletion_authorized', false,
      'live_archive_model', true
    )
  )
  on conflict (accession_id) do update set
    extent_statement = excluded.extent_statement,
    appraisal_decision = excluded.appraisal_decision,
    restrictions_note = excluded.restrictions_note,
    receipt_confirmed = excluded.receipt_confirmed,
    manifest_sha256 = excluded.manifest_sha256,
    metadata = archive.accessions.metadata || excluded.metadata
  returning id into accession_key;

  insert into archive.items (
    item_id, collection_id, title, alternative_titles, item_type,
    description, date_text, languages, places, physical_description,
    scope_and_content, appraisal_note, access_scope, sensitivity_status,
    verification_status, lifecycle_status, preferred_citation, metadata
  ) values (
    'LP-ITEM-2026-0002',
    collection_key,
    'La Pipa 2021 logos and early video files',
    array['LOGO_LA PIPA_2021', 'LA PIPA FIRST EVER VIDEO 1 PRORES 422 FINAL CUT EDIT AND AFTER EFFECTS ANIMATION'],
    'mixed_material',
    'Two PNG La Pipa logo files and two distinct 1080p MPEG-4 La Pipa videos selected from owner-controlled archive folders.',
    'Folder labels refer to 2021 logos and an early or first La Pipa video; the exact video chronology remains unverified.',
    array[]::text[],
    array[]::text[],
    '2 PNG images and 2 MPEG-4 videos; 162,933,571 payload bytes.',
    'Received-state logo and moving-image assets retained unchanged. Filename claims are preserved as source labels rather than treated as independently verified chronology.',
    'Accepted after the offered seven occurrences were reconciled into five byte-distinct files and the zero-byte Finder Icon record was excluded from payload transfer.',
    'restricted',
    'unreviewed',
    'source_verified',
    'review',
    'La Pipa Documentary Archive, LP-ITEM-2026-0002, “La Pipa 2021 logos and early video files.”',
    jsonb_build_object(
      'accession_id', 'LP-ACC-2026-0003',
      'transfer_package_id', 'LP-BAG-2026-0003',
      'owner', 'Alex Lawton',
      'rights_co_holder', 'Miramonte, S.L.',
      'public_release_status', 'not_approved',
      'filename_chronology_claim_verified', false,
      'exact_duplicate_occurrences_preserved_in_reconciliation', true,
      'source_deletion_authorized', false,
      'storage_status', 'backblaze_uploaded_and_restore_verified'
    )
  )
  on conflict (item_id) do update set
    title = excluded.title,
    alternative_titles = excluded.alternative_titles,
    description = excluded.description,
    date_text = excluded.date_text,
    physical_description = excluded.physical_description,
    scope_and_content = excluded.scope_and_content,
    appraisal_note = excluded.appraisal_note,
    access_scope = excluded.access_scope,
    sensitivity_status = excluded.sensitivity_status,
    verification_status = excluded.verification_status,
    lifecycle_status = excluded.lifecycle_status,
    preferred_citation = excluded.preferred_citation,
    metadata = archive.items.metadata || excluded.metadata,
    updated_at = now()
  returning id into item_key;

  insert into archive.item_rights (
    item_id, rights_statement_id, applies_to, access_decision
  )
  select item_key, r.id, scope.applies_to, 'restricted'
  from archive.rights_statements r
  cross join (values ('content'::text), ('digital_file'::text)) scope(applies_to)
  where r.rights_id in ('LP-RIGHTS-ALEX-2026-001', 'LP-RIGHTS-MIRAMONTE-2026-001')
  on conflict (item_id, rights_statement_id, applies_to) do update set
    access_decision = excluded.access_decision;

  insert into archive.representations (
    representation_id, item_id, purpose, generation, label,
    sequence_number, complete, active, metadata
  ) values (
    'LP-REP-2026-0003', item_key, 'original', 'received-state',
    'Original images and videos received from the archive owner', 0, true, true,
    jsonb_build_object(
      'accession_id', 'LP-ACC-2026-0003',
      'transfer_package_id', 'LP-BAG-2026-0003',
      'original_modified', false
    )
  )
  on conflict (representation_id) do update set
    item_id = excluded.item_id,
    label = excluded.label,
    complete = excluded.complete,
    active = excluded.active,
    metadata = archive.representations.metadata || excluded.metadata
  returning id into original_representation_key;

  insert into archive.representations (
    representation_id, item_id, purpose, generation, label,
    sequence_number, complete, active, metadata
  ) values (
    'LP-REP-2026-0004', item_key, 'metadata_export', 'BagIt-1.0',
    'Checksum and transfer verification files', 0, true, true,
    jsonb_build_object(
      'accession_id', 'LP-ACC-2026-0003',
      'transfer_package_id', 'LP-BAG-2026-0003',
      'tag_file_encoding', 'UTF-8',
      'manifest_algorithm', 'sha256'
    )
  )
  on conflict (representation_id) do update set
    item_id = excluded.item_id,
    label = excluded.label,
    complete = excluded.complete,
    active = excluded.active,
    metadata = archive.representations.metadata || excluded.metadata
  returning id into metadata_representation_key;

  insert into archive.transfer_packages (
    package_id, accession_id, package_type, bagit_version, tag_file_encoding,
    manifest_algorithm, payload_file_count, payload_byte_count,
    storage_bucket, storage_object_path, status, validation_tool,
    validated_at, validation_detail
  ) values (
    'LP-BAG-2026-0003', accession_key, 'submission', '1.0', 'UTF-8',
    'sha256', 4, 162933571,
    'miramonte-lapipa-archive', 'archive/incoming/LP-ACC-2026-0003',
    'ingested', 'lapipa-archives validate-bag/1.0',
    '2026-08-07T23:08:30Z',
    jsonb_build_object(
      'valid', true,
      'failures', jsonb_build_array(),
      'payload_file_count', 4,
      'payload_byte_count', 162933571,
      'total_object_count', 8,
      'total_byte_count', 162934529,
      'manifest_file_sha256', 'a2c8ae2e9f641017f17f60e11d08025054dd13c6565f84a814dd931a9eeb13fe',
      'tagmanifest_file_sha256', '0fa7fed16b692a9d5de664f1b960eb19a0ef5b5df8e54f81aaf87d764fb532c6',
      'source_fixity_verified', true,
      'remote_metadata_verified', true,
      'restore_fixity_verified', true,
      'restored_bagit_validation_passed', true,
      'server_side_encryption_observed', 'AES256',
      'object_lock_enabled', false,
      'default_retention', null,
      'temporary_transfer_function_deleted', true,
      'live_archive_model', true
    )
  )
  on conflict (package_id) do update set
    accession_id = excluded.accession_id,
    storage_bucket = excluded.storage_bucket,
    storage_object_path = excluded.storage_object_path,
    status = excluded.status,
    validated_at = excluded.validated_at,
    validation_detail = archive.transfer_packages.validation_detail || excluded.validation_detail,
    updated_at = now()
  returning id into package_key;

  insert into archive.file_objects (
    file_id, representation_id, original_filename, normalized_filename,
    storage_bucket, storage_object_path, mime_type, format_name,
    format_version, byte_count, sha256, creating_application,
    creating_application_version, ingested_at, last_fixity_at,
    fixity_status, malware_scan_status, metadata
  )
  select
    v.file_id,
    case when v.payload then original_representation_key else metadata_representation_key end,
    v.original_filename,
    v.normalized_filename,
    'miramonte-lapipa-archive',
    'archive/incoming/LP-ACC-2026-0003/' || v.relative_path,
    v.mime_type,
    v.format_name,
    v.format_version,
    v.byte_count,
    v.sha256,
    case when v.payload then null else 'lapipa-archives' end,
    case when v.payload then null else '0.1.0' end,
    '2026-08-07T23:08:30Z',
    '2026-08-07T23:08:30Z',
    'verified',
    case when v.payload then 'clear' else 'not_applicable' end,
    v.metadata || jsonb_build_object(
      'package_relative_path', v.relative_path,
      'payload', v.payload,
      'source_scope_policy_id', 'LP-SCOPE-2026-08-08-001',
      'restore_verified', true,
      'source_deletion_authorized', false
    )
  from (values
    ('LP-FILE-2026-0006', true, 'data/images/lapipa logpnew clargeopy.png', 'lapipa logpnew clargeopy.png', 'lapipa-logo-2021-copy.png', 'image/png', 'PNG', null::text, 210745::bigint, '75b146a30cfe60091cbf38a79ac8600512279d67ebd755f8b531d1206e319097', jsonb_build_object('width',2000,'height',2000,'malware_scan_engine','ClamAV 1.5.3')),
    ('LP-FILE-2026-0007', true, 'data/images/lapipa logpnew.png', 'lapipa logpnew.png', 'lapipa-logo-2021.png', 'image/png', 'PNG', null::text, 413856::bigint, 'cfae9cc0950c280ee21d81a82feca44f42cedf4634096ebd02b5073be957b10a', jsonb_build_object('width',3000,'height',3000,'malware_scan_engine','ClamAV 1.5.3')),
    ('LP-FILE-2026-0008', true, 'data/video/LA PIPA _ V001B_BEDROCK LOGO.mp4', 'LA PIPA _ V001B_BEDROCK LOGO.mp4', 'la-pipa-v001b-bedrock-logo.mp4', 'video/mp4', 'MPEG-4', 'H.264/AAC', 79793675::bigint, '654b27912adb18c097b2fbfd828efc8b03496db543bd877fab36894677cc42e9', jsonb_build_object('width',1920,'height',1080,'duration_seconds',66.125,'audio_channels',2,'malware_scan_engine','ClamAV 1.5.3')),
    ('LP-FILE-2026-0009', true, 'data/video/MASTER_LA PIPA _ Video_001_HD1080.mp4', 'MASTER_LA PIPA _ Video_001_HD1080.mp4', 'master-la-pipa-video-001-hd1080.mp4', 'video/mp4', 'MPEG-4', 'H.264/AAC', 82515295::bigint, '449110d192c9f467dcd42efae1c968f0097d24aca055b9f942d74ca647540e12', jsonb_build_object('width',1920,'height',1080,'duration_seconds',67.625,'audio_channels',2,'malware_scan_engine','ClamAV 1.5.3','filename_chronology_claim_verified',false)),
    ('LP-FILE-2026-0010', false, 'bag-info.txt', 'bag-info.txt', 'bag-info.txt', 'text/plain', 'Plain Text', 'UTF-8', 234::bigint, '92534048f8921d7845016ad7be28fbba28cbbe7be803083491495bb9f3c17f9a', jsonb_build_object('bagit_tag_file',true)),
    ('LP-FILE-2026-0012', false, 'manifest-sha256.txt', 'manifest-sha256.txt', 'manifest-sha256.txt', 'text/plain', 'SHA-256 payload manifest', 'SHA-256', 429::bigint, 'a2c8ae2e9f641017f17f60e11d08025054dd13c6565f84a814dd931a9eeb13fe', jsonb_build_object('bagit_tag_file',true)),
    ('LP-FILE-2026-0013', false, 'tagmanifest-sha256.txt', 'tagmanifest-sha256.txt', 'tagmanifest-sha256.txt', 'text/plain', 'SHA-256 tag manifest', 'SHA-256', 241::bigint, '0fa7fed16b692a9d5de664f1b960eb19a0ef5b5df8e54f81aaf87d764fb532c6', jsonb_build_object('bagit_tag_file',true))
  ) as v(file_id, payload, relative_path, original_filename, normalized_filename, mime_type, format_name, format_version, byte_count, sha256, metadata)
  on conflict (file_id) do update set
    representation_id = excluded.representation_id,
    storage_bucket = excluded.storage_bucket,
    storage_object_path = excluded.storage_object_path,
    mime_type = excluded.mime_type,
    format_name = excluded.format_name,
    format_version = excluded.format_version,
    byte_count = excluded.byte_count,
    sha256 = excluded.sha256,
    ingested_at = excluded.ingested_at,
    last_fixity_at = excluded.last_fixity_at,
    fixity_status = excluded.fixity_status,
    malware_scan_status = excluded.malware_scan_status,
    metadata = archive.file_objects.metadata || excluded.metadata;

  insert into archive.transfer_package_files (
    transfer_package_id, relative_path, payload, byte_count,
    digest_algorithm, digest, file_object_id, ingest_decision, note
  )
  select
    package_key, v.relative_path, v.payload, v.byte_count, 'sha256',
    v.sha256, f.id, 'accepted',
    'Uploaded to the private Backblaze live archive, completely restored, and SHA-256 verified.'
  from (values
    ('LP-FILE-2026-0006', true, 'data/images/lapipa logpnew clargeopy.png', 210745::bigint, '75b146a30cfe60091cbf38a79ac8600512279d67ebd755f8b531d1206e319097'),
    ('LP-FILE-2026-0007', true, 'data/images/lapipa logpnew.png', 413856::bigint, 'cfae9cc0950c280ee21d81a82feca44f42cedf4634096ebd02b5073be957b10a'),
    ('LP-FILE-2026-0008', true, 'data/video/LA PIPA _ V001B_BEDROCK LOGO.mp4', 79793675::bigint, '654b27912adb18c097b2fbfd828efc8b03496db543bd877fab36894677cc42e9'),
    ('LP-FILE-2026-0009', true, 'data/video/MASTER_LA PIPA _ Video_001_HD1080.mp4', 82515295::bigint, '449110d192c9f467dcd42efae1c968f0097d24aca055b9f942d74ca647540e12'),
    ('LP-FILE-2026-0010', false, 'bag-info.txt', 234::bigint, '92534048f8921d7845016ad7be28fbba28cbbe7be803083491495bb9f3c17f9a'),
    ('LP-FILE-2026-0003', false, 'bagit.txt', 54::bigint, '1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9'),
    ('LP-FILE-2026-0012', false, 'manifest-sha256.txt', 429::bigint, 'a2c8ae2e9f641017f17f60e11d08025054dd13c6565f84a814dd931a9eeb13fe'),
    ('LP-FILE-2026-0013', false, 'tagmanifest-sha256.txt', 241::bigint, '0fa7fed16b692a9d5de664f1b960eb19a0ef5b5df8e54f81aaf87d764fb532c6')
  ) as v(file_id, payload, relative_path, byte_count, sha256)
  join archive.file_objects f on f.file_id = v.file_id
  on conflict (transfer_package_id, relative_path) do update set
    payload = excluded.payload,
    byte_count = excluded.byte_count,
    digest_algorithm = excluded.digest_algorithm,
    digest = excluded.digest,
    file_object_id = excluded.file_object_id,
    ingest_decision = excluded.ingest_decision,
    note = excluded.note;

  insert into archive.preservation_events (
    event_id, event_type, event_at, outcome, outcome_detail,
    agent_id, software_agent, command_or_process, event_detail
  ) values
  (
    'LP-PRESEVENT-2026-0010', 'replication', '2026-08-07T23:05:49Z', 'success',
    'Eight objects were uploaded directly from the owner-controlled Mac to the private Backblaze B2 live archive bucket.',
    repository_agent_key, 'Supabase Edge Functions + curl',
    'Short-lived exact-path SigV4 PUT URLs; Backblaze credentials remained in Supabase secrets.',
    jsonb_build_object('accession_id','LP-ACC-2026-0003','package_id','LP-BAG-2026-0003','bucket','miramonte-lapipa-archive','object_count',8,'total_byte_count',162934529,'server_side_encryption','AES256','object_lock_enabled',false)
  ),
  (
    'LP-PRESEVENT-2026-0011', 'fixity_check', '2026-08-07T23:08:30Z', 'success',
    'The SHA-256 digest of every restored object matched its pre-upload digest.',
    repository_agent_key, 'shasum 6.0',
    'Complete source-versus-restored SHA-256 comparison.',
    jsonb_build_object('accession_id','LP-ACC-2026-0003','algorithm','sha256','object_count',8,'passing_count',8,'failing_count',0)
  ),
  (
    'LP-PRESEVENT-2026-0012', 'restore', '2026-08-07T23:08:30Z', 'success',
    'All eight objects were downloaded into a clean restore tree; the four-payload BagIt package validated with zero failures.',
    repository_agent_key, 'curl + lapipa-archives validate-bag/1.0',
    'Complete signed-GET restore followed by SHA-256 comparison and package validation.',
    jsonb_build_object('accession_id','LP-ACC-2026-0003','restored_object_count',8,'payload_file_count',4,'payload_byte_count',162933571,'bagit_valid',true,'validation_failures',jsonb_build_array())
  ),
  (
    'LP-PRESEVENT-2026-0013', 'ingest', '2026-08-07T23:09:31Z', 'success',
    'The first simplified live-archive batch was registered as one item, two representations, seven new file objects, one reused digest-identical file object, and eight verified Backblaze copies.',
    repository_agent_key, 'La Pipa live archive ledger',
    'Idempotent registration after upload, read-back, complete restore, and fixity verification.',
    jsonb_build_object('accession_id','LP-ACC-2026-0003','package_id','LP-BAG-2026-0003','item_id','LP-ITEM-2026-0002','linked_file_object_count',8,'new_file_object_count',7,'reused_digest_identical_file_object_count',1,'copy_count',8,'live_archive_model',true)
  )
  on conflict (event_id) do update set
    event_at = excluded.event_at,
    outcome = excluded.outcome,
    outcome_detail = excluded.outcome_detail,
    agent_id = excluded.agent_id,
    software_agent = excluded.software_agent,
    command_or_process = excluded.command_or_process,
    event_detail = excluded.event_detail;

  select id into fixity_event_key
  from archive.preservation_events
  where event_id = 'LP-PRESEVENT-2026-0011';

  insert into archive.file_copies (
    copy_id, file_object_id, storage_location_id, storage_bucket,
    storage_object_path, storage_version_id, replica_state,
    expected_sha256, observed_sha256, byte_count, copied_at,
    last_verified_at, next_verification_due_at, metadata
  )
  select
    v.copy_id, f.id, location_key, 'miramonte-lapipa-archive',
    'archive/incoming/LP-ACC-2026-0003/' || v.relative_path,
    v.version_id, 'verified', v.sha256, v.sha256, v.byte_count,
    '2026-08-07T23:05:49Z', '2026-08-07T23:08:30Z', '2026-11-05T23:08:30Z',
    jsonb_build_object('etag',v.etag,'server_side_encryption','AES256','restore_verified',true,'object_lock_enabled',false)
  from (values
    ('LP-COPY-B2-2026-0006', 'LP-FILE-2026-0006', 'data/images/lapipa logpnew clargeopy.png', '4_z26c26b5c7399daef90f40c13_f1142f76f7d8f537e_d20260807_m230549_c003_v0312006_t0000_u01786143949066', '2862b066e2c481051a633cd108f0e290', 210745::bigint, '75b146a30cfe60091cbf38a79ac8600512279d67ebd755f8b531d1206e319097'),
    ('LP-COPY-B2-2026-0007', 'LP-FILE-2026-0007', 'data/images/lapipa logpnew.png', '4_z26c26b5c7399daef90f40c13_f1101aa9a8db88a2c_d20260807_m230549_c003_v0312028_t0035_u01786143949068', '1e0959c679e1b56e52d89a3265e25294', 413856::bigint, 'cfae9cc0950c280ee21d81a82feca44f42cedf4634096ebd02b5073be957b10a'),
    ('LP-COPY-B2-2026-0008', 'LP-FILE-2026-0008', 'data/video/LA PIPA _ V001B_BEDROCK LOGO.mp4', '4_z26c26b5c7399daef90f40c13_f118f355bfdfdc90e_d20260807_m230548_c003_v0312034_t0018_u01786143948502', '300d6a063b577891071c9fecfa0b3ac5', 79793675::bigint, '654b27912adb18c097b2fbfd828efc8b03496db543bd877fab36894677cc42e9'),
    ('LP-COPY-B2-2026-0009', 'LP-FILE-2026-0009', 'data/video/MASTER_LA PIPA _ Video_001_HD1080.mp4', '4_z26c26b5c7399daef90f40c13_f1045a05222db83a1_d20260807_m230548_c003_v0312029_t0025_u01786143948496', '8b10b311961724e630167b3466e2818e', 82515295::bigint, '449110d192c9f467dcd42efae1c968f0097d24aca055b9f942d74ca647540e12'),
    ('LP-COPY-B2-2026-0010', 'LP-FILE-2026-0010', 'bag-info.txt', '4_z26c26b5c7399daef90f40c13_f1198fea94671fdc9_d20260807_m230549_c003_v0312040_t0012_u01786143949034', 'eed298b70f1617911a53e9d939cd9575', 234::bigint, '92534048f8921d7845016ad7be28fbba28cbbe7be803083491495bb9f3c17f9a'),
    ('LP-COPY-B2-2026-0011', 'LP-FILE-2026-0003', 'bagit.txt', '4_z26c26b5c7399daef90f40c13_f113a807f45b274cf_d20260807_m230549_c003_v0312016_t0021_u01786143949025', 'eaa2c609ff6371712f623f5531945b44', 54::bigint, '1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9'),
    ('LP-COPY-B2-2026-0012', 'LP-FILE-2026-0012', 'manifest-sha256.txt', '4_z26c26b5c7399daef90f40c13_f113d6a810f8d1691_d20260807_m230549_c003_v0312029_t0002_u01786143949032', '13d0d425153114e3eb2c09630f939fd3', 429::bigint, 'a2c8ae2e9f641017f17f60e11d08025054dd13c6565f84a814dd931a9eeb13fe'),
    ('LP-COPY-B2-2026-0013', 'LP-FILE-2026-0013', 'tagmanifest-sha256.txt', '4_z26c26b5c7399daef90f40c13_f1045a05222db83df_d20260807_m230549_c003_v0312029_t0031_u01786143949035', '8eae06e35fde65a6a850ca7b4cece28e', 241::bigint, '0fa7fed16b692a9d5de664f1b960eb19a0ef5b5df8e54f81aaf87d764fb532c6')
  ) as v(copy_id, file_id, relative_path, version_id, etag, byte_count, sha256)
  join archive.file_objects f on f.file_id = v.file_id
  on conflict (copy_id) do update set
    file_object_id = excluded.file_object_id,
    storage_location_id = excluded.storage_location_id,
    storage_bucket = excluded.storage_bucket,
    storage_object_path = excluded.storage_object_path,
    storage_version_id = excluded.storage_version_id,
    replica_state = excluded.replica_state,
    expected_sha256 = excluded.expected_sha256,
    observed_sha256 = excluded.observed_sha256,
    byte_count = excluded.byte_count,
    copied_at = excluded.copied_at,
    last_verified_at = excluded.last_verified_at,
    next_verification_due_at = excluded.next_verification_due_at,
    metadata = archive.file_copies.metadata || excluded.metadata,
    updated_at = now();

  insert into archive.fixity_checks (
    check_id, file_object_id, preservation_event_id, algorithm,
    expected_digest, observed_digest, result, checked_at,
    storage_location, error_detail
  )
  select
    v.check_id, f.id, fixity_event_key, 'sha256', v.sha256, v.sha256,
    'pass', '2026-08-07T23:08:30Z', 'LP-LOC-B2-EUC3-002', null
  from (values
    ('LP-FIXITY-2026-0006', 'LP-FILE-2026-0006', '75b146a30cfe60091cbf38a79ac8600512279d67ebd755f8b531d1206e319097'),
    ('LP-FIXITY-2026-0007', 'LP-FILE-2026-0007', 'cfae9cc0950c280ee21d81a82feca44f42cedf4634096ebd02b5073be957b10a'),
    ('LP-FIXITY-2026-0008', 'LP-FILE-2026-0008', '654b27912adb18c097b2fbfd828efc8b03496db543bd877fab36894677cc42e9'),
    ('LP-FIXITY-2026-0009', 'LP-FILE-2026-0009', '449110d192c9f467dcd42efae1c968f0097d24aca055b9f942d74ca647540e12'),
    ('LP-FIXITY-2026-0010', 'LP-FILE-2026-0010', '92534048f8921d7845016ad7be28fbba28cbbe7be803083491495bb9f3c17f9a'),
    ('LP-FIXITY-2026-0011', 'LP-FILE-2026-0003', '1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9'),
    ('LP-FIXITY-2026-0012', 'LP-FILE-2026-0012', 'a2c8ae2e9f641017f17f60e11d08025054dd13c6565f84a814dd931a9eeb13fe'),
    ('LP-FIXITY-2026-0013', 'LP-FILE-2026-0013', '0fa7fed16b692a9d5de664f1b960eb19a0ef5b5df8e54f81aaf87d764fb532c6')
  ) as v(check_id, file_id, sha256)
  join archive.file_objects f on f.file_id = v.file_id
  on conflict (check_id) do update set
    file_object_id = excluded.file_object_id,
    preservation_event_id = excluded.preservation_event_id,
    expected_digest = excluded.expected_digest,
    observed_digest = excluded.observed_digest,
    result = excluded.result,
    checked_at = excluded.checked_at,
    storage_location = excluded.storage_location,
    error_detail = excluded.error_detail;

  insert into archive.event_file_links (
    preservation_event_id, file_object_id, relationship
  )
  select e.id, f.id, rel.relationship
  from archive.preservation_events e
  cross join (
    select distinct tpf.file_object_id as id
    from archive.transfer_package_files tpf
    where tpf.transfer_package_id = package_key
  ) f
  cross join lateral (values (
    case e.event_type
      when 'fixity_check' then 'subject'::text
      else 'outcome'::text
    end
  )) rel(relationship)
  where e.event_id in (
      'LP-PRESEVENT-2026-0010', 'LP-PRESEVENT-2026-0011',
      'LP-PRESEVENT-2026-0012', 'LP-PRESEVENT-2026-0013'
    )
  on conflict do nothing;
end $$;

commit;
