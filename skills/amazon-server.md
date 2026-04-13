# amazon-server.md - 아마존 서버 (AWS Lightsail)

## 서버 기본 정보

- 인스턴스: AWS Lightsail (서울 ap-northeast-2)
- OS: Debian 12 (Bookworm)
- 퍼블릭 IP: 43.200.251.19
- 프라이빗 IP: 172.26.0.203
- 도메인: tamsa112.com (HTTPS)
- 사용자명: admin
- SSH 키 경로: ~/.ssh/my-key1.pem
- 생성일: 2026-04-09
- 상태: 운영 중

---

## 접속 정보

- 메인 페이지: https://tamsa112.com (공개)
- 편집기: https://tamsa112.com/novel/editor.html (Nginx 기본 인증)
- 모바일 뷰어: https://tamsa112.com/novel/mobile-reader.html (Nginx 기본 인증)
- 로그인 ID: daeho1001@nate.com
- 비밀번호: 100100

---

## 인증 구조

- index.html — 인증 없음 (공개)
- /novel/* — Nginx 기본 인증 (브라우저 팝업)
- /api/* — Nginx 기본 인증
- 인증 파일: /etc/nginx/.htpasswd

---

## 네트워크 규칙

- SSH TCP 22 — 모든 IP 허용
- HTTP TCP 80 — 모든 IP 허용 (HTTPS 자동 리다이렉트)
- HTTPS TCP 443 — 모든 IP 허용

---

## SSL 인증서

- 발급기관: Let's Encrypt
- 발급일: 2026-04-08
- 만료일: 2026-07-08
- 자동 갱신: Certbot 설정됨

---

## 서비스 구성

- Nginx: 포트 80/443, HTTPS 강제 + 기본 인증 + 리버스 프록시
- file-api (PM2, 포트 3001): 파일 관리 REST API — 정상 운영 중
- node-app (PM2, 포트 3000): 테스트 서버 — 에러 상태 (우선순위 낮음)

---

## 파일 구조

### 정적 파일 (Nginx 서빙)

```
/var/www/html/
├── index.html
└── novel/
    ├── editor.html         — 편집기 (현재 미작동, 전면 개편 예정)
    ├── editor.html.backup  — 원본 단일 파일 45KB (기준점)
    ├── editor-api.js
    ├── editor-ui.js
    ├── editor.css
    ├── mobile-reader.html
    └── chapter1.md
```

### Node.js 애플리케이션

```
/var/www/nodeapp/
├── file-api.js  — 파일 관리 API (포트 3001, 정상)
└── server.js    — 테스트 서버 (포트 3000, 에러 상태)
```

### 소설 파일 저장소

```
/var/www/novel-files/  — 마크다운 파일 저장소
├── 루트 파일 다수
├── 등장인물/
├── 세계관/
├── 소설/1부/
├── 소설/2부/
└── 작가노트/
```

---

## API 엔드포인트 (file-api.js, 포트 3001)

### 폴더 관리

- GET /api/folders — 폴더 트리 반환
- POST /api/folders/create — 폴더 생성
- DELETE /api/folders/delete — 폴더 삭제 (빈 폴더만)

### 파일 관리

- GET /api/files — 경로별 파일 목록
- POST /api/files/create — 새 파일 생성
- POST /api/files/save — 파일 저장
- DELETE /api/files/delete — 파일 삭제
- POST /api/files/rename — 파일 이름 변경

### 시스템

- POST /api/system/edit-file — 시스템 파일 수정 (자동 백업)

---

## 서비스 관리 명령어

### Nginx

```bash
sudo systemctl status nginx
sudo systemctl restart nginx
sudo nginx -t
sudo tail -f /var/log/nginx/error.log
```

### PM2

```bash
pm2 list
pm2 logs file-api --lines 50
pm2 restart file-api
```

### 파일 권한

```bash
sudo chown -R www-data:www-data /var/www/html/
sudo chown -R admin:admin /var/www/nodeapp/
sudo chown -R admin:admin /var/www/novel-files/
```

---

## 미해결 문제

- node-app PM2 에러 상태 — 우선순위 낮음
- editor.html 분리 버전 미작동 — 전면 개편 예정
- favicon.ico 누락 — Nginx 로그 404 경고

---

## 배포 워크플로우

서버 직접 수정 금지. 항상 github-workflow.md 참조.

```
./github-pull.sh → 코드 수정 → ./github-push.sh → ./deploy.sh
```

---

**변경사항 발생 시 업데이트할 것.** 🐾
