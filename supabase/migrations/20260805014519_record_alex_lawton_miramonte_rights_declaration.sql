begin;

insert into kb.sources (
  source_id, title, source_type, evidence_class, source_date,
  origin_uri, access_scope, verification_status, description, metadata
) values (
  'LP-SRC-038',
  'Alex Lawton and Miramonte, S.L. rights ownership declaration',
  'user_statement',
  'user_supplied',
  '2026-08-05',
  'https://github.com/alex-lapipa/lapipa.archives/blob/main/docs/archive/rights-ownership-declaration.md',
  'public',
  'user_supplied_owner_declaration',
  'Alex Lawton states that he and his holding company, Miramonte, S.L., collectively own 100% of the intellectual-property and related rights in La Pipa and the associated project materials.',
  jsonb_build_object(
    'declarant', 'Alex Lawton',
    'corporate_rights_holder', 'Miramonte, S.L.',
    'declared_share_collectively', '100%',
    'evidence_boundary', 'direct_owner_statement_not_independent_legal_opinion',
    'controlled_document_id', 'LP-DOC-ARCH-021'
  )
)
on conflict (source_id) do update
set title = excluded.title,
    source_type = excluded.source_type,
    evidence_class = excluded.evidence_class,
    source_date = excluded.source_date,
    origin_uri = excluded.origin_uri,
    access_scope = excluded.access_scope,
    verification_status = excluded.verification_status,
    description = excluded.description,
    metadata = kb.sources.metadata || excluded.metadata,
    updated_at = now();

insert into kb.entities (
  entity_id, canonical_name, entity_type, description,
  verification_status, access_scope
) values (
  'entity:miramonte-sl',
  'Miramonte, S.L.',
  'organization',
  'Holding company named by Alex Lawton as a collective rights holder for La Pipa and associated project materials.',
  'user_supplied',
  'public'
)
on conflict (entity_id) do update
set canonical_name = excluded.canonical_name,
    entity_type = excluded.entity_type,
    description = excluded.description,
    verification_status = excluded.verification_status,
    access_scope = excluded.access_scope,
    updated_at = now();

insert into archive.agents (
  agent_id, entity_id, agent_type, authorized_name, alternative_names,
  biography_or_history, metadata
)
select
  'LP-AGENT-MIRAMONTE-SL',
  e.id,
  'organization',
  'Miramonte, S.L.',
  array['Miramonte SL'],
  'Holding company named by Alex Lawton in a direct declaration dated 2026-08-05 as a collective rights holder for La Pipa and associated project materials.',
  jsonb_build_object(
    'governance_role', 'declared_rights_holder',
    'evidence_class', 'user_supplied',
    'source_id', 'LP-SRC-038',
    'declared_at', '2026-08-05'
  )
from kb.entities e
where e.entity_id = 'entity:miramonte-sl'
on conflict (agent_id) do update
set entity_id = excluded.entity_id,
    authorized_name = excluded.authorized_name,
    alternative_names = excluded.alternative_names,
    biography_or_history = excluded.biography_or_history,
    metadata = archive.agents.metadata || excluded.metadata,
    updated_at = now();

update archive.agents
set biography_or_history =
      'Archive owner for the La Pipa Documentary Archive. Alex Lawton declared on 2026-08-05 that he and his holding company, Miramonte, S.L., collectively own 100% of the intellectual-property and related rights in La Pipa and associated project materials.',
    metadata = metadata || jsonb_build_object(
      'declared_rights_holder', true,
      'rights_declaration_source_id', 'LP-SRC-038',
      'co_holder_agent_id', 'LP-AGENT-MIRAMONTE-SL',
      'rights_declaration_date', '2026-08-05'
    ),
    updated_at = now()
where agent_id = 'LP-AGENT-ALEX-LAWTON';

insert into kb.claims (
  claim_id, statement, verification_status, confidence, review_status
) values (
  'LP-CLAIM-010',
  'On 5 August 2026, Alex Lawton stated that he and his holding company, Miramonte, S.L., collectively own 100% of the intellectual-property and related rights in La Pipa and associated project materials.',
  'user_supplied',
  1.000,
  'approved'
)
on conflict (claim_id) do update
set statement = excluded.statement,
    verification_status = excluded.verification_status,
    confidence = excluded.confidence,
    review_status = excluded.review_status,
    updated_at = now();

insert into kb.claim_sources (claim_id, source_id, locator, support_type)
select c.id, s.id, 'LP-DOC-ARCH-021', 'supports'
from kb.claims c
join kb.sources s on s.source_id = 'LP-SRC-038'
where c.claim_id = 'LP-CLAIM-010'
on conflict (claim_id, source_id) do update
set locator = excluded.locator,
    support_type = excluded.support_type;

