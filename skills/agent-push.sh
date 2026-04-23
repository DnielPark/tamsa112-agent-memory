#!/bin/bash

# agent-push.sh - 에이전트 메모리 파일 맥북에서 GitHub으로 업로드
# 사용법: ./agent-push.sh "커밋 메시지"

set -e  # 에러 발생 시 스크립트 중단

# GitHub 설정
source ~/.openclaw/workspace/.env
REPO="DnielPark/tamsa112-agent-memory"
BRANCH="main"
API_BASE="https://api.github.com/repos/$REPO/contents"

# 커밋 메시지 설정
if [ -z "$1" ]; then
    COMMIT_MSG="에이전트 메모리 업데이트 $(date '+%Y-%m-%d %H:%M')"
else
    COMMIT_MSG="$1"
fi

# 업로드 대상 파일 목록 (로컬 경로 → GitHub 경로)
# macOS bash 3.2 호환을 위해 배열 2개 사용
LOCAL_FILES=(
    "$HOME/.openclaw/workspace/AGENTS.md"
    "$HOME/.openclaw/workspace/MEMORY.md"
    "$HOME/.openclaw/workspace/TOOLS.md"
)

GITHUB_PATHS=(
    "AGENTS.md"
    "MEMORY.md"
    "TOOLS.md"
)

# skills/ 폴더의 모든 .md 파일과 .py 파일 추가
for file in "$HOME/.openclaw/workspace/skills"/*.md "$HOME/.openclaw/workspace/skills"/*.py; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        LOCAL_FILES+=("$file")
        GITHUB_PATHS+=("skills/$filename")
    fi
done

# skills/ 폴더의 모든 .sh 파일 추가
for file in "$HOME/.openclaw/workspace/skills"/*.sh; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        LOCAL_FILES+=("$file")
        GITHUB_PATHS+=("skills/$filename")
    fi
done

echo "=== 에이전트 메모리 파일 업로드 시작 ==="
echo "레포지토리: $REPO"
echo "브랜치: $BRANCH"
echo "커밋 메시지: $COMMIT_MSG"
echo ""

SUCCESS=0
FAILED=0
COMMIT_SHA=""

# 각 파일 업로드
for i in "${!LOCAL_FILES[@]}"; do
    local_file="${LOCAL_FILES[$i]}"
    relative_path="${GITHUB_PATHS[$i]}"
    api_path="$API_BASE/$relative_path"
    
    echo "업로드 중: $relative_path"
    
    # 파일 존재 확인
    if [ ! -f "$local_file" ]; then
        echo "  ❌ 실패: 로컬 파일 없음 - $local_file"
        ((FAILED++))
        continue
    fi
    
    # 파일 내용 Base64 인코딩
    if CONTENT_B64=$(base64 < "$local_file" 2>/dev/null); then
        # 기존 파일 SHA 확인 (업데이트용)
        SHA_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "$api_path?ref=$BRANCH" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('sha', ''))" 2>/dev/null || echo "")
        
        # JSON 데이터 준비
        if [ -n "$SHA_RESPONSE" ]; then
            JSON_DATA="{\"message\":\"$COMMIT_MSG\",\"content\":\"$CONTENT_B64\",\"sha\":\"$SHA_RESPONSE\",\"branch\":\"$BRANCH\"}"
            echo "  📝 기존 파일 업데이트 (SHA: ${SHA_RESPONSE:0:8}...)"
        else
            JSON_DATA="{\"message\":\"$COMMIT_MSG\",\"content\":\"$CONTENT_B64\",\"branch\":\"$BRANCH\"}"
            echo "  📄 새 파일 생성"
        fi
        
        # GitHub API 호출
        RESPONSE=$(curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/json" \
            -H "Accept: application/vnd.github.v3+json" \
            -d "$JSON_DATA" \
            "$api_path")
        
        # 응답 파싱
        NEW_SHA=$(echo "$RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('content', {}).get('sha', ''))" 2>/dev/null || echo "")
        
        if [ -n "$NEW_SHA" ]; then
            echo "  ✅ 성공 (SHA: ${NEW_SHA:0:8}...)"
            COMMIT_SHA="$NEW_SHA"
            ((SUCCESS++))
        else
            ERROR_MSG=$(echo "$RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('message', '알 수 없는 오류'))" 2>/dev/null || echo "응답 파싱 실패")
            
            # 보안 규칙 위반 감지 시 특별 처리
            if echo "$ERROR_MSG" | grep -q "Repository rule violations found"; then
                echo "  ⚠️  보안 규칙 위반: 파일 내용 검토 필요"
                echo "     힌트: GitHub 토큰, SSH 키, 비밀번호 등 확인"
            fi
            
            echo "  ❌ 실패: $ERROR_MSG"
            ((FAILED++))
        fi
    else
        echo "  ❌ 실패: Base64 인코딩 실패"
        ((FAILED++))
    fi
done

echo ""
echo "=== 업로드 완료 ==="
echo "성공: $SUCCESS 파일"
echo "실패: $FAILED 파일"

if [ -n "$COMMIT_SHA" ]; then
    echo "최종 커밋 SHA: $COMMIT_SHA"
fi

echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ 모든 파일 업로드 완료!"
    echo "📁 레포지토리: https://github.com/$REPO"
else
    echo "⚠️  주의: $FAILED 개 파일 업로드 실패"
    exit 1
fi