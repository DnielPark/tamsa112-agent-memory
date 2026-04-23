#!/bin/bash

# github-push.sh - 맥북 로컬에서 수정한 파일을 GitHub에 push
# 사용법: ./github-push.sh "커밋 메시지"

set -e  # 에러 발생 시 스크립트 중단

# GitHub 설정
source ~/.openclaw/workspace/.env
REPO="DnielPark/tamsa112-novel-editor"
BRANCH="main"
API_BASE="https://api.github.com/repos/$REPO/contents"

# 로컬 작업 경로
LOCAL_BASE="$HOME/.openclaw/workspace/github-workspace"

# 커밋 메시지 설정
if [ -z "$1" ]; then
    COMMIT_MSG="update $(date '+%Y-%m-%d %H:%M')"
else
    COMMIT_MSG="$1"
fi

echo "=== GitHub에 파일 업로드 시작 ==="
echo "레포지토리: $REPO"
echo "브랜치: $BRANCH"
echo "커밋 메시지: $COMMIT_MSG"
echo "로컬 경로: $LOCAL_BASE"
echo ""

# 업로드할 파일 목록 찾기
echo "업로드할 파일 검색 중..."
FILES_TO_UPLOAD=()

# HTML 파일
for file in "$LOCAL_BASE"/novel/*.html "$LOCAL_BASE"/novel/*.backup; do
    if [ -f "$file" ]; then
        FILES_TO_UPLOAD+=("$file")
    fi
done

# JavaScript 파일
for file in "$LOCAL_BASE"/novel/*.js "$LOCAL_BASE"/nodeapp/*.js; do
    if [ -f "$file" ]; then
        FILES_TO_UPLOAD+=("$file")
    fi
done

# CSS 파일
for file in "$LOCAL_BASE"/novel/*.css; do
    if [ -f "$file" ]; then
        FILES_TO_UPLOAD+=("$file")
    fi
done

# MD 파일 (문서) - github-workspace/ 루트 및 하위 폴더
find "$LOCAL_BASE" -name "*.md" -type f | while read -r file; do
    # novel/ 폴더의 .md 파일은 제외 (소설 파일들)
    if [[ "$file" != *"/novel/"* ]] || [[ "$file" == *"/novel/workflow-test.md" ]] || [[ "$file" == *"/novel/push-test.md" ]]; then
        FILES_TO_UPLOAD+=("$file")
    fi
done

if [ ${#FILES_TO_UPLOAD[@]} -eq 0 ]; then
    echo "⚠️  업로드할 파일이 없습니다."
    exit 0
fi

echo "발견된 파일: ${#FILES_TO_UPLOAD[@]}개"
echo ""

# 각 파일 업로드
SUCCESS=0
FAILED=0
COMMIT_SHA=""

for local_file in "${FILES_TO_UPLOAD[@]}"; do
    # 로컬 경로에서 상대 경로 계산
    relative_path="${local_file#$LOCAL_BASE/}"
    
    # GitHub API 경로
    api_path="$API_BASE/$relative_path"
    
    echo "업로드 중: $relative_path"
    
    # 파일 내용 Base64 인코딩
    if CONTENT_B64=$(base64 < "$local_file" 2>/dev/null); then
        # 기존 파일 SHA 확인 (업데이트용)
        SHA_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "$api_path?ref=$BRANCH" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('sha', ''))" 2>/dev/null || echo "")
        
        # JSON 데이터 준비
        if [ -n "$SHA_RESPONSE" ]; then
            # 기존 파일 업데이트
            JSON_DATA="{\"message\":\"$COMMIT_MSG\",\"content\":\"$CONTENT_B64\",\"sha\":\"$SHA_RESPONSE\",\"branch\":\"$BRANCH\"}"
            echo "  📝 기존 파일 업데이트 (SHA: ${SHA_RESPONSE:0:8}...)"
        else
            # 새 파일 생성
            JSON_DATA="{\"message\":\"$COMMIT_MSG\",\"content\":\"$CONTENT_B64\",\"branch\":\"$BRANCH\"}"
            echo "  📄 새 파일 생성"
        fi
        
        # GitHub API 호출
        RESPONSE=$(curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/json" \
            -H "Accept: application/vnd.github.v3+json" \
            -d "$JSON_DATA" \
            "$api_path")
        
        # 응답에서 SHA 추출
        NEW_SHA=$(echo "$RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('content', {}).get('sha', ''))" 2>/dev/null || echo "")
        
        if [ -n "$NEW_SHA" ]; then
            echo "  ✅ 성공 (SHA: ${NEW_SHA:0:8}...)"
            COMMIT_SHA="$NEW_SHA"
            ((SUCCESS++))
        else
            ERROR_MSG=$(echo "$RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('message', '알 수 없는 오류'))" 2>/dev/null || echo "응답 파싱 실패")
            echo "  ❌ 실패: $ERROR_MSG"
            ((FAILED++))
        fi
    else
        echo "  ❌ 파일 인코딩 실패"
        ((FAILED++))
    fi
    echo ""
done

# 결과 요약
echo "=== 업로드 완료 ==="
echo "성공: $SUCCESS 파일"
echo "실패: $FAILED 파일"

if [ -n "$COMMIT_SHA" ]; then
    echo "최종 커밋 SHA: $COMMIT_SHA"
fi

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "⚠️  주의: $FAILED 개 파일 업로드 실패"
    exit 1
fi

echo ""
echo "✅ 모든 파일 업로드 완료!"