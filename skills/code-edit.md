# code-edit.md - 서버 파일 수정 워크플로우

## 핵심 원칙

서버 파일은 절대 직접 수정하지 않는다.
모든 수정은 GitHub를 경유하고, Claude 컨펌 없이 배포 금지.

---

## 수정 담당자 판단 기준

Claude가 수정 요청을 받으면 아래 기준으로 담당자를 결정한다.

### 대니얼이 수정하는 경우 — 파일 전체 교체
- 파일 구조가 크게 바뀌는 경우
- 새 기능 추가로 전체를 재작성하는 경우
- Claude가 전체 파일을 새로 작성해서 전달하는 경우

절차:
1. Claude가 전체 파일 내용 작성
2. 대니얼이 GitHub 에디터에서 전체 교체 후 저장
3. 대니얼이 결과물을 Claude에게 공유
4. Claude 검토 및 컨펌
5. 미르가 deploy.sh 실행

### 미르가 수정하는 경우 — 부분 수정
- 특정 함수, 변수, 섹션만 변경하는 경우
- 버그 수정, 텍스트 변경, 설정값 조정 등

절차:
1. Claude가 미르에게 부분 수정 지시문 작성
2. 미르가 github-pull.sh 실행 (최신 파일 다운로드)
3. 미르가 해당 부분만 수정
4. 미르가 github-push.sh 실행
5. 대니얼이 GitHub에서 수정된 파일 내용을 Claude에게 공유
6. Claude 검토 및 컨펌
7. 미르가 deploy.sh 실행

---

## Claude 컨펌 기준

컨펌 시 아래 항목을 반드시 확인한다.

- 요청한 수정 내용이 정확히 반영됐는지
- 의도하지 않은 부분이 변경되지 않았는지
- 기존 기능이 깨질 가능성이 있는지
- API 엔드포인트, 포트, 경로 등 핵심 설정값이 유지됐는지

컨펌 결과는 반드시 명시한다:
- ✅ 컨펌 — 배포 진행 가능
- ⚠️ 수정 필요 — 이유와 수정 내용 안내
- ❌ 롤백 필요 — 즉시 중단, 원인 분석

---

## 배포 전 체크리스트

미르는 아래 항목을 확인한 후에만 deploy.sh 실행.

- [ ] Claude 컨펌 받았는가
- [ ] github-pull.sh → 수정 → github-push.sh 순서를 지켰는가
- [ ] 배포 대상 파일이 맞는가

체크리스트 미완료 시 배포 금지.

---

## 롤백 절차

배포 후 문제 발생 시:

1. 미르가 즉시 대니얼에게 보고
2. Claude가 롤백 여부 판단
3. 롤백 결정 시:

editor.html 롤백:
cp ~/.openclaw/workspace/github-workspace/novel/editor.html.backup \
   ~/.openclaw/workspace/github-workspace/novel/editor.html
./github-push.sh "롤백 - editor.html.backup으로 복구"
./deploy.sh

기타 파일 롤백:
GitHub에서 이전 커밋 내용 확인 후 대니얼이 직접 복구.

---

## 절대 금지 사항

- Claude 컨펌 없이 deploy.sh 실행
- 서버에 SSH 접속해서 파일 직접 수정
- github-pull.sh 없이 수정 시작
- 대니얼이 코드 부분 수정 (전체 교체만 허용)
- 미르가 컨펌 전에 임의로 배포 진행

---

## 파일별 수정 주의사항

### file-api.js (포트 3001, PM2 관리)
- 수정 후 반드시 PM2 재시작 필요
- deploy.sh가 자동 처리하므로 별도 실행 불필요

### editor.html / editor.html.backup
- editor.html.backup은 45KB 원본. 절대 덮어쓰지 않음.
- editor.html만 수정 대상

### Nginx 설정
- 이 워크플로우 범위 밖. 수정 필요 시 별도 협의.

---

새 수정 요청이 오면 이 파일 기준으로 판단하고 진행할 것. 🐾
