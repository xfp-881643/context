#!/usr/bin/env bun
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { basename, join, resolve } from "node:path";
import { spawnSync } from "node:child_process";

type Event = {
  start: number;
  end: number;
  kind: string;
  title: string;
  act?: string | null;
  scene?: string | null;
  confidence: number;
  notes?: string;
};

const args = process.argv.slice(2);
const inputArg = args.find((a) => !a.startsWith("--"));
if (!inputArg) {
  console.error("Usage: bun run scripts/analyze.ts <input.mp3> [--chunk-seconds 300] [--overlap-seconds 15]");
  process.exit(2);
}

function argValue(name: string, fallback: number): number {
  const i = args.indexOf(name);
  if (i < 0) return fallback;
  const n = Number(args[i + 1]);
  if (!Number.isFinite(n) || n <= 0) throw new Error(`Invalid value for ${name}`);
  return n;
}

const input = resolve(inputArg);
const chunkSeconds = argValue("--chunk-seconds", Number(process.env.OPERA_CHUNK_SECONDS ?? 300));
const overlapSeconds = argValue("--overlap-seconds", Number(process.env.OPERA_OVERLAP_SECONDS ?? 15));
if (overlapSeconds >= chunkSeconds) throw new Error("Overlap must be shorter than chunk duration.");

const apiKey = process.env.OPENROUTER_API_KEY;
if (!apiKey) throw new Error("OPENROUTER_API_KEY is not set.");

const baseUrl = (process.env.OPENROUTER_BASE_URL ?? "https://openrouter.ai/api/v1").replace(/\/+$/, "");
const model = process.env.OPENROUTER_AUDIO_MODEL ?? "google/gemini-2.5-pro";
const translationModel = process.env.OPENROUTER_TRANSLATION_MODEL ?? "google/gemini-2.5-flash";
const outputDir = resolve(process.env.OPERA_OUTPUT_DIR ?? "./opera-analysis");
const chunksDir = join(outputDir, "chunks");
const resultsDir = join(outputDir, "chunk-results");

function run(command: string, commandArgs: string[]): string {
  const p = spawnSync(command, commandArgs, { encoding: "utf8" });
  if (p.status !== 0) {
    throw new Error(`${command} failed: ${(p.stderr || p.stdout || "").trim()}`);
  }
  return p.stdout.trim();
}

function ffprobeDuration(path: string): number {
  const out = run("ffprobe", [
    "-v", "error", "-show_entries", "format=duration",
    "-of", "default=noprint_wrappers=1:nokey=1", path,
  ]);
  const duration = Number(out);
  if (!Number.isFinite(duration) || duration <= 0) throw new Error("Could not determine audio duration.");
  return duration;
}

function extractJson(text: string): any {
  const cleaned = text.trim().replace(/^```(?:json)?\s*/i, "").replace(/\s*```$/, "");
  try { return JSON.parse(cleaned); } catch {}
  const first = cleaned.indexOf("{");
  const last = cleaned.lastIndexOf("}");
  if (first >= 0 && last > first) return JSON.parse(cleaned.slice(first, last + 1));
  throw new Error("Model response did not contain valid JSON.");
}