insert into kg.predicate_registry (
  predicate, inverse_predicate, description,
  subject_type_guidance, object_type_guidance
) values
  (
    'DECLARES_RIGHTS_OWNERSHIP_OF',
    'HAS_DECLARED_RIGHTS_HOLDER',
    'The subject is recorded as declaring rights ownership of the object; evidence classification must distinguish a declaration from independent legal verification.',
    'person or organization',
    'project, work, collection, or organization'
  ),
  (
    'HAS_DECLARED_RIGHTS_HOLDER',
    'DECLARES_RIGHTS_OWNERSHIP_OF',
    'The object has the subject recorded as a declared rights holder; evidence classification must remain attached.',
    'project, work, collection, or organization',
    'person or organization'
  )
on conflict (predicate) do update
set inverse_predicate = excluded.inverse_predicate,
    description = excluded.description,
    subject_type_guidance = excluded.subject_type_guidance,
    object_type_guidance = excluded.object_type_guidance;

insert into kg.relationships (
  relationship_id, subject_entity_id, predicate, object_entity_id,
  valid_from, confidence, verification_status, review_status
)
select v.relationship_id, subject_entity.id, 'DECLARES_RIGHTS_OWNERSHIP_OF', lapipa.id,
       '2026-08-05', 1.000, 'user_supplied', 'approved'
from (values
  ('LP-REL-012', 'person:alex-lawton'),
  ('LP-REL-013', 'entity:miramonte-sl')
) v(relationship_id, subject_entity_id)
join kb.entities subject_entity on subject_entity.entity_id = v.subject_entity_id
join kb.entities lapipa on lapipa.entity_id = 'entity:la-pipa'
on conflict (relationship_id) do update
set subject_entity_id = excluded.subject_entity_id,
    predicate = excluded.predicate,
    object_entity_id = excluded.object_entity_id,
    valid_from = excluded.valid_from,
    confidence = excluded.confidence,
    verification_status = excluded.verification_status,
    review_status = excluded.review_status,
    updated_at = now();

insert into kg.relationship_sources (
  relationship_id, source_id, locator, support_type
)
select r.id, s.id, 'LP-DOC-ARCH-021', 'supports'
from kg.relationships r
cross join kb.sources s
where r.relationship_id in ('LP-REL-012', 'LP-REL-013')
  and s.source_id = 'LP-SRC-038'
on conflict (relationship_id, source_id) do update
set locator = excluded.locator,
    support_type = excluded.support_type;

insert into archive.rights_statements (
  rights_id, label, rights_basis, rights_holder_agent_id, jurisdiction,
  permitted_uses, restrictions, credit_line, evidence_source_id,
  review_status, notes
)
select
  v.rights_id,
  v.label,
  'copyright',
  a.id,
  'Spain',
  array[
    'preservation', 'description', 'indexing', 'embedding', 'migration',
    'replication', 'controlled access', 'documentary preparation'
  ],
  array[
    'owner-approved release required for unrestricted publication',
    'privacy, consent, moral rights, publicity rights, confidentiality, performer rights, music clearance, trademark, and contractual duties remain separately reviewed'
  ],
  '© Alex Lawton and Miramonte, S.L. All rights reserved.',
  s.id,
  'approved',
  'Direct owner-supplied declaration dated 2026-08-05. Alex Lawton states that he and Miramonte, S.L. collectively hold 100% of the relevant rights. Approved means accepted as the archive operational basis, not independently verified chain of title.'
from (values
  ('LP-RIGHTS-ALEX-2026-001', 'Alex Lawton declared La Pipa rights ownership', 'LP-AGENT-ALEX-LAWTON'),
  ('LP-RIGHTS-MIRAMONTE-2026-001', 'Miramonte, S.L. declared La Pipa rights ownership', 'LP-AGENT-MIRAMONTE-SL')
) v(rights_id, label, agent_id)
join archive.agents a on a.agent_id = v.agent_id
cross join kb.sources s
where s.source_id = 'LP-SRC-038'
on conflict (rights_id) do update
set label = excluded.label,
    rights_basis = excluded.rights_basis,
    rights_holder_agent_id = excluded.rights_holder_agent_id,
    jurisdiction = excluded.jurisdiction,
    permitted_uses = excluded.permitted_uses,
    restrictions = excluded.restrictions,
    credit_line = excluded.credit_line,
    evidence_source_id = excluded.evidence_source_id,
    review_status = excluded.review_status,
    notes = excluded.notes,
    updated_at = now();

