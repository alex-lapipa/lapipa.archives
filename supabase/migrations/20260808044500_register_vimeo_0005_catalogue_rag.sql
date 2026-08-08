begin;

do $$
begin
  if not exists (select 1 from archive.items where item_id = 'LP-MEDIA-VIMEO-VIDEO-844151157')
     or not exists (select 1 from kb.sources where source_id = 'LP-MEDIA-VIMEO-VIDEO-844151157')
     or not exists (select 1 from archive.storage_locations where location_id = 'LP-LOC-B2-EUC3-002') then
    raise exception 'LP-ACC-2026-0005 prerequisite catalogue records are missing' using errcode = '55000';
  end if;

  if exists (
    select 1
    from archive.file_objects
    where sha256 in (
      'b15ea951246acdd46561f13f87be7fc2de0b2ba35ac7dc79a4f437b7617e09aa',
      '8e7366500e41a6c2ed3fd0ed519782ea5de4cf849ba707969b2c2f7b3f9c3c29',
      '58161bd73117cd207757c5d58b207d3c88717b29c815c8bd4b8632ca10734953',
      '6d67f7f9b41da27c677a682ed8e8524e02902b82890b013759dbcf146a09a84c',
      '35552506b87395007847fc120fdfa8233e1a1658caecb8453c6a66197fe03604',
      'e31eeecff4fa63f59c01f93aef8a853a4b8460b3f98c2fe0880ce73fe02a2a52',
      'b8bee7379ec584a86eaa044b00319b91df17948a81edc198c22635011fefa3df',
      'b4c819ed6c5907c6ed48056a6578e7a391f37ea53deb524ea24477cb2138d5a4',
      'f87f1446f083e18e9dd1c5790105210e3bc54c25f7b8568887fd218869143cc3',
      '197c47a2391312a27eb9190688a7976116dbcc0157218e637a9ab20453ce5eab',
      'f6d90f1c93e058ea7a6506e72994d026fa6404224bf0f67d6b4d7503812f8d36'
    )
    and file_id not like 'LP-FILE-VIMEO-844151157-%'
  ) then
    raise exception 'LP-ACC-2026-0005 content hash already belongs to another canonical file object' using errcode = '23505';
  end if;
end;
$$;

insert into archive.accessions (
  accession_id, collection_id, accessioned_at, source_agent_id,
  transfer_method, agreement_reference, extent_statement,
  appraisal_decision, restrictions_note, receipt_confirmed,
  manifest_sha256, metadata
)
select
  'LP-ACC-2026-0005',
  c.id,
  '2026-08-08'::date,
  a.id,
  'Vimeo owner API source download; checksum-controlled local staging; owner-capability-scoped signed HTTPS transfer to Backblaze B2; clean restore; SHA-256 comparison',
  'Alex Lawton and Miramonte, S.L. rights declaration',
  '1 source-quality Vimeo preservation master; 5 transcript artifacts; 5 manifests or transfer-control artifacts; 11 objects; 328,042,607 bytes',
  'Accepted as the first fully restored and fixity-verified single-video Vimeo preservation accession',
  'No source deletion authorized. Machine transcript is restricted, provisional, and not approved for verified quotation.',
  true,
  'f6d90f1c93e058ea7a6506e72994d026fa6404224bf0f67d6b4d7503812f8d36',
  jsonb_build_object(
    'status', 'uploaded_restored_fixity_verified',
    'completed_at', '2026-08-08T03:42:34.393Z',
    'vimeo_video_id', '844151157',
    'storage_location_id', 'LP-LOC-B2-EUC3-002',
    'backblaze_bucket', 'miramonte-lapipa-archive',
    'remote_prefix', 'lapipa/vimeo/LP-ACC-2026-0005',
    'object_count', 11,
    'verified_count', 11,
    'total_byte_count', 328042607,
    'verification_method', 'exact_path_put_head_get_then_clean_restore_sha256',
    'server_side_encryption', 'AES256',
    'source_deletion_authorized', false,
    'transcript_status', 'machine_generated_provisional',
    'human_transcript_review_required', true,
    'credential_values_recorded', false
  )
from archive.collections c
left join archive.agents a on a.agent_id = 'LP-AGENT-ALEX-LAWTON'
where c.collection_id = 'LP-ARCHIVE-001'
on conflict (accession_id) do update set
  receipt_confirmed = excluded.receipt_confirmed,
  manifest_sha256 = excluded.manifest_sha256,
  restrictions_note = excluded.restrictions_note,
  metadata = archive.accessions.metadata || excluded.metadata;

update archive.storage_locations
set evidence_status = 'tested',
    last_tested_at = '2026-08-08T03:42:34.393Z'::timestamptz,
    metadata = metadata || jsonb_build_object(
      'latest_verified_accession_id', 'LP-ACC-2026-0005',
      'latest_verified_object_count', 11,
      'latest_verified_total_byte_count', 328042607,
      'latest_verification_method', 'exact_path_put_head_get_then_clean_restore_sha256',
      'latest_restore_sha256_match_count', 11,
      'latest_server_side_encryption', 'AES256',
      'source_deletion_authorized', false
    ),
    updated_at = now()
where location_id = 'LP-LOC-B2-EUC3-002';

update archive.items
set languages = array['es'],
    verification_status = 'provider_metadata_preservation_and_restore_verified',
    metadata = metadata || jsonb_build_object(
      'preservation_accession_id', 'LP-ACC-2026-0005',
      'preservation_status', 'uploaded_restored_fixity_verified',
      'preservation_master_sha256', 'b15ea951246acdd46561f13f87be7fc2de0b2ba35ac7dc79a4f437b7617e09aa',
      'preservation_master_bytes', 328003637,
      'preservation_object_path', 'lapipa/vimeo/LP-ACC-2026-0005/preservation/vimeo-844151157-source.mp4',
      'transcript_id', 'LP-TRANSCRIPT-VIMEO-844151157-ES-MLX-V1',
      'transcript_status', 'machine_generated_provisional',
      'human_transcript_review_required', true,
      'source_deletion_authorized', false
    ),
    updated_at = now()
where item_id = 'LP-MEDIA-VIMEO-VIDEO-844151157';

update kb.sources
set verification_status = 'provider_metadata_preservation_and_restore_verified',
    description = 'Vimeo video evidenced on lapipa.io, reconciled through the owner API, preserved in Backblaze B2, clean-restored, SHA-256 verified, and transcribed provisionally in Spanish.',
    metadata = metadata || jsonb_build_object(
      'preservation', jsonb_build_object(
        'accession_id', 'LP-ACC-2026-0005',
        'status', 'uploaded_restored_fixity_verified',
        'b2_object_key', 'lapipa/vimeo/LP-ACC-2026-0005/preservation/vimeo-844151157-source.mp4',
        'sha256', 'b15ea951246acdd46561f13f87be7fc2de0b2ba35ac7dc79a4f437b7617e09aa',
        'bytes', 328003637,
        'restore_verified_at', '2026-08-08T03:42:34.393Z',
        'source_deletion_authorized', false
      ),
      'transcript', jsonb_build_object(
        'transcript_id', 'LP-TRANSCRIPT-VIMEO-844151157-ES-MLX-V1',
        'language', 'es',
        'status', 'machine_generated_provisional',
        'model', 'mlx-community/whisper-large-v3-turbo',
        'human_review_required', true,
        'verified_quotation_approved', false
      )
    ),
    updated_at = now()
where source_id = 'LP-MEDIA-VIMEO-VIDEO-844151157';

insert into archive.identifiers (item_id, identifier_type, identifier_value, authority, canonical)
select id, 'Vimeo video ID', '844151157', 'Vimeo', false
from archive.items where item_id = 'LP-MEDIA-VIMEO-VIDEO-844151157'
on conflict (item_id, identifier_type, identifier_value) do update set authority = excluded.authority;

insert into archive.representations (
  representation_id, item_id, purpose, generation, label,
  sequence_number, complete, active, metadata
)
select v.representation_id, i.id, v.purpose, v.generation, v.label,
       0, true, true, v.metadata
from archive.items i
cross join (values
  ('LP-REP-VIMEO-844151157-MEDIA', 'preservation_master', 'generation_1', 'Vimeo source-quality preservation master', '{"accession_id":"LP-ACC-2026-0005","vimeo_video_id":"844151157","normalized_or_transcoded":false}'::jsonb),
  ('LP-REP-VIMEO-844151157-TRANSCRIPT', 'transcript', 'machine_generation_1', 'MLX Whisper Spanish transcript artifacts', '{"accession_id":"LP-ACC-2026-0005","status":"machine_generated_provisional","human_review_required":true}'::jsonb),
  ('LP-REP-VIMEO-844151157-METADATA', 'metadata_export', 'generation_1', 'Download, technical, transcript, ingest, and transfer manifests', '{"accession_id":"LP-ACC-2026-0005","object_count":5}'::jsonb)
) as v(representation_id, purpose, generation, label, metadata)
where i.item_id = 'LP-MEDIA-VIMEO-VIDEO-844151157'
on conflict (representation_id) do update set
  active = true,
  complete = true,
  metadata = archive.representations.metadata || excluded.metadata;