async function requestChunk(path: string, chunkStart: number, chunkEnd: number, index: number): Promise<Event[]> {
  const bytes = await readFile(path);
  const audio = bytes.toString("base64");
  const prompt = `You are analyzing one segment of a complete opera recording.
This audio segment corresponds to original recording time ${chunkStart.toFixed(3)} to ${chunkEnd.toFixed(3)} seconds.
Identify musical-number and dramatic-section boundaries audible in THIS segment.

Return ONLY valid JSON in this exact shape:
{
  "events": [
    {
      "start": 0.0,
      "end": 42.5,
      "kind": "overture|aria|recitative|duet|ensemble|chorus|interlude|dance|spoken|act|scene|applause|silence|other",
      "title": "known title or cautious descriptive label",
      "act": null,
      "scene": null,
      "confidence": 0.0,
      "notes": "brief evidence or uncertainty"
    }
  ]
}

Rules:
- All start/end values MUST be seconds relative to the beginning of this audio segment, not the original file.
- Include only boundaries supported by audible evidence. Do not invent formal titles or act/scene numbers.
- Distinguish a complete musical number from a local change in orchestration or singer.
- Recitative may flow directly into an aria; identify both only when a meaningful boundary is audible.
- Include orchestral introductions/interludes and choruses when distinguishable.
- The 15-second overlap with neighboring chunks is intentional. Describe partial events at segment edges, but note if the event clearly began before or continues after this segment.
- Mark audience applause, cheering, or bravos as kind "applause" (title "Applause"). Applause usually ends the preceding number; do not extend that number into the applause.
- Mark clearly audible silence (no music, singing, or applause; near-silent room tone only) of 2 seconds or longer as kind "silence" (title "Silence"). Ignore shorter gaps such as breaths, caesuras, and general pauses within the music.
- Do not label applause or silence as "other". Do not force remaining time to be filled; uncertain transitions may be left unassigned.
- Confidence must be between 0 and 1.
- Use an empty events array if no defensible section boundary can be identified.`;

  const response = await fetch(`${baseUrl}/chat/completions`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "HTTP-Referer": "https://localhost/omp-opera-analyzer",
      "X-Title": "OMP Opera Analyzer",
    },
    body: JSON.stringify({
      model,
      temperature: 0.1,
      max_tokens: 5000,
      messages: [{
        role: "user",
        content: [
          { type: "text", text: prompt },
          { type: "input_audio", input_audio: { data: audio, format: "mp3" } },
        ],
      }],
    }),
  });

  const bodyText = await response.text();
  if (!response.ok) throw new Error(`OpenRouter HTTP ${response.status}: ${bodyText.slice(0, 1200)}`);
  const body = JSON.parse(bodyText);
  const content = body?.choices?.[0]?.message?.content;
  const text = typeof content === "string"
    ? content
    : Array.isArray(content) ? content.map((x: any) => x.text ?? "").join("\n") : "";
  if (!text) throw new Error(`Empty model response for chunk ${index}.`);
  await writeFile(join(resultsDir, `chunk-${String(index).padStart(3, "0")}.response.txt`), text);
  const parsed = extractJson(text);
  const items = Array.isArray(parsed.events) ? parsed.events : [];
  return items.map((e: any) => ({
    start: chunkStart + Number(e.start),
    end: chunkStart + Number(e.end),
    kind: String(e.kind ?? "other").toLowerCase(),
    title: String(e.title ?? "Unknown section"),
    act: e.act ?? null,
    scene: e.scene ?? null,
    confidence: Math.max(0, Math.min(1, Number(e.confidence ?? 0.5))),
    notes: String(e.notes ?? ""),
  })).filter((e: Event) =>
    Number.isFinite(e.start) && Number.isFinite(e.end) &&
    e.end > e.start && e.start < chunkEnd + 1 && e.end > chunkStart - 1
  );
}

function normalizeAndMerge(events: Event[], duration: number): Event[] {
  const sorted = events
    .map(e => ({
      ...e,
      start: Math.max(0, Math.min(duration, e.start)),
      end: Math.max(0, Math.min(duration, e.end)),
    }))
    .filter(e => e.end > e.start)
    .sort((a, b) => a.start - b.start);

  const merged: Event[] = [];
  for (const current of sorted) {
    const previous = merged[merged.length - 1];
    const sameKind = previous && previous.kind === current.kind;
    const similarTitle = previous && previous.title.toLowerCase() === current.title.toLowerCase();
    const overlap = previous ? Math.min(previous.end, current.end) - Math.max(previous.start, current.start) : 0;
    const near = previous ? current.start <= previous.end + 8 : false;

    if (previous && (sameKind && similarTitle) && (overlap > 0 || near)) {
      previous.start = Math.min(previous.start, current.start);
      previous.end = Math.max(previous.end, current.end);
      previous.confidence = Math.max(previous.confidence, current.confidence);
      if (current.notes && !previous.notes?.includes(current.notes)) {
        previous.notes = [previous.notes, current.notes].filter(Boolean).join(" | ");
      }
      if (!previous.act && current.act) previous.act = current.act;
      if (!previous.scene && current.scene) previous.scene = current.scene;
    } else {
      merged.push({ ...current });
    }
  }
  return merged;
}


