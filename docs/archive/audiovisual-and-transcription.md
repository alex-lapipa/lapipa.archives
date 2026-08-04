# Audiovisual and transcription workflow

## Media handling

Retain camera, recorder, edit-project, and export originals with their directory context. Never transcode in place. Record time base, duration, codec, frame size, aspect ratio, frame rate, color information, audio sample rate, bit depth, channel count and layout, language, and timecode where present. Preserve captions, cue sheets, logs, slates, sidecars, and edit decision information as related objects.

## Representations

- `original`: received or captured media.
- `preservation_master`: managed high-fidelity representation for preservation.
- `mezzanine`: high-quality editorial working file.
- `access_copy`: streaming or research derivative.
- `thumbnail`: visual or audible preview.
- `transcript`: structured textual representation.

Each derivative records its source file through preservation-event links.

## Oral history

Before recording, document project purpose, interviewer and participant roles, consent, intended uses, withdrawal conditions, sensitive topics, access expectations, and contact preferences. Consent is a continuing ethical relationship, not merely a signed form. Preserve the unedited recording, consent evidence, session log, technical setup, and interviewer notes separately but relationally linked.

## Transcription levels

- **Verbatim:** represents spoken words and meaningful non-speech sound according to a declared convention.
- **Clean read:** removes false starts or fillers for readability and must not be represented as verbatim.
- **Subtitle:** condensed timed text optimized for viewing.
- **Translation:** a language transformation linked to its source transcript.
- **OCR:** machine or human transcription of visible text.

## Segment model

Every segment receives an ordinal, stable segment ID, text, language, optional start and end milliseconds, speaker label or agent, confidence, review status, and annotations. Overlapping speakers, inaudible content, uncertainty, non-speech sound, and redaction are marked explicitly. Timecodes refer to a named representation; they are not assumed portable across edits.

## Automated processing

Machine transcription output is `machine` and `unreviewed`. Record the model or vendor, version when known, language, settings, processing date, and source representation. A human correction changes segment review state but does not erase the original machine output or processing event. Do not send restricted interviews to an external service unless the rights, privacy, data residency, and retention terms permit it.

## Access text

WebVTT is the timed-text exchange format for the access player. The canonical transcript remains the structured database record plus a versioned UTF-8 export. Redacted access transcripts and unredacted preservation transcripts are separate representations with separate rights and access decisions.

