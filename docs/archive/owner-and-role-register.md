# Owner and role register — LP-DOC-ARCH-016

Status: active control record
Effective date: 2026-08-05
Review frequency: semi-annual and on every role change

## Archive owner

The archive owner is **Alex Lawton**, surname spelled **L-A-W-T-O-N**.

The owner declaration was supplied directly by Alex Lawton on 2026-08-05. The live Supabase project contained one active, confirmed Auth account and no existing workspace members. The confirmed account's immutable Auth UUID was bound to the `owner` role in `kb.workspace_members`. Authorization does not depend on editable user metadata, a display name, or an email string.

The authority record is `LP-AGENT-ALEX-LAWTON`, linked to `person:alex-lawton`. The Auth UUID is intentionally retained in the database migration and audit trail; it is not repeated in public-facing archive copy.

## Owner powers and duties

The owner may approve role changes, preservation-provider selection, rights statements, retention or disposal changes, releases, and production promotion. The owner is also accountable for conflict-of-interest disclosure, least-privilege review, takedown decisions, incident escalation, and continuity planning.

Owner status does not override provenance, consent, rights, privacy, preservation, accessibility, or release evidence requirements.

## Role model

| Role | Intended authority |
| --- | --- |
| Owner | Governance, role administration, deletion approval, release approval, and all editor capabilities |
| Editor | Accession, cataloguing, correction, embedding, and preservation operations |
| Reviewer | Read access plus review and recommendation workflows; no direct archive mutation |
| Reader | Authorized retrieval and mediated research access |

No person receives a role from their name, email domain, user metadata, or organizational association alone. Every assignment requires a confirmed Auth UUID, a named approver, a dated rationale, and an audit event.

## Current gap

A second trusted administrator has not yet been designated. Until that occurs, owner-account recovery remains a continuity risk. No backup role will be inferred or granted automatically.

## Acceptance evidence

Database-level authorization tests must prove that the owner's authenticated UUID resolves to `owner`, an unknown authenticated UUID resolves to no role, anonymous access cannot call protected functions, and direct archive-table grants remain absent. Interactive sign-in and session-level acceptance remain separate evidence and must not be marked complete until Alex signs in through the intended client.
