#!/bin/bash

# deploy.sh - GitHub에서 아마존 서버로 파일 배포
# 사용법: ./deploy.sh

set -e  # 에러 발생 시 스크립트 중단

# GitHub 설정
source ~/.openclaw/workspace/.env
REPO="DnielPark/tamsa112-novel-editor"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"

# 서버 설정
SSH_KEY="$HOME/.ssh/my-key1.pem"
SERVER="admin@43.200.251.19"

echo "=== 아마존 서버 배포 시작 ==="
echo "GitHub 레포: $REPO"
echo "서버: $SERVER"
echo "SSH 키: $SSH_KEY"
echo ""

# 배포 카운터
SUCCESS=0
FAILED=0
NODEAPP_DEPLOYED=false

# 배포 함수
deploy_file() {
    local github_path="$1"
    local server_path="$2"
    local url="$RAW_BASE/$github_path"
    
    echo "배포 중: $github_path"
    echo "  → $server_path"
    
    # 서버에서 curl으로 직접 다운로드
    SSH_CMD="curl -s \
             -H \"Authorization: token $GITHUB_TOKEN\" \
             -H \"Accept: application/vnd.github.v3.raw\" \
             -L \"$url\" \
             -o /tmp/downloaded_file"
    
    if ssh -i "$SSH_KEY" "$SERVER" "$SSH_CMD"; then
        # 파일 크기 확인
        SIZE_CMD="stat -c%s /tmp/downloaded_file 2>/dev/null || wc -c < /tmp/downloaded_file"
        file_size=$(ssh -i "$SSH_KEY" "$SERVER" "$SIZE_CMD")
        
        if [ "$file_size" -gt 0 ]; then
            # 파일 이동 및 권한 설정
            MOVE_CMD="sudo cp /tmp/downloaded_file \"$server_path\" && \
                      sudo chown www-data:www-data \"$server_path\" && \
                      rm -f /tmp/downloaded_file"
            
            if ssh -i "$SSH_KEY" "$SERVER" "$MOVE_CMD"; then
                echo "  ✅ 성공 ($file_size bytes)"
                ((SUCCESS++))
                
                # nodeapp 파일 배포 여부 확인
                if [[ "$github_path" == nodeapp/* ]]; then
                    NODEAPP_DEPLOYED=true
                fi
            else
                echo "  ❌ 파일 이동 실패"
                ((FAILED++))
            fi
        else
            echo "  ❌ 다운로드된 파일이 비어있음 (0 bytes)"
            ((FAILED++))
        fi
    else
        echo "  ❌ 다운로드 실패"
        cat /tmp/wget_output
        ((FAILED++))
    fi
    echo ""
}

# 각 파일 배포
deploy_file "novel/editor.html" "/var/www/html/novel/editor.html"
deploy_file "novel/editor.html.backup" "/var/www/html/novel/editor.html.backup"
deploy_file "novel/editor-api.js" "/var/www/html/novel/editor-api.js"
deploy_file "novel/editor-ui.js" "/var/www/html/novel/editor-ui.js"
deploy_file "novel/editor.css" "/var/www/html/novel/editor.css"
deploy_file "novel/mobile-reader.html" "/var/www/html/novel/mobile-reader.html"
deploy_file "nodeapp/file-api.js" "/var/www/nodeapp/file-api.js"

# Nginx 재시작
echo "=== 서비스 관리 ==="
echo "Nginx 재시작 중..."
if ssh -i "$SSH_KEY" "$SERVER" "sudo systemctl restart nginx"; then
    echo "✅ Nginx 재시작 완료"
else
    echo "❌ Nginx 재시작 실패"
    ((FAILED++))
fi

# file-api PM2 재시작 (nodeapp 파일 배포 시에만)
if [ "$NODEAPP_DEPLOYED" = true ]; then
    echo ""
    echo "Node.js 앱 배포 감지됨"
    echo "PM2 재시작 중..."
    
    if ssh -i "$SSH_KEY" "$SERVER" "pm2 restart file-api"; then
        echo "✅ file-api PM2 재시작 완료"
    else
        echo "❌ file-api PM2 재시작 실패"
        ((FAILED++))
    fi
else
    echo ""
    echo "Node.js 앱 변경 없음 - PM2 재시작 생략"
fi

# 결과 요약
echo ""
echo "=== 배포 완료 ==="
echo "성공: $SUCCESS 파일"
echo "실패: $FAILED 파일"

# 배포된 파일 목록 출력
echo ""
echo "=== 배포된 파일 상태 ==="
for github_path in "${!DEPLOY_MAP[@]}"; do
    server_path="${DEPLOY_MAP[$github_path]}"
    SIZE_CMD="stat -c%s \"$server_path\" 2>/dev/null || echo 0"
    file_size=$(ssh -i "$SSH_KEY" "$SERVER" "$SIZE_CMD" 2>/dev/null || echo "N/A")
    
    if [ "$file_size" != "0" ] && [ "$file_size" != "N/A" ]; then
        status="✅"
    else
        status="❌"
    fi
    
    printf "%-40s %10s bytes %s\n" "$(basename "$server_path")" "$file_size" "$status"
done

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "⚠️  주의: $FAILED 개 파일 배포 실패"
    exit 1
fi

echo ""
echo "✅ 모든 배포 작업 완료!"