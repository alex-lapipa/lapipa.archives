# Metadata application profile — LP-MAP 1.0

## Record model

La Pipa separates six layers that must not be collapsed:

1. **Collection hierarchy** — archival context and arrangement.
2. **Intellectual item** — the work, event documentation, interview, photograph, or other content being described.
3. **Representation** — an original, preservation master, mezzanine, access copy, thumbnail, transcript, OCR, or metadata export.
4. **File object** — the stored bitstream with fixity and format metadata.
5. **Essence track** — the video, audio, text, timecode, or data stream within a file.
6. **Knowledge evidence** — sources, claims, events, entities, chunks, and graph relationships used by retrieval.

## Stable identifiers

Identifiers are opaque, permanent, case-sensitive, and never reassigned. Recommended patterns are:

| Record | Pattern | Example |
|---|---|---|
| Collection | `LP-COL-####` | `LP-COL-0001` |
| Item | `LP-ITEM-########` | `LP-ITEM-00000001` |
| Representation | `LP-REP-########-##` | `LP-REP-00000001-01` |
| File | `LP-FILE-##########` | `LP-FILE-0000000001` |
| Track | `LP-TRACK-##########` | `LP-TRACK-0000000001` |
| Transcript | `LP-TR-########-LL` | `LP-TR-00000001-es` |
| Agent | `LP-AGENT-######` | `LP-AGENT-000001` |
| Rights statement | `LP-RIGHTS-######` | `LP-RIGHTS-000001` |
| Preservation event | `LP-PREMIS-EVT-##########` | `LP-PREMIS-EVT-0000000001` |
| Accession | `LP-ACC-YYYY-####` | `LP-ACC-2026-0001` |

Existing stable IDs in the reviewed RAG corpus remain authoritative and are cross-referenced; they are not renumbered.

## Minimum description

An approved item requires: stable item ID, collection, title, item type, description or scope-and-content, creation date or date text, language when applicable, access scope, sensitivity status, verification status, lifecycle status, at least one provenance source or accession, and a rights review outcome. Unknown values are recorded as unknown, not inferred silently.

## Date rules

- Use ISO 8601 for machine-readable dates and preserve the source wording in `date_text`.
- Use start/end ranges for approximate periods.
- Put uncertainty in notes and verification status; do not fabricate precision.
- Store event timestamps with time zone; use UTC for machine-created preservation events.

## Names, places, subjects, and roles

Agents receive an authorized name, type, optional authority URI, alternatives, and history note. Credits link agents to items with an explicit role and ordering. Subjects use preferred and alternative labels, type, optional authority URI, and broader term. Transcribed speaker labels may remain provisional until identity review.

## Audiovisual metadata

Representation and track fields follow the PBCore distinction between an intellectual asset and its instantiations. Extract technical metadata with a versioned tool such as MediaInfo or ffprobe, preserve the raw tool output, and map values to typed fields without discarding the original output.

## File metadata

Every managed file requires original and normalized filenames, storage location, media type, byte count, SHA-256, representation, ingest timestamp, fixity state, and malware-scan state. Format registry identifiers such as PRONOM PUIDs are added when identified. A matching digest is evidence of bit identity, not proof that two records have identical context or rights.

## Rights metadata

Rights are scoped to content, metadata, file, transcript, image, audio, or video. Record rights basis, holder, jurisdiction, dates, permitted uses, restrictions, credit line, evidence, review status, access decision, and embargo. Use a Creative Commons or RightsStatements.org URI only when the exact statement has been reviewed and applies.

## Preservation events

Events align with PREMIS: type, timestamp, outcome, outcome detail, responsible human or software agent, process detail, and linked source, outcome, or subject files. Failed and warning events are retained; they are not overwritten by later success.

## RAG projection

Only approved descriptions and access-permitted transcript or OCR text enter retrieval. Each chunk must retain item ID, representation or transcript ID, source IDs, language, rights/access scope, verification status, content hash, and chunking version. Restricted text must never be exposed merely because its embedding is similar to a query.