create temporary table tmp_lapipa_vimeo_0005_files (
  ordinal integer primary key,
  file_id text not null,
  copy_id text not null,
  representation_id text not null,
  filename text not null,
  object_path text not null,
  mime_type text not null,
  format_name text not null,
  byte_count bigint not null,
  sha256 text not null,
  creating_application text,
  creating_application_version text,
  created_at_source timestamptz,
  malware_scan_status text not null,
  archival_role text not null,
  storage_version_id text not null,
  etag text not null
) on commit drop;

insert into tmp_lapipa_vimeo_0005_files values
  (1,'LP-FILE-VIMEO-844151157-PRESERVATION-MASTER','LP-COPY-B2-VIMEO-844151157-PRESERVATION-MASTER','LP-REP-VIMEO-844151157-MEDIA','vimeo-844151157-source.mp4','lapipa/vimeo/LP-ACC-2026-0005/preservation/vimeo-844151157-source.mp4','video/mp4','QuickTime / MOV; Apple ProRes 422 Standard; PCM 24-bit stereo',328003637,'b15ea951246acdd46561f13f87be7fc2de0b2ba35ac7dc79a4f437b7617e09aa','Vimeo',null,'2023-07-07T18:02:50Z','pending','preservation_master','4_z26c26b5c7399daef90f40c13_f10042d9ea1f6642c_d20260808_m034118_c003_v0312039_t0050_u01786160478323','"7c78695cd492b3f4c14533ccbaad321f"'),
  (2,'LP-FILE-VIMEO-844151157-TRANSCRIPT-JSON','LP-COPY-B2-VIMEO-844151157-TRANSCRIPT-JSON','LP-REP-VIMEO-844151157-TRANSCRIPT','vimeo-844151157-mlx-large-v3-turbo-es.json','lapipa/vimeo/LP-ACC-2026-0005/transcripts/vimeo-844151157-mlx-large-v3-turbo-es.json','application/json','MLX Whisper JSON',14651,'8e7366500e41a6c2ed3fd0ed519782ea5de4cf849ba707969b2c2f7b3f9c3c29','mlx-whisper','0.4.3','2026-08-08T03:14:42.496Z','not_applicable','machine_transcript','4_z26c26b5c7399daef90f40c13_f105b2114acbf5961_d20260808_m034223_c003_v0312022_t0044_u01786160543994','"47010a5e0d14f96507baf66a96758182"'),
  (3,'LP-FILE-VIMEO-844151157-TRANSCRIPT-SRT','LP-COPY-B2-VIMEO-844151157-TRANSCRIPT-SRT','LP-REP-VIMEO-844151157-TRANSCRIPT','vimeo-844151157-mlx-large-v3-turbo-es.srt','lapipa/vimeo/LP-ACC-2026-0005/transcripts/vimeo-844151157-mlx-large-v3-turbo-es.srt','application/x-subrip','SubRip subtitle',1064,'58161bd73117cd207757c5d58b207d3c88717b29c815c8bd4b8632ca10734953','mlx-whisper','0.4.3','2026-08-08T03:14:42.496Z','not_applicable','subtitle','4_z26c26b5c7399daef90f40c13_f106d6adda73cc651_d20260808_m034225_c003_v0312039_t0051_u01786160545045','"0f4ee356e82c750f5cc45c99bd51aeb0"'),
  (4,'LP-FILE-VIMEO-844151157-TRANSCRIPT-TSV','LP-COPY-B2-VIMEO-844151157-TRANSCRIPT-TSV','LP-REP-VIMEO-844151157-TRANSCRIPT','vimeo-844151157-mlx-large-v3-turbo-es.tsv','lapipa/vimeo/LP-ACC-2026-0005/transcripts/vimeo-844151157-mlx-large-v3-turbo-es.tsv','text/tab-separated-values','Tab-separated transcript segments',862,'6d67f7f9b41da27c677a682ed8e8524e02902b82890b013759dbcf146a09a84c','mlx-whisper','0.4.3','2026-08-08T03:14:42.496Z','not_applicable','segment_table','4_z26c26b5c7399daef90f40c13_f1142f76f7d92468c_d20260808_m034226_c003_v0312006_t0021_u01786160546295','"0dbd32e9e7dcdbe380d88aae068cc57a"'),
  (5,'LP-FILE-VIMEO-844151157-TRANSCRIPT-TXT','LP-COPY-B2-VIMEO-844151157-TRANSCRIPT-TXT','LP-REP-VIMEO-844151157-TRANSCRIPT','vimeo-844151157-mlx-large-v3-turbo-es.txt','lapipa/vimeo/LP-ACC-2026-0005/transcripts/vimeo-844151157-mlx-large-v3-turbo-es.txt','text/plain','UTF-8 plain text',733,'35552506b87395007847fc120fdfa8233e1a1658caecb8453c6a66197fe03604','mlx-whisper','0.4.3','2026-08-08T03:14:42.496Z','not_applicable','plain_transcript','4_z26c26b5c7399daef90f40c13_f102476f633db8054_d20260808_m034227_c003_v0312027_t0032_u01786160547301','"1e0f2536f5c4c403013c26d2680e6f6d"'),
  (6,'LP-FILE-VIMEO-844151157-TRANSCRIPT-VTT','LP-COPY-B2-VIMEO-844151157-TRANSCRIPT-VTT','LP-REP-VIMEO-844151157-TRANSCRIPT','vimeo-844151157-mlx-large-v3-turbo-es.vtt','lapipa/vimeo/LP-ACC-2026-0005/transcripts/vimeo-844151157-mlx-large-v3-turbo-es.vtt','text/vtt','WebVTT subtitle',991,'e31eeecff4fa63f59c01f93aef8a853a4b8460b3f98c2fe0880ce73fe02a2a52','mlx-whisper','0.4.3','2026-08-08T03:14:42.496Z','not_applicable','web_subtitle','4_z26c26b5c7399daef90f40c13_f1103af717e6a96dc_d20260808_m034227_c003_v0312026_t0010_u01786160547922','"7c499c4e31fdbc411fd883639c68f626"'),
  (7,'LP-FILE-VIMEO-844151157-MANIFEST-DOWNLOAD','LP-COPY-B2-VIMEO-844151157-MANIFEST-DOWNLOAD','LP-REP-VIMEO-844151157-METADATA','download-manifest.json','lapipa/vimeo/LP-ACC-2026-0005/manifests/download-manifest.json','application/json','La Pipa Vimeo acceptance download manifest v1',1200,'b8bee7379ec584a86eaa044b00319b91df17948a81edc198c22635011fefa3df','La Pipa archive runner',null,'2026-08-08T02:58:07.020Z','not_applicable','download_manifest','4_z26c26b5c7399daef90f40c13_f109eae5c108ed241_d20260808_m034228_c003_v0312026_t0003_u01786160548967','"2dbb6e22f6accbfe8facc69e5bd00011"'),
  (8,'LP-FILE-VIMEO-844151157-MANIFEST-TECHNICAL','LP-COPY-B2-VIMEO-844151157-MANIFEST-TECHNICAL','LP-REP-VIMEO-844151157-METADATA','technical-metadata.json','lapipa/vimeo/LP-ACC-2026-0005/manifests/technical-metadata.json','application/json','ffprobe technical metadata',5859,'b4c819ed6c5907c6ed48056a6578e7a391f37ea53deb524ea24477cb2138d5a4','ffprobe',null,'2026-08-08T03:14:42.452Z','not_applicable','technical_metadata','4_z26c26b5c7399daef90f40c13_f113187fcb2b8bca4_d20260808_m034229_c003_v0312033_t0040_u01786160549677','"b186b520871b9a0b85acc4dcc4428104"'),
  (9,'LP-FILE-VIMEO-844151157-MANIFEST-TRANSCRIPT','LP-COPY-B2-VIMEO-844151157-MANIFEST-TRANSCRIPT','LP-REP-VIMEO-844151157-METADATA','transcript-manifest.json','lapipa/vimeo/LP-ACC-2026-0005/manifests/transcript-manifest.json','application/json','La Pipa transcript manifest v1',2597,'f87f1446f083e18e9dd1c5790105210e3bc54c25f7b8568887fd218869143cc3','La Pipa archive runner',null,'2026-08-08T03:14:42.496Z','not_applicable','transcript_manifest','4_z26c26b5c7399daef90f40c13_f117a54dd667b7369_d20260808_m034230_c003_v0312008_t0016_u01786160550385','"a99c6d1dfb346540dd1445b13ef74110"'),
  (10,'LP-FILE-VIMEO-844151157-MANIFEST-INGEST','LP-COPY-B2-VIMEO-844151157-MANIFEST-INGEST','LP-REP-VIMEO-844151157-METADATA','ingest-manifest.json','lapipa/vimeo/LP-ACC-2026-0005/manifests/ingest-manifest.json','application/json','La Pipa Vimeo preservation ingest manifest v1',3714,'197c47a2391312a27eb9190688a7976116dbcc0157218e637a9ab20453ce5eab','La Pipa archive runner',null,'2026-08-08T03:14:45.664Z','not_applicable','ingest_manifest','4_z26c26b5c7399daef90f40c13_f1045a05222eca5d0_d20260808_m034231_c003_v0312029_t0039_u01786160551374','"7a13cf2d200841f1634228a8967d9e54"'),
  (11,'LP-FILE-VIMEO-844151157-MANIFEST-TRANSFER','LP-COPY-B2-VIMEO-844151157-MANIFEST-TRANSFER','LP-REP-VIMEO-844151157-METADATA','transfer-report.json','lapipa/vimeo/LP-ACC-2026-0005/manifests/transfer-report.json','application/json','La Pipa Backblaze transfer report v1',7299,'f6d90f1c93e058ea7a6506e72994d026fa6404224bf0f67d6b4d7503812f8d36','La Pipa archive runner',null,'2026-08-08T03:42:32.337Z','not_applicable','transfer_report','4_z26c26b5c7399daef90f40c13_f101c95c1b2470539_d20260808_m034234_c003_v0312033_t0029_u01786160554028','"62eabb0b65279270ba9d275060ac272f"');

