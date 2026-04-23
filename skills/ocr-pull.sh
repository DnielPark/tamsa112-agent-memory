#!/bin/bash

# ocr-pull.sh - CM 현장 문서 OCR 프로젝트 GitHub에서 pull
# 사용법: ./ocr-pull.sh

set -e  # 에러 발생 시 스크립트 중단

# 환경 변수 로드
if [ -f ~/.openclaw/workspace/.env ]; then
    source ~/.openclaw/workspace/.env
fi

# 작업 디렉토리
WORK_DIR="$HOME/.openclaw/workspace/construction-document-ocr"
REPO_URL="https://github.com/DnielPark/construction-document-ocr.git"

echo "=== CM 현장 문서 OCR 프로젝트 Pull ==="
echo "작업 디렉토리: $WORK_DIR"
echo "레포지토리: $REPO_URL"
echo ""

# 작업 디렉토리로 이동
cd "$HOME/.openclaw/workspace"

# 디렉토리 존재 여부 확인
if [ -d "$WORK_DIR/.git" ]; then
    echo "✅ 기존 레포지토리 발견. 최신 변경사항 pull 중..."
    cd "$WORK_DIR"
    
    # 현재 브랜치 확인
    CURRENT_BRANCH=$(git branch --show-current)
    echo "현재 브랜치: $CURRENT_BRANCH"
    
    # 변경사항 stash (로컬 수정사항 임시 저장)
    if [ -n "$(git status --porcelain)" ]; then
        echo "⚠️  로컬 변경사항 발견. stash 중..."
        git stash push -m "Auto-stash before pull $(date '+%Y-%m-%d %H:%M:%S')"
        STASHED=true
    fi
    
    # pull 실행
    if git pull origin "$CURRENT_BRANCH"; then
        echo "✅ Pull 성공!"
        
        # stash한 변경사항 복원
        if [ "$STASHED" = true ]; then
            echo "🔄 stash된 변경사항 복원 중..."
            if git stash pop; then
                echo "✅ 변경사항 복원 완료"
            else
                echo "⚠️  변경사항 복원 중 충돌 발생. 수동 해결 필요"
                echo "   git stash list 로 확인 후 git stash pop --index 로 시도해보세요"
            fi
        fi
    else
        echo "❌ Pull 실패!"
        echo "   충돌이 발생했을 수 있습니다. 수동으로 해결해주세요:"
        echo "   cd $WORK_DIR"
        echo "   git status"
        exit 1
    fi
    
else
    echo "📥 레포지토리 클론 중..."
    
    # 부모 디렉토리로 이동
    cd "$HOME/.openclaw/workspace"
    
    # 이미 디렉토리가 있지만 .git이 없는 경우
    if [ -d "$WORK_DIR" ]; then
        echo "⚠️  디렉토리 존재 but .git 없음. 백업 후 클론..."
        BACKUP_DIR="${WORK_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
        mv "$WORK_DIR" "$BACKUP_DIR"
        echo "   기존 디렉토리 백업: $BACKUP_DIR"
    fi
    
    # GitHub 토큰으로 인증된 URL 사용
    if [ -n "$GITHUB_TOKEN" ]; then
        AUTH_REPO_URL="https://${GITHUB_TOKEN}@github.com/DnielPark/construction-document-ocr.git"
        echo "🔑 GitHub 토큰 인증 사용"
    else
        AUTH_REPO_URL="$REPO_URL"
        echo "⚠️  GitHub 토큰 없음. 공개 레포거나 수동 인증 필요"
    fi
    
    # 클론 실행
    if git clone "$AUTH_REPO_URL" "$WORK_DIR"; then
        echo "✅ 클론 성공!"
        echo "   디렉토리: $WORK_DIR"
    else
        echo "❌ 클론 실패!"
        echo "   가능한 원인:"
        echo "   1. 레포지토리가 존재하지 않음"
        echo "   2. 접근 권한 없음 (비공개 레포)"
        echo "   3. 네트워크 문제"
        echo "   수동 확인: $REPO_URL"
        exit 1
    fi
fi

echo ""
echo "📊 최종 상태:"
cd "$WORK_DIR"
git log --oneline -3
echo ""
echo "✅ 작업 완료! 디렉토리: $WORK_DIR"