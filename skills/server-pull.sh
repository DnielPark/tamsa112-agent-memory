#!/bin/bash

# github-pull.sh - GitHub 레포에서 파일을 맥북 로컬로 다운로드
# 사용법: ./github-pull.sh

set -e  # 에러 발생 시 스크립트 중단

# GitHub 설정
source ~/.openclaw/workspace/.env
REPO="DnielPark/tamsa112-novel-editor"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"

# 로컬 저장 경로
LOCAL_BASE="$HOME/.openclaw/workspace/github-workspace"

echo "=== GitHub에서 파일 다운로드 시작 ==="
echo "레포지토리: $REPO"
echo "브랜치: $BRANCH"
echo "로컬 저장 경로: $LOCAL_BASE"
echo ""

# 저장 경로 생성
mkdir -p "$LOCAL_BASE/novel"
mkdir -p "$LOCAL_BASE/nodeapp"

# 다운로드 카운터
SUCCESS=0
FAILED=0

# 다운로드 함수
download_file() {
    local remote_path="$1"
    local local_path="$LOCAL_BASE/$2"
    local url="$RAW_BASE/$remote_path"
    
    echo "다운로드 중: $remote_path"
    echo "  → $local_path"
    
    # 디렉토리 생성
    mkdir -p "$(dirname "$local_path")"
    
    # curl로 다운로드 (GitHub 토큰 사용)
    if curl -s -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3.raw" \
            -L "$url" \
            -o "$local_path"; then
        
        # 파일 크기 확인 (빈 파일 체크)
        if [ -s "$local_path" ]; then
            size=$(wc -c < "$local_path")
            lines=$(wc -l < "$local_path" 2>/dev/null || echo "N/A")
            echo "  ✅ 성공 ($size bytes, $lines lines)"
            ((SUCCESS++))
        else
            echo "  ⚠️  파일이 비어있음 (0 bytes)"
            ((FAILED++))
        fi
    else
        echo "  ❌ 실패"
        ((FAILED++))
    fi
    echo ""
}

# 각 파일 다운로드
download_file "novel/editor.html" "novel/editor.html"
download_file "novel/editor.html.backup" "novel/editor.html.backup"
download_file "novel/editor-api.js" "novel/editor-api.js"
download_file "novel/editor-ui.js" "novel/editor-ui.js"
download_file "novel/editor.css" "novel/editor.css"
download_file "novel/mobile-reader.html" "novel/mobile-reader.html"
download_file "nodeapp/file-api.js" "nodeapp/file-api.js"

# 결과 요약
echo "=== 다운로드 완료 ==="
echo "성공: $SUCCESS 파일"
echo "실패: $FAILED 파일"
echo ""

# 저장된 파일 목록 출력
echo "=== 저장된 파일 목록 ==="
find "$LOCAL_BASE" -type f -name "*.html" -o -name "*.js" -o -name "*.css" | while read file; do
    size=$(wc -c < "$file" 2>/dev/null | awk '{print $1}')
    lines=$(wc -l < "$file" 2>/dev/null | awk '{print $1}')
    printf "%-40s %10s bytes %6s lines\n" "$(basename "$file")" "$size" "$lines"
done | sort

echo ""
echo "총 파일 수: $(find "$LOCAL_BASE" -type f | wc -l)"
echo "총 용량: $(du -sh "$LOCAL_BASE" | cut -f1)"

# 실패한 파일이 있으면 경고
if [ $FAILED -gt 0 ]; then
    echo ""
    echo "⚠️  주의: $FAILED 개 파일 다운로드 실패"
    echo "GitHub 토큰이나 파일 경로를 확인하세요."
    exit 1
fi

echo ""
echo "✅ 모든 파일 다운로드 완료!"