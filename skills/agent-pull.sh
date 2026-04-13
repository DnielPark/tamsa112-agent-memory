#!/bin/bash

# agent-pull.sh - 에이전트 메모리 파일 GitHub에서 맥북으로 다운로드
# 사용법: ./agent-pull.sh

set -e  # 에러 발생 시 스크립트 중단

# GitHub 설정
source ~/.openclaw/workspace/.env
REPO="DnielPark/tamsa112-agent-memory"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"

# 다운로드 대상 파일 목록
declare -a FILES_TO_DOWNLOAD=(
    "MEMORY.md"
    "TOOLS.md"
)

# GitHub 레포에서 skills/ 폴더 파일 목록 가져오기
SKILLS_FILES=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO/contents/skills" | \
    python3 -c "
import sys,json
data=json.load(sys.stdin)
for item in data:
    if item['type'] == 'file' and (item['name'].endswith('.md') or item['name'].endswith('.py')):
        print('skills/' + item['name'])
" 2>/dev/null || echo "")

# skills 파일 목록 추가
if [ -n "$SKILLS_FILES" ]; then
    while IFS= read -r skill_file; do
        if [ -n "$skill_file" ]; then
            FILES_TO_DOWNLOAD+=("$skill_file")
        fi
    done <<< "$SKILLS_FILES"
fi

echo "=== 에이전트 메모리 파일 다운로드 시작 ==="
echo "레포지토리: $REPO"
echo "브랜치: $BRANCH"
echo ""

SUCCESS=0
FAILED=0
TOTAL_SIZE=0
TOTAL_LINES=0

# 각 파일 다운로드
for relative_path in "${FILES_TO_DOWNLOAD[@]}"; do
    filename=$(basename "$relative_path")
    
    # 로컬 저장 경로 결정
    if [[ "$relative_path" == skills/* ]]; then
        local_file="$HOME/.openclaw/workspace/$relative_path"
    else
        local_file="$HOME/.openclaw/workspace/$relative_path"
    fi
    
    # 디렉토리 생성
    mkdir -p "$(dirname "$local_file")"
    
    echo "다운로드 중: $relative_path"
    echo "  → $local_file"
    
    # GitHub에서 파일 다운로드
    if curl -s -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3.raw" \
        -o "$local_file" \
        "$RAW_BASE/$relative_path" 2>/dev/null; then
        
        # 파일 정보 확인
        if [ -s "$local_file" ]; then
            file_size=$(wc -c < "$local_file" | tr -d ' ')
            file_lines=$(wc -l < "$local_file" | tr -d ' ')
            TOTAL_SIZE=$((TOTAL_SIZE + file_size))
            TOTAL_LINES=$((TOTAL_LINES + file_lines))
            
            echo "  ✅ 성공 (    $file_size bytes,      $file_lines lines)"
            ((SUCCESS++))
        else
            echo "  ⚠️  경고: 빈 파일"
            ((SUCCESS++))
        fi
    else
        echo "  ❌ 실패: 다운로드 오류"
        ((FAILED++))
    fi
done

echo ""
echo "=== 다운로드 완료 ==="
echo "성공: $SUCCESS 파일"
echo "실패: $FAILED 파일"
echo ""

# 저장된 파일 목록 출력
echo "=== 저장된 파일 목록 ==="
for relative_path in "${FILES_TO_DOWNLOAD[@]}"; do
    if [[ "$relative_path" == skills/* ]]; then
        local_file="$HOME/.openclaw/workspace/$relative_path"
    else
        local_file="$HOME/.openclaw/workspace/$relative_path"
    fi
    
    if [ -f "$local_file" ]; then
        file_size=$(wc -c < "$local_file" | tr -d ' ')
        file_lines=$(wc -l < "$local_file" | tr -d ' ')
        printf "%-30s %10s bytes %8s lines\n" "$relative_path" "$file_size" "$file_lines"
    fi
done

echo ""
echo "총 파일 수:        $SUCCESS"
echo "총 용량: $(numfmt --to=iec $TOTAL_SIZE)"
echo "총 줄 수: $TOTAL_LINES"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ 모든 파일 다운로드 완료!"
else
    echo "⚠️  주의: $FAILED 개 파일 다운로드 실패"
    exit 1
fi