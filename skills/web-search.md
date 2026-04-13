# 웹 검색 API

## 타빌리 API (기본 사용)
외부 인터넷 검색: `~/.openclaw/workspace/skills/tavily-api/` 폴더 내 SKILL.md 읽고 실행.

### 간단한 사용법
```bash
cd ~/.openclaw/workspace/skills/tavily-api
python3 simple_search.py "검색어"
```

### 고급 사용법
```bash
cd ~/.openclaw/workspace/skills/tavily-api
python3 scripts/tavily_search.py search "검색어" --max-results 5 --include-answer
```

### 장점
- 카드 등록 불필요
- 한국어 검색 품질 우수
- 이미 검증된 성능 (뉴스, 주소 검색 등)
- simple_search.py (curl 기반)와 scripts/tavily_search.py (Python SDK) 두 가지 옵션

### 타빌리 고급검색 가능 세부 사항은 타빌리 스킬 폴더 내 SKILL.md 참조

### 빠른 참조
- 스킬 경로: `~/.openclaw/workspace/skills/tavily-api/`
- 기본 스크립트: `simple_search.py`
- 고급 스크립트: `scripts/tavily_search.py`
- API 키: 이미 포함됨 (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)

## 브레이브 API (대체 옵션)
- **URL**: https://brave.com/search/api/
- **특징**: 카드 등록 필수, 월 2,000회 무료
- **설정 명령**: `openclaw configure --section web`
- **환경 변수**: `BRAVE_API_KEY`

**URL 검색(web_fetch)은 비상시 작동** - 타빌리 API에 문제 있을 때 대체 수단

---

## ⚠️ 중요 교훈: 검색어 언어 전략

### **2026년 3월 22일 학습: 현지 언어 검색의 중요성**

**문제 상황:**
- 파키스탄·UAE 현지 뉴스 검색 시 **영어만 사용**
- **결과**: 현지 언어(우르두어, 아랍어) 자료 누락
- **영향**: 현지 시각과 생생한 정보 접근 불가

### **검색어 언어 전략:**

#### **1. 다중 언어 검색 원칙**
- **1차**: 현지 언어 검색 (가능한 경우)
- **2차**: 영어 검색 (국제 매체)
- **3차**: 한국어 검색 (국내 매체 번역)

#### **2. 지역별 권장 검색 언어**

**중동 지역:**
- **아랍어**: `"الجيش الأمريكي"` (미군), `"إيران"` (이란)
- **영어**: `"US military Iran"`, `"Gulf news"`
- **한국어**: `"미군 중동 뉴스"`

**남아시아 지역:**
- **우르두어(파키스탄)**: `"امریکی فوج"` (미군)
- **힌디어(인도)**: `"अमेरिकी सेना"` (미군)
- **영어**: `"Pakistan US military"`
- **한국어**: `"파키스탄 미군"`

**동아시아 지역:**
- **중국어**: `"美军"` (미군), `"伊朗"` (이란)
- **일본어**: `"米軍"` (미군), `"イラン"` (이란)
- **한국어**: `"미군"`, `"이란"`

#### **3. 검색 도구별 언어 지원**

**타빌리 API:**
- ✅ **한국어 우수**: 한국어 검색 품질 좋음
- ⚠️ **다국어 제한**: 아랍어·우르두어 직접 검색 불확실
- **전략**: 영어 키워드 + 지역명 조합

**브레이브 API:**
- ✅ **다국어 지원**: 다양한 언어 검색 가능
- ⚠️ **지역 제한**: 국가 코드 제한 있음 (AE 미지원)
- **전략**: `country` 파라미터 + 영어/현지어 혼용

#### **4. 실전 검색 예시**

**잘못된 접근:**
```bash
# 영어만 사용 → 현지 자료 누락
python3 simple_search.py "UAE media US military news"
```

**올바른 접근:**
```bash
# 1. 현지 언어 시도 (가능한 경우)
python3 simple_search.py "الجيش الأمريكي الإمارات"

# 2. 영어 + 지역명
python3 simple_search.py "US military UAE Arab news"

# 3. 한국어 + 지역명  
python3 simple_search.py "아랍에미리트 미군 뉴스"
```

#### **5. 언어 장벽 극복 전략**

1. **기본 번역 활용**: Google Translate로 기본 키워드 번역
2. **로마자 표기**: 아랍어·우르두어 키워드 로마자 표기 시도
3. **지역 포털**: `aljazeera.net` (아랍어), `dawn.com` (우르두어/영어)
4. **소셜미디어 해시태그**: `#امریکی_فوج` (파키스탄), `#الجيش_الأمريكي` (아랍어)

#### **6. 검증된 효과적 키워드 조합**

**파키스탄 뉴스:**
- `"پاکستان امریکی فوج تازہ خبریں"` (우르두어)
- `"Pakistan US army latest news"` (영어)
- `"파키스탄 미군 최신 뉴스"` (한국어)

**UAE 뉴스:**
- `"الإمارات الجيش الأمريكي أخبار"` (아랍어)
- `"UAE US military news today"` (영어)
- `"아랍에미리트 미군 소식"` (한국어)

**이란 반군:**
- `"مقاومت ایران اخبار"` (아랍어/페르시아어)
- `"Iran resistance forces news"` (영어)
- `"이란 저항 세력 소식"` (한국어)

### **핵심 원칙:**
> **"현지 뉴스를 찾으려면 현지 언어로 검색하라"**

이 교훈을 통해 앞으로 더 풍부하고 현지적인 정보를 수집할 수 있을 것입니다.