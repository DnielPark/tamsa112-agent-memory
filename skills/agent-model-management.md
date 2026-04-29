# 에이전트 모델 관리

OpenClaw 에이전트(writer, main)의 모델 설정과 API 키 관리 방법을 정리한다.

**에이전트 역할:**
- **Writer**: 텔레그램, Discord 등 외부 채널용 (세션 유지)
- **Main**: CLI 직접 실행용 (`--agent main`, 세션 없음)

**핵심 원칙:**
- API 키는 `auth-profiles.json`에 하드코딩되어 저장됨
- `.env` 파일은 참고용, 실제 인증은 `auth-profiles.json`을 통해 이루어짐
- 모델 설정은 `models.json`에서 관리

## 키가 저장된 파일 목록

| # | 파일 | 포함 키 |
|---|------|---------|
| 1 | `~/.openclaw/auth-profiles.json` | DeepSeek |
| 2 | `~/.openclaw/agents/main/agent/auth-profiles.json` | DeepSeek, Moonshot(Kimi) |
| 3 | `~/.openclaw/agents/writer/agent/auth-profiles.json` | DeepSeek, Moonshot(Kimi) |

## ⚠️ 중요: 수정 시 주의할 설정 파일들

OpenClaw 설정 변경 시 **절대 건드리면 안 되는 파일** (시스템 먹통 위험):

| 파일 | 설명 | 위험도 |
|------|------|--------|
| `~/.openclaw/openclaw.json` | 메인 설정 파일 | 🔴 **치명적** |
| `~/.openclaw/config.json` | 설정 파일 (openclaw.json과 유사) | 🔴 **치명적** |
| `~/.openclaw/agents/writer/agent/models.json` | Writer 에이전트 모델 설정 | 🔴 **치명적** |
| `~/.openclaw/agents/main/agent/models.json` | Main 에이전트 모델 설정 | 🔴 **치명적** |
| `~/.openclaw/agents/writer/agent/auth-profiles.json` | Writer 인증 프로필 | 🟡 **높음** |
| `~/.openclaw/agents/main/agent/auth-profiles.json` | Main 인증 프로필 | 🟡 **높음** |
| `~/.openclaw/auth-profiles.json` | 글로벌 인증 프로필 | 🟡 **높음** |
| `~/.openclaw/identity/device-auth.json` | 기기 인증 정보 | 🟡 **높음** |

### 안전한 수정 방법
- **API 키 변경**: `openclaw configure --section models` 명령어 사용
- **모델 설정 변경**: 웹 UI 또는 `openclaw` CLI 명령어 사용
- **직접 파일 수정 금지**: JSON 파싱 오류 시 OpenClaw 완전 먹통됨

### 백업 파일
OpenClaw는 설정 파일 변경 시 자동으로 백업 생성:
- `openclaw.json.bak`
- `openclaw.json.bak.2`
- `openclaw.json.bak5.json`

## 키 변경 워크플로우

⚠️ **중요**: OpenClaw는 공개 소스라 API 키가 여러 파일에 분산 저장됨. 한 파일만 바꾸면 다른 곳에서 인증 실패할 수 있음.

### Kimi (Moonshot) 키 변경 시
**총 3개 파일 업데이트 필요:**

1. `~/.openclaw/.env` - 환경 변수 파일
2. `~/.openclaw/agents/writer/agent/auth-profiles.json` - Writer 에이전트 인증
3. `~/.openclaw/agents/main/agent/auth-profiles.json` - Main 에이전트 인증

```bash
# 방법 1: openclaw configure 사용 (권장)
openclaw configure --section models
# → moonshot 프로필의 API 키 업데이트
# → 단, .env 파일은 수동으로 업데이트해야 함

# 방법 2: 수동 업데이트 (모든 파일 직접 수정)
# 1. ~/.openclaw/.env 의 KIMI_API_KEY 변경
# 2. ~/.openclaw/agents/writer/agent/auth-profiles.json 의 key 값 변경
# 3. ~/.openclaw/agents/main/agent/auth-profiles.json 의 key 값 변경
```

