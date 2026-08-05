begin;

create index relationships_predicate_idx on kg.relationships (predicate);
create index review_tasks_resolved_by_idx on ops.review_tasks (resolved_by);

create or replace function private.current_workspace_role_internal()
returns text language sql stable security definer set search_path=''
as $$
  select role from kb.workspace_members
  where user_id=(select auth.uid()) and active limit 1;
$$;
revoke all on function private.current_workspace_role_internal() from public, anon;
grant execute on function private.current_workspace_role_internal() to authenticated, service_role;

create or replace function public.current_workspace_role()
returns text language sql stable security invoker set search_path=''
as $$ select private.current_workspace_role_internal(); $$;

create or replace function private.search_knowledge_internal(
  query_text text,
  query_embedding extensions.vector(1024),
  match_count integer,
  filter_verification text[]
)
returns table (
  chunk_id text, document_id text, heading_path text, content text,
  verification_status text, source_ids text[], keyword_rank real,
  semantic_similarity real, combined_score double precision
)
language sql stable security definer set search_path=''
as $$
  with permitted as (
    select c.*, d.document_id
    from kb.chunks c
    join kb.document_versions dv on dv.id=c.document_version_id
    join kb.documents d on d.id=dv.document_id
    where c.active
      and (filter_verification is null or c.verification_status=any(filter_verification))
      and private.has_workspace_role(array['owner','editor','reviewer','reader'])
  ), keyword as (
    select p.id,
      row_number() over(order by ts_rank_cd(p.search_vector,websearch_to_tsquery('simple',query_text)) desc,p.id) rank,
      ts_rank_cd(p.search_vector,websearch_to_tsquery('simple',query_text))::real score
    from permitted p
    where nullif(btrim(query_text),'') is not null
      and p.search_vector @@ websearch_to_tsquery('simple',query_text)
    order by score desc,p.id limit greatest(match_count*5,20)
  ), semantic as (
    select p.id,
      row_number() over(order by ce.embedding operator(extensions.<=>) query_embedding,p.id) rank,
      (1-(ce.embedding operator(extensions.<=>) query_embedding))::real score
    from permitted p join rag.chunk_embeddings ce on ce.chunk_id=p.id and ce.status='active'
    where query_embedding is not null
    order by ce.embedding operator(extensions.<=>) query_embedding,p.id
    limit greatest(match_count*5,20)
  ), candidates as (
    select coalesce(k.id,s.id) id,k.score keyword_rank,s.score semantic_similarity,
      coalesce(1.0/(60+k.rank),0)+coalesce(1.0/(60+s.rank),0) combined_score
    from keyword k full outer join semantic s on s.id=k.id
  )
  select p.chunk_id,p.document_id,p.heading_path,p.content,p.verification_status,
    coalesce(array_agg(src.source_id order by src.source_id) filter(where src.source_id is not null),'{}') source_ids,
    c.keyword_rank,c.semantic_similarity,c.combined_score
  from candidates c join permitted p on p.id=c.id
  left join kb.chunk_sources cs on cs.chunk_id=p.id
  left join kb.sources src on src.id=cs.source_id
  group by p.chunk_id,p.document_id,p.heading_path,p.content,p.verification_status,
    c.keyword_rank,c.semantic_similarity,c.combined_score
  order by c.combined_score desc,p.chunk_id
  limit least(greatest(match_count,1),50);
$$;
revoke all on function private.search_knowledge_internal(text,extensions.vector,integer,text[]) from public,anon;
grant execute on function private.search_knowledge_internal(text,extensions.vector,integer,text[]) to authenticated,service_role;

create or replace function public.search_knowledge(
  query_text text,
  query_embedding extensions.vector(1024) default null,
  match_count integer default 10,
  filter_verification text[] default null
)
returns table (
  chunk_id text, document_id text, heading_path text, content text,
  verification_status text, source_ids text[], keyword_rank real,
  semantic_similarity real, combined_score double precision
)
language sql stable security invoker set search_path=''
as $$
  select * from private.search_knowledge_internal(query_text,query_embedding,match_count,filter_verification);
