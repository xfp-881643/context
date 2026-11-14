# Vue3 로 개발시 코딩 규칙

---

## 1. 스택 / 디렉터리

- Vue 3 `<script setup lang='ts'>` + Vite + Vuetify 4 + Pinia + unplugin-vue-router + vite-plugin-vue-layouts
- 파일 기반 라우팅: `src/pages/**/*.vue`
- 레이아웃: `src/layouts/` (`default`, `blank`)
- 페이지 전용 뷰(드로어/탭): `src/views/`
- CRUD 우측 드로어: `src/views/drawr/{name}.vue`
- 공통 컴포넌트: `src/components/` (자동 import, 수동 import 금지)
- Pinia 스토어: `src/plugins/store/{name}.ts` (자동 import)
- 유틸 named export: `src/utils/` (자동 import)
- 플러그인: `src/plugins/` — 파일명 숫자 prefix로 로드 순서 (`00-router.ts`, `02-pinia.ts`)
- 커스텀 디렉티브: `src/plugins/directive/`
- 아이콘: `tabler-*` only (Iconify)

경로 alias:
- `@/` → `src/`
- `@views/` → `src/views/`
- `@utils/` → `src/utils/`
- `@styles/` → `src/assets/styles/`
- `@images/` → `src/assets/images/`

자동 import 대상 (import 문을 쓰지 말 것):
- `vue`, `vue-router`, `pinia`, `@vueuse/core`, `@vueuse/math`
- `src/plugins/store/*` 의 named export (`useUser`, `useClimqtt` …)
- `src/utils/*` 의 **named** export (`apiUser`, `dayjs`, `columnLens`, `UserType` …)
- `src/components/*` 컴포넌트 (`Actions`, `typeTags`, `DEBUG_` …)

명시 import가 필요한 것:
- `.vue` 페이지/드로어 (`import Mod from '@/views/drawr/user.vue'`)
- **default export** 유틸 (`import rules from '@/utils/rules'`, `import toast from '@/utils/toast'`)
- Vuetify 타입 (`import type { VForm } from 'vuetify/components/VForm'`)
- 자동 import에 없는 외부 패키지
- SVG raw (`import logo from '@/assets/images/logo/short.svg?raw'`)

---

## 2. 포맷 (가장 중요 — 모델이 가장 자주 깨뜨림)

- 들여쓰기: **Tab** (스페이스 금지)
- 문자열/속성: **작은따옴표** `'...'`
- 세미콜론: 문장 끝에 사용
- 주석: 넣지 않는다 (요청 시에만)

SFC 블록 순서 (고정):
1. `<style lang='scss'>` (있을 때만)
2. `<template>`
3. `<script setup lang='ts'>`

```
<style lang='scss'>
.pages-foo { ... }
</style>

<template>
...
</template>

<script setup lang='ts'>
...
</script>
```

할당 정렬: 식별자와 `=` 사이를 탭으로 맞춘다. 객체 키도 동일.

```
const user	= useUser();
const mod	= ref({
	show:	false,
	id:		0,
});
```

`var` vs `const`:
- `const`: store 인스턴스, `ref`/`computed`/`defineModel`/`defineProps`
- `var`: 함수, 액션 배열, `.then` 콜백 안 임시 변수, 인덱스 루프

```
var formNew	= () => { ... };
var trAction	= (action: string, i: number) => { ... };
var fv	= form.value;
```

비교: `==` / `!=` 사용 (`===` 쓰지 말 것).

```
if (r1.valid == false) return;
if (ix == -1) return {};
if (sss.logind() == false) ...
```

타입: 도메인 객체는 `as any` / `any[]`. 새 interface를 만들어 엔티티를 엄격히 모델링하지 않는다.

```
const form	= ref({ prop: {} } as any);
const aa	= ref([] as any[]);
```

Promise: 데이터 fetch는 `.then(rj => ..., err => ...)` .
`async/await`는 폼 `validate()` 정도만.

```
apiUserSave(t).then(
	rj	=> _set(rj.data)
);
```

---

## 3. 짧은 변수명 (필수)

기존 약어를 그대로 쓴다. 긴 영어 이름을 만들지 않는다.

| 이름 | 의미 |
|------|------|
| `pp` | `defineProps` 결과 |
| `rr` | `useRoute()` |
| `rrr` | `useRouter()` |
| `sss` | `useSession()` |
| `mod` | 드로어 열림 상태 `{ show, id }` |
| `table` | 테이블 페이지 상태 `{ cur, per, srch, header }` |
| `form` | 폼 ref |
| `vform` | `VForm` 컴포넌트 ref |
| `fv` | `form.value` |
| `fp` | `form.value.prop` |
| `dv` | `mod.value` |
| `vv` | `vform.value` |
| `r1` | 첫 번째 결과 (validate 등) |
| `rj` | resolve/응답 JSON |
| `aa` | 스토어 목록 배열 |
| `tk` | 동기화 토큰/타임스탬프 |
| `ix` | 인덱스 |
| `t` | 현재 아이템/임시 |
| `q` | 쿼리 |
| `r_` | 누적 결과 배열 |
| `id` | 엔티티 id. 없으면 `0` (신규) |

