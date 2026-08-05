begin;

create schema if not exists archive;
revoke all on schema archive from public, anon, authenticated;
grant usage on schema archive to service_role;

create table archive.controlled_terms (
  vocabulary text not null,
  code text not null,
  label text not null,
  definition text not null,
  authority_uri text,
  active boolean not null default true,
  sort_order integer not null default 0,
  primary key (vocabulary, code)
);

create table archive.collections (
  id bigint generated always as identity primary key,
  collection_id text not null unique,
  parent_collection_id bigint references archive.collections(id) on delete restrict,
  title text not null,
  description text,
  level_of_description text not null check (level_of_description in ('repository','fonds','collection','series','subseries','file')),
  inclusive_start_date date,
  inclusive_end_date date,
  date_text text,
  extent_statement text,
  arrangement_note text,
  custodial_history text,
  acquisition_note text,
  access_scope text not null default 'restricted' check (access_scope in ('closed','restricted','reading_room','public')),
  lifecycle_status text not null default 'draft' check (lifecycle_status in ('draft','review','approved','archived')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (inclusive_end_date is null or inclusive_start_date is null or inclusive_end_date >= inclusive_start_date),
  check (parent_collection_id is null or parent_collection_id <> id)
);
create index archive_collections_parent_idx on archive.collections (parent_collection_id);

create table archive.items (
  id bigint generated always as identity primary key,
  item_id text not null unique,
  collection_id bigint not null references archive.collections(id) on delete restrict,
  title text not null,
  alternative_titles text[] not null default '{}',
  item_type text not null check (item_type in ('moving_image','sound','photograph','graphic','document','object','dataset','web_resource','mixed_material')),
  description text,
  created_start date,
  created_end date,
  date_text text,
  languages text[] not null default '{}',
  places text[] not null default '{}',
  physical_description text,
  scope_and_content text,
  appraisal_note text,
  access_scope text not null default 'restricted' check (access_scope in ('closed','restricted','reading_room','public')),
  sensitivity_status text not null default 'unreviewed' check (sensitivity_status in ('unreviewed','clear','sensitive','highly_sensitive')),
  verification_status text not null default 'unreviewed',
  lifecycle_status text not null default 'draft' check (lifecycle_status in ('draft','review','approved','archived','withdrawn')),
  preferred_citation text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (created_end is null or created_start is null or created_end >= created_start)
);
create index archive_items_collection_idx on archive.items (collection_id, item_id);
create index archive_items_date_idx on archive.items (created_start, created_end);
create index archive_items_access_idx on archive.items (access_scope, lifecycle_status);

create table archive.identifiers (
  id bigint generated always as identity primary key,
  item_id bigint not null references archive.items(id) on delete cascade,
  identifier_type text not null,
  identifier_value text not null,
  authority text,
  canonical boolean not null default false,
  unique (item_id, identifier_type, identifier_value)
);
create unique index archive_identifiers_one_canonical_idx on archive.identifiers (item_id) where canonical;

create table archive.item_sources (
  item_id bigint not null references archive.items(id) on delete cascade,
  source_id bigint not null references kb.sources(id) on delete restrict,
  locator text,
  support_type text not null default 'documents' check (support_type in ('documents','depicts','describes','context','rights_evidence')),
  primary key (item_id, source_id, support_type)
);
create index archive_item_sources_source_idx on archive.item_sources (source_id);

create table archive.agents (
  id bigint generated always as identity primary key,
  agent_id text not null unique,
  entity_id bigint references kb.entities(id) on delete set null,
  agent_type text not null check (agent_type in ('person','family','organization','software','service')),
  authorized_name text not null,
  alternative_names text[] not null default '{}',
  authority_uri text,
  biography_or_history text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index archive_agents_entity_idx on archive.agents (entity_id);

create table archive.item_credits (
  item_id bigint not null references archive.items(id) on delete cascade,
  agent_id bigint not null references archive.agents(id) on delete restrict,
  role text not null,
  credited_as text,
  ordinal integer not null default 0 check (ordinal >= 0),
  note text,
  primary key (item_id, agent_id, role)
);
create index archive_item_credits_agent_idx on archive.item_credits (agent_id);

create table archive.subjects (
  id bigint generated always as identity primary key,
  subject_id text not null unique,
  pref_label text not null,
  alt_labels text[] not null default '{}',
  subject_type text not null check (subject_type in ('concept','person','organization','place','event','work','genre_form')),
  authority_uri text,
  scope_note text,
  broader_subject_id bigint references archive.subjects(id) on delete set null,
  created_at timestamptz not null default now()
);
create index archive_subjects_broader_idx on archive.subjects (broader_subject_id);

create table archive.item_subjects (
  item_id bigint not null references archive.items(id) on delete cascade,
  subject_id bigint not null references archive.subjects(id) on delete restrict,
  relation_type text not null default 'about' check (relation_type in ('about','depicts','mentions','genre_form')),
  primary key (item_id, subject_id, relation_type)
);
create index archive_item_subjects_subject_idx on archive.item_subjects (subject_id);

create table archive.representations (
  id bigint generated always as identity primary key,
  representation_id text not null unique,
  item_id bigint not null references archive.items(id) on delete cascade,
  purpose text not null check (purpose in ('original','preservation_master','mezzanine','access_copy','thumbnail','transcript','ocr','metadata_export')),
  generation text,
  label text,
  sequence_number integer not null default 0 check (sequence_number >= 0),
  complete boolean not null default true,
  active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (item_id, purpose, sequence_number)
);
create index archive_representations_item_idx on archive.representations (item_id, purpose);

create table archive.file_objects (
  id bigint generated always as identity primary key,
  file_id text not null unique,
  representation_id bigint not null references archive.representations(id) on delete cascade,
  original_filename text not null,
  normalized_filename text not null,
  storage_bucket text not null,
  storage_object_path text not null,
  mime_type text not null,
  format_name text,
  format_version text,
  format_registry text,
  format_registry_key text,
  byte_count bigint not null check (byte_count >= 0),
  sha256 text not null check (sha256 ~ '^[0-9a-f]{64}$'),
  creating_application text,
  creating_application_version text,
  created_at_source timestamptz,
  ingested_at timestamptz not null default now(),
  last_fixity_at timestamptz,
  fixity_status text not null default 'pending' check (fixity_status in ('pending','verified','failed','missing')),
  malware_scan_status text not null default 'pending' check (malware_scan_status in ('pending','clear','infected','failed','not_applicable')),
  metadata jsonb not null default '{}'::jsonb,
  unique (storage_bucket, storage_object_path),
  unique (sha256, byte_count)
);
create index archive_file_objects_representation_idx on archive.file_objects (representation_id);
create index archive_file_objects_fixity_idx on archive.file_objects (fixity_status, last_fixity_at);

create table archive.essence_tracks (
  id bigint generated always as identity primary key,
  track_id text not null unique,
  file_object_id bigint not null references archive.file_objects(id) on delete cascade,
  track_type text not null check (track_type in ('video','audio','text','timecode','data')),
  stream_index integer not null check (stream_index >= 0),
  codec_name text,
  codec_profile text,
  duration_ms bigint check (duration_ms is null or duration_ms >= 0),
  data_rate_bps bigint check (data_rate_bps is null or data_rate_bps >= 0),
  frame_rate numeric(10,5) check (frame_rate is null or frame_rate > 0),
  frame_width integer check (frame_width is null or frame_width > 0),
  frame_height integer check (frame_height is null or frame_height > 0),
  aspect_ratio text,
  color_space text,
  chroma_subsampling text,
  sampling_rate_hz integer check (sampling_rate_hz is null or sampling_rate_hz > 0),
  bit_depth integer check (bit_depth is null or bit_depth > 0),
  channel_count integer check (channel_count is null or channel_count > 0),
  channel_layout text,
  language text,
  metadata jsonb not null default '{}'::jsonb,
  unique (file_object_id, stream_index)
);
create index archive_essence_tracks_file_idx on archive.essence_tracks (file_object_id);

create table archive.transcripts (
  id bigint generated always as identity primary key,
  transcript_id text not null unique,
  item_id bigint not null references archive.items(id) on delete cascade,
  representation_id bigint references archive.representations(id) on delete set null,
  language text not null,
  transcript_type text not null check (transcript_type in ('verbatim','clean_read','subtitle','translation','ocr')),
  source_method text not null check (source_method in ('human','machine','machine_reviewed','hybrid')),
  status text not null default 'draft' check (status in ('draft','review','approved','superseded')),
  model_or_vendor text,
  vocabulary_notes text,
  speaker_reviewed boolean not null default false,
  content_sha256 text check (content_sha256 is null or content_sha256 ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index archive_transcripts_item_idx on archive.transcripts (item_id, language);

create table archive.transcript_segments (
  id bigint generated always as identity primary key,
  transcript_id bigint not null references archive.transcripts(id) on delete cascade,
  segment_id text not null,
  ordinal integer not null check (ordinal >= 0),
  start_ms bigint check (start_ms is null or start_ms >= 0),
  end_ms bigint check (end_ms is null or end_ms >= 0),
  speaker_agent_id bigint references archive.agents(id) on delete set null,
  speaker_label text,
  text text not null check (length(btrim(text)) > 0),
  confidence numeric(5,4) check (confidence is null or confidence between 0 and 1),
  review_status text not null default 'unreviewed' check (review_status in ('unreviewed','reviewed','corrected','redacted')),
  annotations jsonb not null default '{}'::jsonb,
  unique (transcript_id, segment_id),
  unique (transcript_id, ordinal),
  check (end_ms is null or start_ms is null or end_ms >= start_ms)
);
create index archive_transcript_segments_time_idx on archive.transcript_segments (transcript_id, start_ms);

create table archive.rights_statements (
  id bigint generated always as identity primary key,
  rights_id text not null unique,
  label text not null,
  rights_basis text not null check (rights_basis in ('copyright','license','statute','policy','contract','consent','other','unknown')),
  rights_uri text,
  rights_holder_agent_id bigint references archive.agents(id) on delete set null,
  jurisdiction text,
  start_date date,
  end_date date,
  permitted_uses text[] not null default '{}',
  restrictions text[] not null default '{}',
  credit_line text,
  evidence_source_id bigint references kb.sources(id) on delete restrict,
  review_status text not null default 'unreviewed' check (review_status in ('unreviewed','review','approved','expired','superseded')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_date is null or start_date is null or end_date >= start_date)
);
create index archive_rights_holder_idx on archive.rights_statements (rights_holder_agent_id);

create table archive.item_rights (
  item_id bigint not null references archive.items(id) on delete cascade,
  rights_statement_id bigint not null references archive.rights_statements(id) on delete restrict,
  applies_to text not null default 'content' check (applies_to in ('content','metadata','digital_file','transcript','image','audio','video')),
  access_decision text not null check (access_decision in ('closed','restricted','reading_room','public')),
  embargo_until date,
  primary key (item_id, rights_statement_id, applies_to)
);
create index archive_item_rights_statement_idx on archive.item_rights (rights_statement_id);

create table archive.preservation_events (
  id bigint generated always as identity primary key,
  event_id text not null unique,
  event_type text not null check (event_type in ('capture','ingest','virus_check','metadata_extraction','normalization','transcode','fixity_check','replication','migration','validation','redaction','publication','withdrawal','restore')),
  event_at timestamptz not null,
  outcome text not null check (outcome in ('success','partial','failure','warning')),
  outcome_detail text,
  agent_id bigint references archive.agents(id) on delete set null,
  software_agent text,
  command_or_process text,
  event_detail jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index archive_preservation_events_type_time_idx on archive.preservation_events (event_type, event_at);

create table archive.event_file_links (
  preservation_event_id bigint not null references archive.preservation_events(id) on delete cascade,
  file_object_id bigint not null references archive.file_objects(id) on delete restrict,
  relationship text not null check (relationship in ('source','outcome','subject')),
  primary key (preservation_event_id, file_object_id, relationship)
);
create index archive_event_file_links_file_idx on archive.event_file_links (file_object_id);

create table archive.fixity_checks (
  id bigint generated always as identity primary key,
  check_id text not null unique,
  file_object_id bigint not null references archive.file_objects(id) on delete cascade,
  preservation_event_id bigint not null references archive.preservation_events(id) on delete restrict,
  algorithm text not null check (algorithm in ('sha256','sha512')),
  expected_digest text not null,
  observed_digest text,
  result text not null check (result in ('pass','fail','missing','error')),
  checked_at timestamptz not null,
  storage_location text,
  error_detail text,
  check ((algorithm = 'sha256' and expected_digest ~ '^[0-9a-f]{64}$') or (algorithm = 'sha512' and expected_digest ~ '^[0-9a-f]{128}$')),
  check (observed_digest is null or observed_digest ~ '^[0-9a-f]+$')
);
create index archive_fixity_checks_file_time_idx on archive.fixity_checks (file_object_id, checked_at desc);

create table archive.accessions (
  id bigint generated always as identity primary key,
  accession_id text not null unique,
  collection_id bigint references archive.collections(id) on delete restrict,
  accessioned_at date not null,
  source_agent_id bigint references archive.agents(id) on delete set null,
  transfer_method text,
  agreement_reference text,
  extent_statement text,
  appraisal_decision text,
  restrictions_note text,
  receipt_confirmed boolean not null default false,
  manifest_sha256 text check (manifest_sha256 is null or manifest_sha256 ~ '^[0-9a-f]{64}$'),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table archive.custody_events (
  id bigint generated always as identity primary key,
  custody_event_id text not null unique,
  accession_id bigint references archive.accessions(id) on delete restrict,
  item_id bigint references archive.items(id) on delete restrict,
  event_at timestamptz not null,
  event_type text not null check (event_type in ('offered','received','transferred','returned','loaned','located','relocated','released')),
  from_agent_id bigint references archive.agents(id) on delete set null,
  to_agent_id bigint references archive.agents(id) on delete set null,
  location text,
  evidence_source_id bigint references kb.sources(id) on delete restrict,
  note text,
  created_at timestamptz not null default now(),
  check (accession_id is not null or item_id is not null)
);
create index archive_custody_events_item_time_idx on archive.custody_events (item_id, event_at);
create index archive_custody_events_accession_idx on archive.custody_events (accession_id, event_at);

insert into archive.controlled_terms (vocabulary, code, label, definition, authority_uri, sort_order) values
  ('representation_purpose','original','Original','Received or captured object in its original state.','https://www.loc.gov/standards/premis/',10),
  ('representation_purpose','preservation_master','Preservation master','Highest-fidelity managed representation retained for long-term preservation.','https://www.loc.gov/standards/premis/',20),
  ('representation_purpose','mezzanine','Mezzanine','High-quality production derivative suitable for editing and future derivatives.','https://pbcore.org/',30),
  ('representation_purpose','access_copy','Access copy','Derivative optimized for discovery, streaming, or research use.','https://pbcore.org/',40),
  ('access_scope','closed','Closed','No access pending legal, ethical, preservation, or donor review.',null,10),
  ('access_scope','restricted','Restricted','Access only for authorized staff or named users under stated conditions.',null,20),
  ('access_scope','reading_room','Reading room','Mediated research access without unrestricted redistribution.',null,30),
  ('access_scope','public','Public','Approved for public access subject to the recorded rights statement.',null,40),
  ('preservation_event','fixity_check','Fixity check','Recalculation and comparison of a cryptographic digest.','https://id.loc.gov/vocabulary/preservation/eventType/fix',10),
  ('preservation_event','migration','Migration','Creation of a new representation to mitigate format or platform risk.','https://www.loc.gov/standards/premis/',20),
  ('preservation_event','validation','Validation','Assessment of a file or package against its declared format or profile.','https://www.loc.gov/standards/premis/',30);

insert into archive.collections (
  collection_id, title, description, level_of_description, date_text,
  extent_statement, access_scope, lifecycle_status, metadata
) values (
  'LP-ARCHIVE-001',
  'La Pipa Documentary Archive',
  'The archival control record for original, digitized, and born-digital materials documenting La Pipa, its people, places, activities, productions, and legacy.',
  'fonds',
  'Open dates; collection building began in 2026',
  'Evolving hybrid documentary archive; extent to be established through accessioning and fixity-controlled ingest.',
  'restricted',
  'approved',
  jsonb_build_object('standards_profile','LP-MAP-1.0','premis_version','3.0','pbcore_version','2.1','iiif_presentation_version','3.0')
);

do $$
declare table_record record;
begin
  for table_record in select tablename from pg_tables where schemaname='archive'
  loop
    execute format('alter table archive.%I enable row level security', table_record.tablename);
  end loop;
end $$;

revoke all on all tables in schema archive from public, anon, authenticated;
revoke all on all sequences in schema archive from public, anon, authenticated;
grant select, insert, update, delete on all tables in schema archive to service_role;
grant usage, select on all sequences in schema archive to service_role;

insert into storage.buckets (id, name, public, file_size_limit)
values
  ('preservation-masters','preservation-masters',false,5368709120),
  ('access-media','access-media',false,2147483648)
on conflict (id) do update set public=excluded.public, file_size_limit=excluded.file_size_limit;

create policy archive_media_member_select on storage.objects for select to authenticated
using (
  bucket_id in ('preservation-masters','access-media')
  and (select private.has_workspace_role(array['owner','editor','reviewer','reader']))
);
create policy archive_media_editor_insert on storage.objects for insert to authenticated
with check (
  bucket_id in ('preservation-masters','access-media')
  and (storage.foldername(name))[1]='la-pipa'
  and (select private.has_workspace_role(array['owner','editor']))
);
create policy archive_media_editor_update on storage.objects for update to authenticated
using (
  bucket_id in ('preservation-masters','access-media')
  and (select private.has_workspace_role(array['owner','editor']))
)
with check (
  bucket_id in ('preservation-masters','access-media')
  and (storage.foldername(name))[1]='la-pipa'
  and (select private.has_workspace_role(array['owner','editor']))
);
create policy archive_media_owner_delete on storage.objects for delete to authenticated
using (
  bucket_id in ('preservation-masters','access-media')
  and (select private.has_workspace_role(array['owner']))
);

insert into ops.schema_versions (version, description)
values ('2026-08-05-archive-v1', 'PREMIS-aligned preservation, PBCore-aligned audiovisual, transcript, rights, accession, custody, and fixity layer.');

alter default privileges for role postgres in schema archive revoke all on tables from public, anon, authenticated;
alter default privileges for role postgres in schema archive revoke all on sequences from public, anon, authenticated;
alter default privileges for role postgres in schema archive grant select, insert, update, delete on tables to service_role;
alter default privileges for role postgres in schema archive grant usage, select on sequences to service_role;

commit;
