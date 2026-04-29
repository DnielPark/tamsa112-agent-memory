#!/bin/bash
# cost-manager-pull.sh
# GitHub → 맥북: civil-cost-manager 레포 최신 코드 가져오기
# 사용법: ./cost-manager-pull.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

# .env에서 GitHub 토큰 로드
source "$WORKSPACE_DIR/.env" 2>/dev/null || {
    echo "❌ .env 파일을 찾을 수 없습니다."
    exit 1
}

REPO_DIR="$WORKSPACE_DIR/civil-cost-manager"
REPO_URL="https://DnielPark:${GITHUB_TOKEN}@github.com/DnielPark/civil-cost-manager.git"

echo "📦 civil-cost-manager 레포 동기화 중..."

if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR"
    git pull origin main
    echo "✅ 업데이트 완료"
else
    echo "📁 로컬에 없음. 클론 시작..."
    git clone "$REPO_URL" "$REPO_DIR"
    echo "✅ 클론 완료"
fi

echo "📂 위치: $REPO_DIR"
