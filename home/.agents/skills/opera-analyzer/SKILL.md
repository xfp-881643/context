---
name: opera-analyzer
description: Analyze complete opera recordings from MP3 files, detect musical numbers, scene transitions, applause, and silence with absolute timestamps, and produce JSON/CSV plus Korean copies using Bun, FFmpeg, and OpenRouter audio models.
---

# Opera Analyzer

Analyze a full opera MP3 recording and return absolute start/end timestamps for acts, scenes, overtures, recitatives, arias, ensembles, choruses, orchestral interludes, audience applause, and silence (≥ 2 s).

## Run

Requires `bun`, `ffmpeg`, `ffprobe`, and `OPENROUTER_API_KEY`.

```bash
bun run scripts/analyze.ts /path/to/recording.mp3
# Optional: --chunk-seconds 300 --overlap-seconds 15
```

Environment variables:
- `OPENROUTER_API_KEY` (required)
- `OPENROUTER_AUDIO_MODEL` (default `google/gemini-2.5-pro`)
- `OPENROUTER_TRANSLATION_MODEL` (default `google/gemini-2.5-flash`)
- `OPENROUTER_BASE_URL` (default `https://openrouter.ai/api/v1`)
- `OPERA_OUTPUT_DIR` (default `./opera-analysis`)

## Outputs

- `analysis.json`, `analysis.csv`: merged timeline in seconds and `HH:MM:SS`
- `analysis.ko.json`, `analysis.ko.csv`: Korean-translated copies
- `chunks/`, `chunk-results/`: intermediate audio chunks and raw per-chunk model responses

## Post-run review

Read `analysis.json` (or `analysis.ko.json`) and check:
1. Low-confidence events (`< 0.70`) and boundaries within 20 s of chunk edges (multiples of `chunk-seconds`).
2. First event starts at/near `0`, last event does not exceed recording duration.
3. If the user supplied a libretto, track list, or edition, reconcile against it; never invent formal titles, act/scene numbers, or character names from audio alone.
4. Report the timeline table with absolute timestamps (`HH:MM:SS` and seconds), flag uncertain boundaries, and list output file paths.