### DeepSeek 키 변경 시
**총 4개 파일 업데이트 필요:**

1. `~/.openclaw/.env` - 환경 변수 파일
2. `~/.openclaw/auth-profiles.json` - 글로벌 인증
3. `~/.openclaw/agents/writer/agent/auth-profiles.json` - Writer 에이전트
4. `~/.openclaw/agents/main/agent/auth-profiles.json` - Main 에이전트

```bash
# 방법 1: openclaw configure 사용 (권장)
openclaw configure --section models
# → deepseek 프로필의 API 키 업데이트
# → 단, .env 파일은 수동으로 업데이트해야 함

# 방법 2: 수동 업데이트
# 1. ~/.openclaw/.env 의 DEEPSEEK_API_KEY 변경
# 2. ~/.openclaw/auth-profiles.json 의 key 값 변경
# 3. ~/.openclaw/agents/writer/agent/auth-profiles.json 확인/변경
# 4. ~/.openclaw/agents/main/agent/auth-profiles.json 확인/변경
```

### Brave Search 키 변경 시
**1개 파일 업데이트:**

1. `~/.openclaw/.env` - 환경 변수 파일

```bash
# ~/.openclaw/.env 의 BRAVE_API_KEY 변경
```

## 모델 설정 파일 구조

### 파일 위치 및 역할

| 에이전트 | 모델 설정 파일 | 설명 | 사용처 |
|----------|---------------|------|--------|
| Writer | `~/.openclaw/agents/writer/agent/models.json` | 채널용 모델 | 텔레그램, Discord 등 외부 채널 |
| Main | `~/.openclaw/agents/main/agent/models.json` | 기본 에이전트 모델 | CLI 직접 실행 (`--agent main`) |

**에이전트 역할:**
- **Writer**: 외부 메신저 채널(텔레그램, Discord 등)에서 자동으로 사용됨. 세션 유지.
- **Main**: CLI에서 `openclaw agent --agent main ...`으로 수동 실행 시 사용. 세션 없음.

**확인 방법:**
```bash
# 세션 정보에서 에이전트 확인
grep "telegram" ~/.openclaw/agents/writer/sessions/sessions.json
# → "agent:writer:telegram:direct:8024121053"

# 또는 런타임 정보에서 확인
# Runtime: agent=writer
```

### models.json 구조

```json
{
  "providers": {
    "moonshot": {
      "baseUrl": "https://api.moonshot.ai/v1",
      "api": "openai-completions",
      "models": [
        {
          "id": "kimi-k2.6",
          "name": "Kimi K2.6",
          "reasoning": false,
          "input": ["text", "image"],
          "cost": { "input": 0.1, "output": 0.2 },
          "contextWindow": 262144,
          "maxTokens": 8192
        }
      ],
      "apiKey": "KIMI_API_KEY"
    }
  }
}
```

## OpenClaw 미지원 모델 수동 추가

OpenClaw CLI에서 기본 제공되지 않는 모델(DeepSeek, 로컬 모델 등)을 추가하려면 다음 파일들을 직접 수정해야 한다.

### 수정해야 할 파일 목록 (총 6개)

| 순서 | 파일 | 수정 내용 |
|------|------|-----------|
| 1 | `~/.openclaw/.env` | API 키 환경변수 추가 |
| 2 | `~/.openclaw/auth-profiles.json` | 글로벌 인증 프로필 추가 |
| 3 | `~/.openclaw/agents/writer/agent/auth-profiles.json` | Writer 인증 프로필 추가 |
| 4 | `~/.openclaw/agents/main/agent/auth-profiles.json` | Main 인증 프로필 추가 |
| 5 | `~/.openclaw/agents/writer/agent/models.json` | Writer 모델 정의 추가 |
| 6 | `~/.openclaw/agents/main/agent/models.json` | Main 모델 정의 추가 |

### 1. .env 파일 수정

**파일 위치**: `~/.openclaw/.env` (홈 디렉토리 기준)

