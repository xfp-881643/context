---
date: 2026-11-25
status: done
tags: [opera-analyzer, skills]
related: []
---

# 2026-11-25: opera-analyzer에 박수·무음 이벤트 추가

## 변경
`~/.agents/skills/opera-analyzer`의 청크 프롬프트 `kind`에 `applause`, `silence`를 추가했다. 박수는 직전 번호를 끝내는 경계로 취급하고, 무음은 2초 이상만 표기하도록 했다. `KIND_KO`에 "박수", "무음"을 추가했고 `SKILL.md`, `README.md`, `prompts/review.md`를 맞췄다.

## 검증
실제 오디오로 실행하지 않았다. 병합 로직(`normalizeAndMerge`)은 수정하지 않았다.

## 다음 작업
- `ffmpeg silencedetect` 선처리를 추가해 `silence` 구간의 시작·끝을 파형 기준으로 정확히 잡는다. 청크 시작 시각을 더한 뒤 모델 이벤트와 병합한다. 상세는 skill `README.md`의 "Next work".
- 저장소 사본 `home/.agents/skills/opera-analyzer/`는 설치본(`~/.agents/skills/opera-analyzer`)과 내용이 다르다(`diff -rq` 확인). 이번 변경은 설치본에만 반영했다. 사본 동기화 여부는 미정.
