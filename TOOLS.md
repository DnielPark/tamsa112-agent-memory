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

### 토목 단가 구조 (Civil Cost Manager)
- **설명**: 단가 체계 계층 구조 및 입력 규칙. 단가 추가 시 먼저 읽고 작업.
- **사용 시기**: 단가 추가/수정 요청 시 반드시 먼저 읽을 것
- **스킬 위치**: `./skills/unit-cost-structure.md`

### 🔑 OpenClaw 키 관리
- **설명**: auth-profiles.json 파일들에 하드코딩된 API 키 관리. 키 변경 시 3개 파일 일괄 업데이트.
- **사용 시기**: API 키 변경, 모델 추가 필요 시
- **스킬 위치**: `./skills/key-management.md`

### GitHub 워크플로우
- **설명**: 맥북 ↔ GitHub ↔ 서버 간 파일 동기화 표준 워크플로우. 서버 직접 수정 금지.
- **사용 시기**: 코드 수정, 서버 배포, 파일 동기화 작업 시
- **스킬 위치**: `./skills/github-workflow.md`

### 서버 파일 수정 워크플로우
- **설명**: 서버 파일 수정 시 담당자 판단 기준, Claude 컨펌 절차, 배포 안전 규칙. 모든 배포는 Claude 컨펌 후에만 진행.
- **사용 시기**: 서버 파일 수정 요청이 있을 때 반드시 먼저 읽을 것
- **스킬 위치**: `./skills/code-edit.md`

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
./server-pull.sh          # 1. 작업 시작 전
# 코드 수정               # 2. github-workspace/ 안에서
./server-push.sh "설명"   # 3. 수정 완료 후
# Claude 컨펌             # 4. 대니얼이 코드 공유 → Claude 검토
./server-deploy.sh        # 5. 컨펌 후 배포
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

## 📋 Civil Cost Manager 프로젝트

### 스크립트
```bash
# GitHub → 맥북 (최신 코드 가져오기)
cd ~/.openclaw/workspace/skills
./cost-manager-pull.sh

# 맥북 → GitHub (변경사항 푸시)
cd ~/.openclaw/workspace/skills
./cost-manager-push.sh "커밋 메시지"
```

### 서버 실행/중지
```bash
cd ~/.openclaw/workspace/skills
./cost-manager-app-on.sh    # 서버 시작 (http://localhost:8080)
./cost-manager-app-off.sh   # 서버 중지
```

### 레포 정보
- **GitHub**: https://github.com/DnielPark/civil-cost-manager (공개)
- **로컬**: `~/.openclaw/workspace/civil-cost-manager/`
- **기술 스택**: Flask + SQLite3 + HTML/CSS/JS + openpyxl + pandas
- **포트**: 8080 (5000번 AirPlay 충돌 회피)

### 단가 구조 (7개 테이블)
| 계층 | 테이블 | 설명 |
|------|--------|------|
| 📊 내역단가 | `unit_cost_final` | 최종 설계 단가 (cost_source 추적) |
| 📋 일위대가 | `unit_cost_composite` | 복합단가 (composition_detail) |
| 📐 품셈단가 | `unit_cost_standard` | 표준 품셈 |
| 🏪 표준시장단가 | `unit_cost_market` | 시장 조사 |
| 📄 견적단가 | `unit_cost_quote` | 업체 견적 |
| 💰 물가정보지 | `unit_cost_price_info` | 자재 단가 (발행처/발행일) |
| 🔧 실정보고 | `unit_cost_field_report` | 현장 변경/이슈 |

**규칙**: 단가 추가 시 `skills/unit-cost-structure.md` 먼저 읽고 작업할 것

---

## 📁 스킬 파일 구조

```
~/.openclaw/workspace/
├── TOOLS.md — 인덱스 (이 파일)
├── MEMORY.md — 장기 기억
└── skills/
    ├── code-edit.md — 서버 파일 수정 워크플로우 (Claude 컨펌 필수)
    ├── web-search.md — 웹 검색 API
    ├── novel-brain.md — 소설 보조작가
    ├── amazon-server.md — 아마존 서버 정보
    ├── github-workflow.md — GitHub 배포 워크플로우
    ├── server-pull.sh — GitHub → 맥북 (서버 코드)
    ├── server-push.sh — 맥북 → GitHub (서버 코드)
    ├── server-deploy.sh — GitHub → 서버 배포 (Claude 컨펌 후에만)
    ├── agent-pull.sh — GitHub → 맥북 (메모리 파일)
    ├── agent-push.sh — 맥북 → GitHub (메모리 파일)
    ├── send_to_telegram.py — 텔레그램 파일 전송
    ├── tavily-api/ — 타빌리 검색 스킬
    └── backup/ — 구버전 파일 보관
```

---

이 파일은 인덱스입니다. 상세 내용은 각 스킬 파일을 참조하세요. 🐾