insert into archive.file_objects (
  file_id, representation_id, original_filename, normalized_filename,
  storage_bucket, storage_object_path, mime_type, format_name,
  byte_count, sha256, creating_application, creating_application_version,
  created_at_source, last_fixity_at, fixity_status, malware_scan_status, metadata
)
select
  f.file_id, r.id, f.filename, f.filename,
  'miramonte-lapipa-archive', f.object_path, f.mime_type, f.format_name,
  f.byte_count, f.sha256, f.creating_application, f.creating_application_version,
  f.created_at_source, '2026-08-08T03:42:34.393Z'::timestamptz,
  'verified', f.malware_scan_status,
  jsonb_build_object(
    'accession_id', 'LP-ACC-2026-0005',
    'archival_role', f.archival_role,
    'clean_restore_verified', true,
    'expected_sha256', f.sha256,
    'restored_sha256', f.sha256,
    'source_deletion_authorized', false
  )
from tmp_lapipa_vimeo_0005_files f
join archive.representations r on r.representation_id = f.representation_id
on conflict (file_id) do update set
  representation_id = excluded.representation_id,
  storage_bucket = excluded.storage_bucket,
  storage_object_path = excluded.storage_object_path,
  byte_count = excluded.byte_count,
  sha256 = excluded.sha256,
  last_fixity_at = excluded.last_fixity_at,
  fixity_status = excluded.fixity_status,
  metadata = archive.file_objects.metadata || excluded.metadata;

insert into archive.file_copies (
  copy_id, file_object_id, storage_location_id, storage_bucket,
  storage_object_path, storage_version_id, replica_state,
  expected_sha256, observed_sha256, byte_count, copied_at,
  last_verified_at, next_verification_due_at, metadata
)
select
  f.copy_id, o.id, l.id, 'miramonte-lapipa-archive',
  f.object_path, f.storage_version_id, 'verified',
  f.sha256, f.sha256, f.byte_count,
  '2026-08-08T03:42:34.393Z'::timestamptz,
  '2026-08-08T03:42:34.393Z'::timestamptz,
  '2026-11-06T03:42:34.393Z'::timestamptz,
  jsonb_build_object(
    'etag', f.etag,
    'server_side_encryption', 'AES256',
    'verification_method', 'clean_restore_sha256',
    'restore_verified', true,
    'reused_existing_remote_object', false
  )
from tmp_lapipa_vimeo_0005_files f
join archive.file_objects o on o.file_id = f.file_id
join archive.storage_locations l on l.location_id = 'LP-LOC-B2-EUC3-002'
on conflict (copy_id) do update set
  storage_version_id = excluded.storage_version_id,
  replica_state = 'verified',
  expected_sha256 = excluded.expected_sha256,
  observed_sha256 = excluded.observed_sha256,
  byte_count = excluded.byte_count,
  last_verified_at = excluded.last_verified_at,
  next_verification_due_at = excluded.next_verification_due_at,
  metadata = archive.file_copies.metadata || excluded.metadata,
  updated_at = now();

insert into archive.essence_tracks (
  track_id, file_object_id, track_type, stream_index, codec_name,
  codec_profile, duration_ms, data_rate_bps, frame_rate, frame_width,
  frame_height, aspect_ratio, color_space, chroma_subsampling,
  sampling_rate_hz, bit_depth, channel_count, channel_layout, language, metadata
)
select t.track_id, o.id, t.track_type, t.stream_index, t.codec_name,
       t.codec_profile, 46520, t.data_rate_bps, t.frame_rate, t.frame_width,
       t.frame_height, t.aspect_ratio, t.color_space, t.chroma_subsampling,
       t.sampling_rate_hz, t.bit_depth, t.channel_count, t.channel_layout,
       t.language, t.metadata
from archive.file_objects o
cross join (values
  ('LP-TRACK-VIMEO-844151157-AUDIO','audio',0,'pcm_s24le',null,2304000::bigint,null::numeric,null::integer,null::integer,null::text,null::text,null::text,48000,24,2,'stereo','es','{"sample_format":"s32","source_language_tag":"und"}'::jsonb),
  ('LP-TRACK-VIMEO-844151157-VIDEO','video',1,'prores','Standard',53964084,25.00000,1024,768,'4:3','bt709','4:2:2',null,null,null,null,null,'{"pixel_format":"yuv422p10le","field_order":"progressive","encoder":"Apple ProRes 422"}'::jsonb),
  ('LP-TRACK-VIMEO-844151157-TIMECODE','data',2,'tmcd',null,null,null,null,null,null,null,null,null,null,null,null,null,'{"timecode":"00:00:00:00"}'::jsonb)
) as t(track_id,track_type,stream_index,codec_name,codec_profile,data_rate_bps,frame_rate,frame_width,frame_height,aspect_ratio,color_space,chroma_subsampling,sampling_rate_hz,bit_depth,channel_count,channel_layout,language,metadata)
where o.file_id = 'LP-FILE-VIMEO-844151157-PRESERVATION-MASTER'
on conflict (track_id) do update set
  duration_ms = excluded.duration_ms,
  data_rate_bps = excluded.data_rate_bps,
  metadata = excluded.metadata;

insert into archive.preservation_events (
  event_id, event_type, event_at, outcome, outcome_detail,
  agent_id, software_agent, command_or_process, event_detail
)
select e.event_id, e.event_type, e.event_at, 'success', e.outcome_detail,
       a.id, e.software_agent, e.command_or_process, e.event_detail
from archive.agents a
cross join (values
  ('LP-PRESEVENT-2026-0014','capture','2026-08-08T02:58:07.020Z'::timestamptz,'Vimeo source-quality file downloaded to owner-controlled staging and locally SHA-256 verified.','La Pipa Vimeo acceptance runner','owner-authorized exact-video API download','{"vimeo_video_id":"844151157","source_deleted":false}'::jsonb),
  ('LP-PRESEVENT-2026-0015','metadata_extraction','2026-08-08T03:14:45.664Z'::timestamptz,'ffprobe technical metadata and provisional Spanish MLX Whisper transcript artifacts created without rewriting the source.','ffprobe 8 / mlx-whisper 0.4.3','read-only technical inspection and local machine transcription','{"transcript_status":"machine_generated_provisional","human_review_required":true}'::jsonb),
  ('LP-PRESEVENT-2026-0016','replication','2026-08-08T03:42:34.393Z'::timestamptz,'Eleven exact-path objects uploaded to private Backblaze B2 storage with distinct version IDs and AES256 server-side encryption.','La Pipa preservation ingest runner','owner-capability-scoped signed S3 PUT and HEAD','{"object_count":11,"total_byte_count":328042607,"bucket":"miramonte-lapipa-archive"}'::jsonb),
  ('LP-PRESEVENT-2026-0017','fixity_check','2026-08-08T03:42:34.393Z'::timestamptz,'Expected and clean-restored SHA-256 digests matched for 11 of 11 objects.','La Pipa preservation ingest runner','clean restore followed by local SHA-256 comparison','{"pass_count":11,"fail_count":0,"algorithm":"sha256"}'::jsonb),
  ('LP-PRESEVENT-2026-0018','restore','2026-08-08T03:42:34.393Z'::timestamptz,'Every stored object was downloaded into a new clean restore tree and byte-for-byte verified.','La Pipa preservation ingest runner','signed S3 GET to clean restore tree','{"verified_count":11,"source_deleted":false}'::jsonb),
  ('LP-PRESEVENT-2026-0019','ingest',now(),'Accession, objects, copies, fixity, transcript, RAG provenance, and graph records registered in the archive catalogue.','Supabase Postgres migration','idempotent controlled catalogue registration','{"accession_id":"LP-ACC-2026-0005","credential_values_recorded":false}'::jsonb)
) as e(event_id,event_type,event_at,outcome_detail,software_agent,command_or_process,event_detail)
where a.agent_id = 'LP-AGENT-LA-PIPA-REPOSITORY'
on conflict (event_id) do update set
  outcome = excluded.outcome,
  outcome_detail = excluded.outcome_detail,
  event_detail = archive.preservation_events.event_detail || excluded.event_detail;

insert into archive.event_file_links (preservation_event_id, file_object_id, relationship)
select e.id, f.id, links.relationship
from (values
  ('LP-PRESEVENT-2026-0014','LP-FILE-VIMEO-844151157-PRESERVATION-MASTER','outcome'),
  ('LP-PRESEVENT-2026-0015','LP-FILE-VIMEO-844151157-PRESERVATION-MASTER','source')
) as links(event_id,file_id,relationship)
join archive.preservation_events e on e.event_id = links.event_id
join archive.file_objects f on f.file_id = links.file_id
on conflict do nothing;

