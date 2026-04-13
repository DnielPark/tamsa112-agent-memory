# MEMORY.md - Long-term Memory

이 파일은 장기 기억을 저장합니다. 중요한 결정, 학습 내용, 지속적으로 기억해야 할 사항을 기록하세요.

## 📅 생성일: 2026년 3월 24일

---

## 시스템 아키텍처 결정

- Google CLI 삭제: Calendar API 버그, 유용성 부족으로 인한 제거 결정
- 로컬 일정 관리 시스템: 단일 JSON 파일(schedule.json) 통합 방식 채택
- 메인 서버 렌더링 페이지: 모든 웹 서비스의 통합 시작점으로 명확화

---

## 원칙 및 규칙

1. 얼라우 모드 준수: 모든 작업 전 승인 요청
2. 간결한 응답: 질문에만 답변, 불필요한 설명 생략
3. 읽기 전용 모니터링: 일정관리는 웹 모니터링 전용
4. 단일 파일 통합: 일정 데이터는 schedule.json 하나로 관리

---

## 학습 내용

- 검색어 언어 전략: 현지 뉴스는 현지 언어로 검색 (상세 내용: web-search.md)
- macOS Base64: base64 -i 대신 base64 < 사용
- GitHub API JSON 파싱: macOS grep 한계로 Python 파싱 사용

---

## 웹 검색 API

### 타빌리 API (기본)
- 스킬 경로: ~/.openclaw/workspace/skills/tavily-api/
- API 키: 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
- 기본 실행: python3 simple_search.py "검색어"
- 상세 내용: skills/tavily-api/SKILL.md 참조

### 브레이브 API (대체)
- 환경 변수: BRAVE_API_KEY
- 설정: openclaw configure --section web
- 특징: 다국어 지원, 월 2,000회 무료 (카드 등록 필수)

### 핵심 원칙
현지 뉴스 검색 시 현지 언어 우선. 상세 전략은 skills/web-search.md 참조.

---

## 소설 편집기 프로젝트 (2026-04-13 기준)

### 기본 정보
- GitHub 레포: DnielPark/tamsa112-novel-editor (비공개)
- 서버: AWS Lightsail, tamsa112.com
- 스킬 위치: ~/.openclaw/workspace/skills/github-workflow.md

### 표준 워크플로우 (2026-04-13 확립)
서버 직접 수정 금지. 맥북이 유일한 작업 공간.

1. ./github-pull.sh — GitHub → 맥북 다운로드
2. 코드 수정 — github-workspace/ 안에서
3. ./github-push.sh — 맥북 → GitHub 업로드
4. ./deploy.sh — GitHub → 서버 배포

### 핵심 파일
- editor.html.backup — Claude와 대니얼 공유 원본 단일 파일 (45KB, 기준점)
- 분리된 4개 파일 (editor.html + editor-api.js + editor-ui.js + editor.css) — 작업 중 꼬인 상태, 전면 개편 예정

### 역할 분담
- Claude: 기능 설계, 지시문 작성, 문서 작성
- 미르: 코드 수정, 스크립트 실행, 서버 배포
- 대니얼: 검수, 최종 승인

### 현재 미해결 문제
- node-app PM2 에러 상태 (우선순위 낮음)
- editor.html 분리 버전 미작동 → 전면 개편으로 해결 예정

---

## 백업 파일
구버전 스킬 파일 백업 위치: `~/.openclaw/workspace/skills/backup/` (2026-04-13)

## 향후 작업

- 소설 편집기 전면 개편 (editor.html.backup 기준으로 재작업)
- 아마존 서버 PM2 node-app 문제 해결 (우선순위 낮음)
- 일정관리 시스템에 실제 데이터 추가
- USER.md 상세 내용 업데이트

---

이 파일은 정기적으로 업데이트하세요. 중요한 결정과 학습 내용을 기록하여 세션 간 지속성을 유지합니다. 🐾