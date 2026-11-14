# Golang 언어로 개발시 코딩 규칙

이 저장소의 기존 Go 코드와 **거의 동일한 형태**로 작성한다.
표준 Go 관례보다 **이 프로젝트 스타일**을 우선한다. gofmt 기본 정렬, godoc, 레이어 추상화, 새 프레임워크를 들이지 않는다.

모듈 경로는 `go.mod` 의 `module` 을 따른다.

---

## 1. 디렉터리 / 패키지

| 경로 | 역할 |
|---|---|
| `main.go`, `daemon.go` | `package main`. 엔트리 / 데몬 |
| `etc/` | 환경변수, 경로, 앱 메타 |
| `ctl/` | Echo HTTP. `Init`/`Start`/`Close` |
| `ctl/a/` | API 그룹. `Route(e *echo.Echo)` |
| `ctl/a/<name>/` | 리소스별 컨트롤러. 패키지명 = 디렉터리명 |
| `model/` | GORM 모델 + DB. 전역 `db_` |
| `lib/<pkg>/` | 작은 유틸 패키지. 한 기능 단위 |
| `test/` | `package main`. 느슨한 테스트 |

- import 경로는 항상 `<module>/...` (`go.mod` 의 module)
- 패키지명은 짧게: `logg`, `qtk`, `sess`, `conv`
- 새 상위 레이어(`internal/`, `pkg/`, `service/`, `repository/`)를 만들지 않는다
- 이미 있는 `lib/*` 를 재사용한다. 동등 기능을 새로 만들지 않는다

---

## 2. 파일 이름

번호 접두사는 **역할 고정**이다. 한 패키지 안에서 같은 역할을 새 이름로 만들지 않는다.

| 파일 | 내용 |
|---|---|
| `00-init.go` | `var`, `init()`, `Init()`, `Close()`, 패키지 상태 |
| `01-const.go` | `const` |
| `01-type.go` | `type`, 타입 별칭, 타입 메서드 |
| `01-func.go` / `02-func.go` / `03-func.go` | 패키지 함수 |
| `07-query.go` | 쿼리 헬퍼 |
| `08-struct.go` | 모델/공개 구조체 |
| `09-model.go` / `09-struct.go` | 임베드 모델 메서드 / 파일 구조체 |
| `<entity>.go` | 해당 타입 메서드 (`user.go`, `device.go`) |
| `api.go` | 핸들러 (`list`/`save`/`delete`) |
| `middle.go` | 미들웨어 |

- 소문자, 짧은 이름. camelCase 파일명 금지
- 컨트롤러는 `00-init.go`(Route) + `api.go`(핸들러)
- 함수 하나짜리 `lib` 파일은 기능명 (`string.go`, `keys.go`)

---

## 3. 정렬 · 공백 (가장 중요)

탭 들여쓰기. **`=` / `:=` / 구조체 필드 / return 값** 을 탭으로 세로 맞춘다.

필수:
- `return` 과 값 사이 탭: `return	e`, `return	nil`, `return	r_`
- import 블록 다음 **빈 줄 2개** 후 첫 선언
- 함수 사이 빈 줄 1개. 관련 없는 그룹은 2개
- 파일 끝 개행 1개. 불필요한 주석 추가 금지
- `gofmt`가 맞추는 한 칸 공백 스타일로 **다시 정렬하지 않는다**

---

## 4. 이름

### 변수
짧고 위치 기반. 설명적 장문 이름 쓰지 않는다.

| 이름 | 용도 |
|---|---|
| `c` | 리시버, `echo.Context` |
| `e` | error (기본). `err` 는 드물게 |
| `m`, `m1`, `m2` | 모델 |
| `r_`, `r1`, `r2` | 결과 |
| `wh` | where `[]any` |
| `tx`, `res` | `*gorm.DB` |
| `t` | range 원소, type switch |
| `o` | map ok |
| `p` | 포인터/임시 |
| `s`, `b` | string / []byte |
| `n` | 개수 |
| `id` | 식별자 |

### 리시버
항상 `c` (훅만 `h` 허용). `func (c *User)`, `func (c *log_t)`.

### 타입
- 비공개 구조체: `*_t` → `model_t`, `conn_t`, `log_t`, `topic_t`
- 별칭은 대문자 + 끝 `_` → `AAI_`, `AAS_`, `MAPAI_`, `LEVEL_`
- 패키지 전역 비공개: 끝 `_` → `db_`, `r_`
- FK/연관 필드: 끝 `_` → `User_`, `Tag_`, `Sess_`
- 컬렉션 타입 대문자 → `CONNS`, `MPCONNS`, `TOPICS`

### 함수/필드 (축약 유지)
`Enabld`, `Changd`, `Pyload`, `Passwd`, `NetAllw`, `Apprv`, `Lgout`, `Rowd`, `Tk`, `Mssg`, `Startd`, `fil`, `lin`, `fun`

- 공개 초기화: `Init()`, 비공개 변형: `init_()`
- 모델 CRUD: `Changd`, `List`, `ListSimple`, `Get`, `Save`, `Delete`, `Count`, `table()`
- 집합 추가: `PushIf`
- 쓰지 말 것: `NewXxxRepository`, `XxxService`, `HandleListUsers`

---

## 5. import

```go
import (
	"net/http"

	"github.com/labstack/echo/v4"

	"<module>/lib/qtk"
	"<module>/model"
)
```

