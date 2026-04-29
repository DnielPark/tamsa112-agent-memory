#!/bin/bash
# cost-manager-push.sh
# 맥북 → GitHub: civil-cost-manager 변경사항 커밋 & 푸시
# 사용법: ./cost-manager-push.sh "커밋 메시지"

set -e

if [ -z "$1" ]; then
    echo "❌ 사용법: ./cost-manager-push.sh \"커밋 메시지\""
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
REPO_DIR="$WORKSPACE_DIR/civil-cost-manager"

if [ ! -d "$REPO_DIR/.git" ]; then
    echo "❌ $REPO_DIR 에 Git 레포지토리가 없습니다."
    echo "   먼저 ./cost-manager-pull.sh 를 실행하세요."
    exit 1
fi

cd "$REPO_DIR"

echo "📦 변경사항 확인 중..."
git add -A

if git diff --cached --quiet; then
    echo "ℹ️  변경사항 없음"
    exit 0
fi

git commit -m "$1"
git push origin main

echo "✅ 푸시 완료: $1"
