# github-workflow.md - 아마존 서버 작업 워크플로우

## 📋 개요

소설 편집기 코드 작업의 표준 워크플로우.
맥북이 유일한 작업 공간. 서버 직접 수정 금지.

---

## 🔑 환경 정보

- GitHub 토큰: .env 파일에서 관리 (아래 참조)
- 레포지토리: DnielPark/tamsa112-novel-editor (비공개)
- 로컬 작업 경로: ~/.openclaw/workspace/github-workspace/
- 스크립트 경로: ~/.openclaw/workspace/skills/
- SSH 키: ~/.ssh/my-key1.pem
- 서버: admin@43.200.251.19

### .env 파일

- 경로: ~/.openclaw/workspace/.env
- 역할: GitHub 토큰 등 민감한 환경 변수 저장. 모든 스크립트가 이 파일을 source해서 사용.
- 형식: GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
- 주의: 이 파일은 절대 GitHub에 업로드하지 않음.

---

## 🚀 표준 작업 순서 — 서버 코드 배포

### 1단계 — 작업 시작 전 (항상)
cd ~/.openclaw/workspace/skills
./github-pull.sh
GitHub에서 최신 파일을 맥북으로 다운로드.
이 단계 없이 작업 시작 금지.

### 2단계 — 코드 수정
~/.openclaw/workspace/github-workspace/ 안에서 자유롭게 수정.

수정 대상 파일:
- novel/editor.html — 편집기 HTML 구조
- novel/editor.css — 스타일시트
- novel/editor-api.js — API 통신
- novel/editor-ui.js — UI/렌더링
- novel/mobile-reader.html — 모바일 뷰어
- novel/editor.html.backup — 원본 단일 파일 (45KB, 기준점)
- nodeapp/file-api.js — 백엔드 API

### 3단계 — GitHub에 올리기
cd ~/.openclaw/workspace/skills
./github-push.sh "작업 내용 설명"
커밋 메시지 예시: "editor.css 헤더 높이 수정", "file-api.js 업로드 버그 수정"

### 4단계 — 서버 배포
./deploy.sh
GitHub → 서버 자동 배포 + Nginx 재시작 + PM2 재시작(nodeapp 변경 시).
deploy.sh 방식: 서버에서 curl로 GitHub Raw URL 직접 다운로드 (Authorization 헤더 사용).

---

## 📋 스킬 파일 관리 원칙

스킬 파일(MEMORY.md, TOOLS.md, skills/ 폴더)은 별도 워크플로우로 관리.

역할 분담:
- Claude — 수정본 작성
- 대니얼 — GitHub 에디터에서 직접 업로드
- 미르 — agent-pull.sh로 다운로드만. 스킬 파일 직접 수정 금지.

미르가 스킬 파일을 직접 수정하면 내용이 오염되거나 포맷이 흐트러질 수 있음.
수정 권한은 사람(대니얼)에게만 있음.

스킬 파일 업데이트 흐름:
Claude가 수정본 작성 → 대니얼이 GitHub 에디터에서 업로드 → 미르가 agent-pull.sh로 적용

---

## ⚠️ 절대 금지 사항

- 서버에 SSH 접속해서 파일 직접 수정 (sed, vi, nano 등)
- /api/system/edit-file 엔드포인트로 서버 파일 수정
- github-pull.sh 없이 작업 시작
- 테스트 안 된 코드 배포
- GitHub 토큰을 스크립트에 하드코딩 (.env 파일 사용할 것)
- 미르가 스킬 파일 직접 수정

---

## 🛠 문제 발생 시

### GitHub 토큰 확인
source ~/.openclaw/workspace/.env
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/DnielPark/tamsa112-novel-editor \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('레포:', d.get('full_name'), '/ 접근:', '✅' if not d.get('message') else '❌')"

### 배포 후 서버 파일 확인
ssh -i ~/.ssh/my-key1.pem admin@43.200.251.19 \
  "ls -la /var/www/html/novel/"

### Nginx / PM2 상태 확인
ssh -i ~/.ssh/my-key1.pem admin@43.200.251.19 \
  "sudo systemctl status nginx | head -3 && pm2 list"

### 롤백이 필요할 때
editor.html.backup (45KB 원본 단일 파일)이 기준점.
GitHub에서 이 파일을 받아서 editor.html로 복사 후 배포.

cp ~/.openclaw/workspace/github-workspace/novel/editor.html.backup \
   ~/.openclaw/workspace/github-workspace/novel/editor.html
./github-push.sh "롤백 - editor.html.backup으로 복구"
./deploy.sh

---

## 📁 레포지토리 분리

### tamsa112-novel-editor (비공개)
- 서버 배포 파일만 저장
- 경로: novel/, nodeapp/
- 용도: 서버 코드 버전 관리

### tamsa112-agent-memory (공개)
- 에이전트 메모리 파일 + 스크립트 저장
- 파일: MEMORY.md, TOOLS.md, skills/ (md, py, sh 파일 포함)
- 수정 권한: 대니얼 (GitHub 에디터)
- 미르 접근: 읽기 전용 (agent-pull.sh)

---

## 🛠️ 스크립트 요약

| 스크립트 | 용도 | 실행 주체 |
|---|---|---|
| github-pull.sh | 서버 코드 다운로드 (GitHub → 맥북) | 미르 |
| github-push.sh | 서버 코드 업로드 (맥북 → GitHub) | 미르 |
| agent-pull.sh | 스킬 파일 다운로드 (GitHub → 맥북) | 미르 |
| agent-push.sh | 스킬 파일 업로드 (맥북 → GitHub) | 사용 안 함 (대니얼이 직접 업로드) |
| deploy.sh | 서버 배포 (GitHub → 서버, curl 방식) | 미르 |

---

새 세션 시작 시 이 파일과 amazon-server.md 먼저 읽을 것. 🐾