금지 예: `const router = useRouter()`, `const props = defineProps`, `const items = ref`, `handleSubmit`, `isValid`, `pagination`.

---

## 4. 페이지 (`src/pages/{name}.vue`)

파일 하나가 라우트 하나. `definePage`로 메뉴 메타를 넣는다.

인증 필요 (기본 레이아웃):
```
definePage({
	meta: {
		title:	'화면이름',
		icon:	'tabler-xxx',
	}
});
```

비인증 / 빈 레이아웃:
```
definePage({
	meta: {
		layout: 'blank',
		requiredAuth: false,
		public: true,
	},
});
```

메뉴에 넣으려면 `src/utils/menu.ts`에 `{ to: '/{name}' }` 추가.
섹션 제목은 `{ title: '관리' }` (to 없음).
메뉴 라벨/아이콘은 페이지 `definePage.meta`에서 읽는다.

페이지 스타일 클래스: `.pages-{파일명}` (하이픈, 라우트 path 기준).

```
<style lang='scss'>
.pages-user {
	.page-content-container {
		height: 100%;
	}
}
</style>
```

규칙:
- 행 액션은 반드시 `Actions` + `tAction` switch. 행마다 `v-btn`을 직접 나열하지 않는다.
- 드로어는 `v-if='mod.show'`로 마운트. `id==0` 이면 신규.
- 시간 컬럼: `dayjs(item.prop.tkins * 1000).fromNow()` (초 단위 unix).
- 줄수 셀렉트는 `columnLens` (utils, 자동 import).
- UI 문구는 한국어.

---

## 5. 드로어 (`src/views/drawr/{name}.vue`)

규칙:
- `show`는 `defineModel<boolean>('show')`. emit으로 `update:show` 만들지 말 것.
- props는 `const pp = defineProps<{ id: number }>()`.
- 초기값은 `useCloned(store.findObj(pp.id))`로 복사. store 객체를 직접 바인딩하지 말 것.
- 파생 필드는 `computed({ get() {}, set(i) {} })`.
- 검증 실패 시 `console.error(r1.errors)` 후 return.
- 개발 중 폼 덤프가 필요하면 `<DEBUG_>{{ form }}</DEBUG_>`.

---

## 6. 스토어 (`src/plugins/store/{name}.ts`)

규칙:
- 목록 필드는 항상 `aa`. `items`/`list`/`data` 금지.
- 서버 반영 전 로컬 갱신은 `_set` / `_del` (언더스코어 prefix).
- persist가 필요하면 `login.ts`/`session.ts`처럼 두 번째 인자에 `persist: { storage: Storg as StorageLike }`.
- `defineStore`는 자동 import되지만 스토어 파일에서는 `import { defineStore } from 'pinia'`를 기존처럼 명시해도 된다.

---

## 7. API (`src/utils/api.ts`)

새 엔드포인트는 이 파일 하단에 한 줄씩 추가. 새 api 모듈을 만들지 말 것.

```
export const apiXxx		= (q?: any)				=> get_('/xxx', { q });
export const apiXxxSave	= (t: any, q?: any)		=> post_(`/xxx/${t.id ?? 0}`, { t, q });
export const apiXxxDel	= (id: any, q?: any)	=> del_(`/xxx/${id}`, { q });
```

규칙:
- body 키는 `t`, query 키는 `q`. (`fetch_`가 `opt.t`/`opt.q`를 사용)
- 생성/수정은 같은 `Save`. 신규 id는 `t.id ?? 0`.
- base URL은 `VITE_API_BASE_URL || '/a'`. 하드코딩 금지.
- 에러는 `fetch_`가 `fetchError` 커스텀 이벤트를 쏜다. 호출부에서 try/catch로 HTTP를 감싸지 말 것.
- 로그인: `POST /sess`, 로그아웃: `DELETE /sess`.

---

## 8. 컴포넌트 (`src/components/`)

- PascalCase 파일: `Actions.vue`, `AppDrawerHeaderSection.vue`
- 타입 표시용은 `type` prefix 소문자 시작: `typeTags.vue`, `typeApprv.vue`, `typeMember.vue`
- props는 짧게: `a`, `v`, `fp`, `id`
- `v-model`은 `defineModel`. 기본 모델명은 필요 시 `'modelValue'`
- `src/components`는 자동 등록. 페이지에서 import 하지 말 것
- 행 액션 UI는 새로 만들지 말고 `Actions`를 쓴다
  - `:panel='1'` → 앞 N개는 아이콘, 나머지는 `tabler-dots-vertical` 메뉴
  - `@click='trAction'` → `(action, value)`

기존 표시 컴포넌트:
- `typeTags` — `:a='item.tag_'` `:id='item._id'` `:fp='UserTypeFind'`
- `typeApprv` — `:v='item.apprv'` (0=미승인)
- `typeMember` — `v-model` + `:items='UserType'`

