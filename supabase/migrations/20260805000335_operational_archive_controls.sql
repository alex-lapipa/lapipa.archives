begin;

create table archive.storage_locations (
  id bigint generated always as identity primary key,
  location_id text not null unique,
  name text not null,
  provider text not null,
  service_type text not null check (service_type in ('object_storage','filesystem','offline_media','repository','cold_archive')),
  role text not null check (role in ('operational','replica','offline','access','quarantine')),
  administrative_domain text not null,
  geographic_region text,
  media_or_storage_class text,
  online boolean not null default true,
  immutable_or_object_locked boolean not null default false,
  encrypted_at_rest boolean,
  active boolean not null default true,
  evidence_status text not null default 'planned' check (evidence_status in ('planned','configured','tested','degraded','retired')),
  last_tested_at timestamptz,
  recovery_notes text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table archive.file_copies (
  id bigint generated always as identity primary key,
  copy_id text not null unique,
  file_object_id bigint not null references archive.file_objects(id) on delete cascade,
  storage_location_id bigint not null references archive.storage_locations(id) on delete restrict,
  storage_bucket text,
  storage_object_path text not null,
  storage_version_id text,
  replica_state text not null default 'pending' check (replica_state in ('pending','copying','verified','degraded','missing','retired')),
  expected_sha256 text not null check (expected_sha256 ~ '^[0-9a-f]{64}$'),
  observed_sha256 text check (observed_sha256 is null or observed_sha256 ~ '^[0-9a-f]{64}$'),
  byte_count bigint not null check (byte_count >= 0),
  copied_at timestamptz,
  last_verified_at timestamptz,
  next_verification_due_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (storage_location_id, storage_object_path, storage_version_id),
  unique (file_object_id, storage_location_id, storage_object_path)
);
create index archive_file_copies_file_idx on archive.file_copies (file_object_id, replica_state);
create index archive_file_copies_location_idx on archive.file_copies (storage_location_id, replica_state);
create index archive_file_copies_due_idx on archive.file_copies (next_verification_due_at) where replica_state='verified';
create unique index archive_file_copies_location_object_version_idx
  on archive.file_copies (storage_location_id, storage_object_path, coalesce(storage_version_id,''));

create table archive.file_relationships (
  id bigint generated always as identity primary key,
  source_file_object_id bigint not null references archive.file_objects(id) on delete restrict,
  target_file_object_id bigint not null references archive.file_objects(id) on delete cascade,
  relationship_type text not null check (relationship_type in ('derived_from','normalized_from','transcoded_from','extracted_from','redacted_from','thumbnail_of','transcript_of','metadata_for','part_of')),
  preservation_event_id bigint references archive.preservation_events(id) on delete restrict,
  transformation_profile text,
  created_at timestamptz not null default now(),
  check (source_file_object_id <> target_file_object_id),
  unique (source_file_object_id, target_file_object_id, relationship_type)
);
create index archive_file_relationships_source_idx on archive.file_relationships (source_file_object_id);
create index archive_file_relationships_target_idx on archive.file_relationships (target_file_object_id);
create index archive_file_relationships_event_idx on archive.file_relationships (preservation_event_id);

create table archive.transfer_packages (
  id bigint generated always as identity primary key,
  package_id text not null unique,
  accession_id bigint references archive.accessions(id) on delete restrict,
  package_type text not null check (package_type in ('submission','archival','dissemination')),
  bagit_version text,
  tag_file_encoding text not null default 'UTF-8',
  manifest_algorithm text not null check (manifest_algorithm in ('sha256','sha512')),
  package_sha256 text check (package_sha256 is null or package_sha256 ~ '^[0-9a-f]{64}$'),
  payload_file_count bigint not null default 0 check (payload_file_count >= 0),
  payload_byte_count bigint not null default 0 check (payload_byte_count >= 0),
  storage_bucket text,
  storage_object_path text,
  status text not null default 'received' check (status in ('received','validating','valid','invalid','ingested','superseded')),
  validation_tool text,
  validated_at timestamptz,
  validation_detail jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index archive_transfer_packages_accession_idx on archive.transfer_packages (accession_id, created_at);
create index archive_transfer_packages_status_idx on archive.transfer_packages (status, created_at);

create table archive.transfer_package_files (
  transfer_package_id bigint not null references archive.transfer_packages(id) on delete cascade,
  relative_path text not null,
  payload boolean not null default true,
  byte_count bigint not null check (byte_count >= 0),
  digest_algorithm text not null check (digest_algorithm in ('sha256','sha512')),
  digest text not null check (digest ~ '^[0-9a-f]+$'),
  file_object_id bigint references archive.file_objects(id) on delete set null,
  ingest_decision text not null default 'pending' check (ingest_decision in ('pending','accepted','duplicate','excluded','quarantined','failed')),
  note text,
  primary key (transfer_package_id, relative_path)
);
create index archive_transfer_package_files_object_idx on archive.transfer_package_files (file_object_id);
create index archive_transfer_package_files_decision_idx on archive.transfer_package_files (transfer_package_id, ingest_decision);

create table archive.consent_records (
  id bigint generated always as identity primary key,
  consent_id text not null unique,
  item_id bigint references archive.items(id) on delete restrict,
  participant_agent_id bigint not null references archive.agents(id) on delete restrict,
  consent_type text not null check (consent_type in ('participation','recording','archiving','research_access','public_access','quotation','image_use','name_use','other')),
  granted boolean not null,
  granted_at timestamptz,
  valid_from date,
  valid_until date,
  territories text[] not null default '{}',
  media_and_channels text[] not null default '{}',
  conditions text[] not null default '{}',
  withdrawal_terms text,
  withdrawn_at timestamptz,
  evidence_source_id bigint references kb.sources(id) on delete restrict,
  evidence_file_object_id bigint references archive.file_objects(id) on delete restrict,
  review_status text not null default 'unreviewed' check (review_status in ('unreviewed','review','approved','withdrawn','expired','superseded')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (valid_until is null or valid_from is null or valid_until >= valid_from),
  check (not granted or granted_at is not null)
);
create index archive_consent_records_item_idx on archive.consent_records (item_id, review_status);
create index archive_consent_records_participant_idx on archive.consent_records (participant_agent_id);
create index archive_consent_records_source_idx on archive.consent_records (evidence_source_id);
create index archive_consent_records_file_idx on archive.consent_records (evidence_file_object_id);

create table archive.takedown_requests (
  id bigint generated always as identity primary key,
  request_id text not null unique,
  item_id bigint references archive.items(id) on delete restrict,
  representation_id bigint references archive.representations(id) on delete restrict,
  requester_name text not null,
  requester_contact_ref text,
  received_at timestamptz not null,
  reason_category text not null check (reason_category in ('copyright','privacy','consent','defamation','safety','cultural_sensitivity','accuracy','other')),
  request_summary text not null,
  status text not null default 'received' check (status in ('received','triage','temporarily_restricted','under_review','upheld','partially_upheld','declined','withdrawn','closed')),
  immediate_action text,
  decision text,
  decided_at timestamptz,
  decided_by uuid references auth.users(id) on delete set null,
  response_due_at timestamptz,
  confidential_detail jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (item_id is not null or representation_id is not null)
);
create index archive_takedown_requests_item_idx on archive.takedown_requests (item_id, status);
create index archive_takedown_requests_representation_idx on archive.takedown_requests (representation_id);
create index archive_takedown_requests_decider_idx on archive.takedown_requests (decided_by);
create index archive_takedown_requests_due_idx on archive.takedown_requests (response_due_at) where status not in ('declined','withdrawn','closed');

create table archive.quality_control_checks (
  id bigint generated always as identity primary key,
  check_id text not null unique,
  item_id bigint references archive.items(id) on delete cascade,
  representation_id bigint references archive.representations(id) on delete cascade,
  file_object_id bigint references archive.file_objects(id) on delete cascade,
  check_type text not null check (check_type in ('fixity','format_validation','malware','technical_av','metadata','transcript','rights','consent','privacy','accessibility','editorial','citation','release_package')),
  profile_version text not null,
  outcome text not null check (outcome in ('pass','pass_with_warnings','fail','not_applicable')),
  checked_at timestamptz not null,
  checked_by uuid references auth.users(id) on delete set null,
  tool_or_method text not null,
  findings jsonb not null default '{}'::jsonb,
  remediation_due_at timestamptz,
  remediated_at timestamptz,
  supersedes_check_id bigint references archive.quality_control_checks(id) on delete set null,
  created_at timestamptz not null default now(),
  check (item_id is not null or representation_id is not null or file_object_id is not null)
);
create index archive_quality_checks_item_idx on archive.quality_control_checks (item_id, check_type, checked_at desc);
create index archive_quality_checks_representation_idx on archive.quality_control_checks (representation_id);
create index archive_quality_checks_file_idx on archive.quality_control_checks (file_object_id);
create index archive_quality_checks_checker_idx on archive.quality_control_checks (checked_by);
create index archive_quality_checks_supersedes_idx on archive.quality_control_checks (supersedes_check_id);
create index archive_quality_checks_remediation_idx on archive.quality_control_checks (remediation_due_at) where outcome in ('fail','pass_with_warnings') and remediated_at is null;

create table archive.release_records (
  id bigint generated always as identity primary key,
  release_id text not null unique,
  title text not null,
  release_type text not null check (release_type in ('research_export','catalog_release','exhibition','documentary','dataset','iiif_collection','rag_corpus')),
  version text not null,
  status text not null default 'draft' check (status in ('draft','review','approved','published','withdrawn','superseded')),
  release_notes text,
  manifest_sha256 text check (manifest_sha256 is null or manifest_sha256 ~ '^[0-9a-f]{64}$'),
  storage_bucket text,
  storage_object_path text,
  approved_by uuid references auth.users(id) on delete set null,
  approved_at timestamptz,
  published_at timestamptz,
  withdrawn_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (title, version),
  check (status not in ('approved','published') or (approved_by is not null and approved_at is not null))
);
create index archive_release_records_approver_idx on archive.release_records (approved_by);
create index archive_release_records_status_idx on archive.release_records (status, created_at);

create table archive.release_items (
  release_record_id bigint not null references archive.release_records(id) on delete cascade,
  item_id bigint not null references archive.items(id) on delete restrict,
  representation_id bigint references archive.representations(id) on delete restrict,
  ordinal integer not null check (ordinal >= 0),
  public_label text,
  citation_text text not null,
  rights_statement_id bigint not null references archive.rights_statements(id) on delete restrict,
  access_decision text not null check (access_decision in ('reading_room','public')),
  primary key (release_record_id, item_id, ordinal)
);
create index archive_release_items_item_idx on archive.release_items (item_id);
create index archive_release_items_representation_idx on archive.release_items (representation_id);
create index archive_release_items_rights_idx on archive.release_items (rights_statement_id);

create table archive.preservation_assessments (
  id bigint generated always as identity primary key,
  assessment_id text not null unique,
  framework text not null,
  framework_version text not null,
  assessment_date date not null,
  scope text not null,
  assessor text not null,
  results jsonb not null,
  evidence jsonb not null default '{}'::jsonb,
  gaps jsonb not null default '[]'::jsonb,
  approved_by uuid references auth.users(id) on delete set null,
  approved_at timestamptz,
  next_assessment_due date not null,
  created_at timestamptz not null default now()
);
create index archive_preservation_assessments_approver_idx on archive.preservation_assessments (approved_by);
create index archive_preservation_assessments_due_idx on archive.preservation_assessments (next_assessment_due);

insert into archive.storage_locations (
  location_id, name, provider, service_type, role, administrative_domain,
  geographic_region, media_or_storage_class, online, immutable_or_object_locked,
  encrypted_at_rest, evidence_status, recovery_notes, metadata
) values (
  'LP-LOC-SUPABASE-EU-001', 'Supabase operational object storage', 'Supabase',
  'object_storage', 'operational', 'Supabase project jxilnxchvdeiazmopslf',
  'eu-west-1', 'managed object storage', true, false, true, 'configured',
  'Operational copy only. This record does not count as a geographically or administratively independent preservation replica.',
  jsonb_build_object('project_ref','jxilnxchvdeiazmopslf','verification_date','2026-08-05')
);

insert into archive.controlled_terms (vocabulary, code, label, definition, authority_uri, sort_order) values
  ('package_type','submission','Submission Information Package','Material transferred to the archive for appraisal and ingest.','https://www.iso.org/standard/87471.html',10),
  ('package_type','archival','Archival Information Package','Managed preservation package retained by the archive.','https://www.iso.org/standard/87471.html',20),
  ('package_type','dissemination','Dissemination Information Package','Package produced for an authorized user or release.','https://www.iso.org/standard/87471.html',30),
  ('copy_role','operational','Operational','Primary managed copy used by the active repository.',null,10),
  ('copy_role','replica','Replica','Independent managed preservation copy.',null,20),
  ('copy_role','offline','Offline','Offline or logically isolated preservation copy.',null,30),
  ('quality_gate','rights','Rights','Rights evidence and access decision have been reviewed.',null,10),
  ('quality_gate','accessibility','Accessibility','Required captions, transcript, alternatives, and navigation have passed review.',null,20),
  ('quality_gate','citation','Citation','Every public assertion and media use retains stable evidence references.',null,30)
on conflict (vocabulary, code) do update set
  label=excluded.label, definition=excluded.definition, authority_uri=excluded.authority_uri,
  active=true, sort_order=excluded.sort_order;

do $$
declare table_record record;
begin
  for table_record in
    select tablename from pg_tables
    where schemaname='archive'
      and tablename in (
        'storage_locations','file_copies','file_relationships','transfer_packages',
        'transfer_package_files','consent_records','takedown_requests',
        'quality_control_checks','release_records','release_items','preservation_assessments'
      )
  loop
    execute format('alter table archive.%I enable row level security', table_record.tablename);
    execute format(
      'create policy %I on archive.%I for select to authenticated using ((select private.has_workspace_role(array[''owner'',''editor'',''reviewer'',''reader''])))',
      table_record.tablename || '_member_select', table_record.tablename
    );
    execute format(
      'create policy %I on archive.%I for insert to authenticated with check ((select private.has_workspace_role(array[''owner'',''editor''])))',
      table_record.tablename || '_editor_insert', table_record.tablename
    );
    execute format(
      'create policy %I on archive.%I for update to authenticated using ((select private.has_workspace_role(array[''owner'',''editor'']))) with check ((select private.has_workspace_role(array[''owner'',''editor''])))',
      table_record.tablename || '_editor_update', table_record.tablename
    );
    execute format(
      'create policy %I on archive.%I for delete to authenticated using ((select private.has_workspace_role(array[''owner''])))',
      table_record.tablename || '_owner_delete', table_record.tablename
    );
  end loop;
end $$;

revoke all on all tables in schema archive from public, anon, authenticated;
revoke all on all sequences in schema archive from public, anon, authenticated;
grant select, insert, update, delete on all tables in schema archive to service_role;
grant usage, select on all sequences in schema archive to service_role;

insert into ops.schema_versions (version, description)
values ('2026-08-05-archive-v1.2', 'Operational package, preservation-copy, derivative-lineage, consent, takedown, quality-control, release, and maturity-assessment controls.');

commit;