1. 표준 2. 빈 줄 3. 외부 4. 빈 줄 5. `<module>/...`
- 별칭은 기존처럼 짧게: `mochi`, `mqtt`, `mw`, `gnid`, `jsoniter`
- 새 라이브러리 추가 금지. 있는 것만 쓴다
  - HTTP: `echo/v4`
  - DB: `gorm` + postgres
  - JSON: `encoding/json` 또는 `json-iterator` (`conv.JsonIt*`, `model.jsonr`)
  - 로그: `lib/logg` (zap/slog 금지)
  - 설정: `etc`
  - 시간: 표준 `time` 또는 `lib/time`

---

## 6. 제어 흐름

- 가드 후 바로 return. 중첩 최소화
- error: `if e != nil { return e }` 또는 `return	c.String(http.StatusBadRequest, e.Error())`
-  squashing: `p,_	:=`, `b,_	:=` 기존처럼 필요할 때만
- 에러 래핑(`fmt.Errorf("...: %w")`) 하지 않는다
- `context.Context` 를 API 전체에 넣지 않는다 (GORM logger 등 기존 자리만)
- 조건에 괄호를 쓰던 자리면 그대로: `if (uid != 0 && gid != 0)`, `if (c.Passwd == "")`
- 불가능한 케이스용 방어 코드 추가 금지
- 빈 `if` 몸통이 기존에 있으면 스타일만 맞추고 리팩터하지 않는다

---

## 7. 모델 (`model/`)

구조체는 `08-struct.go` 의 `type (` 블록에 모은다. 파일 밖으로 새 엔티티 구조체를 흩뿌리지 않는다.
메서드는 `<entity>.go`.

규칙:
- 임베드 `model_t` (`Err error`, `Rowd int64`, 둘 다 `gorm:"-" json:"-"`)
- PK 컬럼 `_id`, 필드 `ID`, json `id`, param `id`
- 타임스탬프 `Tk`, gorm `;->` (DB 생성, 쓰기 omit)
- JSONB 는 `MAPAI_`, 문자열 배열은 `AAS_`
- 리시버 `*Type`, 결과는 `c.goResult(res)` 로 `Err`/`Rowd` 저장
- where 는 `[]any{"col=?", v}` 를 `...any` 로 `goWhere` 에 전달
- `Save`: `ID == 0` 이면 `Create`, 아니면 `Save`/`Omit`
- 성공은 `bool` 또는 포인터. 인터페이스/Repo 없음
- 전역 `db_`. 세션 객체를 핸들러에 주입하지 않음

새 엔티티 체크리스트:
1. `08-struct.go` 에 구조체 + `model_t`
2. `<entity>.go` 에 `Changd`/`List`/`ListSimple`/`Get`/`Save`/`Delete`
3. 필요하면 `table()`

---

## 8. 컨트롤러 (`ctl/a/<name>/`)

`00-init.go`:

```go
func Route(g *echo.Group) {
	r	:= g.Group( "/"+ pkg.Name() )
	{
		r.GET("", list)
		r.POST("/:id", save)
		r.DELETE("/:id", delete)
	}
}
```

- 경로는 `pkg.Name()` (디렉터리명). 문자열 하드코딩 하지 않음
- 핸들러는 비공개: `list`, `save`, `delete`, `login`
- `ctl/a/00-init.go` 의 `Route` 에 서브패키지 `Route` 를 추가

`api.go` 응답 고정 키: `list`/`data`, `err`, `id`, `tk`, `mth`

- Bind 실패 → `400` + `e.Error()` 문자열
- 변경 없음 → `304` 빈 문자열
- 본문을 두 타입으로 써야 하면 `io.ReadAll` 후 `json.Unmarshal` 두 번 (`MAPAI_` + 구조체)
- 핸들러에서 로깅/미들웨어/DTO 레이어를 새로 만들지 않음

---

## 9. 패키지 초기화

- 상태는 패키지 `var`. 생성자 주입 없음
- 기동 순서 유지: `logg.Init()` → `model.Init()` → `ctl.Init` → `ctl.Start`
- 서버 Listen 은 고루틴 + `time.Sleep` 후 에러 확인 (기존 `ctl.Start`, `cmq.Init`)

---

## 10. lib 유틸

- 패키지 작고, 파일당 함수 적게
- 제네릭은 기존처럼 짧은 헬퍼만 (`conv.ToAnys`, `maps.Keys`)
- `switch t := v.(type)` 로 변환. 큰 추상화 없음

기존 패키지 우선:
- `etc.String` / `etc.Int`
- `conv.String` / `conv.AByte` / `conv.JsonItEncode`
- `logg.Printf` / `Infof` / `Errorf` / `Fatal`
- `qtk.Stamp` / `qtk.Range`
- `pkg.Name`
- `dbutils.Passwd` / `UAdmin`
- `session.SIDSet` / `SIDGet`
- `lib/echo` 미들웨어 (`mw`)

---

## 11. 주석 · 테스트 · 금지

- 주석 추가하지 않는다. 기존 주석/주석 처리된 코드는 건드리지 않는다
- 테스트는 `test/`, `package main`, `func Test_foo(t *testing.T)` (언더스코어)
- 새 인터페이스, mock, wire, fx, 제네릭 Repo 금지
- `if err != nil` 래핑 헬퍼, `Must*`(이미 있는 `gnid.Must` 제외) 남발 금지
- 인접 코드 리포맷/리네임 금지. 요청한 부분만 수정
- 시크릿/솔트를 새 파일에 복사하거나 로그로 찍지 않는다

---

## 12. 새 작업 시 복제 순서

1. 같은 종류의 기존 파일 하나를 연다 (컨트롤러면 `ctl/a/climq/`, 모델이면 `device.go`)
2. 파일 분할·이름·정렬·짧은 변수·응답 키를 그대로 복제한다
3. 동작에 필요한 최소 코드만 추가한다
4. `gofmt`로 탭 정렬을 깨지 않게 저장한다
