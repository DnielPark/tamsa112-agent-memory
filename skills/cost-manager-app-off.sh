#!/bin/bash
# cost-manager-app-off.sh
# Civil Cost Manager Flask 서버 중지
# 사용법: ./cost-manager-app-off.sh

PORT=8080

echo "🛑 서버 중지 중..."

# PID 파일로 종료
if [ -f /tmp/civil-cost-manager.pid ]; then
    PID=$(cat /tmp/civil-cost-manager.pid)
    if kill -0 $PID 2>/dev/null; then
        kill $PID 2>/dev/null
        echo "✅ 서버 중지됨 (PID: $PID)"
    else
        echo "ℹ️  이미 종료된 프로세스입니다."
    fi
    rm -f /tmp/civil-cost-manager.pid
fi

# 혹시 남아있으면 포트 기준으로 정리
PID=$(lsof -ti :$PORT 2>/dev/null)
if [ -n "$PID" ]; then
    kill -9 $PID 2>/dev/null
    echo "✅ 포트 $PORT 프로세스 강제 종료 (PID: $PID)"
fi

echo "🛑 서버 완전히 중지됨"