insert into archive.event_file_links (preservation_event_id, file_object_id, relationship)
select e.id, f.id, relation.relationship
from tmp_lapipa_vimeo_0005_files tf
join archive.file_objects f on f.file_id = tf.file_id
cross join (values
  ('LP-PRESEVENT-2026-0016','outcome'),
  ('LP-PRESEVENT-2026-0017','subject'),
  ('LP-PRESEVENT-2026-0018','outcome'),
  ('LP-PRESEVENT-2026-0019','subject')
) as relation(event_id,relationship)
join archive.preservation_events e on e.event_id = relation.event_id
on conflict do nothing;

insert into archive.event_file_links (preservation_event_id, file_object_id, relationship)
select e.id, f.id, 'outcome'
from tmp_lapipa_vimeo_0005_files tf
join archive.file_objects f on f.file_id = tf.file_id
join archive.preservation_events e on e.event_id = 'LP-PRESEVENT-2026-0015'
where tf.ordinal between 2 and 10
on conflict do nothing;

insert into archive.fixity_checks (
  check_id, file_object_id, preservation_event_id, algorithm,
  expected_digest, observed_digest, result, checked_at, storage_location
)
select
  'LP-FIXITY-2026-' || lpad((13 + tf.ordinal)::text, 4, '0'),
  f.id, e.id, 'sha256', tf.sha256, tf.sha256, 'pass',
  '2026-08-08T03:42:34.393Z'::timestamptz, 'LP-LOC-B2-EUC3-002'
from tmp_lapipa_vimeo_0005_files tf
join archive.file_objects f on f.file_id = tf.file_id
join archive.preservation_events e on e.event_id = 'LP-PRESEVENT-2026-0017'
on conflict (check_id) do update set
  expected_digest = excluded.expected_digest,
  observed_digest = excluded.observed_digest,
  result = excluded.result,
  checked_at = excluded.checked_at,
  storage_location = excluded.storage_location;

insert into archive.file_relationships (
  source_file_object_id, target_file_object_id, relationship_type,
  preservation_event_id, transformation_profile
)
select related.id, master.id,
       case when tf.ordinal between 2 and 6 then 'transcript_of' else 'metadata_for' end,
       event.id,
       case when tf.ordinal between 2 and 6 then 'mlx-whisper 0.4.3 / mlx-community/whisper-large-v3-turbo / language es' else 'La Pipa preservation manifest profile v1' end
from tmp_lapipa_vimeo_0005_files tf
join archive.file_objects master on master.file_id = 'LP-FILE-VIMEO-844151157-PRESERVATION-MASTER'
join archive.file_objects related on related.file_id = tf.file_id
join archive.preservation_events event on event.event_id = 'LP-PRESEVENT-2026-0015'
where tf.ordinal between 2 and 10
on conflict (source_file_object_id, target_file_object_id, relationship_type) do update set
  preservation_event_id = excluded.preservation_event_id,
  transformation_profile = excluded.transformation_profile;

insert into archive.transcripts (
  transcript_id, item_id, representation_id, language, transcript_type,
  source_method, status, model_or_vendor, vocabulary_notes,
  speaker_reviewed, content_sha256
)
select
  'LP-TRANSCRIPT-VIMEO-844151157-ES-MLX-V1', i.id, r.id, 'es', 'verbatim',
  'machine', 'review', 'mlx-community/whisper-large-v3-turbo',
  'Machine-generated discovery transcript. Segments after approximately 27 seconds contain recognition uncertainty and must be reviewed against the recording. Exact machine output retained; not approved for verified quotation.',
  false, '35552506b87395007847fc120fdfa8233e1a1658caecb8453c6a66197fe03604'
from archive.items i
join archive.representations r on r.item_id = i.id and r.representation_id = 'LP-REP-VIMEO-844151157-TRANSCRIPT'
where i.item_id = 'LP-MEDIA-VIMEO-VIDEO-844151157'
on conflict (transcript_id) do update set
  status = 'review',
  model_or_vendor = excluded.model_or_vendor,
  vocabulary_notes = excluded.vocabulary_notes,
  speaker_reviewed = false,
  content_sha256 = excluded.content_sha256,
  updated_at = now();

insert into archive.transcript_segments (
  transcript_id, segment_id, ordinal, start_ms, end_ms,
  speaker_label, text, confidence, review_status, annotations
)
select t.id, s.segment_id, s.ordinal, s.start_ms, s.end_ms,
       null, s.text, null, 'unreviewed',
       jsonb_build_object(
         'machine_generated', true,
         'human_review_required', true,
         'quotation_approved', false,
         'uncertainty_note', case when s.ordinal >= 3 then 'elevated recognition uncertainty after approximately 27 seconds' else null end
       )
from archive.transcripts t
cross join (values
  ('SEG-000',0,0::bigint,7320::bigint,'La escena no está solo en Madrid, esto es muy importante, y en Barcelona, que es algo que últimamente hablamos mucho, estamos escribiendo sobre ello.'),
  ('SEG-001',1,7980,17140,'Ah, tengo un grupo, quiero que salga bien, me voy. Es como, no tío, a veces hay que hacer resistencia para las generaciones que vienen detrás, tengan un espacio, unos compañeros, una escena.'),
  ('SEG-002',2,17580,26800,'Es difícil, obviamente, y es un riesgo, y todas las decisiones son buenas, pero bueno, que sepáis, gente que estáis escuchando, que es también una opción, y que es una opción buena, aunque sea una opción arriesgada.'),
  ('SEG-003',3,27400,29500,'tenemos la suerte de estar en humo'),
  ('SEG-004',4,29500,30400,'que no hemos hablado de'),
  ('SEG-005',5,31180,31760,'eso'),
  ('SEG-006',6,31760,35240,'ha hecho por la escena musical'),
  ('SEG-007',7,35240,37440,'y mola que estén Asturias'),
  ('SEG-008',8,37440,39440,'es una cosa que me hace sentirme'),
  ('SEG-009',9,39440,39920,'orgullosa')
) as s(segment_id,ordinal,start_ms,end_ms,text)
where t.transcript_id = 'LP-TRANSCRIPT-VIMEO-844151157-ES-MLX-V1'
on conflict (transcript_id, segment_id) do update set
  ordinal = excluded.ordinal,
  start_ms = excluded.start_ms,
  end_ms = excluded.end_ms,
  text = excluded.text,
  review_status = 'unreviewed',
  annotations = excluded.annotations;

insert into archive.file_relationships (
  source_file_object_id, target_file_object_id, relationship_type,
  preservation_event_id, transformation_profile
)
select related.id, master.id, 'metadata_for', event.id,
       'La Pipa Backblaze transfer report v1'
from archive.file_objects related
join archive.file_objects master on master.file_id = 'LP-FILE-VIMEO-844151157-PRESERVATION-MASTER'
join archive.preservation_events event on event.event_id = 'LP-PRESEVENT-2026-0016'
where related.file_id = 'LP-FILE-VIMEO-844151157-MANIFEST-TRANSFER'
on conflict (source_file_object_id, target_file_object_id, relationship_type) do update set
  preservation_event_id = excluded.preservation_event_id,
  transformation_profile = excluded.transformation_profile;

insert into kb.sources (
  source_id, title, source_type, evidence_class, source_date,
  source_date_text, origin_uri, access_scope, verification_status,
  description, metadata
) values (
  'LP-SRC-042',
  'LP-DOC-ARCH-030 — Vimeo accession LP-ACC-2026-0005 preservation ingest',
  'vimeo_preservation_ingest_report',
  'workspace_and_live_connector_verified',
  '2026-08-08',
  'Preservation upload and clean restore completed 8 August 2026',
  'https://github.com/alex-lapipa/lapipa.archives/blob/main/docs/archive/vimeo-0005-preservation-ingest-2026-08-08.md',
  'restricted',
  'verified_operating_evidence',
  'Provenance record for Vimeo accession LP-ACC-2026-0005: 11 private Backblaze objects, clean restore, SHA-256 verification, technical characterization, provisional Spanish transcript, and explicit source-retention controls.',
  jsonb_build_object(
    'controlled_document_id', 'LP-DOC-ARCH-030',
    'github_path', 'docs/archive/vimeo-0005-preservation-ingest-2026-08-08.md',
    'accession_id', 'LP-ACC-2026-0005',
    'vimeo_video_id', '844151157',
    'archive_item_id', 'LP-MEDIA-VIMEO-VIDEO-844151157',
    'transcript_id', 'LP-TRANSCRIPT-VIMEO-844151157-ES-MLX-V1',
    'storage_location_id', 'LP-LOC-B2-EUC3-002',
    'object_count', 11,
    'total_byte_count', 328042607,
    'evidence_classes', jsonb_build_array('workspace_verified','live_connector_verified','provider_metadata','user_supplied_rights'),
    'credential_values_recorded', false,
    'public_release_approved', false,
    'source_deletion_authorized', false
  )
)
on conflict (source_id) do update set
  title = excluded.title,
  source_type = excluded.source_type,
  evidence_class = excluded.evidence_class,
  source_date = excluded.source_date,
  source_date_text = excluded.source_date_text,
  origin_uri = excluded.origin_uri,
  access_scope = excluded.access_scope,
  verification_status = excluded.verification_status,
  description = excluded.description,
  metadata = kb.sources.metadata || excluded.metadata,
  updated_at = now();

