# MEMORY.md - Long-term Memory

이 파일은 장기 기억을 저장합니다. 중요한 결정, 학습 내용, 지속적으로 기억해야 할 사항을 기록하세요.

## 📅 생성일: 2026년 3월 24일

---

## 시스템 아키텍처 결정

- **Google CLI 삭제**: Calendar API 버그, 유용성 부족으로 인한 제거 결정
- **로컬 일정 관리 시스템**: 단일 JSON 파일(`schedule.json`) 통합 방식 채택
- **메인 서버 렌더링 페이지**: 모든 웹 서비스의 통합 시작점으로 명확화

---

## 원칙 및 규칙

1. **얼라우 모드 준수**: 모든 작업 전 승인 요청
2. **간결한 응답**: 질문에만 답변, 불필요한 설명 생략
3. **읽기 전용 모니터링**: 일정관리는 웹 모니터링 전용
4. **단일 파일 통합**: 일정 데이터는 schedule.json 하나로 관리

---

## 학습 내용

- **검색어 언어 전략**: 현지 뉴스는 현지 언어로 검색 (상세 내용: `web-search.md`)
- **macOS Base64**: `base64 -i` 대신 `base64 <` 사용
- **GitHub API JSON 파싱**: macOS grep 한계로 Python 파싱 사용

---

## 웹 검색 API

### 타빌리 API (기본)
- **스킬 경로**: `~/.openclaw/workspace/skills/tavily-api/`
- **API 키**: `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`
- **기본 실행**: `python3 simple_search.py "검색어"`
- **상세 내용**: `skills/tavily-api/SKILL.md` 참조

### 브레이브 API (대체)
- **환경 변수**: `BRAVE_API_KEY`
- **설정**: `openclaw configure --section web`
- **특징**: 다국어 지원, 월 2,000회 무료 (카드 등록 필수)

---

## 소설 편집기 프로젝트 (2026-04-13 기준)

### 기본 정보
- **GitHub 레포 (코드)**: `DnielPark/tamsa112-novel-editor` (비공개)
- **GitHub 레포 (메모리)**: `DnielPark/tamsa112-agent-memory` (공개)
- **서버**: AWS Lightsail, tamsa112.com
- **상세 내용**: `skills/amazon-server.md`, `skills/github-workflow.md` 참조

### 역할 분담
- **Claude**: 기능 설계, 지시문 작성, 문서 작성
- **미르**: 코드 수정, 스크립트 실행, 서버 배포
- **대니얼**: 검수, 최종 승인

### 현재 상태
- editor.html 전면 개편 예정 (editor.html.backup 45KB 기준)
- 분리된 4개 파일 현재 미작동 상태
- 미해결 문제 및 예정 작업 목록: `TODO.md` 참조

---

## 향후 작업

- 소설 편집기 전면 개편 (editor.html.backup 기준으로 재작업)
- 아마존 서버 PM2 node-app 문제 해결 (우선순위 낮음)
- 일정관리 시스템에 실제 데이터 추가
- USER.md 상세 내용 업데이트

---

## 테스트 (2026-04-13)
- 시나리오 A 워크플로우 테스트 실행

---
## 환경 변수 관리 (2026-04-13 변경)

- GitHub 토큰 하드코딩 방식 → .env 파일 방식으로 전환
- .env 경로: ~/.openclaw/workspace/.env
- 모든 스크립트가 source ~/.openclaw/workspace/.env 로 토큰 로드
- .env 파일은 GitHub 업로드 금지 (민감 정보)

---

## 스킬 파일 관리 원칙 (2026-04-13 확정)

스킬 파일(MEMORY.md, TOOLS.md, skills/ 폴더)의 수정 권한은 사람(대니얼)에게만 있음.

- Claude — 수정본 작성
- 대니얼 — GitHub 에디터에서 직접 업로드
- 미르 — agent-pull.sh로 다운로드만. 직접 수정 금지.

이 원칙은 스킬 파일 오염 및 포맷 훼손 방지를 위한 핵심 규칙.
agent-push.sh는 더 이상 미르가 실행하지 않음.

---

## deploy.sh 방식 변경 (2026-04-13)

- 변경 전: wget → 비공개 레포 인증 불가로 실패
- 변경 후: curl + Authorization: token 헤더 방식
- 이유: curl이 비공개 레포 인증에 적합
- 
**이 파일은 정기적으로 업데이트하세요. 중요한 결정과 학습 내용을 기록하여 세션 간 지속성을 유지합니다.** 🐾
