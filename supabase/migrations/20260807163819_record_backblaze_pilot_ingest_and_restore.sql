begin;

do $$
declare
  owner_user_key uuid;
  owner_agent_key bigint;
  repository_agent_key bigint;
  collection_key bigint;
  source_key bigint;
  accession_key bigint;
  package_key bigint;
  location_key bigint;
  item_key bigint;
  original_representation_key bigint;
  package_representation_key bigint;
  pdf_file_key bigint;
  bag_info_file_key bigint;
  bagit_file_key bigint;
  manifest_file_key bigint;
  tagmanifest_file_key bigint;
  replication_event_key bigint;
  fixity_event_key bigint;
  restore_event_key bigint;
  ingest_event_key bigint;
begin
  select wm.user_id into owner_user_key
  from kb.workspace_members wm
  where wm.role = 'owner' and wm.active
  order by wm.created_at
  limit 1;

  select id into owner_agent_key
  from archive.agents
  where agent_id = 'LP-AGENT-ALEX-LAWTON';

  select id into repository_agent_key
  from archive.agents
  where agent_id = 'LP-AGENT-LA-PIPA-REPOSITORY';

  select id into collection_key
  from archive.collections
  where collection_id = 'LP-ARCHIVE-001';

  select id into source_key
  from kb.sources
  where source_id = 'LP-SRC-001';

  select id into accession_key
  from archive.accessions
  where accession_id = 'LP-ACC-2026-0001';

  select id into package_key
  from archive.transfer_packages
  where package_id = 'LP-BAG-2026-0001';

  select id into location_key
  from archive.storage_locations
  where location_id = 'LP-LOC-B2-EUC3-001';

  if owner_user_key is null
     or owner_agent_key is null
     or repository_agent_key is null
     or collection_key is null
     or source_key is null
     or accession_key is null
     or package_key is null
     or location_key is null then
    raise exception 'Required owner, repository, collection, source, accession, package, or storage-location record is absent';
  end if;

  insert into archive.items (
    item_id, collection_id, title, alternative_titles, item_type,
    description, created_start, date_text, languages, places,
    physical_description, scope_and_content, appraisal_note,
    access_scope, sensitivity_status, verification_status,
    lifecycle_status, preferred_citation, metadata
  ) values (
    'LP-ITEM-2026-0001',
    collection_key,
    'La Pipa project origin presentation',
    array['LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO'],
    'document',
    'A 36-page presentation documenting the La Pipa project concept and development context. This is the first fixity-controlled item ingested into the La Pipa Documentary Archive.',
    '2019-06-10',
    'Created 10 June 2019; source file modified 11 March 2020',
    array['en'],
    array[]::text[],
    '1 PDF file; 194,031,448 bytes; 36 pages; landscape 960 by 540 point pages.',
    'Origin-deck presentation retained as received. The object is preserved unchanged; its descriptive interpretation and any public release remain subject to archival review.',
    'Accepted as the first pilot item because it is the earliest strongly documented La Pipa origin presentation presently under archive control.',
    'restricted',
    'unreviewed',
    'source_verified',
    'review',
    'La Pipa Documentary Archive, LP-ITEM-2026-0001, “La Pipa project origin presentation,” 2019.',
    jsonb_build_object(
      'accession_id', 'LP-ACC-2026-0001',
      'transfer_package_id', 'LP-BAG-2026-0001',
      'source_id', 'LP-SRC-001',
      'evidence_document_id', 'LP-DOC-ARCH-024',
      'owner', 'Alex Lawton',
      'rights_co_holder', 'Miramonte, S.L.',
      'public_release_status', 'not_approved',
      'preservation_ingest_status', 'verified'
    )
  )
  on conflict (item_id) do update set
    collection_id = excluded.collection_id,
    title = excluded.title,
    alternative_titles = excluded.alternative_titles,
    description = excluded.description,
    created_start = excluded.created_start,
    date_text = excluded.date_text,
    languages = excluded.languages,
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

  insert into archive.item_sources (item_id, source_id, locator, support_type)
  values (
    item_key,
    source_key,
    'LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf',
    'documents'
  )
  on conflict (item_id, source_id, support_type) do update set
    locator = excluded.locator;

  insert into archive.item_rights (
    item_id, rights_statement_id, applies_to, access_decision
  )
  select item_key, r.id, scope.applies_to, 'restricted'
  from archive.rights_statements r
  cross join (values ('content'::text), ('digital_file'::text)) scope(applies_to)
  where r.rights_id in (
    'LP-RIGHTS-ALEX-2026-001',
    'LP-RIGHTS-MIRAMONTE-2026-001'
  )
  on conflict (item_id, rights_statement_id, applies_to) do update set
    access_decision = excluded.access_decision;

  insert into archive.representations (
    representation_id, item_id, purpose, generation, label,
    sequence_number, complete, active, metadata
  ) values (
    'LP-REP-2026-0001', item_key, 'original', 'received-state',
    'Original PDF received from the archive owner', 0, true, true,
    jsonb_build_object(
      'accession_id', 'LP-ACC-2026-0001',
      'transfer_package_id', 'LP-BAG-2026-0001',
      'original_modified', false
    )
  )
  on conflict (representation_id) do update set
    item_id = excluded.item_id,
    purpose = excluded.purpose,
    generation = excluded.generation,
    label = excluded.label,
    complete = excluded.complete,
    active = excluded.active,
    metadata = archive.representations.metadata || excluded.metadata
  returning id into original_representation_key;

  insert into archive.representations (
    representation_id, item_id, purpose, generation, label,
    sequence_number, complete, active, metadata
  ) values (
    'LP-REP-2026-0002', item_key, 'metadata_export', 'BagIt-1.0',
    'BagIt 1.0 package-control files', 0, true, true,
    jsonb_build_object(
      'accession_id', 'LP-ACC-2026-0001',
      'transfer_package_id', 'LP-BAG-2026-0001',
      'tag_file_encoding', 'UTF-8',
      'manifest_algorithm', 'sha256'
    )
  )
  on conflict (representation_id) do update set
    item_id = excluded.item_id,
    purpose = excluded.purpose,
    generation = excluded.generation,
    label = excluded.label,
    complete = excluded.complete,
    active = excluded.active,
    metadata = archive.representations.metadata || excluded.metadata
  returning id into package_representation_key;

  insert into archive.file_objects (
    file_id, representation_id, original_filename, normalized_filename,
    storage_bucket, storage_object_path, mime_type, format_name,
    format_version, byte_count, sha256, creating_application,
    created_at_source, ingested_at, last_fixity_at, fixity_status,
    malware_scan_status, metadata
  ) values (
    'LP-FILE-2026-0001',
    original_representation_key,
    'LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf',
    'lapipa-project-origin-presentation-2019.pdf',
    'miramonte-lapipa-preservation-pilot',
    'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001/data/LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf',
    'application/pdf',
    'PDF',
    'header 1.3; metadata 1.4',
    194031448,
    'c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e',
    'Microsoft PowerPoint',
    '2019-06-10T18:29:48+02:00'::timestamptz,
    '2026-08-07T16:30:52Z'::timestamptz,
    '2026-08-07T16:30:52Z'::timestamptz,
    'verified',
    'clear',
    jsonb_build_object(
      'package_relative_path', 'data/LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf',
      'source_modified_at', '2020-03-11T03:12:53+01:00',
      'page_count', 36,
      'encrypted', false,
      'javascript', false,
      'tagged_for_accessibility', false,
      'qpdf_status', 'pass_with_warnings',
      'qpdf_warning_object_numbers', jsonb_build_array(48, 50, 184, 221, 236),
      'malware_scan_engine', 'ClamAV 1.5.3',
      'malware_scan_completed_at', '2026-08-07T15:00:35Z',
      'evidence_document_id', 'LP-DOC-ARCH-024'
    )
  )
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
    metadata = archive.file_objects.metadata || excluded.metadata
  returning id into pdf_file_key;

  insert into archive.file_objects (
    file_id, representation_id, original_filename, normalized_filename,
    storage_bucket, storage_object_path, mime_type, format_name,
    format_version, byte_count, sha256, creating_application,
    creating_application_version, ingested_at, last_fixity_at,
    fixity_status, malware_scan_status, metadata
  ) values
  (
    'LP-FILE-2026-0002', package_representation_key,
    'bag-info.txt', 'bag-info.txt',
    'miramonte-lapipa-preservation-pilot',
    'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001/bag-info.txt',
    'text/plain', 'Plain Text', 'UTF-8', 189,
    '4c224fa076bb5fbfaaa5889d9d5e80a382ce670f9379b4fd8271981e96a18ad3',
    'lapipa-archives BagIt packager', '1.0',
    '2026-08-07T16:30:52Z', '2026-08-07T16:30:52Z',
    'verified', 'not_applicable',
    jsonb_build_object('package_relative_path', 'bag-info.txt', 'bagit_tag_file', true)
  ),
  (
    'LP-FILE-2026-0003', package_representation_key,
    'bagit.txt', 'bagit.txt',
    'miramonte-lapipa-preservation-pilot',
    'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001/bagit.txt',
    'text/plain', 'BagIt declaration', '1.0', 54,
    '1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9',
    'lapipa-archives BagIt packager', '1.0',
    '2026-08-07T16:30:52Z', '2026-08-07T16:30:52Z',
    'verified', 'not_applicable',
    jsonb_build_object('package_relative_path', 'bagit.txt', 'bagit_tag_file', true)
  ),
  (
    'LP-FILE-2026-0004', package_representation_key,
    'manifest-sha256.txt', 'manifest-sha256.txt',
    'miramonte-lapipa-preservation-pilot',
    'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001/manifest-sha256.txt',
    'text/plain', 'BagIt payload manifest', 'SHA-256', 125,
    'ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf',
    'lapipa-archives BagIt packager', '1.0',
    '2026-08-07T16:30:52Z', '2026-08-07T16:30:52Z',
    'verified', 'not_applicable',
    jsonb_build_object('package_relative_path', 'manifest-sha256.txt', 'bagit_tag_file', true)
  ),
  (
    'LP-FILE-2026-0005', package_representation_key,
    'tagmanifest-sha256.txt', 'tagmanifest-sha256.txt',
    'miramonte-lapipa-preservation-pilot',
    'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001/tagmanifest-sha256.txt',
    'text/plain', 'BagIt tag manifest', 'SHA-256', 241,
    '4f7d305e432109062e4208cc67559a1d16e02666b8664658981f2d653c1e50f3',
    'lapipa-archives BagIt packager', '1.0',
    '2026-08-07T16:30:52Z', '2026-08-07T16:30:52Z',
    'verified', 'not_applicable',
    jsonb_build_object('package_relative_path', 'tagmanifest-sha256.txt', 'bagit_tag_file', true)
  )
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

  select id into bag_info_file_key from archive.file_objects where file_id = 'LP-FILE-2026-0002';
  select id into bagit_file_key from archive.file_objects where file_id = 'LP-FILE-2026-0003';
  select id into manifest_file_key from archive.file_objects where file_id = 'LP-FILE-2026-0004';
  select id into tagmanifest_file_key from archive.file_objects where file_id = 'LP-FILE-2026-0005';

  insert into archive.transfer_package_files (
    transfer_package_id, relative_path, payload, byte_count,
    digest_algorithm, digest, file_object_id, ingest_decision, note
  ) values
  (
    package_key,
    'data/LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf',
    true, 194031448, 'sha256',
    'c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e',
    pdf_file_key, 'accepted',
    'Accepted, registered as LP-FILE-2026-0001, copied to Backblaze B2, and restore-fixity verified.'
  ),
  (package_key, 'bag-info.txt', false, 189, 'sha256',
    '4c224fa076bb5fbfaaa5889d9d5e80a382ce670f9379b4fd8271981e96a18ad3',
    bag_info_file_key, 'accepted', 'BagIt tag file copied and restore-fixity verified.'),
  (package_key, 'bagit.txt', false, 54, 'sha256',
    '1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9',
    bagit_file_key, 'accepted', 'BagIt declaration copied and restore-fixity verified.'),
  (package_key, 'manifest-sha256.txt', false, 125, 'sha256',
    'ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf',
    manifest_file_key, 'accepted', 'BagIt payload manifest copied and restore-fixity verified.'),
  (package_key, 'tagmanifest-sha256.txt', false, 241, 'sha256',
    '4f7d305e432109062e4208cc67559a1d16e02666b8664658981f2d653c1e50f3',
    tagmanifest_file_key, 'accepted', 'BagIt tag manifest copied and restore-fixity verified.')
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
  ) values (
    'LP-PRESEVENT-2026-0006',
    'replication',
    '2026-08-07T16:30:18Z',
    'success',
    'All five BagIt objects were written directly to the private Backblaze B2 preservation prefix. Backblaze reported AES-256 server-side encryption and a distinct immutable version identifier for each uploaded object.',
    repository_agent_key,
    'Supabase Edge Functions + AWS SDK for JavaScript 3.1105.0 + curl',
    'Short-lived package-scoped SigV4 pre-signed PUT operations; permanent credentials remained in Supabase Edge Function secrets.',
    jsonb_build_object(
      'package_id', 'LP-BAG-2026-0001',
      'accession_id', 'LP-ACC-2026-0001',
      'storage_location_id', 'LP-LOC-B2-EUC3-001',
      'bucket', 'miramonte-lapipa-preservation-pilot',
      'prefix', 'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001',
      'object_count', 5,
      'total_byte_count', 194032057,
      'upload_seconds_total', 14,
      'server_side_encryption', 'AES256',
      'credential_values_exposed', false,
      'temporary_bridge_deleted', true,
      'objects', jsonb_build_array(
        jsonb_build_object('file_id','LP-FILE-2026-0002','relative_path','bag-info.txt','byte_count',189,'sha256','4c224fa076bb5fbfaaa5889d9d5e80a382ce670f9379b4fd8271981e96a18ad3','etag','"ab3bd23ef5cc90154cb703b851e5f984"','version_id','4_zd6822b1cb3b9caff90f40c13_f108ab1040fc3df28_d20260807_m163018_c003_v0312039_t0029_u01786120218804'),
        jsonb_build_object('file_id','LP-FILE-2026-0003','relative_path','bagit.txt','byte_count',54,'sha256','1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9','etag','"eaa2c609ff6371712f623f5531945b44"','version_id','4_zd6822b1cb3b9caff90f40c13_f1139981bf7a82617_d20260807_m163019_c003_v0312027_t0000_u01786120219645'),
        jsonb_build_object('file_id','LP-FILE-2026-0001','relative_path','data/LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf','byte_count',194031448,'sha256','c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e','etag','"25474bcc1555a5a0af82df717ca691cc"','version_id','4_zd6822b1cb3b9caff90f40c13_f11206326a93b616a_d20260807_m163021_c003_v0312010_t0002_u01786120221442'),
        jsonb_build_object('file_id','LP-FILE-2026-0004','relative_path','manifest-sha256.txt','byte_count',125,'sha256','ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf','etag','"3752a83d58ef715b5ef6dfa16cc4e65b"','version_id','4_zd6822b1cb3b9caff90f40c13_f109567b3a82d75a3_d20260807_m163048_c003_v0312019_t0001_u01786120248667'),
        jsonb_build_object('file_id','LP-FILE-2026-0005','relative_path','tagmanifest-sha256.txt','byte_count',241,'sha256','4f7d305e432109062e4208cc67559a1d16e02666b8664658981f2d653c1e50f3','etag','"c2a7a944eb68035d3ac3ba89db025a7b"','version_id','4_zd6822b1cb3b9caff90f40c13_f10512a812a234949_d20260807_m163049_c003_v0312041_t0003_u01786120249704')
      ),
      'evidence_document_id', 'LP-DOC-ARCH-024'
    )
  )
  on conflict (event_id) do update set
    event_at = excluded.event_at,
    outcome = excluded.outcome,
    outcome_detail = excluded.outcome_detail,
    agent_id = excluded.agent_id,
    software_agent = excluded.software_agent,
    command_or_process = excluded.command_or_process,
    event_detail = excluded.event_detail
  returning id into replication_event_key;

  insert into archive.preservation_events (
    event_id, event_type, event_at, outcome, outcome_detail,
    agent_id, software_agent, command_or_process, event_detail
  ) values (
    'LP-PRESEVENT-2026-0007',
    'fixity_check',
    '2026-08-07T16:30:52Z',
    'success',
    'Source checksums, object metadata checksums, downloaded-object checksums, sizes, and the restored BagIt manifests all agreed for five of five objects.',
    repository_agent_key,
    'shasum + Backblaze S3 HEAD + lapipa-archives validate-bag/1.0',
    'SHA-256 and byte-count comparison before upload, against remote metadata, and after complete download.',
    jsonb_build_object(
      'package_id', 'LP-BAG-2026-0001',
      'algorithm', 'sha256',
      'object_count', 5,
      'source_fixity_verified', true,
      'remote_metadata_verified', true,
      'restored_object_fixity_verified', true,
      'bagit_validation_passed', true,
      'failure_count', 0,
      'evidence_document_id', 'LP-DOC-ARCH-024'
    )
  )
  on conflict (event_id) do update set
    event_at = excluded.event_at,
    outcome = excluded.outcome,
    outcome_detail = excluded.outcome_detail,
    agent_id = excluded.agent_id,
    software_agent = excluded.software_agent,
    command_or_process = excluded.command_or_process,
    event_detail = excluded.event_detail
  returning id into fixity_event_key;

  insert into archive.preservation_events (
    event_id, event_type, event_at, outcome, outcome_detail,
    agent_id, software_agent, command_or_process, event_detail
  ) values (
    'LP-PRESEVENT-2026-0008',
    'restore',
    '2026-08-07T16:30:52Z',
    'success',
    'The complete package was downloaded into a clean temporary restore tree. All five object hashes and byte counts matched, BagIt validation passed, and qpdf reproduced only the five already documented recoverable warnings.',
    repository_agent_key,
    'Backblaze S3 GET + lapipa-archives validate-bag/1.0 + qpdf 12.3.2',
    'Full clean-directory restore test; temporary restore data and time-limited signed URLs were deleted after validation.',
    jsonb_build_object(
      'package_id', 'LP-BAG-2026-0001',
      'object_count', 5,
      'total_byte_count', 194032057,
      'download_seconds_total', 15,
      'object_fixity_passed', true,
      'bagit_validation_passed', true,
      'qpdf_exit_status', 3,
      'qpdf_warning_object_numbers', jsonb_build_array(48, 50, 184, 221, 236),
      'temporary_restore_deleted', true,
      'evidence_document_id', 'LP-DOC-ARCH-024'
    )
  )
  on conflict (event_id) do update set
    event_at = excluded.event_at,
    outcome = excluded.outcome,
    outcome_detail = excluded.outcome_detail,
    agent_id = excluded.agent_id,
    software_agent = excluded.software_agent,
    command_or_process = excluded.command_or_process,
    event_detail = excluded.event_detail
  returning id into restore_event_key;

  insert into archive.preservation_events (
    event_id, event_type, event_at, outcome, outcome_detail,
    agent_id, software_agent, command_or_process, event_detail
  ) values (
    'LP-PRESEVENT-2026-0009',
    'ingest',
    '2026-08-07T16:30:52Z',
    'success',
    'The validated submission package was registered as one archival item, two representations, five file objects, and five verified Backblaze preservation copies.',
    repository_agent_key,
    'La Pipa Documentary Archive preservation ledger',
    'Idempotent database registration after successful replication, fixity comparison, and restore validation.',
    jsonb_build_object(
      'package_id', 'LP-BAG-2026-0001',
      'accession_id', 'LP-ACC-2026-0001',
      'item_id', 'LP-ITEM-2026-0001',
      'representation_ids', jsonb_build_array('LP-REP-2026-0001','LP-REP-2026-0002'),
      'file_object_count', 5,
      'copy_count', 5,
      'status', 'ingested',
      'evidence_document_id', 'LP-DOC-ARCH-024'
    )
  )
  on conflict (event_id) do update set
    event_at = excluded.event_at,
    outcome = excluded.outcome,
    outcome_detail = excluded.outcome_detail,
    agent_id = excluded.agent_id,
    software_agent = excluded.software_agent,
    command_or_process = excluded.command_or_process,
    event_detail = excluded.event_detail
  returning id into ingest_event_key;

  insert into archive.file_copies (
    copy_id, file_object_id, storage_location_id, storage_bucket,
    storage_object_path, storage_version_id, replica_state,
    expected_sha256, observed_sha256, byte_count, copied_at,
    last_verified_at, next_verification_due_at, metadata
  ) values
  (
    'LP-COPY-B2-2026-0001', bag_info_file_key, location_key,
    'miramonte-lapipa-preservation-pilot',
    'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001/bag-info.txt',
    '4_zd6822b1cb3b9caff90f40c13_f108ab1040fc3df28_d20260807_m163018_c003_v0312039_t0029_u01786120218804',
    'verified',
    '4c224fa076bb5fbfaaa5889d9d5e80a382ce670f9379b4fd8271981e96a18ad3',
    '4c224fa076bb5fbfaaa5889d9d5e80a382ce670f9379b4fd8271981e96a18ad3',
    189, '2026-08-07T16:30:18.804Z', '2026-08-07T16:30:52Z', '2026-11-05T16:30:52Z',
    jsonb_build_object('etag','"ab3bd23ef5cc90154cb703b851e5f984"','server_side_encryption','AES256','restore_verified',true)
  ),
  (
    'LP-COPY-B2-2026-0002', bagit_file_key, location_key,
    'miramonte-lapipa-preservation-pilot',
    'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001/bagit.txt',
    '4_zd6822b1cb3b9caff90f40c13_f1139981bf7a82617_d20260807_m163019_c003_v0312027_t0000_u01786120219645',
    'verified',
    '1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9',
    '1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9',
    54, '2026-08-07T16:30:19.645Z', '2026-08-07T16:30:52Z', '2026-11-05T16:30:52Z',
    jsonb_build_object('etag','"eaa2c609ff6371712f623f5531945b44"','server_side_encryption','AES256','restore_verified',true)
  ),
  (
    'LP-COPY-B2-2026-0003', pdf_file_key, location_key,
    'miramonte-lapipa-preservation-pilot',
    'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001/data/LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf',
    '4_zd6822b1cb3b9caff90f40c13_f11206326a93b616a_d20260807_m163021_c003_v0312010_t0002_u01786120221442',
    'verified',
    'c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e',
    'c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e',
    194031448, '2026-08-07T16:30:21.442Z', '2026-08-07T16:30:52Z', '2026-11-05T16:30:52Z',
    jsonb_build_object('etag','"25474bcc1555a5a0af82df717ca691cc"','server_side_encryption','AES256','restore_verified',true)
  ),
  (
    'LP-COPY-B2-2026-0004', manifest_file_key, location_key,
    'miramonte-lapipa-preservation-pilot',
    'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001/manifest-sha256.txt',
    '4_zd6822b1cb3b9caff90f40c13_f109567b3a82d75a3_d20260807_m163048_c003_v0312019_t0001_u01786120248667',
    'verified',
    'ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf',
    'ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf',
    125, '2026-08-07T16:30:48.667Z', '2026-08-07T16:30:52Z', '2026-11-05T16:30:52Z',
    jsonb_build_object('etag','"3752a83d58ef715b5ef6dfa16cc4e65b"','server_side_encryption','AES256','restore_verified',true)
  ),
  (
    'LP-COPY-B2-2026-0005', tagmanifest_file_key, location_key,
    'miramonte-lapipa-preservation-pilot',
    'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001/tagmanifest-sha256.txt',
    '4_zd6822b1cb3b9caff90f40c13_f10512a812a234949_d20260807_m163049_c003_v0312041_t0003_u01786120249704',
    'verified',
    '4f7d305e432109062e4208cc67559a1d16e02666b8664658981f2d653c1e50f3',
    '4f7d305e432109062e4208cc67559a1d16e02666b8664658981f2d653c1e50f3',
    241, '2026-08-07T16:30:49.704Z', '2026-08-07T16:30:52Z', '2026-11-05T16:30:52Z',
    jsonb_build_object('etag','"c2a7a944eb68035d3ac3ba89db025a7b"','server_side_encryption','AES256','restore_verified',true)
  )
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
  ) values
  ('LP-FIXITY-2026-0001', bag_info_file_key, fixity_event_key, 'sha256',
   '4c224fa076bb5fbfaaa5889d9d5e80a382ce670f9379b4fd8271981e96a18ad3',
   '4c224fa076bb5fbfaaa5889d9d5e80a382ce670f9379b4fd8271981e96a18ad3',
   'pass', '2026-08-07T16:30:52Z', 'LP-LOC-B2-EUC3-001', null),
  ('LP-FIXITY-2026-0002', bagit_file_key, fixity_event_key, 'sha256',
   '1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9',
   '1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9',
   'pass', '2026-08-07T16:30:52Z', 'LP-LOC-B2-EUC3-001', null),
  ('LP-FIXITY-2026-0003', pdf_file_key, fixity_event_key, 'sha256',
   'c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e',
   'c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e',
   'pass', '2026-08-07T16:30:52Z', 'LP-LOC-B2-EUC3-001', null),
  ('LP-FIXITY-2026-0004', manifest_file_key, fixity_event_key, 'sha256',
   'ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf',
   'ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf',
   'pass', '2026-08-07T16:30:52Z', 'LP-LOC-B2-EUC3-001', null),
  ('LP-FIXITY-2026-0005', tagmanifest_file_key, fixity_event_key, 'sha256',
   '4f7d305e432109062e4208cc67559a1d16e02666b8664658981f2d653c1e50f3',
   '4f7d305e432109062e4208cc67559a1d16e02666b8664658981f2d653c1e50f3',
   'pass', '2026-08-07T16:30:52Z', 'LP-LOC-B2-EUC3-001', null)
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
  select e.event_key, f.file_key, e.relationship
  from (values
    (replication_event_key, 'outcome'::text),
    (fixity_event_key, 'subject'::text),
    (restore_event_key, 'outcome'::text),
    (ingest_event_key, 'outcome'::text)
  ) e(event_key, relationship)
  cross join (values
    (pdf_file_key),
    (bag_info_file_key),
    (bagit_file_key),
    (manifest_file_key),
    (tagmanifest_file_key)
  ) f(file_key)
  on conflict do nothing;

  insert into archive.quality_control_checks (
    check_id, item_id, representation_id, file_object_id,
    check_type, profile_version, outcome, checked_at, checked_by,
    tool_or_method, findings
  ) values
  (
    'LP-QC-2026-0001', item_key, original_representation_key, pdf_file_key,
    'malware', 'LP-QC-1.0', 'pass', '2026-08-07T15:00:35Z', owner_user_key,
    'ClamAV 1.5.3 with current official databases',
    jsonb_build_object('infected_files',0,'known_signatures',3627999,'preservation_event_id','LP-PRESEVENT-2026-0004')
  ),
  (
    'LP-QC-2026-0002', item_key, original_representation_key, pdf_file_key,
    'format_validation', 'LP-QC-1.0', 'pass_with_warnings', '2026-08-07T15:00:37Z', owner_user_key,
    'qpdf 12.3.2 + ExifTool 13.55 + Poppler pdfinfo 26.05.0 + file 5.41',
    jsonb_build_object('qpdf_warning_object_numbers',jsonb_build_array(48,50,184,221,236),'preservation_event_id','LP-PRESEVENT-2026-0005','original_modified',false)
  ),
  (
    'LP-QC-2026-0003', item_key, original_representation_key, pdf_file_key,
    'fixity', 'LP-QC-1.0', 'pass', '2026-08-07T16:30:52Z', owner_user_key,
    'Pre-upload SHA-256 + remote metadata comparison + complete restore SHA-256 + BagIt validation',
    jsonb_build_object('source_fixity_verified',true,'remote_metadata_verified',true,'restore_fixity_verified',true,'bagit_validation_passed',true,'preservation_event_id','LP-PRESEVENT-2026-0007')
  )
  on conflict (check_id) do update set
    item_id = excluded.item_id,
    representation_id = excluded.representation_id,
    file_object_id = excluded.file_object_id,
    outcome = excluded.outcome,
    checked_at = excluded.checked_at,
    checked_by = excluded.checked_by,
    tool_or_method = excluded.tool_or_method,
    findings = excluded.findings;

  update archive.storage_locations
  set evidence_status = 'tested',
      last_tested_at = '2026-08-07T16:30:52Z',
      recovery_notes = 'A full five-object BagIt pilot was uploaded, metadata-checked, downloaded into a clean restore tree, SHA-256 verified, and BagIt-validated on 2026-08-07. AES-256 server-side encryption and object version identifiers were observed. Object Lock remains disabled and the current application key retains broad capability by owner choice during setup; split replication, verification, and deletion authority before routine automation.',
      metadata = metadata || jsonb_build_object(
        'object_operations_performed', true,
        'fixity_test_performed', true,
        'restore_test_performed', true,
        'tested_package_id', 'LP-BAG-2026-0001',
        'tested_accession_id', 'LP-ACC-2026-0001',
        'tested_prefix', 'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001',
        'tested_object_count', 5,
        'tested_total_byte_count', 194032057,
        'server_side_encryption_observed', 'AES256',
        'temporary_transfer_bridge_deleted', true,
        'next_fixity_due_at', '2026-11-05T16:30:52Z',
        'evidence_document_id', 'LP-DOC-ARCH-024'
      ),
      updated_at = now()
  where id = location_key;

  update archive.transfer_packages
  set storage_bucket = 'miramonte-lapipa-preservation-pilot',
      storage_object_path = 'preservation/LP-ACC-2026-0001/LP-BAG-2026-0001',
      status = 'ingested',
      validated_at = '2026-08-07T16:30:52Z',
      validation_detail = validation_detail || jsonb_build_object(
        'managed_storage_status', 'ingested_and_restore_verified',
        'managed_storage_location_id', 'LP-LOC-B2-EUC3-001',
        'managed_object_count', 5,
        'managed_total_byte_count', 194032057,
        'source_fixity_verified', true,
        'remote_metadata_verified', true,
        'restore_fixity_verified', true,
        'restored_bagit_validation_passed', true,
        'server_side_encryption_observed', 'AES256',
        'ingested_at', '2026-08-07T16:30:52Z',
        'next_fixity_due_at', '2026-11-05T16:30:52Z',
        'evidence_document_id', 'LP-DOC-ARCH-024'
      ),
      updated_at = now()
  where id = package_key;

  update archive.accessions
  set metadata = metadata || jsonb_build_object(
        'stage', 'preservation_ingested_fixity_and_restore_verified',
        'item_id', 'LP-ITEM-2026-0001',
        'storage_location_id', 'LP-LOC-B2-EUC3-001',
        'ingested_at', '2026-08-07T16:30:52Z',
        'evidence_document_id', 'LP-DOC-ARCH-024'
      )
  where id = accession_key;

  update ops.review_tasks
  set reason = 'Preservation ingest is complete: malware and format validation, file-object registration, Backblaze replication, SHA-256 comparison, and full restore testing passed. Remaining review is item sensitivity, privacy and consent, accessibility, citation, and owner-approved publication scope.',
      status = 'open',
      resolved_at = null,
      resolved_by = null
  where review_id = 'LP-REV-FIRST-ACCESSION-2026-001';

  update archive.preservation_assessments
  set scope = 'La Pipa Documentary Archive foundation and operating controls, including one fixity-controlled accession replicated to and restored from independent object storage.',
      results = results || jsonb_build_object(
        'overall', 'partially_demonstrated',
        'storage', 'one_independent_online_replica_tested',
        'metadata', 'item_representation_file_and_copy_records_operational',
        'integrity', 'pilot_ingest_fixity_and_restore_demonstrated'
      ),
      evidence = evidence || jsonb_build_object(
        'pilot_item_id', 'LP-ITEM-2026-0001',
        'pilot_file_object_count', 5,
        'pilot_verified_copy_count', 5,
        'pilot_restore_test_passed', true,
        'pilot_restored_bagit_validation_passed', true,
        'tested_independent_preservation_locations', 1,
        'pilot_managed_storage_location_id', 'LP-LOC-B2-EUC3-001',
        'pilot_managed_storage_bucket', 'miramonte-lapipa-preservation-pilot',
        'pilot_ingested_at', '2026-08-07T16:30:52Z',
        'evidence_document_id', 'LP-DOC-ARCH-024'
      ),
      gaps = coalesce((
        select jsonb_agg(value)
        from jsonb_array_elements(gaps) value
        where value <> to_jsonb('No geographically and administratively independent preservation replica is configured and tested.'::text)
          and value <> to_jsonb('No restoration exercise has produced operating evidence.'::text)
          and value <> to_jsonb('The pilot submission package is valid, but managed-storage ingest, malware scan, file-object registration, rights review, and restore testing remain pending.'::text)
      ), '[]'::jsonb)
  where assessment_id = 'LP-ASSESS-2026-0001';

  insert into ops.audit_log (
    actor_user_id, actor_role, action, record_type, stable_record_id, details
  )
  select owner_user_key, 'owner', 'preservation_ingest_restore_verified',
         'transfer_package', 'LP-BAG-2026-0001',
         jsonb_build_object(
           'accession_id', 'LP-ACC-2026-0001',
           'item_id', 'LP-ITEM-2026-0001',
           'storage_location_id', 'LP-LOC-B2-EUC3-001',
           'object_count', 5,
           'total_byte_count', 194032057,
           'fixity_passed', true,
           'restore_passed', true,
           'temporary_bridge_deleted', true,
           'evidence_document_id', 'LP-DOC-ARCH-024'
         )
  where not exists (
    select 1 from ops.audit_log
    where action = 'preservation_ingest_restore_verified'
      and stable_record_id = 'LP-BAG-2026-0001'
  );
end $$;

insert into ops.schema_versions (version, description)
values (
  '2026-08-07-backblaze-pilot-ingest-restore-v1',
  'Registers LP-BAG-2026-0001 in Backblaze B2 with item, representation, file-object, copy, fixity, replication, restore, and audit evidence.'
)
on conflict (version) do nothing;

commit;