insert into archive.item_rights (
  item_id, rights_statement_id, applies_to, access_decision
)
select i.id, rs.id, 'content',
       case i.access_scope
         when 'public' then 'public'
         when 'reading_room' then 'reading_room'
         when 'closed' then 'closed'
         else 'restricted'
       end
from archive.items i
cross join archive.rights_statements rs
where rs.rights_id in (
  'LP-RIGHTS-ALEX-2026-001',
  'LP-RIGHTS-MIRAMONTE-2026-001'
)
on conflict (item_id, rights_statement_id, applies_to) do update
set access_decision = excluded.access_decision;

insert into kb.documents (
  document_id, primary_source_id, title, language, document_type,
  lifecycle_status, access_scope
)
select
  'lp-rights-ownership-declaration-2026-08-05-v1',
  s.id,
  'La Pipa rights ownership declaration',
  'en',
  'rights_declaration',
  'approved',
  'public'
from kb.sources s
where s.source_id = 'LP-SRC-038'
on conflict (document_id) do update
set primary_source_id = excluded.primary_source_id,
    title = excluded.title,
    language = excluded.language,
    document_type = excluded.document_type,
    lifecycle_status = excluded.lifecycle_status,
    access_scope = excluded.access_scope,
    updated_at = now();

with declaration_text(content) as (values (
  $$Alex Lawton states that he and his holding company, Miramonte, S.L., collectively own 100% of the intellectual-property and related rights in La Pipa and in the materials, initiatives, content, archive, documentation, and project assets associated with La Pipa. The archive records this as a direct owner-supplied declaration and operational copyright basis, not as an independently verified chain-of-title opinion. The declaration authorizes preservation, description, indexing, embedding, migration, replication, controlled access, and documentary preparation. It does not automatically authorize unrestricted publication or supersede privacy, consent, moral-rights, performer, confidentiality, contractual, trademark, accessibility, and release review. The approved credit line is: © Alex Lawton and Miramonte, S.L. All rights reserved.$$
))
insert into kb.document_versions (
  document_id, version, content_sha256, mime_type, byte_count,
  extracted_text, effective_from
)
select
  d.id,
  '2026-08-05-v1',
  encode(extensions.digest(dt.content, 'sha256'), 'hex'),
  'text/markdown',
  octet_length(dt.content),
  dt.content,
  '2026-08-05T00:00:00Z'
from kb.documents d
cross join declaration_text dt
where d.document_id = 'lp-rights-ownership-declaration-2026-08-05-v1'
on conflict (document_id, version) do update
set content_sha256 = excluded.content_sha256,
    mime_type = excluded.mime_type,
    byte_count = excluded.byte_count,
    extracted_text = excluded.extracted_text,
    effective_from = excluded.effective_from;

with declaration_text(content) as (values (
  $$Alex Lawton states that he and his holding company, Miramonte, S.L., collectively own 100% of the intellectual-property and related rights in La Pipa and in the materials, initiatives, content, archive, documentation, and project assets associated with La Pipa. The archive records this as a direct owner-supplied declaration and operational copyright basis, not as an independently verified chain-of-title opinion. The declaration authorizes preservation, description, indexing, embedding, migration, replication, controlled access, and documentary preparation. It does not automatically authorize unrestricted publication or supersede privacy, consent, moral-rights, performer, confidentiality, contractual, trademark, accessibility, and release review. The approved credit line is: © Alex Lawton and Miramonte, S.L. All rights reserved.$$
))
insert into kb.chunks (
  chunk_id, document_version_id, ordinal, heading_path, content,
  token_count, content_sha256, language, verification_status,
  access_scope, active, metadata
)
select
  'LP-RAG-020',
  dv.id,
  20,
  'rights ownership declaration',
  dt.content,
  greatest(1, ceil(length(dt.content)::numeric / 4)::integer),
  encode(extensions.digest(dt.content, 'sha256'), 'hex'),
  'en',
  'user_supplied',
  'public',
  true,
  jsonb_build_object(
    'source_ids', jsonb_build_array('LP-SRC-038'),
    'evidence_boundary', 'direct_owner_statement_not_independent_legal_opinion',
    'rights_statement_ids', jsonb_build_array(
      'LP-RIGHTS-ALEX-2026-001',
      'LP-RIGHTS-MIRAMONTE-2026-001'
    ),
    'retrieval_scope', 'authenticated'
  )
from kb.document_versions dv
join kb.documents d on d.id = dv.document_id
cross join declaration_text dt
where d.document_id = 'lp-rights-ownership-declaration-2026-08-05-v1'
  and dv.version = '2026-08-05-v1'
