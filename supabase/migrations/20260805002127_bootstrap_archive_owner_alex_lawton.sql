begin;

do $$
declare
  owner_user_id constant uuid := '827fa26f-df7f-4d24-9521-0e44bcf37696';
  owner_entity_id bigint;
begin
  if not exists (
    select 1 from auth.users
    where id = owner_user_id and deleted_at is null and confirmed_at is not null
  ) then
    raise notice 'Archive owner Auth identity is absent in this environment; owner bootstrap skipped.';
    return;
  end if;

  insert into kb.workspace_members (user_id, role, active)
  values (owner_user_id, 'owner', true)
  on conflict (user_id) do update
  set role = excluded.role, active = true, updated_at = now();

  select id into owner_entity_id
  from kb.entities where entity_id = 'person:alex-lawton';

  insert into archive.agents (
    agent_id, entity_id, agent_type, authorized_name, alternative_names,
    biography_or_history, metadata
  ) values (
    'LP-AGENT-ALEX-LAWTON', owner_entity_id, 'person', 'Alex Lawton',
    array['Alex Lawton (L-A-W-T-O-N)'],
    'Archive owner for the La Pipa Documentary Archive. Ownership was declared directly by Alex Lawton on 2026-08-05 and bound to the confirmed Supabase Auth identity by immutable user UUID.',
    jsonb_build_object(
      'governance_role', 'archive_owner',
      'evidence_class', 'user_supplied_and_live_identity_reconciled',
      'declared_at', '2026-08-05',
      'auth_binding', 'kb.workspace_members'
    )
  )
  on conflict (agent_id) do update
  set entity_id = excluded.entity_id,
      authorized_name = excluded.authorized_name,
      alternative_names = excluded.alternative_names,
      biography_or_history = excluded.biography_or_history,
      metadata = archive.agents.metadata || excluded.metadata,
      updated_at = now();

  insert into ops.audit_log (
    actor_user_id, actor_role, action, record_type, stable_record_id, details
  )
  select owner_user_id, 'owner', 'archive_owner_bootstrapped', 'workspace_member',
         owner_user_id::text,
         jsonb_build_object(
           'authorized_name', 'Alex Lawton',
           'method', 'owner_declaration_plus_confirmed_auth_uuid',
           'migration', 'bootstrap_archive_owner_alex_lawton'
         )
  where not exists (
    select 1 from ops.audit_log
    where action = 'archive_owner_bootstrapped'
      and stable_record_id = owner_user_id::text
  );

  insert into ops.review_tasks (
    review_id, record_type, stable_record_id, reason, status, assigned_to
  ) values
    ('LP-REV-OWNER-BACKUP-2026-001', 'governance', 'archive-owner-backup',
     'Designate and verify a second trusted administrator; no role is granted until the owner identifies the person and their exact Auth UUID.',
     'open', owner_user_id),
    ('LP-REV-FIRST-ACCESSION-2026-001', 'accession', 'LP-ACC-2026-0001',
     'Locate and approve the 2019 origin deck source directory for read-only inventory and first controlled accession.',
     'open', owner_user_id),
    ('LP-REV-PRESERVATION-STORAGE-2026-001', 'storage_location', 'independent-preservation-copy',
     'Select an administratively independent preservation provider and approve jurisdiction, immutability, recovery, egress, and cost before configuration.',
     'open', owner_user_id)
  on conflict (review_id) do update
  set assigned_to = excluded.assigned_to, reason = excluded.reason;

  update archive.preservation_assessments
  set results = jsonb_set(
        results, '{control}',
        '"owner_bootstrap_complete_acceptance_pending"'::jsonb, true
      ),
      evidence = evidence || jsonb_build_object(
        'owner_identity_assigned', true,
        'owner_auth_binding', 'confirmed_auth_uuid',
        'owner_agent_id', 'LP-AGENT-ALEX-LAWTON'
      ),
      gaps = (
        select coalesce(jsonb_agg(value), '[]'::jsonb)
        from jsonb_array_elements(gaps) value
        where value <> to_jsonb('No intended owner identity is present in kb.workspace_members.'::text)
      ) || jsonb_build_array(
        'A second trusted administrator has not been designated.',
        'Interactive owner sign-in and role acceptance testing remain pending.'
      )
  where assessment_id = 'LP-ASSESS-2026-0001'
    and not (evidence @> '{"owner_identity_assigned": true}'::jsonb);
end $$;

insert into ops.schema_versions (version, description)
values (
  '2026-08-05-owner-v1',
  'Alex Lawton archive-owner declaration, exact Auth UUID binding, authority record, audit event, and accountable next-work queue.'
)
on conflict (version) do nothing;

commit;
