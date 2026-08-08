begin;

do $$
declare
  active_embedding_count integer;
begin
  select count(*) into active_embedding_count
  from rag.chunk_embeddings e
  join kb.chunks c on c.id = e.chunk_id
  join rag.embedding_models m on m.id = e.embedding_model_id
  where c.chunk_id = any (array[
    'LP-MEDIA-VIMEO-VIDEO-454577632-TRANSCRIPT-DOC-CH-001',
    'LP-MEDIA-VIMEO-VIDEO-668249621-TRANSCRIPT-DOC-CH-001',
    'LP-MEDIA-VIMEO-VIDEO-668249621-TRANSCRIPT-DOC-CH-002',
    'LP-MEDIA-VIMEO-VIDEO-806187133-TRANSCRIPT-DOC-CH-001'
  ])
    and e.status = 'active'
    and e.content_sha256 = c.content_sha256
    and m.provider = 'voyage'
    and m.model = 'voyage-context-4'
    and m.dimensions = 1024;

  if active_embedding_count <> 4 then
    raise exception 'Vimeo pilot embedding finalization expected 4 active current embeddings, found %',
      active_embedding_count;
  end if;
end
$$;

update ops.ingestion_jobs
set status = 'succeeded',
    counts = counts || '{"embeddings_pending":0,"embeddings_active":4}'::jsonb,
    error_summary = null,
    completed_at = coalesce(completed_at, now())
where job_id = 'LP-INGEST-VIMEO-PILOT-2026-08-08';

insert into ops.schema_versions (version, description)
values (
  '2026-08-08-vimeo-preservation-pilot-embeddings-v1',
  'Validated four current Voyage context-4 embeddings for accession LP-ACC-2026-0004 and finalized the pilot ingestion job.'
)
on conflict (version) do nothing;

commit;