insert into archive.item_sources (item_id, source_id, locator, support_type)
select i.id, s.id, 'LP-DOC-ARCH-030', 'context'
from archive.items i
cross join kb.sources s
where i.item_id = 'LP-MEDIA-VIMEO-VIDEO-844151157'
  and s.source_id = 'LP-SRC-042'
on conflict (item_id, source_id, support_type) do update set locator = excluded.locator;

insert into kb.documents (
  document_id, primary_source_id, title, language,
  document_type, lifecycle_status, access_scope
)
select
  'lp-vimeo-0005-preservation-ingest-2026-08-08-v1', s.id,
  'Vimeo accession LP-ACC-2026-0005 preservation ingest',
  'en', 'vimeo_preservation_ingest_report', 'approved', 'restricted'
from kb.sources s where s.source_id = 'LP-SRC-042'
on conflict (document_id) do update set
  primary_source_id = excluded.primary_source_id,
  title = excluded.title,
  language = excluded.language,
  document_type = excluded.document_type,
  lifecycle_status = excluded.lifecycle_status,
  access_scope = excluded.access_scope,
  updated_at = now();

with chunk_content(chunk_id, ordinal, heading_path, content) as (values
  (
    'LP-RAG-033', 0, 'Outcome and preservation decision',
    $$LP-DOC-ARCH-030 records the first fully restored and fixity-verified single-video Vimeo accession for the La Pipa Documentary Archive. On 8 August 2026, accession LP-ACC-2026-0005 preserved Subterranea @ LA PIPA :: VIUDA, Vimeo video 844151157. Eleven objects totaling 328,042,607 bytes were uploaded to the private Backblaze B2 bucket miramonte-lapipa-archive under lapipa/vimeo/LP-ACC-2026-0005. The set comprises one 328,003,637-byte source-quality preservation master, five provisional transcript artifacts, and five manifest or transfer-control artifacts. Every object was restored into a new clean directory and recomputed with SHA-256; 11 of 11 restored digests and byte counts matched. Backblaze reported AES256 server-side encryption and a distinct version identifier for each object. No Vimeo source or local master was moved, renamed, rewritten, or deleted. Source deletion remains unauthorized.$$
  ),
  (
    'LP-RAG-034', 1, 'Object inventory and technical characterization',
    $$The LP-ACC-2026-0005 preservation master is lapipa/vimeo/LP-ACC-2026-0005/preservation/vimeo-844151157-source.mp4, 328,003,637 bytes, SHA-256 b15ea951246acdd46561f13f87be7fc2de0b2ba35ac7dc79a4f437b7617e09aa. It is a 46.52-second QuickTime-family file with 1024 by 768 Apple ProRes 422 Standard video at 25 frames per second, 10-bit 4:2:2 BT.709 color, 24-bit stereo PCM audio at 48 kHz, and a timecode track. Embedded creation metadata records 7 July 2023; Vimeo provider metadata records release on 11 July 2023. The other preserved objects are MLX Whisper JSON, SRT, TSV, TXT, and VTT outputs plus download, technical-metadata, transcript, ingest, and transfer manifests. Their exact byte counts, SHA-256 digests, Backblaze version identifiers, ETags, and clean-restore results are registered as canonical file objects, copies, and fixity checks.$$
  ),
  (
    'LP-RAG-035', 2, 'Transcript and quotation boundary',
    $$MLX Whisper 0.4.3 with model mlx-community/whisper-large-v3-turbo produced a Spanish transcript for Vimeo 844151157. The archive registers transcript LP-TRANSCRIPT-VIMEO-844151157-ES-MLX-V1 and ten timestamped segments covering 00:00.000 through 00:39.920. The transcript is machine-generated, provisional, restricted, unreviewed, and useful only for discovery and semantic retrieval. Speech after approximately 00:27 contains evident recognition uncertainty. The exact machine output is retained rather than silently normalized. No segment is approved for verified quotation, captions, publication, or speaker attribution until a human Spanish-language review compares it with the recording.$$
  ),
  (
    'LP-RAG-036', 3, 'Evidence boundaries and continuing controls',
    $$Workspace-verified evidence for LP-ACC-2026-0005 covers local byte counts, source SHA-256 values, clean-restore byte counts, restored SHA-256 values, ffprobe technical metadata, and transcript artifacts. Live-connector-verified evidence covers Backblaze version identifiers, ETags, encryption headers, exact-path transfer responses, and Supabase catalogue records. Vimeo title, identifier, dates, duration, privacy setting, and source-quality download metadata remain provider evidence. Alex Lawton and Miramonte, S.L. rights ownership is user-supplied evidence; preservation does not itself settle participant consent or approve public release for every recording. No credential, access token, owner capability, signed URL, or secret value is stored in this record. The next controls are human transcript review, periodic fixity verification due 6 November 2026, independent-copy planning, and an explicit later disposal decision before any source deletion.$$
  )
), document_text(content) as (
  select string_agg('## ' || heading_path || E'\n\n' || content, E'\n\n' order by ordinal)
  from chunk_content
)
insert into kb.document_versions (
  document_id, version, content_sha256, mime_type, byte_count,
  extracted_text, effective_from
)
select d.id, '2026-08-08-v1',
       encode(extensions.digest(dt.content, 'sha256'), 'hex'),
       'text/markdown', octet_length(dt.content), dt.content,
       '2026-08-08T03:42:34.393Z'::timestamptz
from kb.documents d
cross join document_text dt
where d.document_id = 'lp-vimeo-0005-preservation-ingest-2026-08-08-v1'
on conflict (document_id, version) do update set
  content_sha256 = excluded.content_sha256,
  mime_type = excluded.mime_type,
  byte_count = excluded.byte_count,
  extracted_text = excluded.extracted_text,
  effective_from = excluded.effective_from;

with chunk_content(chunk_id, ordinal, heading_path, content) as (values
  ('LP-RAG-033',0,'Outcome and preservation decision',$$LP-DOC-ARCH-030 records the first fully restored and fixity-verified single-video Vimeo accession for the La Pipa Documentary Archive. On 8 August 2026, accession LP-ACC-2026-0005 preserved Subterranea @ LA PIPA :: VIUDA, Vimeo video 844151157. Eleven objects totaling 328,042,607 bytes were uploaded to the private Backblaze B2 bucket miramonte-lapipa-archive under lapipa/vimeo/LP-ACC-2026-0005. The set comprises one 328,003,637-byte source-quality preservation master, five provisional transcript artifacts, and five manifest or transfer-control artifacts. Every object was restored into a new clean directory and recomputed with SHA-256; 11 of 11 restored digests and byte counts matched. Backblaze reported AES256 server-side encryption and a distinct version identifier for each object. No Vimeo source or local master was moved, renamed, rewritten, or deleted. Source deletion remains unauthorized.$$),
  ('LP-RAG-034',1,'Object inventory and technical characterization',$$The LP-ACC-2026-0005 preservation master is lapipa/vimeo/LP-ACC-2026-0005/preservation/vimeo-844151157-source.mp4, 328,003,637 bytes, SHA-256 b15ea951246acdd46561f13f87be7fc2de0b2ba35ac7dc79a4f437b7617e09aa. It is a 46.52-second QuickTime-family file with 1024 by 768 Apple ProRes 422 Standard video at 25 frames per second, 10-bit 4:2:2 BT.709 color, 24-bit stereo PCM audio at 48 kHz, and a timecode track. Embedded creation metadata records 7 July 2023; Vimeo provider metadata records release on 11 July 2023. The other preserved objects are MLX Whisper JSON, SRT, TSV, TXT, and VTT outputs plus download, technical-metadata, transcript, ingest, and transfer manifests. Their exact byte counts, SHA-256 digests, Backblaze version identifiers, ETags, and clean-restore results are registered as canonical file objects, copies, and fixity checks.$$),
  ('LP-RAG-035',2,'Transcript and quotation boundary',$$MLX Whisper 0.4.3 with model mlx-community/whisper-large-v3-turbo produced a Spanish transcript for Vimeo 844151157. The archive registers transcript LP-TRANSCRIPT-VIMEO-844151157-ES-MLX-V1 and ten timestamped segments covering 00:00.000 through 00:39.920. The transcript is machine-generated, provisional, restricted, unreviewed, and useful only for discovery and semantic retrieval. Speech after approximately 00:27 contains evident recognition uncertainty. The exact machine output is retained rather than silently normalized. No segment is approved for verified quotation, captions, publication, or speaker attribution until a human Spanish-language review compares it with the recording.$$),
  ('LP-RAG-036',3,'Evidence boundaries and continuing controls',$$Workspace-verified evidence for LP-ACC-2026-0005 covers local byte counts, source SHA-256 values, clean-restore byte counts, restored SHA-256 values, ffprobe technical metadata, and transcript artifacts. Live-connector-verified evidence covers Backblaze version identifiers, ETags, encryption headers, exact-path transfer responses, and Supabase catalogue records. Vimeo title, identifier, dates, duration, privacy setting, and source-quality download metadata remain provider evidence. Alex Lawton and Miramonte, S.L. rights ownership is user-supplied evidence; preservation does not itself settle participant consent or approve public release for every recording. No credential, access token, owner capability, signed URL, or secret value is stored in this record. The next controls are human transcript review, periodic fixity verification due 6 November 2026, independent-copy planning, and an explicit later disposal decision before any source deletion.$$)
)
insert into kb.chunks (
  chunk_id, document_version_id, ordinal, heading_path, content,
  token_count, content_sha256, language, verification_status,
  access_scope, active, metadata
)
select cc.chunk_id, dv.id, cc.ordinal, cc.heading_path, cc.content,
       greatest(1, ceil(length(cc.content)::numeric / 4)::integer),
       encode(extensions.digest(cc.content, 'sha256'), 'hex'),
       'en', 'workspace_and_live_connector_verified', 'restricted', true,
       jsonb_build_object(
         'source_ids', jsonb_build_array('LP-SRC-042'),
         'controlled_document_id', 'LP-DOC-ARCH-030',
         'accession_id', 'LP-ACC-2026-0005',
         'vimeo_video_id', '844151157',
         'retrieval_scope', 'authenticated',
         'contains_credential_values', false
       )
