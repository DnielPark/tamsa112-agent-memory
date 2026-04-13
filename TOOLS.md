# TOOLS.md - Local Notes (인덱스 파일)

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

---

## 📋 기능 인덱스

### 웹 검색 API
- **설명**: 타빌리/브레이브 API를 활용한 인터넷 검색. 현지 언어 검색 전략 포함.
- **사용 시기**: 뉴스 검색, 정보 조사, 현지 언론 자료 수집 필요 시
- **스킬 위치**: `./skills/web-search.md`

### 보조작가 (소설 서브 브레인)
- **설명**: 다니엘의 소설 보조작가. 세계관/등장인물/장별요약/타임라인 4개 파일 기반 정보 관리.
- **사용 시기**: 소설 설정 질문, 파일 업데이트, 일관성 체크 필요 시
- **파일 위치**: `~/.openclaw/workspace/novel-brain/`
- **스킬 위치**: `./skills/novel-brain.md`

### 아마존 서버 (AWS Lightsail)
- **설명**: 소설 편집기가 호스팅된 외부 서버. Node.js + Nginx + SSL 구성.
- **사용 시기**: 서버 관리, 서비스 상태 확인, 배포 작업 시
- **스킬 위치**: `./skills/amazon-server.md`

### GitHub 워크플로우
- **설명**: 맥북 ↔️ GitHub ↔️ 서버 간 파일 동기화 표준 워크플로우. 서버 직접 수정 금지.
- **사용 시기**: 코드 수정, 서버 배포, 파일 동기화 작업 시
- **스킬 위치**: `./skills/github-workflow.md`

### 텔레그램 파일 전송
- **설명**: 파일 내용을 텔레그램으로 전송하는 스크립트. 긴 파일은 자동 분할 전송.
- **사용 시기**: 파일 내용을 텔레그램으로 빠르게 공유 필요 시
- **스킬 위치**: `./skills/send_to_telegram.py`

---

## 🚀 빠른 참조

### 웹 검색
```bash
cd ~/.openclaw/workspace/skills/tavily-api
python3 simple_search.py "검색어"
```

### 텔레그램 파일 전송
```bash
# 단일 파일
python3 ~/.openclaw/workspace/skills/send_to_telegram.py MEMORY.md

# 여러 파일
python3 ~/.openclaw/workspace/skills/send_to_telegram.py MEMORY.md TOOLS.md
```

### GitHub 워크플로우 (항상 이 순서)
```bash
cd ~/.openclaw/workspace/skills
./github-pull.sh # 1. 작업 시작 전
# 코드 수정 # 2. github-workspace/ 안에서
./github-push.sh "설명" # 3. 수정 완료 후
./deploy.sh # 4. 서버 배포
```

### 아마존 서버 SSH 접속
```bash
ssh -i ~/.ssh/my-key1.pem admin@43.200.251.19
```

### 서버 상태 확인
```bash
ssh -i ~/.ssh/my-key1.pem admin@43.200.251.19 \
 "sudo systemctl status nginx | head -3 && pm2 list"
```

---

## 📁 스킬 파일 구조

```
~/.openclaw/workspace/
├── TOOLS.md — 인덱스 (이 파일)
├── MEMORY.md — 장기 기억
└── skills/
 ├── web-search.md — 웹 검색 API
 ├── novel-brain.md — 소설 보조작가
 ├── amazon-server.md — 아마존 서버 정보
 ├── github-workflow.md — GitHub 배포 워크플로우
 ├── github-pull.sh — GitHub → 맥북
 ├── github-push.sh — 맥북 → GitHub
 ├── deploy.sh — GitHub → 서버 배포
 ├── send_to_telegram.py — 텔레그램 파일 전송
 ├── tavily-api/ — 타빌리 검색 스킬
 └── backup/ — 구버전 파일 보관
```

---

이 파일은 인덱스입니다. 상세 내용은 각 스킬 파일을 참조하세요. 🐾