const KIND_KO: Record<string, string> = {
  act: "막", scene: "장면", aria: "아리아", recitative: "레치타티보",
  duet: "이중창", ensemble: "중창", chorus: "합창", overture: "서곡",
  interlude: "간주곡", dance: "무곡", spoken: "대사", other: "기타",
  applause: "박수", silence: "무음",
  section: "음악 구간", number: "독립 음악 번호",
};

async function translateResult(result: any): Promise<any> {
  const source = result.events.map((e: Event, index: number) => ({
    id: index, title: e.title, act: e.act ?? null, scene: e.scene ?? null, notes: e.notes ?? "",
  }));
  const prompt = `Translate the following opera-analysis event descriptions into natural Korean.
` +
    `Keep proper names, work titles, and established musical terms accurate. Do not add facts.
` +
    `Return ONLY valid JSON in this shape: {"events":[{"id":0,"title":"...","act":null,"scene":null,"notes":"..."}],"quality_notes":["..."]}.
` +
    `Preserve every id exactly and return every event exactly once. Translate quality_notes too.

` +
    JSON.stringify({ events: source, quality_notes: result.quality_notes }, null, 2);
  const response = await fetch(`${baseUrl}/chat/completions`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "HTTP-Referer": "https://localhost/omp-opera-analyzer",
      "X-Title": "OMP Opera Analyzer Korean Translation",
    },
    body: JSON.stringify({
      model: translationModel,
      temperature: 0.1,
      max_tokens: 6000,
      messages: [{ role: "user", content: prompt }],
    }),
  });
  const bodyText = await response.text();
  if (!response.ok) throw new Error(`Translation API HTTP ${response.status}: ${bodyText.slice(0, 1000)}`);
  const body = JSON.parse(bodyText);
  const content = body?.choices?.[0]?.message?.content;
  const text = typeof content === "string" ? content : Array.isArray(content)
    ? content.map((x: any) => x.text ?? "").join("\n") : "";
  if (!text) throw new Error("Empty translation response.");
  const translated = extractJson(text);
  if (!Array.isArray(translated.events) || translated.events.length !== result.events.length) {
    throw new Error("Translation response has a missing or incomplete events array.");
  }
  const byId = new Map<number, any>(translated.events.map((e: any) => [Number(e.id), e]));
  const events = result.events.map((e: Event, index: number) => {
    const t = byId.get(index);
    if (!t || typeof t.title !== "string") throw new Error(`Missing Korean translation for event ${index}.`);
    return { ...e, title: t.title, act: t.act ?? null, scene: t.scene ?? null,
      notes: String(t.notes ?? ""), kind_ko: KIND_KO[e.kind] ?? e.kind };
  });
  return {
    ...result,
    language: "ko",
    translation_model: translationModel,
    events,
    quality_notes: Array.isArray(translated.quality_notes)
      ? translated.quality_notes.map(String) : result.quality_notes,
  };
}

function csvEscape(value: unknown): string {
  const s = String(value ?? "");
  return `"${s.replace(/"/g, '""')}"`;
}

await mkdir(chunksDir, { recursive: true });
await mkdir(resultsDir, { recursive: true });

const duration = ffprobeDuration(input);
console.log(`Input: ${input}`);
console.log(`Duration: ${duration.toFixed(2)} sec`);
console.log(`Model: ${model}`);
console.log(`Chunk: ${chunkSeconds}s / overlap: ${overlapSeconds}s`);

const chunks: { path: string; start: number; end: number }[] = [];
for (let baseStart = 0, index = 0; baseStart < duration; baseStart += chunkSeconds, index++) {
  const start = Math.max(0, baseStart - (index === 0 ? 0 : overlapSeconds));
  const end = Math.min(duration, baseStart + chunkSeconds);
  const file = join(chunksDir, `chunk-${String(index + 1).padStart(3, "0")}-${Math.floor(start)}s.mp3`);
  const length = end - start;
  run("ffmpeg", [
    "-hide_banner", "-loglevel", "error", "-y",
    "-ss", String(start), "-i", input, "-t", String(length),
    "-vn", "-c:a", "libmp3lame", "-b:a", "128k", file,
  ]);
  chunks.push({ path: file, start, end });
}
console.log(`Created ${chunks.length} chunks.`);