from chunk_content cc
join kb.documents d on d.document_id = 'lp-vimeo-0005-preservation-ingest-2026-08-08-v1'
join kb.document_versions dv on dv.document_id = d.id and dv.version = '2026-08-08-v1'
on conflict (chunk_id) do update set
  document_version_id = excluded.document_version_id,
  ordinal = excluded.ordinal,
  heading_path = excluded.heading_path,
  content = excluded.content,
  token_count = excluded.token_count,
  content_sha256 = excluded.content_sha256,
  language = excluded.language,
  verification_status = excluded.verification_status,
  access_scope = excluded.access_scope,
  active = excluded.active,
  metadata = excluded.metadata,
  updated_at = now();

insert into kb.documents (
  document_id, primary_source_id, title, language,
  document_type, lifecycle_status, access_scope
)
select
  'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC', s.id,
  'Subterranea @ LA PIPA :: VIUDA — provisional machine transcript',
  'es', 'vimeo_machine_transcript', 'review', 'restricted'
from kb.sources s where s.source_id = 'LP-MEDIA-VIMEO-VIDEO-844151157'
on conflict (document_id) do update set
  primary_source_id = excluded.primary_source_id,
  title = excluded.title,
  language = excluded.language,
  document_type = excluded.document_type,
  lifecycle_status = excluded.lifecycle_status,
  access_scope = excluded.access_scope,
  updated_at = now();

insert into kb.document_versions (
  document_id, version, content_sha256, mime_type, byte_count,
  storage_bucket, storage_object_path, extracted_text, effective_from
)
select d.id, '2026-08-08-mlx-large-v3-turbo',
       '35552506b87395007847fc120fdfa8233e1a1658caecb8453c6a66197fe03604',
       'text/plain', 733, 'miramonte-lapipa-archive',
       'lapipa/vimeo/LP-ACC-2026-0005/transcripts/vimeo-844151157-mlx-large-v3-turbo-es.txt',
       $$La escena no está solo en Madrid, esto es muy importante, y en Barcelona, que es algo que últimamente hablamos mucho, estamos escribiendo sobre ello.
Ah, tengo un grupo, quiero que salga bien, me voy. Es como, no tío, a veces hay que hacer resistencia para las generaciones que vienen detrás, tengan un espacio, unos compañeros, una escena.
Es difícil, obviamente, y es un riesgo, y todas las decisiones son buenas, pero bueno, que sepáis, gente que estáis escuchando, que es también una opción, y que es una opción buena, aunque sea una opción arriesgada.
tenemos la suerte de estar en humo
que no hemos hablado de
eso
ha hecho por la escena musical
y mola que estén Asturias
es una cosa que me hace sentirme
orgullosa
$$,
       '2026-08-08T03:14:42.496Z'::timestamptz
from kb.documents d
where d.document_id = 'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC'
on conflict (document_id, version) do update set
  content_sha256 = excluded.content_sha256,
  mime_type = excluded.mime_type,
  byte_count = excluded.byte_count,
  storage_bucket = excluded.storage_bucket,
  storage_object_path = excluded.storage_object_path,
  extracted_text = excluded.extracted_text,
  effective_from = excluded.effective_from;

with transcript_content(content) as (values (
  $$La escena no está solo en Madrid, esto es muy importante, y en Barcelona, que es algo que últimamente hablamos mucho, estamos escribiendo sobre ello.
Ah, tengo un grupo, quiero que salga bien, me voy. Es como, no tío, a veces hay que hacer resistencia para las generaciones que vienen detrás, tengan un espacio, unos compañeros, una escena.
Es difícil, obviamente, y es un riesgo, y todas las decisiones son buenas, pero bueno, que sepáis, gente que estáis escuchando, que es también una opción, y que es una opción buena, aunque sea una opción arriesgada.
tenemos la suerte de estar en humo
que no hemos hablado de
eso
ha hecho por la escena musical
y mola que estén Asturias
es una cosa que me hace sentirme
orgullosa
$$
))
insert into kb.chunks (
  chunk_id, document_version_id, ordinal, heading_path, content,
  token_count, content_sha256, language, verification_status,
  access_scope, active, metadata
)
select
  'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC-CH-001', dv.id, 0,
  'Machine transcript — provisional and unreviewed', tc.content,
  greatest(1, ceil(length(tc.content)::numeric / 4)::integer),
  encode(extensions.digest(tc.content, 'sha256'), 'hex'),
  'es', 'machine_generated_unreviewed', 'restricted', true,
  jsonb_build_object(
    'source_ids', jsonb_build_array('LP-MEDIA-VIMEO-VIDEO-844151157','LP-SRC-042'),
    'accession_id', 'LP-ACC-2026-0005',
    'transcript_id', 'LP-TRANSCRIPT-VIMEO-844151157-ES-MLX-V1',
    'machine_generated', true,
    'human_review_required', true,
    'verified_quotation_approved', false,
    'uncertainty_after_ms', 27000,
    'retrieval_scope', 'authenticated'
  )
from transcript_content tc
join kb.documents d on d.document_id = 'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC'
join kb.document_versions dv on dv.document_id = d.id and dv.version = '2026-08-08-mlx-large-v3-turbo'
on conflict (chunk_id) do update set
  document_version_id = excluded.document_version_id,
  ordinal = excluded.ordinal,
  heading_path = excluded.heading_path,
  content = excluded.content,
  token_count = excluded.token_count,
  content_sha256 = excluded.content_sha256,
  language = excluded.language,
  verification_status = excluded.verification_status,
  access_scope = excluded.access_scope,
  active = excluded.active,
  metadata = excluded.metadata,
  updated_at = now();

insert into kb.chunk_sources (chunk_id, source_id, locator, support_type)
select c.id, s.id, c.heading_path, 'supports'
from kb.chunks c
cross join kb.sources s
where c.chunk_id in ('LP-RAG-033','LP-RAG-034','LP-RAG-035','LP-RAG-036')
  and s.source_id = 'LP-SRC-042'
on conflict (chunk_id, source_id) do update set
  locator = excluded.locator,
  support_type = excluded.support_type;

insert into kb.chunk_sources (chunk_id, source_id, locator, support_type)
select c.id, s.id, '00:00.000–00:39.920; machine-generated and unreviewed',
       case when s.source_id = 'LP-MEDIA-VIMEO-VIDEO-844151157' then 'supports' else 'context' end
from kb.chunks c
join kb.sources s on s.source_id in ('LP-MEDIA-VIMEO-VIDEO-844151157','LP-SRC-042')
where c.chunk_id = 'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC-CH-001'
on conflict (chunk_id, source_id) do update set
  locator = excluded.locator,
  support_type = excluded.support_type;

insert into kb.collection_items (collection_id, record_type, stable_record_id, ordinal)
select collection.id, 'rag_chunk', c.chunk_id,
       case c.chunk_id
         when 'LP-RAG-033' then 33 when 'LP-RAG-034' then 34
         when 'LP-RAG-035' then 35 when 'LP-RAG-036' then 36
         else 37
       end
from kb.collections collection
join kb.chunks c on c.chunk_id in (
  'LP-RAG-033','LP-RAG-034','LP-RAG-035','LP-RAG-036',
  'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC-CH-001'
)
where collection.collection_id = 'LP-COLLECTION-001'
on conflict (collection_id, record_type, stable_record_id) do update set ordinal = excluded.ordinal;

insert into rag.evaluation_questions (
  question_id, question, language, expected_source_ids,
  required_concepts, forbidden_concepts, active
) values (
  'LP-EVAL-011',
  'Was Vimeo 844151157 preserved and restore-verified, and may its machine transcript be quoted as verified?',
  'en',
  array['LP-SRC-042','LP-MEDIA-VIMEO-VIDEO-844151157'],
  array['eleven objects','clean restore','SHA-256','AES256','machine-generated','human review required','source deletion unauthorized'],
  array['transcript approved','public release approved','source deleted','human-reviewed transcript'],
  true
)
on conflict (question_id) do update set
  question = excluded.question,
  language = excluded.language,
  expected_source_ids = excluded.expected_source_ids,
  required_concepts = excluded.required_concepts,
  forbidden_concepts = excluded.forbidden_concepts,
  active = excluded.active;

