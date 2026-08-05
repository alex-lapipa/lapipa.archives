begin;

create or replace function public.get_chunks_for_embedding(requested_chunk_ids text[] default null)
returns table (chunk_id text, content text, content_sha256 text)
language sql
stable
security invoker
set search_path = ''
as $$
  select c.chunk_id, c.content, c.content_sha256
  from kb.chunks c
  where c.active
    and (requested_chunk_ids is null or c.chunk_id = any(requested_chunk_ids))
    and private.has_workspace_role(array['owner','editor'])
  order by c.ordinal, c.chunk_id
  limit 1000;
$$;

revoke all on function public.get_chunks_for_embedding(text[]) from public, anon;
grant execute on function public.get_chunks_for_embedding(text[]) to authenticated, service_role;

create or replace function public.upsert_chunk_embedding(
  requested_chunk_id text,
  requested_model text,
  requested_dimensions integer,
  requested_embedding extensions.vector(1024),
  requested_content_sha256 text,
  requested_metadata jsonb default '{}'::jsonb
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_chunk kb.chunks%rowtype;
  target_model_id bigint;
begin
  if not private.has_workspace_role(array['owner','editor']) then
    raise exception 'insufficient workspace role' using errcode = '42501';
  end if;

  select * into target_chunk
  from kb.chunks
  where chunk_id = requested_chunk_id and active;

  if target_chunk.id is null then
    raise exception 'unknown active chunk' using errcode = '22023';
  end if;

  if target_chunk.content_sha256 <> requested_content_sha256 then
    raise exception 'content hash mismatch' using errcode = '22000';
  end if;

  select id into target_model_id
  from rag.embedding_models
  where provider = 'voyage'
    and model = requested_model
    and dimensions = requested_dimensions
    and status in ('pilot','active');

  if target_model_id is null then
    raise exception 'unapproved embedding model' using errcode = '22023';
  end if;

  insert into rag.chunk_embeddings (
    chunk_id, embedding_model_id, embedding, content_sha256, status, embedded_at, metadata
  ) values (
    target_chunk.id, target_model_id, requested_embedding, requested_content_sha256, 'active', now(), requested_metadata
  )
  on conflict (chunk_id, embedding_model_id, content_sha256)
  do update set embedding = excluded.embedding, status = 'active', embedded_at = now(), metadata = excluded.metadata;

  return requested_chunk_id;
end;
$$;

revoke all on function public.upsert_chunk_embedding(text,text,integer,extensions.vector,text,jsonb) from public, anon;
grant execute on function public.upsert_chunk_embedding(text,text,integer,extensions.vector,text,jsonb) to authenticated, service_role;

create or replace function public.admin_get_chunks_for_embedding(requested_chunk_ids text[] default null)
returns table (chunk_id text, content text, content_sha256 text)
language sql
stable
security definer
set search_path = ''
as $$
  select c.chunk_id, c.content, c.content_sha256
  from kb.chunks c
  where c.active and (requested_chunk_ids is null or c.chunk_id = any(requested_chunk_ids))
  order by c.ordinal, c.chunk_id
  limit 1000;
$$;

revoke all on function public.admin_get_chunks_for_embedding(text[]) from public, anon, authenticated;
grant execute on function public.admin_get_chunks_for_embedding(text[]) to service_role;

create or replace function public.admin_upsert_chunk_embedding(
  requested_chunk_id text,
  requested_model text,
  requested_dimensions integer,
  requested_embedding extensions.vector(1024),
  requested_content_sha256 text,
  requested_metadata jsonb default '{}'::jsonb
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_chunk kb.chunks%rowtype;
  target_model_id bigint;
begin
  select * into target_chunk from kb.chunks where chunk_id=requested_chunk_id and active;
  if target_chunk.id is null or target_chunk.content_sha256 <> requested_content_sha256 then
    raise exception 'unknown chunk or content hash mismatch' using errcode='22023';
  end if;
  select id into target_model_id from rag.embedding_models
  where provider='voyage' and model=requested_model and dimensions=requested_dimensions and status in ('pilot','active');
  if target_model_id is null then raise exception 'unapproved embedding model' using errcode='22023'; end if;
  insert into rag.chunk_embeddings (chunk_id,embedding_model_id,embedding,content_sha256,status,embedded_at,metadata)
  values (target_chunk.id,target_model_id,requested_embedding,requested_content_sha256,'active',now(),requested_metadata)
  on conflict (chunk_id,embedding_model_id,content_sha256)
  do update set embedding=excluded.embedding,status='active',embedded_at=now(),metadata=excluded.metadata;
  return requested_chunk_id;
end;
$$;

revoke all on function public.admin_upsert_chunk_embedding(text,text,integer,extensions.vector,text,jsonb) from public, anon, authenticated;
grant execute on function public.admin_upsert_chunk_embedding(text,text,integer,extensions.vector,text,jsonb) to service_role;

commit;