상수/찾기 함수는 `src/utils/const.ts`에 추가 (`UserType` / `UserTypeFind` 패턴).

---

## 9. Vuetify / 템플릿

혼용 규칙 (기존과 맞출 것):
- 구조/액션: PascalCase — `VNavigationDrawer`, `VCard`, `VCardText`, `VForm`, `VBtn`, `VDivider`, `VPagination`, `VSpacer`
- 입력/테이블: kebab-case — `v-card`, `v-text-field`, `v-select`, `v-checkbox`, `v-combobox`, `v-data-table`, `v-chip`
- 같은 파일 안에서 기존 혼용을 유지. 한 파일 전체를 Pascal로 통일하지 말 것.

클래스:
- 레이아웃: `d-flex`, `d-flex-col`, `d-flex-cols`, `fx-1d`, `fx-1a`, `h-100`, `fulld`
- 폭: `col-02`, `col-12`, `col-030`, `col-050`, `col-100` (이 프로젝트 커스텀 그리드)
- 간격: `mb-3`, `mb-5`, `me-3`, `pa-2`, `mx-2`

아이콘 버튼: `icon='tabler-plus'`.
비밀번호 토글: `:append-inner-icon="form.visib ? 'tabler-eye-off' : 'tabler-eye'"` + `@click:append-inner`.

검증 규칙은 `src/utils/rules.ts` (`required`, `userid`, `passwd` …). 인라인 메시지 함수를 새로 쓰지 말고 여기에 추가.

토스트: `toast.warning('...')`, `toast.error(...)` (default import).

날짜: `dayjs` (자동 import, locale ko, tz Asia/Seoul).

디렉티브:
- `v-urlAuthority='item.prop'` — broker URL 표시
- `v-json` / `v-jsonDiff='{ a, b }'`
- 새 디렉티브는 `src/plugins/directive/` + `index.ts`에 등록

---

## 10. 플러그인 / 라우터 / 레이아웃

플러그인 파일:
```
import type { App } from 'vue';

export default function (app: App) {
	app.use(...);
}
```

로드: `src/utils/plugins.ts`가 `../plugins/*.{ts,js}` 와 `../plugins/*/index.{ts,js}` 를 **파일명 정렬**로 eager import.
순서에 민감하면 숫자 prefix.

라우터 (`src/plugins/00-router.ts`):
- `unplugin-vue-router` auto routes + `setupLayouts`
- `meta.requiredAuth === false` 만 공개
- 그 외 `useSession().logind() == false` 이면 `/login?url=`
- 401은 레이아웃의 `fetchError` → `/logout`

레이아웃:
- 기본: `src/layouts/default.vue` (세로 네비)
- 로그인/에러: `blank`
- 페이지에서 `meta.layout`로 지정

---

## 11. 새 CRUD 기능 체크리스트

한 리소스 `foo`를 추가할 때 **이 5파일을 함께** 만든다/수정한다. 하나만 만들지 말 것.

1. `src/utils/api.ts` — `apiFoo`, `apiFooSave`, `apiFooDel`
2. `src/plugins/store/foo.ts` — `useFoo`, `aa`/`find`/`findObj`/`load`/`set`/`del`
3. `src/pages/foo.vue` — 테이블 + `mod` + `Actions` + `definePage`
4. `src/views/drawr/foo.vue` — 우측 드로어 폼
5. `src/utils/menu.ts` — `{ to: '/foo' }`

페이지에서 `store.load()`를 스크립트 하단에 바로 호출 (onMounted로 감싸지 않음. 기존 climq/user와 동일).

---

## 12. 하지 말 것

- `<script setup>` 위에 `<template>`을 두지 않기 (style이 있으면 style이 먼저, 그 다음 template, 마지막 script)
- `const handleXxx`, `onClickXxx` 같은 React식 이름. 액션은 `tAction` / `formNew` / `onSubmit`
- Pinia option store (`state/getters/actions` 객체)
- `storeToRefs` (이 프로젝트는 `store.aa` 직접 사용)
- `useAsyncState` / 로딩 스피너 프레임워크 추가. 기존처럼 단순 then
- i18n 레이어. 문자열은 템플릿에 한국어로 직접
- CSS module / scoped를 기본으로 쓰지 않음. 페이지는 `.pages-{name}` 전역 셀렉터. scoped는 login처럼 예외일 때만
- `prettier` 스타일 재포맷, 주변 파일 리팩터
- 사용하지 않는 추상화, barrel `index.ts` 추가
- `ref` 대신 `reactive`로 폼을 바꾸지 말 것. 폼은 `ref({ ... } as any)`
- `watch`로 드로어 id를 로드하지 말 것. `v-if='mod.show'` + `useCloned(findObj(id))`로 마운트 시 복사

---

## 13. 작성 전 확인

새 `.vue`/스토어를 쓰기 전에 가장 가까운 기존 파일을 연다.
구조를 복사한 뒤 이름·필드·API만 바꾼다.
기존에 없는 패턴이 필요하면 먼저 사용자에게 확인하고, 추측으로 새 아키텍처를 만들지 않는다.