$$;

create or replace function private.get_chunks_for_embedding_internal(requested_chunk_ids text[])
returns table(chunk_id text,content text,content_sha256 text)
language sql stable security definer set search_path=''
as $$
  select c.chunk_id,c.content,c.content_sha256 from kb.chunks c
  where c.active
    and (requested_chunk_ids is null or c.chunk_id=any(requested_chunk_ids))
    and private.has_workspace_role(array['owner','editor'])
  order by c.ordinal,c.chunk_id limit 1000;
$$;
revoke all on function private.get_chunks_for_embedding_internal(text[]) from public,anon;
grant execute on function private.get_chunks_for_embedding_internal(text[]) to authenticated,service_role;

create or replace function public.get_chunks_for_embedding(requested_chunk_ids text[] default null)
returns table(chunk_id text,content text,content_sha256 text)
language sql stable security invoker set search_path=''
as $$ select * from private.get_chunks_for_embedding_internal(requested_chunk_ids); $$;

create or replace function private.upsert_chunk_embedding_internal(
  requested_chunk_id text, requested_model text, requested_dimensions integer,
  requested_embedding extensions.vector(1024), requested_content_sha256 text,
  requested_metadata jsonb
)
returns text language plpgsql security definer set search_path=''
as $$
declare target_chunk kb.chunks%rowtype; target_model_id bigint;
begin
  if not private.has_workspace_role(array['owner','editor']) then
    raise exception 'insufficient workspace role' using errcode='42501';
  end if;
  select * into target_chunk from kb.chunks where chunk_id=requested_chunk_id and active;
  if target_chunk.id is null or target_chunk.content_sha256<>requested_content_sha256 then
    raise exception 'unknown chunk or content hash mismatch' using errcode='22023';
  end if;
  select id into target_model_id from rag.embedding_models
  where provider='voyage' and model=requested_model and dimensions=requested_dimensions and status in ('pilot','active');
  if target_model_id is null then raise exception 'unapproved embedding model' using errcode='22023'; end if;
  insert into rag.chunk_embeddings(chunk_id,embedding_model_id,embedding,content_sha256,status,embedded_at,metadata)
  values(target_chunk.id,target_model_id,requested_embedding,requested_content_sha256,'active',now(),requested_metadata)
  on conflict(chunk_id,embedding_model_id,content_sha256)
  do update set embedding=excluded.embedding,status='active',embedded_at=now(),metadata=excluded.metadata;
  return requested_chunk_id;
end;
$$;
revoke all on function private.upsert_chunk_embedding_internal(text,text,integer,extensions.vector,text,jsonb) from public,anon;
grant execute on function private.upsert_chunk_embedding_internal(text,text,integer,extensions.vector,text,jsonb) to authenticated,service_role;

create or replace function public.upsert_chunk_embedding(
  requested_chunk_id text, requested_model text, requested_dimensions integer,
  requested_embedding extensions.vector(1024), requested_content_sha256 text,
  requested_metadata jsonb default '{}'::jsonb
)
returns text language sql security invoker set search_path=''
as $$
  select private.upsert_chunk_embedding_internal(requested_chunk_id,requested_model,requested_dimensions,requested_embedding,requested_content_sha256,requested_metadata);
$$;

drop function public.admin_get_chunks_for_embedding(text[]);
drop function public.admin_upsert_chunk_embedding(text,text,integer,extensions.vector,text,jsonb);

revoke all on all tables in schema kb,kg,rag,ops from authenticated;
revoke all on all sequences in schema kb,kg,rag,ops from authenticated;
revoke usage on schema kb,kg,rag,ops from authenticated;

grant execute on function public.current_workspace_role() to authenticated,service_role;
grant execute on function public.search_knowledge(text,extensions.vector,integer,text[]) to authenticated,service_role;
grant execute on function public.get_chunks_for_embedding(text[]) to authenticated,service_role;
grant execute on function public.upsert_chunk_embedding(text,text,integer,extensions.vector,text,jsonb) to authenticated,service_role;

commit;
