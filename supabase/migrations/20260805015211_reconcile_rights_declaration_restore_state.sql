begin;

-- Preview branches and database restores intentionally do not copy production
-- Auth rows. Documentary authority records must still replay completely; the
-- environment-specific Auth UUID remains a nullable assignment and audit actor.
insert into archive.agents (
  agent_id, entity_id, agent_type, authorized_name, alternative_names,
  biography_or_history, metadata
)
select
  'LP-AGENT-ALEX-LAWTON',
  e.id,
  'person',
  'Alex Lawton',
  array['Alex Lawton (L-A-W-T-O-N)'],
  'Archive owner for the La Pipa Documentary Archive. Alex Lawton declared on 2026-08-05 that he and his holding company, Miramonte, S.L., collectively own 100% of the intellectual-property and related rights in La Pipa and associated project materials.',
  jsonb_build_object(
    'governance_role', 'archive_owner_and_declared_rights_holder',
    'evidence_class', 'user_supplied',
    'rights_declaration_source_id', 'LP-SRC-038',
    'co_holder_agent_id', 'LP-AGENT-MIRAMONTE-SL',
    'rights_declaration_date', '2026-08-05',
    'auth_binding', case
      when exists (
        select 1 from auth.users
        where id = '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid
      ) then 'kb.workspace_members'
      else 'environment_specific_auth_binding_absent'
    end
  )
from kb.entities e
where e.entity_id = 'person:alex-lawton'
on conflict (agent_id) do update
set entity_id = excluded.entity_id,
    authorized_name = excluded.authorized_name,
    alternative_names = excluded.alternative_names,
    biography_or_history = excluded.biography_or_history,
    metadata = archive.agents.metadata || excluded.metadata,
    updated_at = now();

insert into archive.rights_statements (
  rights_id, label, rights_basis, rights_holder_agent_id, jurisdiction,
  permitted_uses, restrictions, credit_line, evidence_source_id,
  review_status, notes
)
select
  'LP-RIGHTS-ALEX-2026-001',
  'Alex Lawton declared La Pipa rights ownership',
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
from archive.agents a
cross join kb.sources s
where a.agent_id = 'LP-AGENT-ALEX-LAWTON'
  and s.source_id = 'LP-SRC-038'
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

insert into ops.review_tasks (
  review_id, record_type, stable_record_id, reason, status, assigned_to
)
values (
  'LP-REV-RIGHTS-NONCOPYRIGHT-2026-001',
  'rights_and_ethics',
  'LP-ARCHIVE-001',
  'Archive-level copyright ownership is declared by Alex Lawton for himself and Miramonte, S.L. Continue item-level privacy, consent, moral-rights, performer, confidentiality, contractual, trademark, accessibility, and release review before unrestricted publication.',
  'open',
  (select id from auth.users where id = '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid)
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
values (
  'LP-EMBED-RIGHTS-2026-08-05',
  'voyage_contextual_embedding',
  'queued',
  (select id from auth.users where id = '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid),
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
  (select id from auth.users where id = '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid),
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
    'access_scope_changed', false,
    'auth_actor_present', exists (
      select 1 from auth.users
      where id = '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid
    )
  )
where not exists (
  select 1 from ops.audit_log
  where action = 'rights_ownership_declaration_recorded'
    and stable_record_id = 'LP-DOC-ARCH-021'
);

insert into ops.schema_versions (version, description)
values (
  '2026-08-05-rights-ownership-restore-v1',
  'Makes documentary rights-holder, item-rights, review, embedding-job, and audit records replay independently of environment-specific Auth data.'
)
on conflict (version) do nothing;

commit;
