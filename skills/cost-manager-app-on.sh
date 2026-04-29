#!/bin/bash
# cost-manager-app-on.sh
# Civil Cost Manager Flask 서버 시작
# 사용법: ./cost-manager-app-on.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
APP_DIR="$WORKSPACE_DIR/civil-cost-manager"
PORT=8080

# 이미 실행 중인지 확인
if lsof -i :$PORT -P 2>/dev/null | grep -q LISTEN; then
    echo "⚠️  포트 $PORT 에서 이미 서버가 실행 중입니다."
    lsof -i :$PORT -P 2>/dev/null | grep LISTEN
    echo "재시작하려면 먼저 ./cost-manager-app-off.sh 를 실행하세요."
    exit 0
fi

cd "$APP_DIR"

# venv 확인
if [ ! -d "venv" ]; then
    echo "📦 venv 생성 중..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt -q
else
    source venv/bin/activate
fi

echo "🚀 Flask 서버 시작 중... (포트 $PORT)"
echo "   http://localhost:$PORT"
nohup python app.py > /tmp/civil-cost-manager.log 2>&1 &
echo $! > /tmp/civil-cost-manager.pid

sleep 2

if lsof -i :$PORT -P 2>/dev/null | grep -q LISTEN; then
    echo "✅ 서버 실행 중: http://localhost:$PORT"
else
    echo "❌ 서버 시작 실패. 로그 확인: cat /tmp/civil-cost-manager.log"
fi
