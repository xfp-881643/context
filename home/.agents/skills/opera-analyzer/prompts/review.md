# Final Timeline Review Prompt

Review the merged opera timeline against the per-chunk observations.

Requirements:
- Preserve absolute timestamps from the original recording.
- Do not invent formal titles, act numbers, scene numbers, or character names.
- Merge duplicate observations caused by 15-second chunk overlap.
- Keep distinct consecutive numbers separate even when they are musically connected.
- Distinguish act, scene, and individual musical number.
- Flag uncertain boundaries and events within 20 seconds of chunk boundaries.
- Do not force events to be contiguous.
- Return JSON with start/end seconds, HH:MM:SS display values, kind, title, confidence, and notes.
