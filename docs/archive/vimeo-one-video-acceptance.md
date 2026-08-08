# LP-DOC-ARCH-029 — Vimeo one-video acceptance

Status: local Vimeo acceptance completed and fixity-verified; Backblaze ingest not yet claimed.
Owner: Alex Lawton
Exact source: Vimeo `844151157`, *Subterranea @ LA PIPA :: VIUDA*
Accession: `LP-ACC-2026-0005`

## Purpose

This stage proves the smallest controlled transfer before any multi-video processing. It downloads exactly one 46-second, La Pipa-branded video directly from Vimeo to the external archive staging drive. It does not upload to Backblaze, transcribe media, write archive records, request Voyage embeddings, or delete any source.

The selected item is intentionally not one of the ReMotive-labelled entries shown by the planning dry run. Vumi and unrelated client work remain categorically outside the archive scope.

## Acceptance outcome — 8 August 2026

Alex completed the owner-authorized terminal run. Vimeo delivered the source-quality preservation master directly to `G-DRIVE 02`; no source was deleted and no capability or signed provider URL was retained.

| Control | Verified result |
|---|---|
| Media file | `vimeo-844151157-source.mp4` |
| Byte count | 328,003,637 |
| SHA-256 | `b15ea951246acdd46561f13f87be7fc2de0b2ba35ac7dc79a4f437b7617e09aa` |
| Duration | 46.52 seconds |
| Video | Apple ProRes, 1024 × 768, 25 fps |
| Audio | 24-bit little-endian PCM, stereo, 48 kHz |
| Local transcript | MLX Whisper 0.4.3, `whisper-large-v3-turbo`, Spanish, 10 timed provisional segments |
| Transcript review | Machine-generated and unreviewed; not approved as a verified quotation |

The transcript discusses the music scene beyond Madrid and Barcelona, the value of sustaining an Asturian scene for future generations, and local music-community support. This summary describes machine output and remains subject to human review.

## Authorization design

1. Alex signs into the archive owner interface through Supabase Auth.
2. The interface asks Supabase for a 10-minute, one-time code restricted to Vimeo `844151157`.
3. Only the SHA-256 digest of that code is stored in the database.
4. The Mac exchanges the code once for a random runner capability held only in memory for the duration of the transfer.
5. Supabase uses the Vimeo token held in Edge Function secrets to request the provider download record.
6. The signed provider URL remains in Mac process memory only and is never placed in source control, the database, logs, or the archive manifest.

The database verifies the immutable `owner` role before issuing the code. Direct anonymous and authenticated access to the capability table is denied by grants, RLS, and an explicit restrictive policy. The mixed browser-and-terminal Edge Function performs its own authorization checks; its gateway JWT check is therefore disabled deliberately while each action is authenticated inside the handler.

## Owner procedure after deployment

1. Connect `G-DRIVE 02` and confirm the archive owner page identifies the signed-in account as `owner`.
2. Under **Controlled Vimeo acceptance**, select **Generate one-time terminal code**.
3. Copy the code before its displayed expiry time.
4. In Finder, open the repository and double-click `Run La Pipa One Video Acceptance.command`.
5. Paste the code and type the exact confirmation `YES`.
6. Wait for the launcher to report the stored path and SHA-256 digest.

Expected outputs:

```text
/Volumes/G-DRIVE 02/LA_PIPA_ARCHIVE_STAGING/vimeo/LP-ACC-2026-0005/preservation/vimeo-844151157-source.[provider-validated extension]
/Volumes/G-DRIVE 02/LA_PIPA_ARCHIVE_STAGING/vimeo/LP-ACC-2026-0005/manifests/download-manifest.json
```

The manifest records the provider metadata, byte count, SHA-256 fixity, optional provider MD5 verification, and explicit `not_started` states for every later phase. It never records an authorization code, runner token, Vimeo access token, or signed download URL.

## Acceptance criteria

- the owner role is required to generate the code;
- the code expires after 10 minutes and cannot be exchanged twice;
- every server and Mac-side check pins the scope to Vimeo `844151157`;
- the file is written directly to the external archive drive using a resumable partial file;
- the completed file size matches Vimeo's declared byte count;
- SHA-256 is calculated after transfer and recorded atomically;
- any supplied Vimeo MD5 digest matches before the manifest is accepted;
- no source deletion, Backblaze upload, transcription, database registration, or embedding occurs;
- no capability or signed provider URL is retained.

## Next controlled stage

The follow-on implementation adds exact-object Backblaze upload and complete clean restore verification under a new owner-issued code. Permanent Backblaze credentials remain only in Supabase secrets. The transfer permits no delete operation, accepts only the eleven declared paths under `lapipa/vimeo/LP-ACC-2026-0005`, refuses to overwrite a differing object, and retains source deletion as false. Supabase catalogue registration and Voyage embedding occur only after the restore evidence exists. Batch size remains one until that full path passes and its evidence is reviewed.
