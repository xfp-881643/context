# OMP Opera Analyzer

A user-level OMP skill plus a Bun/FFmpeg pipeline for analyzing 30-minute to 2-hour opera MP3 recordings.

## Install

Copy this directory to:

```bash
mkdir -p ~/.omp/agent/skills
cp -a opera-analyzer ~/.omp/agent/skills/
```

OMP discovers native user skills at `~/.omp/agent/skills/<skill-name>/SKILL.md`. Restart OMP (or refresh skills if your build supports it), then invoke:

```text
/skill:opera-analyzer Analyze ./output.mp3 and identify all musical numbers and scene transitions.
```

You can also run the pipeline directly without OMP.

## Requirements

- Bun
- FFmpeg (`ffmpeg` and `ffprobe`)
- OpenRouter API key
- An OpenRouter model that supports audio input

Check tools:

```bash
bun --version
ffmpeg -version
ffprobe -version
```

## Configure

```bash
export OPENROUTER_API_KEY="sk-or-v1-..."
export OPENROUTER_AUDIO_MODEL="google/gemini-2.5-pro"
```

Optional environment variables:

| Variable | Default | Purpose |
|---|---|---|
| `OPENROUTER_BASE_URL` | `https://openrouter.ai/api/v1` | API base URL |
| `OPENROUTER_AUDIO_MODEL` | `google/gemini-2.5-pro` | Audio-understanding model |
| `OPENROUTER_TRANSLATION_MODEL` | `google/gemini-2.5-flash` | Korean translation model |
| `OPERA_OUTPUT_DIR` | `./opera-analysis` | Output directory |
| `OPERA_CHUNK_SECONDS` | `300` | Chunk duration |
| `OPERA_OVERLAP_SECONDS` | `15` | Overlap between chunks |

## Run

```bash
bun run ~/.omp/agent/skills/opera-analyzer/scripts/analyze.ts ./output.mp3
```

Override chunk settings:

```bash
bun run scripts/analyze.ts ./output.mp3 --chunk-seconds 300 --overlap-seconds 15
```

The script processes one chunk at a time to avoid bursts of API requests. It saves each raw response so a failed or malformed chunk can be inspected without losing all progress.

## Output schema

Each timeline event includes:

- `start`: absolute seconds from the beginning of the original MP3
- `end`: absolute seconds from the beginning of the original MP3
- `kind`: `act`, `scene`, `aria`, `recitative`, `duet`, `ensemble`, `chorus`, `overture`, `interlude`, `dance`, `spoken`, or `other`
- `title`: title if known, otherwise a descriptive label
- `confidence`: 0–1
- `notes`: uncertainty and evidence

Timestamps are estimates, not score-edition-certified timings.

## Korean output

After the English JSON/CSV are written, the pipeline makes Korean-localized copies:

- `analysis.ko.json`: Korean event titles, act/scene labels, notes, and quality notes (machine-readable keys and timestamps are preserved).
- `analysis.ko.csv`: Korean column headings and event descriptions; saved as UTF-8 with BOM for spreadsheet compatibility.

Set `OPENROUTER_TRANSLATION_MODEL` to change the text model used for translation. If translation fails, the English outputs remain available and the error is saved to `translation.error.txt`.
