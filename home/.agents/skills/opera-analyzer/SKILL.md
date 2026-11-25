---
name: opera-analyzer
description: Analyze complete opera recordings from MP3 files, detect musical numbers and scene transitions, calculate absolute start and end timestamps, and produce JSON and CSV results, including Korean-translated copies using Bun, FFmpeg, and OpenRouter audio models.
---

# Opera Analyzer

Use this skill when the user asks to analyze a complete opera recording and identify the start/end times of overtures, acts, scenes, recitatives, arias, ensembles, choruses, and orchestral interludes.

## Operating rules

1. Do not send the entire 30-minute to 2-hour recording in one request.
2. Use the bundled Bun pipeline. It splits the source into 300-second chunks with 15-second overlap by default.
3. The audio-analysis request MUST contain an `input_audio` content item. Never call an audio model with text-only content. This avoids errors such as:
   `This model requires that either input content or output modality contain audio.`
4. Use `OPENROUTER_AUDIO_MODEL` (default `google/gemini-2.5-pro`) for audio understanding. Use `OPENROUTER_TEXT_MODEL` only for text-only reconciliation if a separate verifier is configured. Do not route ordinary OMP chat turns to an audio-only model.
5. Treat model-detected boundaries as candidates, not ground truth. Music transitions may be continuous and may not contain silence.
6. Preserve the source-relative timestamps. Each chunk's local timestamps must be offset by that chunk's actual start time.
7. The 15-second overlap intentionally creates duplicate observations. Reconcile duplicates; do not add overlap duration to the total recording duration.
8. Do not invent official titles, character names, act numbers, or composer metadata. Use `unknown` or `null` when uncertain.
9. Distinguish:
   - `act`: large dramatic division
   - `scene`: scene/location or dramatic sequence
   - `number`: individual musical number (aria, duet, chorus, etc.)
   - `section`: descriptive musical passage where formal title is unknown
10. Return confidence from 0 to 1 and explain uncertain boundaries in `notes`.

## Run

From the skill directory:

```bash
bun run scripts/analyze.ts /path/to/output.mp3
```

Options:

```bash
bun run scripts/analyze.ts output.mp3 --chunk-seconds 300 --overlap-seconds 15
```

Environment:

```bash
export OPENROUTER_API_KEY="..."
export OPENROUTER_AUDIO_MODEL="google/gemini-2.5-pro"
export OPENROUTER_TRANSLATION_MODEL="google/gemini-2.5-flash"
```

Optional:

```bash
export OPENROUTER_BASE_URL="https://openrouter.ai/api/v1"
export OPERA_OUTPUT_DIR="./opera-analysis"
```

## Expected output

- `opera-analysis/analysis.json`: merged timeline in seconds
- `opera-analysis/analysis.csv`: spreadsheet-friendly timeline
- `opera-analysis/analysis.ko.json`: Korean-translated timeline (same timestamps and machine-readable keys)
- `opera-analysis/analysis.ko.csv`: Korean-translated spreadsheet with Korean headers
- `opera-analysis/chunks/`: audio chunks
- `opera-analysis/chunk-results/`: raw per-chunk model results

## Quality control

After the script completes:

1. Inspect low-confidence boundaries (below 0.70).
2. Check boundaries near chunk edges (within 20 seconds of a chunk start/end).
3. Check that the first event begins at or near 0 and the final event does not exceed source duration.
4. Check for gaps and overlaps. A short overlap can be musically valid; do not force all events to be contiguous.
5. If the user supplies a libretto, track list, or recording edition, use it as supporting evidence. Do not infer an edition from the audio alone.
6. If a boundary is ambiguous, report a range or mark it uncertain instead of pretending to have frame-accurate precision.

## Important limitation

Audio-language models can describe musical content but are not guaranteed to identify the exact formal structure of every opera. For high accuracy, combine the model output with waveform listening, the libretto/score, and manual review of uncertain boundaries.
