# 🔑 OpenClaw 키 관리 스킬

OpenClaw는 auth 키를 `auth-profiles.json` 파일들에 하드코딩해서 저장한다.
`.env` 파일은 참고용일 뿐, 실제 인증은 auth-profiles.json을 통해 이루어진다.

## 키가 저장된 파일 목록

| # | 파일 | 포함 키 |
|---|------|---------|
| 1 | `~/.openclaw/auth-profiles.json` | DeepSeek |
| 2 | `~/.openclaw/agents/main/agent/auth-profiles.json` | DeepSeek, Moonshot(Kimi) |
| 3 | `~/.openclaw/agents/writer/agent/auth-profiles.json` | DeepSeek, Moonshot(Kimi) |

## 키 변경 워크플로우

### DeepSeek 키 변경
```bash
# 1. 모든 auth-profiles.json의 DeepSeek 키 업데이트
# 2. agents/main/agent/auth-profiles.json
# 3. agents/writer/agent/auth-profiles.json
# 4. auth-profiles.json
```

### Moonshot(Kimi) 키 변경
```bash
# 1. agents/main/agent/auth-profiles.json
# 2. agents/writer/agent/auth-profiles.json
```

## 모델 추가

모델 정의는 `agents/*/agent/models.json`에서 관리한다.

### DeepSeek V4-Flash 추가
- 프로바이더: `deepseek`
- 모델 ID: `deepseek-v4-flash`
- baseUrl: `https://api.deepseek.com/v1`
- api: `openai-completions`
- 컨텍스트: 1,048,576
- 맥스토큰: 384,000
- 가격: Input $0.14 / Output $0.28 (1M 토큰 기준)

### DeepSeek V4-Pro 추가
- 프로바이더: `deepseek`
- 모델 ID: `deepseek-v4-pro`
- baseUrl: `https://api.deepseek.com/v1`
- api: `openai-completions`
- reasoning: true (추론 모드)
- 컨텍스트: 1,048,576
- 맥스토큰: 384,000
- 가격: Input $0.435 / Output $0.87 (1M 토큰, 할인가)

## 주의사항
- `openclaw configure` 실행 시 auth-profiles.json이 재생성될 수 있음
- configure 실행 후에는 다시 스킬로 키를 업데이트해야 함
- writer와 main 에이전트는 별도 파일이므로 둘 다 업데이트 필요
