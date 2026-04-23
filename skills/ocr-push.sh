#!/bin/bash

# ocr-push.sh - CM 현장 문서 OCR 프로젝트 변경사항 push
# 사용법: ./ocr-push.sh "커밋 메시지"

set -e  # 에러 발생 시 스크립트 중단

# 환경 변수 로드
if [ -f ~/.openclaw/workspace/.env ]; then
    source ~/.openclaw/workspace/.env
fi

# 작업 디렉토리
WORK_DIR="$HOME/.openclaw/workspace/construction-document-ocr"

# 커밋 메시지 확인
if [ $# -eq 0 ]; then
    echo "❌ 사용법: ./ocr-push.sh \"커밋 메시지\""
    echo "   예: ./ocr-push.sh \"Week1: UI 기본 구조 완성\""
    exit 1
fi

COMMIT_MSG="$1"

echo "=== CM 현장 문서 OCR 프로젝트 Push ==="
echo "작업 디렉토리: $WORK_DIR"
echo "커밋 메시지: $COMMIT_MSG"
echo ""

# 작업 디렉토리 존재 여부 확인
if [ ! -d "$WORK_DIR" ]; then
    echo "❌ 작업 디렉토리가 존재하지 않음: $WORK_DIR"
    echo "   먼저 ./ocr-pull.sh 로 레포지토리를 가져오세요"
    exit 1
fi

cd "$WORK_DIR"

# .git 디렉토리 확인
if [ ! -d ".git" ]; then
    echo "❌ Git 레포지토리가 아님: $WORK_DIR"
    echo "   올바른 디렉토리인지 확인하세요"
    exit 1
fi

# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
    echo "❌ Git 브랜치를 확인할 수 없음"
    exit 1
fi
echo "현재 브랜치: $CURRENT_BRANCH"

# 변경사항 확인
if [ -z "$(git status --porcelain)" ]; then
    echo "⚠️  커밋할 변경사항이 없습니다"
    echo "   파일을 수정한 후 다시 시도해주세요"
    exit 0
fi

echo "📋 변경사항 목록:"
git status --short

# 변경사항 스테이징
echo ""
echo "📦 변경사항 스테이징 중..."
if git add .; then
    echo "✅ 스테이징 완료"
else
    echo "❌ 스테이징 실패"
    exit 1
fi

# 커밋
echo ""
echo "💾 커밋 중..."
if git commit -m "$COMMIT_MSG"; then
    echo "✅ 커밋 완료"
    echo "   커밋 해시: $(git log --oneline -1 | cut -d' ' -f1)"
else
    echo "❌ 커밋 실패"
    echo "   가능한 원인:"
    echo "   1. 커밋 메시지가 비어있음"
    echo "   2. Git 사용자 설정 필요"
    exit 1
fi

# 원격 저장소 확인
REMOTE_EXISTS=$(git remote -v | grep -c origin)
if [ "$REMOTE_EXISTS" -eq 0 ]; then
    echo "❌ 원격 저장소(origin)가 설정되지 않음"
    echo "   git remote add origin https://github.com/DnielPark/construction-document-ocr.git"
    exit 1
fi

# Push
echo ""
echo "🚀 원격 저장소에 push 중..."
echo "   브랜치: $CURRENT_BRANCH -> origin/$CURRENT_BRANCH"

# GitHub 토큰으로 인증된 push
if [ -n "$GITHUB_TOKEN" ]; then
    echo "🔑 GitHub 토큰 인증 사용"
    # 원격 URL 업데이트 (토큰 포함)
    git remote set-url origin "https://${GITHUB_TOKEN}@github.com/DnielPark/construction-document-ocr.git"
fi

if git push origin "$CURRENT_BRANCH"; then
    echo "✅ Push 성공!"
else
    echo "❌ Push 실패!"
    echo "   가능한 원인:"
    echo "   1. 권한 없음 (비공개 레포)"
    echo "   2. 원격 브랜치와 충돌"
    echo "   3. 네트워크 문제"
    echo ""
    echo "   해결 방법:"
    echo "   1. git pull origin $CURRENT_BRANCH 으로 최신 버전 가져오기"
    echo "   2. 충돌 해결 후 다시 시도"
    exit 1
fi

echo ""
echo "📊 최종 상태:"
git log --oneline -2
echo ""
echo "✅ 작업 완료! 변경사항이 GitHub에 업로드되었습니다"