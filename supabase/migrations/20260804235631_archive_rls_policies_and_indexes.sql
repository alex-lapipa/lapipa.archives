begin;

create index archive_accessions_collection_idx on archive.accessions (collection_id);
create index archive_accessions_source_agent_idx on archive.accessions (source_agent_id);
create index archive_custody_events_evidence_source_idx on archive.custody_events (evidence_source_id);
create index archive_custody_events_from_agent_idx on archive.custody_events (from_agent_id);
create index archive_custody_events_to_agent_idx on archive.custody_events (to_agent_id);
create index archive_fixity_checks_event_idx on archive.fixity_checks (preservation_event_id);
create index archive_preservation_events_agent_idx on archive.preservation_events (agent_id);
create index archive_rights_evidence_source_idx on archive.rights_statements (evidence_source_id);
create index archive_transcript_segments_speaker_idx on archive.transcript_segments (speaker_agent_id);
create index archive_transcripts_representation_idx on archive.transcripts (representation_id);

do $$
declare table_record record;
begin
  for table_record in select tablename from pg_tables where schemaname='archive'
  loop
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

insert into ops.schema_versions (version, description)
values ('2026-08-05-archive-v1.1', 'Defense-in-depth archive RLS policies and complete foreign-key indexing.');

commit;