insert into ops.ingestion_jobs (
  job_id, job_type, status, initiated_by, input_manifest, counts
) values (
  'LP-EMBED-VIMEO-0005-2026-08-08',
  'voyage_contextual_embedding',
  'queued',
  (
    select wm.user_id from kb.workspace_members wm
    where wm.role = 'owner' and wm.active
    order by wm.created_at limit 1
  ),
  jsonb_build_object(
    'source_ids', jsonb_build_array('LP-SRC-042','LP-MEDIA-VIMEO-VIDEO-844151157'),
    'document_ids', jsonb_build_array(
      'lp-vimeo-0005-preservation-ingest-2026-08-08-v1',
      'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC'
    ),
    'chunk_ids', jsonb_build_array(
      'LP-RAG-033','LP-RAG-034','LP-RAG-035','LP-RAG-036',
      'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC-CH-001'
    ),
    'provider', 'voyage',
    'model', 'voyage-context-4',
    'dimensions', 1024,
    'preflight_existing_embeddings', 0,
    'controlled_one_time_trigger', true
  ),
  jsonb_build_object('expected_chunks',5,'embedded',0,'pending',5)
)
on conflict (job_id) do update set
  input_manifest = excluded.input_manifest,
  counts = case when ops.ingestion_jobs.status = 'succeeded' then ops.ingestion_jobs.counts else excluded.counts end;

create or replace function public.claim_lapipa_vimeo_0005_embedding_job(requested_job_id text)
returns boolean language plpgsql security definer set search_path = ''
as $$
declare affected integer;
begin
  if requested_job_id <> 'LP-EMBED-VIMEO-0005-2026-08-08' then
    raise exception 'unknown embedding job' using errcode = '22023';
  end if;
  update ops.ingestion_jobs
  set status = 'running', started_at = coalesce(started_at, now()),
      completed_at = null, error_summary = null
  where job_id = requested_job_id
    and status in ('queued','running','partially_succeeded','failed');
  get diagnostics affected = row_count;
  return affected = 1;
end;
$$;

create or replace function public.get_lapipa_vimeo_0005_embedding_documents(requested_job_id text)
returns jsonb language plpgsql stable security definer set search_path = ''
as $$
declare result jsonb;
begin
  if requested_job_id <> 'LP-EMBED-VIMEO-0005-2026-08-08'
     or not exists (select 1 from ops.ingestion_jobs where job_id = requested_job_id and status = 'running') then
    raise exception 'embedding job is not running' using errcode = '55000';
  end if;

  select jsonb_build_object(
    'documents', jsonb_agg(document_payload order by document_order),
    'expected_chunks', 5
  ) into result
  from (
    select 0 as document_order, jsonb_build_object(
      'document_id', 'lp-vimeo-0005-preservation-ingest-2026-08-08-v1',
      'chunks', jsonb_agg(jsonb_build_object(
        'chunk_id', c.chunk_id, 'content', c.content,
        'content_sha256', c.content_sha256
      ) order by c.ordinal)
    ) as document_payload
    from kb.chunks c
    join kb.document_versions dv on dv.id = c.document_version_id
    join kb.documents d on d.id = dv.document_id
    where d.document_id = 'lp-vimeo-0005-preservation-ingest-2026-08-08-v1'
      and c.active and c.chunk_id in ('LP-RAG-033','LP-RAG-034','LP-RAG-035','LP-RAG-036')
    union all
    select 1, jsonb_build_object(
      'document_id', 'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC',
      'chunks', jsonb_agg(jsonb_build_object(
        'chunk_id', c.chunk_id, 'content', c.content,
        'content_sha256', c.content_sha256
      ) order by c.ordinal)
    )
    from kb.chunks c
    join kb.document_versions dv on dv.id = c.document_version_id
    join kb.documents d on d.id = dv.document_id
    where d.document_id = 'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC'
      and c.active and c.chunk_id = 'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC-CH-001'
  ) documents;

  if result is null
     or jsonb_array_length(result->'documents') <> 2
     or (select sum(jsonb_array_length(value->'chunks')) from jsonb_array_elements(result->'documents')) <> 5 then
    raise exception 'LP-ACC-2026-0005 embedding documents are incomplete' using errcode = '55000';
  end if;
  return result;
end;
$$;

create or replace function public.store_lapipa_vimeo_0005_embedding_results(
  requested_job_id text, requested_items jsonb
)
returns integer language plpgsql security definer set search_path = ''
as $$
declare
  item jsonb;
  target_chunk kb.chunks%rowtype;
  target_model bigint;
  stored integer := 0;
begin
  if requested_job_id <> 'LP-EMBED-VIMEO-0005-2026-08-08'
     or not exists (select 1 from ops.ingestion_jobs where job_id = requested_job_id and status = 'running') then
    raise exception 'embedding job is not running' using errcode = '55000';
  end if;
  if jsonb_typeof(requested_items) <> 'array' or jsonb_array_length(requested_items) <> 5 then
    raise exception 'invalid embedding result batch' using errcode = '22023';
  end if;
  select id into target_model from rag.embedding_models
  where provider = 'voyage' and model = 'voyage-context-4'
    and dimensions = 1024 and status in ('pilot','active')
  order by id limit 1;
  if target_model is null then
    raise exception 'embedding model is not approved' using errcode = '22023';
  end if;

  for item in select value from jsonb_array_elements(requested_items)
  loop
    select * into target_chunk from kb.chunks
    where chunk_id = item->>'chunk_id' and active
      and chunk_id in (
        'LP-RAG-033','LP-RAG-034','LP-RAG-035','LP-RAG-036',
        'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC-CH-001'
      );
    if target_chunk.id is null
       or target_chunk.content_sha256 <> item->>'content_sha256'
       or jsonb_typeof(item->'embedding') <> 'array'
       or jsonb_array_length(item->'embedding') <> 1024 then
      raise exception 'invalid embedding result item' using errcode = '22023';
    end if;
    insert into rag.chunk_embeddings (
      chunk_id, embedding_model_id, embedding, content_sha256,
      status, embedded_at, metadata
    ) values (
      target_chunk.id, target_model,
      (item->'embedding')::text::extensions.vector,
      target_chunk.content_sha256, 'active', now(),
      jsonb_build_object(
        'provider','voyage', 'api','contextualizedembeddings',
        'input_type','document', 'job_id','LP-EMBED-VIMEO-0005-2026-08-08',
        'accession_id','LP-ACC-2026-0005', 'controlled_document_id','LP-DOC-ARCH-030'
      )
    )
    on conflict (chunk_id, embedding_model_id, content_sha256) do update set
      embedding = excluded.embedding,
      status = 'active',
      embedded_at = excluded.embedded_at,
      metadata = excluded.metadata;
    stored := stored + 1;
  end loop;
  return stored;
end;
$$;

create or replace function public.finish_lapipa_vimeo_0005_embedding_job(
  requested_job_id text, requested_error text default null
)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare embedded_count integer; pending_count integer; final_status text;
begin
  if requested_job_id <> 'LP-EMBED-VIMEO-0005-2026-08-08' then
    raise exception 'unknown embedding job' using errcode = '22023';
  end if;
  select count(*) filter (where ce.id is not null), count(*) filter (where ce.id is null)
  into embedded_count, pending_count
  from kb.chunks c
  left join rag.embedding_models em
    on em.provider = 'voyage' and em.model = 'voyage-context-4' and em.dimensions = 1024
  left join rag.chunk_embeddings ce
    on ce.chunk_id = c.id and ce.embedding_model_id = em.id
   and ce.content_sha256 = c.content_sha256 and ce.status = 'active'
  where c.active and c.chunk_id in (
    'LP-RAG-033','LP-RAG-034','LP-RAG-035','LP-RAG-036',
    'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC-CH-001'
  );
  final_status := case when pending_count = 0 then 'succeeded' when embedded_count > 0 then 'partially_succeeded' else 'failed' end;
  update ops.ingestion_jobs
  set status = final_status,
      counts = jsonb_build_object('expected_chunks',5,'embedded',embedded_count,'pending',pending_count),
      error_summary = left(requested_error, 2000),
      completed_at = case when pending_count = 0 then now() else null end
  where job_id = requested_job_id;
  return jsonb_build_object('status',final_status,'embedded',embedded_count,'pending',pending_count);
end;
$$;

create or replace function public.search_lapipa_vimeo_0005_test(requested_query_embedding jsonb)
returns jsonb language plpgsql stable security definer set search_path = ''
as $$
declare result jsonb;
begin
  if jsonb_typeof(requested_query_embedding) <> 'array'
     or jsonb_array_length(requested_query_embedding) <> 1024 then
    raise exception 'invalid query embedding' using errcode = '22023';
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'chunk_id', ranked.chunk_id,
    'heading_path', ranked.heading_path,
    'similarity', ranked.similarity
  ) order by ranked.similarity desc), '[]'::jsonb)
  into result
  from (
    select c.chunk_id, c.heading_path,
      round((1 - (ce.embedding OPERATOR(extensions.<=>) requested_query_embedding::text::extensions.vector))::numeric, 6) similarity
    from kb.chunks c
    join rag.chunk_embeddings ce on ce.chunk_id = c.id
    join rag.embedding_models em on em.id = ce.embedding_model_id
    where c.active
      and c.chunk_id in (
        'LP-RAG-033','LP-RAG-034','LP-RAG-035','LP-RAG-036',
        'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC-CH-001'
      )
      and em.provider = 'voyage' and em.model = 'voyage-context-4' and em.dimensions = 1024
      and ce.status = 'active' and ce.content_sha256 = c.content_sha256
    order by ce.embedding OPERATOR(extensions.<=>) requested_query_embedding::text::extensions.vector
    limit 5
  ) ranked;
  return result;