on conflict (chunk_id) do update
set document_version_id = excluded.document_version_id,
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
select c.id, s.id, 'LP-DOC-ARCH-021', 'supports'
from kb.chunks c
cross join kb.sources s
where c.chunk_id = 'LP-RAG-020'
  and s.source_id = 'LP-SRC-038'
on conflict (chunk_id, source_id) do update
set locator = excluded.locator,
    support_type = excluded.support_type;

insert into kb.collection_items (
  collection_id, record_type, stable_record_id, ordinal
)
select c.id, 'rag_chunk', 'LP-RAG-020', 20
from kb.collections c
where c.collection_id = 'LP-COLLECTION-001'
on conflict (collection_id, record_type, stable_record_id) do update
set ordinal = excluded.ordinal;

insert into rag.evaluation_questions (
  question_id, question, language, expected_source_ids,
  required_concepts, forbidden_concepts, active
) values (
  'LP-EVAL-009',
  'Who owns the rights in La Pipa and its project materials?',
  'en',
  array['LP-SRC-038'],
  array['Alex Lawton', 'Miramonte, S.L.', 'owner declaration', '100% collectively'],
  array['independently verified chain of title', 'automatically public'],
  true
)
on conflict (question_id) do update
set question = excluded.question,
    language = excluded.language,
    expected_source_ids = excluded.expected_source_ids,
    required_concepts = excluded.required_concepts,
    forbidden_concepts = excluded.forbidden_concepts,
    active = excluded.active;

insert into ops.review_tasks (
  review_id, record_type, stable_record_id, reason, status, assigned_to
)
select
  'LP-REV-RIGHTS-NONCOPYRIGHT-2026-001',
  'rights_and_ethics',
  'LP-ARCHIVE-001',
  'Archive-level copyright ownership is declared by Alex Lawton for himself and Miramonte, S.L. Continue item-level privacy, consent, moral-rights, performer, confidentiality, contractual, trademark, accessibility, and release review before unrestricted publication.',
  'open',
  '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid
where exists (
  select 1 from auth.users
  where id = '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid
)
on conflict (review_id) do update
set reason = excluded.reason,
    status = excluded.status,
    assigned_to = excluded.assigned_to,
    resolved_by = null,
    resolved_at = null;

insert into ops.ingestion_jobs (
  job_id, job_type, status, initiated_by, input_manifest, counts
)
select
  'LP-EMBED-RIGHTS-2026-08-05',
  'voyage_contextual_embedding',
  'queued',
  '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid,
  jsonb_build_object(
    'source_id', 'LP-SRC-038',
    'document_id', 'lp-rights-ownership-declaration-2026-08-05-v1',
    'chunk_id', 'LP-RAG-020',
    'provider', 'voyage',
    'model', 'voyage-context-4',
    'dimensions', 1024,
    'evidence_boundary', 'user_supplied_owner_declaration'
  ),
  jsonb_build_object('expected_chunks', 1, 'embedded', 0, 'pending', 1)
where exists (
  select 1 from auth.users
  where id = '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid
)
on conflict (job_id) do update
set input_manifest = excluded.input_manifest,
    counts = case
      when ops.ingestion_jobs.status = 'succeeded' then ops.ingestion_jobs.counts
      else excluded.counts
    end;

insert into ops.audit_log (
  actor_user_id, actor_role, action, record_type, stable_record_id, details
)
select
  '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid,
  'owner',
  'rights_ownership_declaration_recorded',
  'rights_declaration',
  'LP-DOC-ARCH-021',
  jsonb_build_object(
    'source_id', 'LP-SRC-038',
    'declarant_agent_id', 'LP-AGENT-ALEX-LAWTON',
    'corporate_holder_agent_id', 'LP-AGENT-MIRAMONTE-SL',
    'declared_share_collectively', '100%',
    'rights_statement_ids', jsonb_build_array(
      'LP-RIGHTS-ALEX-2026-001',
      'LP-RIGHTS-MIRAMONTE-2026-001'
    ),
    'evidence_class', 'user_supplied',
    'independent_legal_verification_claimed', false,
    'access_scope_changed', false
  )
where exists (
  select 1 from auth.users
  where id = '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid
)
and not exists (
  select 1 from ops.audit_log
  where action = 'rights_ownership_declaration_recorded'
    and stable_record_id = 'LP-DOC-ARCH-021'
);

insert into ops.schema_versions (version, description)
values (
  '2026-08-05-rights-ownership-v1',
  'Owner-supplied Alex Lawton and Miramonte, S.L. collective 100% La Pipa rights declaration, provenance, graph, RAG, archive rights, and audit controls.'
)
on conflict (version) do nothing;

commit;
