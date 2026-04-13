#!/usr/bin/env python3
"""
파일 내용을 텔레그램으로 전송하는 스크립트
사용법: python3 send_to_telegram.py [파일경로]
"""

import sys
import requests

# ===== 설정 =====
BOT_TOKEN = "8555461248:AAFhPx0YnJ8-DLLzH0y-y4-wF7MiEYH_e7A"
CHAT_ID = "8024121053"
# ================

MAX_LENGTH = 4000  # 텔레그램 메시지 최대 길이

def send_message(text):
    """텔레그램으로 메시지 전송"""
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    try:
        resp = requests.post(url, json={"chat_id": CHAT_ID, "text": text})
        return resp.ok
    except Exception as e:
        print(f"전송 오류: {e}")
        return False

def send_file(filepath):
    """파일 내용을 텔레그램으로 전송"""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        print(f"파일을 찾을 수 없어요: {filepath}")
        return False
    except UnicodeDecodeError:
        try:
            with open(filepath, "r", encoding="cp949") as f:
                content = f.read()
        except:
            print(f"파일 인코딩 문제: {filepath}")
            return False

    # 파일명만 추출
    import os
    filename = os.path.basename(filepath)
    
    header = f"📄 {filename}\n{'─' * 30}\n"
    full_text = header + content

    # 4000자 초과 시 분할 전송
    chunks = [full_text[i:i+MAX_LENGTH] for i in range(0, len(full_text), MAX_LENGTH)]
    
    print(f"전송 중: {filename} ({len(chunks)}개 메시지)")
    
    for i, chunk in enumerate(chunks):
        prefix = f"[{i+1}/{len(chunks)}]\n" if len(chunks) > 1 else ""
        success = send_message(prefix + chunk)
        if not success:
            print(f"전송 실패: {i+1}번째 청크")
            return False
    
    print(f"✅ 전송 완료: {filename}")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("사용법: python3 send_to_telegram.py [파일경로1] [파일경로2] ...")
        print("예시: python3 send_to_telegram.py MEMORY.md TOOLS.md")
        sys.exit(1)

    all_success = True
    for filepath in sys.argv[1:]:
        if not send_file(filepath):
            all_success = False
    
    if all_success:
        print("🎉 모든 파일 전송 완료!")
    else:
        print("⚠️ 일부 파일 전송 실패")
        sys.exit(1)