---
date: 2026-11-15
status: done
tags: [context, rules]
related: [DECISIONS.md#adr-006]
---

# 2026-11-15: context 규칙 파일 재작성

## Objective
복사 중 손상된 `context.md`, `context-reference.md`를 다시 작성하고 `~/.agents`에 반영한다.

## Background
사용자가 복사 중 파일 손상을 보고했다. 저장소와 `~/.agents`의 파일을 재작성하고 무결성을 확인했다.

## Changes
- `home/.agents/rules/context.md` 재작성 (2,516 bytes).
- `home/.agents/rules/context-reference.md` 재작성 (4,700 bytes, 영어).
- `~/.agents/rules/`에 복사.

## Verification
- `diff -u` 저장소와 `~/.agents` 동일.
- `isutf8` 통과.
- `discoverRuleFromMarkdown`: `context.md` alwaysApply true, `context-reference.md` rulebook(`globs: .context/**`).
- `context-reference.md`의 중첩 fence를 4-backtick으로 수정.
- `context-reference.md`에서 한국어 문자 0 확인 (완전 영어판).

## Remaining
없음.
