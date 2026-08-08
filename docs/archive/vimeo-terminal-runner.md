# Vimeo terminal runner

Status: safe planning release. Live downloads, uploads, embeddings, database writes, and source deletion are locked.

## Purpose

The terminal runner moves repeatable archive work out of conversational tooling. Its planning stage uses only committed La Pipa evidence and local system checks, so it consumes no GPT tokens and makes no paid API requests.

The controlled source universe is the 78 Vimeo video identifiers discovered from `lapipa.io` and captured in `LP-WEB-2026-08-05`. A Vimeo account-wide inventory is not an ingestion allowlist. Material outside the controlled list remains excluded until evidence links it to La Pipa and the archive owner approves the scope.

## Beginner-safe use

Do not use `--execute`. Live execution is intentionally unavailable in this release.

From Finder, open the repository and double-click:

```text
Run La Pipa Vimeo Archive.command
```

Alternatively, from Terminal:

```bash
cd "/Users/alexlawton/Documents/Codex/2026-08-05/i-would-like-you-to-revise/work/lapipa-batch1"
npm run archive:vimeo -- --batch-size 5
```

The command only prints a proposed batch. It does not write a state file, contact Vimeo, contact Supabase, call Voyage, contact Backblaze, download media, upload objects, or delete files.

## Controls

- Dry-run is the default and currently the only permitted mode.
- Batch size is restricted to 1–10 videos.
- Selection is deterministic: oldest provider date first, then Vimeo identifier.
- The three completed pilot videos are detected from accession source records and skipped.
- The scope policy is applied before any future hashing, downloading, or copying stage.
- Vumi client material is explicitly rejected.
- Source deletion is always unauthorized.
- Cloud credential values remain in Supabase Edge Function secrets and are not read or printed by the planner.
- The external staging drive, free space, FFmpeg, local MLX Whisper runtime, and model cache are checked without modifying them.

## Acceptance gates before enabling live mode

1. Deploy and interactively verify the implemented owner-authorized, exact-video Vimeo control endpoint, which retains the Vimeo access token in Supabase. See [LP-DOC-ARCH-029](vimeo-one-video-acceptance.md).
2. Add an owner-authorized, exact-object Backblaze signing endpoint that retains Backblaze credentials in Supabase.
3. Add resumable local transfer state with atomic checkpoints.
4. Reconcile remote size and SHA-256 evidence before recording a copy as verified.
5. Run a zero-cost skip test against an already completed pilot video.
6. Run one new video through download, local transcription, preservation upload, restore verification, Supabase registration, and Voyage embedding.
7. Review the resulting transcript and provenance record before increasing the batch size to five.