end;
$$;

revoke all on function public.claim_lapipa_vimeo_0005_embedding_job(text) from public, anon, authenticated;
revoke all on function public.get_lapipa_vimeo_0005_embedding_documents(text) from public, anon, authenticated;
revoke all on function public.store_lapipa_vimeo_0005_embedding_results(text, jsonb) from public, anon, authenticated;
revoke all on function public.finish_lapipa_vimeo_0005_embedding_job(text, text) from public, anon, authenticated;
revoke all on function public.search_lapipa_vimeo_0005_test(jsonb) from public, anon, authenticated;
grant execute on function public.claim_lapipa_vimeo_0005_embedding_job(text) to service_role;
grant execute on function public.get_lapipa_vimeo_0005_embedding_documents(text) to service_role;
grant execute on function public.store_lapipa_vimeo_0005_embedding_results(text, jsonb) to service_role;
grant execute on function public.finish_lapipa_vimeo_0005_embedding_job(text, text) to service_role;
grant execute on function public.search_lapipa_vimeo_0005_test(jsonb) to service_role;

insert into kb.entities (
  entity_id, canonical_name, entity_type, description,
  verification_status, access_scope
) values
  (
    'archive-item:lp-media-vimeo-video-844151157',
    'Subterranea @ LA PIPA :: VIUDA',
    'archive_item',
    'Vimeo recording 844151157, preserved as accession LP-ACC-2026-0005 with a clean-restore-verified preservation master.',
    'workspace_and_live_connector_verified', 'restricted'
  ),
  (
    'transcript:lp-transcript-vimeo-844151157-es-mlx-v1',
    'Subterranea @ LA PIPA :: VIUDA provisional Spanish transcript',
    'machine_transcript',
    'Restricted machine-generated discovery transcript awaiting human Spanish-language review and not approved for verified quotation.',
    'machine_generated_unreviewed', 'restricted'
  ),
  (
    'platform:vimeo',
    'Vimeo',
    'media_platform',
    'Provider platform from which the owner-authorized source-quality file and provider metadata were captured. No credential material is recorded.',
    'provider_metadata_and_owner_api_reconciled', 'internal'
  )
on conflict (entity_id) do update set
  canonical_name = excluded.canonical_name,
  entity_type = excluded.entity_type,
  description = excluded.description,
  verification_status = excluded.verification_status,
  access_scope = excluded.access_scope,
  updated_at = now();

with proposed(relationship_id, subject_id, predicate, object_id, review_status) as (values
  ('LP-REL-018','entity:la-pipa-archives','HAS_COMPONENT','archive-item:lp-media-vimeo-video-844151157','approved'),
  ('LP-REL-019','platform:vimeo','PLATFORM_FOR','archive-item:lp-media-vimeo-video-844151157','approved'),
  ('LP-REL-020','archive-item:lp-media-vimeo-video-844151157','USES_PLATFORM','storage:miramonte-lapipa-archive','approved'),
  ('LP-REL-021','archive-item:lp-media-vimeo-video-844151157','HAS_COMPONENT','transcript:lp-transcript-vimeo-844151157-es-mlx-v1','review')
)
insert into kg.relationships (
  relationship_id, subject_entity_id, predicate, object_entity_id,
  valid_from, confidence, verification_status, review_status
)
select p.relationship_id, subject.id, p.predicate, object.id,
       '2026-08-08'::date, 1.000,
       case when p.relationship_id = 'LP-REL-021' then 'machine_generated_unreviewed' else 'workspace_and_live_connector_verified' end,
       p.review_status
from proposed p
join kb.entities subject on subject.entity_id = p.subject_id
join kb.entities object on object.entity_id = p.object_id
on conflict (relationship_id) do update set
  subject_entity_id = excluded.subject_entity_id,
  predicate = excluded.predicate,
  object_entity_id = excluded.object_entity_id,
  valid_from = excluded.valid_from,
  confidence = excluded.confidence,
  verification_status = excluded.verification_status,
  review_status = excluded.review_status,
  updated_at = now();

insert into kg.relationship_sources (relationship_id, source_id, locator, support_type)
select r.id, s.id, 'LP-DOC-ARCH-030', 'supports'
from kg.relationships r
cross join kb.sources s
where r.relationship_id in ('LP-REL-018','LP-REL-019','LP-REL-020','LP-REL-021')
  and s.source_id = 'LP-SRC-042'
on conflict (relationship_id, source_id) do update set
  locator = excluded.locator,
  support_type = excluded.support_type;

insert into kb.events (
  event_id, title, event_type, starts_at, ends_at, date_text,
  status, description, verification_status
) values (
  'LP-EVENT-010',
  'Vimeo 844151157 preservation ingest',
  'digital_preservation_ingest',
  '2026-08-08T02:58:07.020Z',
  '2026-08-08T03:42:34.393Z',
  '8 August 2026',
  'documented',
  'Owner-authorized capture, local technical characterization and provisional transcription, Backblaze replication, clean restore, SHA-256 verification, and Supabase registration for LP-ACC-2026-0005.',
  'workspace_and_live_connector_verified'
)
on conflict (event_id) do update set
  title = excluded.title,
  event_type = excluded.event_type,
  starts_at = excluded.starts_at,
  ends_at = excluded.ends_at,
  date_text = excluded.date_text,
  status = excluded.status,
  description = excluded.description,
  verification_status = excluded.verification_status,
  updated_at = now();

insert into kb.event_sources (event_id, source_id, locator, support_type)
select e.id, s.id, 'LP-DOC-ARCH-030', 'supports'
from kb.events e
cross join kb.sources s
where e.event_id = 'LP-EVENT-010' and s.source_id = 'LP-SRC-042'
on conflict (event_id, source_id) do update set
  locator = excluded.locator,
  support_type = excluded.support_type;

insert into kb.event_entities (event_id, entity_id, role)
select e.id, entity.id, roles.role
from kb.events e
join (values
  ('archive-item:lp-media-vimeo-video-844151157','preserved item'),
  ('platform:vimeo','source platform'),
  ('storage:miramonte-lapipa-archive','preservation destination'),
  ('transcript:lp-transcript-vimeo-844151157-es-mlx-v1','derived discovery transcript')
) as roles(entity_id,role) on true
join kb.entities entity on entity.entity_id = roles.entity_id
where e.event_id = 'LP-EVENT-010'
on conflict (event_id, entity_id, role) do nothing;

do $$
declare
  object_count integer;
  copy_count integer;
  fixity_count integer;
  segment_count integer;
  chunk_count integer;
  relationship_count integer;
  unsafe_rpc_grants integer;
begin
  select count(*) into object_count
  from archive.file_objects
  where file_id like 'LP-FILE-VIMEO-844151157-%';

  select count(*) into copy_count
  from archive.file_copies
  where copy_id like 'LP-COPY-B2-VIMEO-844151157-%'
    and replica_state = 'verified'
    and expected_sha256 = observed_sha256;

  select count(*) into fixity_count
  from archive.fixity_checks
  where check_id between 'LP-FIXITY-2026-0014' and 'LP-FIXITY-2026-0024'
    and result = 'pass'
    and expected_digest = observed_digest;

  select count(*) into segment_count
  from archive.transcript_segments s
  join archive.transcripts t on t.id = s.transcript_id
  where t.transcript_id = 'LP-TRANSCRIPT-VIMEO-844151157-ES-MLX-V1'
    and s.review_status = 'unreviewed';

  select count(*) into chunk_count
  from kb.chunks
  where active and chunk_id in (
    'LP-RAG-033','LP-RAG-034','LP-RAG-035','LP-RAG-036',
    'LP-MEDIA-VIMEO-VIDEO-844151157-TRANSCRIPT-DOC-CH-001'
  );

  select count(*) into relationship_count
  from kg.relationships
  where relationship_id in ('LP-REL-018','LP-REL-019','LP-REL-020','LP-REL-021');

  select count(*) into unsafe_rpc_grants
  from information_schema.routine_privileges
  where routine_schema = 'public'
    and routine_name in (
      'claim_lapipa_vimeo_0005_embedding_job',
      'get_lapipa_vimeo_0005_embedding_documents',
      'store_lapipa_vimeo_0005_embedding_results',
      'finish_lapipa_vimeo_0005_embedding_job',
      'search_lapipa_vimeo_0005_test'
    )
    and grantee in ('PUBLIC','anon','authenticated');

  if object_count <> 11 or copy_count <> 11 or fixity_count <> 11
     or segment_count <> 10 or chunk_count <> 5 or relationship_count <> 4
     or unsafe_rpc_grants <> 0 then
    raise exception 'LP-ACC-2026-0005 registration invariant failed: objects %, copies %, fixity %, segments %, chunks %, relationships %, unsafe grants %',
      object_count, copy_count, fixity_count, segment_count, chunk_count,
      relationship_count, unsafe_rpc_grants using errcode = '55000';
  end if;
end;
$$;

insert into ops.schema_versions (version, description)
values (
  '2026-08-08-vimeo-0005-catalogue-rag-v1',
  'Registers LP-ACC-2026-0005, 11 Backblaze objects and copies, full clean-restore fixity evidence, technical tracks, provisional transcript and segments, provenance-linked RAG records, one-time Voyage embedding RPCs, and graph records.'
)
on conflict (version) do nothing;

commit;