const allEvents: Event[] = [];
for (let i = 0; i < chunks.length; i++) {
  const chunk = chunks[i];
  const resultPath = join(resultsDir, `chunk-${String(i + 1).padStart(3, "0")}.json`);
  try {
    console.log(`[${i + 1}/${chunks.length}] Analyzing ${basename(chunk.path)} ...`);
    const events = await requestChunk(chunk.path, chunk.start, chunk.end, i + 1);
    allEvents.push(...events);
    await writeFile(resultPath, JSON.stringify({
      chunk: i + 1, sourceStart: chunk.start, sourceEnd: chunk.end, events
    }, null, 2));
    console.log(`  ${events.length} candidate events`);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    await writeFile(join(resultsDir, `chunk-${String(i + 1).padStart(3, "0")}.error.txt`), message);
    console.error(`  Failed: ${message}`);
  }
}

const events = normalizeAndMerge(allEvents, duration);
const result = {
  source: basename(input),
  duration_seconds: Number(duration.toFixed(3)),
  model,
  chunk_seconds: chunkSeconds,
  overlap_seconds: overlapSeconds,
  generated_at: new Date().toISOString(),
  events,
  quality_notes: [
    "AI-detected boundaries are estimates and should be reviewed by listening.",
    "Formal act/scene/number labels are not guaranteed without a matching libretto or score.",
    "Overlapping chunk observations are merged heuristically; inspect events near chunk boundaries."
  ],
};

await writeFile(join(outputDir, "analysis.json"), JSON.stringify(result, null, 2));
const header = ["start_seconds", "end_seconds", "start_hms", "end_hms", "kind", "title", "act", "scene", "confidence", "notes"];
const hms = (seconds: number) => {
  const s = Math.floor(seconds);
  return [Math.floor(s / 3600), Math.floor((s % 3600) / 60), s % 60]
    .map(v => String(v).padStart(2, "0")).join(":");
};
const rows = events.map(e => [
  e.start.toFixed(3), e.end.toFixed(3), hms(e.start), hms(e.end),
  e.kind, e.title, e.act ?? "", e.scene ?? "", e.confidence.toFixed(2), e.notes ?? ""
].map(csvEscape).join(","));
await writeFile(join(outputDir, "analysis.csv"), [header.join(","), ...rows].join("\n") + "\n");

// Produce Korean-localized copies without changing the canonical English outputs.
try {
  console.log(`Translating results to Korean with ${translationModel} ...`);
  const ko = await translateResult(result);
  await writeFile(join(outputDir, "analysis.ko.json"), JSON.stringify(ko, null, 2) + "\n");
  const koHeader = ["시작_초", "종료_초", "시작_시각", "종료_시각", "구분", "제목", "막", "장면", "신뢰도", "설명_및_근거"];
  const koRows = ko.events.map((e: any) => [
    e.start.toFixed(3), e.end.toFixed(3), hms(e.start), hms(e.end),
    e.kind_ko, e.title, e.act ?? "", e.scene ?? "", e.confidence.toFixed(2), e.notes ?? "",
  ].map(csvEscape).join(","));
  await writeFile(join(outputDir, "analysis.ko.csv"), "\uFEFF" + [koHeader.join(","), ...koRows].join("\r\n") + "\r\n");
  console.log(`Korean JSON: ${join(outputDir, "analysis.ko.json")}`);
  console.log(`Korean CSV:  ${join(outputDir, "analysis.ko.csv")}`);
} catch (error) {
  const message = error instanceof Error ? error.message : String(error);
  await writeFile(join(outputDir, "translation.error.txt"), message + "\n");
  console.error(`Korean translation failed: ${message}`);
  console.error("English JSON/CSV are available; rerun to retry translation.");
}

console.log(`Finished. ${events.length} merged events.`);
console.log(`JSON: ${join(outputDir, "analysis.json")}`);
console.log(`CSV:  ${join(outputDir, "analysis.csv")}`);
