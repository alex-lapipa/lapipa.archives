begin;

create table if not exists kb.authorized_identities (
  id bigint generated always as identity primary key,
  normalized_email text not null unique,
  principal_agent_id bigint references archive.agents(id) on delete restrict,
  role text not null check (role in ('owner', 'editor', 'reviewer', 'reader')),
  active boolean not null default true,
  authorized_by uuid references auth.users(id) on delete set null,
  authorized_at timestamptz not null default now(),
  bound_user_id uuid unique references auth.users(id) on delete set null,
  bound_at timestamptz,
  last_verified_at timestamptz,
  verification_status text not null default 'preauthorized'
    check (verification_status in ('preauthorized', 'bound_confirmed', 'signed_in_verified', 'revoked')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (normalized_email = lower(btrim(normalized_email))),
  check (position('@' in normalized_email) > 1)
);

comment on table kb.authorized_identities is
  'Private governance register of identities approved for archive access. Authorization, Auth confirmation, and actual sign-in are deliberately distinct states.';

alter table kb.authorized_identities enable row level security;
revoke all on kb.authorized_identities from public, anon, authenticated;
grant select, insert, update, delete on kb.authorized_identities to service_role;
grant usage, select on sequence kb.authorized_identities_id_seq to service_role;

create or replace function private.reconcile_authorized_identities()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  affected integer := 0;
begin
  update kb.authorized_identities ai
  set bound_user_id = u.id,
      bound_at = coalesce(ai.bound_at, now()),
      last_verified_at = now(),
      verification_status = case
        when u.last_sign_in_at is not null then 'signed_in_verified'
        else 'bound_confirmed'
      end,
      updated_at = now()
  from auth.users u
  where ai.active
    and u.deleted_at is null
    and u.confirmed_at is not null
    and lower(btrim(u.email)) = ai.normalized_email
    and (
      ai.bound_user_id is distinct from u.id
      or ai.last_verified_at is null
      or ai.verification_status is distinct from case
        when u.last_sign_in_at is not null then 'signed_in_verified'
        else 'bound_confirmed'
      end
    );

  get diagnostics affected = row_count;

  insert into kb.workspace_members (user_id, role, active)
  select bound_user_id, role, true
  from kb.authorized_identities
  where active and bound_user_id is not null
  on conflict (user_id) do update
  set role = excluded.role,
      active = true,
      updated_at = now();

  return affected;
end;
$$;

revoke all on function private.reconcile_authorized_identities() from public, anon, authenticated;
grant execute on function private.reconcile_authorized_identities() to service_role;

insert into kb.authorized_identities (
  normalized_email, principal_agent_id, role, active, authorized_by,
  verification_status, metadata
)
select
  approved.email,
  agent.id,
  'owner',
  true,
  owner_user.id,
  'preauthorized',
  jsonb_build_object(
    'authorized_name', 'Alex Lawton',
    'principal', 'LP-AGENT-ALEX-LAWTON',
    'authorization_basis', 'direct_owner_instruction_2026-08-05',
    'identity_policy', 'authorization_is_not_sign_in'
  )
from (values ('alex@rmtv.io'), ('lawton.alex@gmail.com')) approved(email)
left join archive.agents agent on agent.agent_id = 'LP-AGENT-ALEX-LAWTON'
left join auth.users owner_user on owner_user.id = '827fa26f-df7f-4d24-9521-0e44bcf37696'
on conflict (normalized_email) do update
set principal_agent_id = excluded.principal_agent_id,
    role = 'owner',
    active = true,
    authorized_by = coalesce(kb.authorized_identities.authorized_by, excluded.authorized_by),
    metadata = kb.authorized_identities.metadata || excluded.metadata,
    updated_at = now();

select private.reconcile_authorized_identities();

insert into ops.audit_log (
  actor_user_id, actor_role, action, record_type, stable_record_id, details
)
select
  '827fa26f-df7f-4d24-9521-0e44bcf37696'::uuid,
  'owner',
  'archive_owner_identity_authorized',
  'authorized_identity',
  ai.bound_user_id::text,
  jsonb_build_object(
    'normalized_email', ai.normalized_email,
    'principal_agent_id', 'LP-AGENT-ALEX-LAWTON',
    'role', ai.role,
    'verification_status', ai.verification_status,
    'session_claimed', false,
    'migration', 'authorize_alex_owner_identities'
  )
from kb.authorized_identities ai
where ai.normalized_email in ('alex@rmtv.io', 'lawton.alex@gmail.com')
  and ai.bound_user_id is not null
  and not exists (
    select 1 from ops.audit_log al
    where al.action = 'archive_owner_identity_authorized'
      and al.stable_record_id = ai.bound_user_id::text
  );

update archive.agents
set metadata = metadata || jsonb_build_object(
      'authorized_auth_identities', 2,
      'identity_register', 'kb.authorized_identities',
      'identity_register_updated_at', '2026-08-05'
    ),
    updated_at = now()
where agent_id = 'LP-AGENT-ALEX-LAWTON';

insert into ops.schema_versions (version, description)
values (
  '2026-08-05-owner-identities-v1',
  'Private preauthorization register and confirmed UUID bindings for Alex Lawton owner identities; sign-in evidence remains independently verified.'
)
on conflict (version) do nothing;

commit;