```bash
# DeepSeek 예시
DEEPSEEK_API_KEY=sk-your-api-key-here

# 로컬 Ollama 예시 (이미 설정되어 있을 수 있음)
OLLAMA_API_KEY=ollama
```

### 2. auth-profiles.json 수정 (3개 파일)

**주의**: 글로벌 파일과 에이전트 파일의 구조가 다름

**`~/.openclaw/auth-profiles.json` (글로벌 - version 필드 없음):**
```json
{
  "profiles": {
    "deepseek:default": {
      "type": "api_key",
      "key": "sk-your-api-key-here"
    }
  }
}
```

**`~/.openclaw/agents/writer/agent/auth-profiles.json` (에이전트 - version 필드 있음):**
```json
{
  "version": 1,
  "profiles": {
    "deepseek:default": {
      "type": "api_key",
      "provider": "deepseek",
      "key": "sk-your-api-key-here"
    }
  }
}
```

**`~/.openclaw/agents/main/agent/auth-profiles.json`:** (writer와 동일한 구조)

### 3. models.json 수정 (2개 파일)

**`~/.openclaw/agents/writer/agent/models.json`에 provider 추가:**
```json
{
  "providers": {
    "deepseek": {
      "baseUrl": "https://api.deepseek.com/v1",
      "api": "openai-completions",
      "models": [
        {
          "id": "deepseek-chat",
          "name": "DeepSeek V3",
          "reasoning": false,
          "input": ["text"],
          "cost": {
            "input": 0.14,
            "output": 0.28,
            "cacheRead": 0.014,
            "cacheWrite": 0.14
          },
          "contextWindow": 65536,
          "maxTokens": 8192
        },
        {
          "id": "deepseek-reasoner",
          "name": "DeepSeek R1",
          "reasoning": true,
          "input": ["text"],
          "cost": {
            "input": 0.55,
            "output": 2.19,
            "cacheRead": 0.14,
            "cacheWrite": 0.55
          },
          "contextWindow": 65536,
          "maxTokens": 8192
        }
      ],
      "apiKey": "DEEPSEEK_API_KEY"
    }
  }
}
```

**`~/.openclaw/agents/main/agent/models.json`:** (동일한 provider 추가)

### 필수 필드 설명

| 필드 | 설명 | 예시 |
|------|------|------|
| `baseUrl` | API 엔드포인트 | `https://api.deepseek.com/v1` |
| `api` | API 타입 | `openai-completions`, `anthropic-messages` |
| `id` | 모델 식별자 | `deepseek-chat`, `llama3.1:8b` |
| `contextWindow` | 최대 컨텍스트 길이 | 65536, 131072 |
| `maxTokens` | 최대 출력 토큰 | 4096, 8192 |
| `reasoning` | 추론 모드 여부 | true, false |
| `cost` | 가격 정보 (1M 토큰 기준 USD) | `{ "input": 0.14, "output": 0.28 }` |

### 주의사항

⚠️ **JSON 문법 오류 주의**: 쉼표, 중괄호, 따옴표 하나라도 틀리면 OpenClaw가 완전히 먹통됨
- 수정 전 반드시 백업: `cp models.json models.json.bak`
- JSON 유효성 검사: `python3 -m json.tool models.json`
- 오류 발생 시 백업 복원: `cp models.json.bak models.json`

### 예시: Ollama 로컬 모델

```json
"ollama": {
  "baseUrl": "http://127.0.0.1:11434/v1",
  "apiKey": "ollama",
  "api": "openai-completions",
  "models": [
    {
      "id": "llama3.1:8b-instruct-q8_0",
      "name": "Llama 3.1 8B Q8",
      "contextWindow": 65536,
      "reasoning": false,
      "input": ["text"],
      "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
      "maxTokens": 8192
    }
  ]
}
```

## 주의사항
- `openclaw configure` 실행 시 auth-profiles.json이 재생성될 수 있음
- configure 실행 후에는 다시 스킬로 키를 업데이트해야 함
- writer와 main 에이전트는 별도 파일이므로 둘 다 업데이트 필요
