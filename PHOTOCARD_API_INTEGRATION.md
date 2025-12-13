# PhotoCard API Integration Guide

**브랜치**: `feature/photocard-api`
**작성일**: 2025-12-13
**상태**: ✅ 구현 완료

---

## 📋 구현 개요

PhotoCard를 **디바이스 로컬(SharedPreferences)**에 저장하고, 서버는 **검증용**으로만 사용합니다.

### 핵심 원칙

1. ✅ **PhotoCard는 디바이스에 저장** (SharedPreferences)
2. ✅ **서버는 UUID 발급 + 검증 전용**
3. ✅ **이미지는 로컬 저장 안 함** (나중에 S3 연동 예정)
4. ✅ **사용자가 삭제하면 로컬에서만 삭제** (서버 비활성화 불필요)

---

## 🚀 구현된 기능

### 1. API 서비스 레이어

**파일**: `lib/services/travel_api_service.dart`

#### 주요 메서드:

```dart
// PhotoCard 생성
static Future<Map<String, dynamic>> createPhotoCard({
  required String province,
  required String city,
  required String message,
  required List<String> hashtags,
  required String aiQuote,
  String? userId,
  String? imagePath,
});

// PhotoCard 검증 (만남승강장 접근 전)
static Future<bool> verifyPhotoCard(String photoCardId);

// 여행 추천 (area_code + sigungu_code 지원)
static Future<Map<String, dynamic>> getRecommendations({
  required String query,
  required String areaCode,
  String? sigunguCode,
});

// Province → area_code 매핑
static const Map<String, String> provinceToAreaCode = {
  '강원도': '32',
  '제주도': '39',
  // ...
};

// City → sigungu_code 매핑 (강원도, 제주도만 구현됨)
static const Map<String, Map<String, String>> citySigunguCodeMap = {
  '강원도': {
    '강릉시': '1',
    '속초시': '4',
    // ...
  },
};
```

---

### 2. 로컬 저장소 서비스

**파일**: `lib/services/photo_card_storage_service.dart`

#### 주요 메서드:

```dart
// PhotoCard 저장
static Future<void> savePhotoCard(PhotoCard photoCard);

// 모든 PhotoCard 조회
static Future<List<PhotoCard>> getAllPhotoCards();

// 특정 PhotoCard 조회
static Future<PhotoCard?> getPhotoCardById(String id);

// 현재 PhotoCard 가져오기
static Future<PhotoCard?> getCurrentPhotoCard();

// PhotoCard 삭제 (로컬에서만)
static Future<void> deletePhotoCard(String id);

// PhotoCard 개수
static Future<int> getPhotoCardCount();
```

---

### 3. AppProvider 업데이트

**파일**: `lib/providers/app_provider.dart`

#### 새로운 메서드:

```dart
// PhotoCard 생성 (API + 로컬 저장)
Future<PhotoCard> createPhotoCardWithAPI({
  required String province,
  required String city,
  required String message,
  required List<String> hashtags,
  required String aiQuote,
  String? imagePath,
});

// PhotoCard 삭제 (로컬에서만)
Future<void> deletePhotoCard(String photoCardId);

// PhotoCard 검증 (만남승강장 접근 전)
Future<bool> verifyPhotoCard(String photoCardId);
```

---

## 📱 사용 예시

### 1. PhotoCard 생성 (UI에서 호출)

```dart
// 사용자 입력 수집
final province = '강원도';
final city = '강릉시';
final message = '강릉에서의 특별한 하루';
final hashtags = ['맛집탐방', '카페투어', '해변산책'];
final aiQuote = AIQuotes.getRandomQuote(); // 로컬에서 랜덤 선택

// AppProvider를 통해 생성
final provider = Provider.of<AppProvider>(context, listen: false);

try {
  final photoCard = await provider.createPhotoCardWithAPI(
    province: province,
    city: city,
    message: message,
    hashtags: hashtags,
    aiQuote: aiQuote,
  );

  print('PhotoCard 생성 완료: ${photoCard.id}');

  // 성공 메시지 표시
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('PhotoCard가 생성되었습니다!')),
  );
} catch (e) {
  // 에러 처리
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('오류'),
      content: Text('PhotoCard 생성 실패: $e'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('확인'),
        ),
      ],
    ),
  );
}
```

---

### 2. 만남승강장 접근 (검증)

```dart
// 만남승강장 버튼 클릭 시
Future<void> _navigateToMeetingPlatform(BuildContext context) async {
  final provider = Provider.of<AppProvider>(context, listen: false);

  // 1. 현재 PhotoCard 확인
  final currentPhotoCard = provider.currentPhotoCard;

  if (currentPhotoCard == null) {
    // PhotoCard가 없으면 생성 화면으로
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('PhotoCard가 필요합니다'),
        content: Text('만남승강장에 접근하려면 PhotoCard를 먼저 생성해주세요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/create-photocard');
            },
            child: Text('PhotoCard 생성하기'),
          ),
        ],
      ),
    );
    return;
  }

  // 2. 서버에서 PhotoCard 검증
  final isValid = await provider.verifyPhotoCard(currentPhotoCard.id);

  if (isValid) {
    // 검증 성공 → 만남승강장 진입
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingPlatformScreen(
          photoCardId: currentPhotoCard.id,
        ),
      ),
    );
  } else {
    // 검증 실패
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('접근 불가'),
        content: Text('PhotoCard가 유효하지 않습니다. 다시 생성해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
```

---

### 3. PhotoCard 삭제

```dart
// PhotoCard 목록 화면에서 삭제 버튼 클릭 시
Future<void> _deletePhotoCard(BuildContext context, String photoCardId) async {
  final provider = Provider.of<AppProvider>(context, listen: false);

  // 확인 다이얼로그
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('PhotoCard 삭제'),
      content: Text('이 PhotoCard를 삭제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('삭제'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      await provider.deletePhotoCard(photoCardId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PhotoCard가 삭제되었습니다')),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('오류'),
          content: Text('PhotoCard 삭제 실패: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }
}
```

---

### 4. 여행 추천 받기 (만남승강장)

```dart
// 만남승강장 화면에서
Future<void> _getRecommendations(String query) async {
  final provider = Provider.of<AppProvider>(context, listen: false);
  final currentPhotoCard = provider.currentPhotoCard!;

  // Province → area_code 변환
  final areaCodes = TravelApiService.getAreaCodes(
    currentPhotoCard.province,
    currentPhotoCard.city,
  );

  final areaCode = areaCodes['area_code'];
  final sigunguCode = areaCodes['sigungu_code'];

  if (areaCode == null) {
    // 지역 코드를 찾을 수 없음
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('오류'),
        content: Text('지역 코드를 찾을 수 없습니다: ${currentPhotoCard.province}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
    return;
  }

  try {
    // 로딩 표시
    setState(() {
      isLoading = true;
    });

    // API 호출
    final result = await TravelApiService.getRecommendations(
      query: query,
      areaCode: areaCode,
      sigunguCode: sigunguCode,
    );

    // 결과 파싱
    final curatedCourse = result['curated_course'];
    final rawCourses = result['raw_courses'];

    // UI 업데이트
    setState(() {
      isLoading = false;
      this.curatedCourse = curatedCourse;
      this.rawCourses = rawCourses;
    });

  } catch (e) {
    setState(() {
      isLoading = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('오류'),
        content: Text('추천 요청 실패: $e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔧 환경 설정

### `.env` 파일

```env
API_BASE_URL=http://127.0.0.1:8080/api/v1
DEBUG=true
```

**중요**:
- 에뮬레이터에서 테스트 시: `http://10.0.2.2:8080/api/v1` (Android)
- iOS 시뮬레이터: `http://localhost:8080/api/v1`
- 실제 디바이스: 서버 IP 주소 사용 (예: `http://192.168.0.10:8080/api/v1`)

---

## 📊 데이터 흐름

```
┌─────────────────────┐
│  사용자 입력        │
│  (province, city,   │
│   message, etc.)    │
└──────┬──────────────┘
       │
       │ provider.createPhotoCardWithAPI()
       ▼
┌─────────────────────┐
│  TravelApiService   │
│  POST /photo_cards  │
└──────┬──────────────┘
       │ 응답: { id: "uuid", created_at: "..." }
       ▼
┌─────────────────────┐
│  PhotoCard 객체생성 │
│  (서버 ID 사용)     │
└──────┬──────────────┘
       │
       │ PhotoCardStorageService.savePhotoCard()
       ▼
┌─────────────────────┐
│  SharedPreferences  │
│  로컬 저장          │
└──────┬──────────────┘
       │
       │ AppProvider 상태 업데이트
       ▼
┌─────────────────────┐
│  UI 업데이트        │
│  (photoCards 목록)  │
└─────────────────────┘
```

---

## ⚠️ 주의사항

### 1. 이미지 처리
- **현재**: `imagePath`는 필드만 존재, 실제 저장 안 함
- **향후**: S3 연동 후 이미지 업로드 구현 예정
- PhotoCard 생성 시 `imagePath`는 `null`로 전달

### 2. AI 기능
- **AI 해시태그 생성**: 아직 미구현 → 클라이언트에서 프리셋 선택
- **AI 감성 글귀**: 아직 미구현 → `AIQuotes.getRandomQuote()` 사용

### 3. 에러 처리
- 네트워크 에러 시 사용자에게 명확한 메시지 표시
- 타임아웃: PhotoCard 생성(10초), 추천 요청(3분)
- try-catch로 모든 API 호출 감싸기

### 4. 로컬 vs 서버
- PhotoCard는 **로컬 기반** (디바이스에 저장)
- 서버는 **UUID 발급 + 검증용**
- 삭제 시 **로컬에서만 삭제** (서버 비활성화 불필요)

---

## 🔨 TODO: 향후 작업

### 단기 (이번 주)
- [ ] PhotoCard 생성 UI 업데이트 (`createPhotoCardWithAPI` 사용)
- [ ] 만남승강장 진입 시 검증 로직 추가
- [ ] PhotoCard 목록 화면에 삭제 버튼 추가
- [ ] 에러 메시지 한국어화

### 중기 (1-2주)
- [ ] 전국 시군구 코드 매핑 완성 (현재 강원도, 제주도만 구현)
- [ ] 이미지 S3 업로드 기능
- [ ] 오프라인 모드 지원 (네트워크 없을 때 로컬 데이터만 사용)

### 장기 (1개월+)
- [ ] AI 자동 해시태그 생성
- [ ] AI 감성 글귀 생성
- [ ] PhotoCard 공유 기능

---

## 🧪 테스트 방법

### 1. 로컬 서버 실행

```bash
cd /Users/yoonseungjae/Documents/code/Seoul-Soft/hackerthon/travel-server

# Docker Compose 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f travel-server
```

### 2. Flutter 앱 실행

```bash
cd /Users/yoonseungjae/Documents/code/Seoul-Soft/hackerthon/FCM_APP-Flutter-with-AOS-IOS-

# 브랜치 확인
git branch  # feature/photocard-api

# 의존성 설치
flutter pub get

# 실행
flutter run
```

### 3. API 테스트 (수동)

```bash
# PhotoCard 생성
curl -X POST http://localhost:8080/api/v1/photo_cards \
  -H "Content-Type: application/json" \
  -d '{
    "province": "강원도",
    "city": "강릉시",
    "message": "테스트",
    "hashtags": ["맛집", "카페"],
    "ai_quote": "테스트 글귀"
  }'

# PhotoCard 검증
curl http://localhost:8080/api/v1/photo_cards/{id}/verify
```

---

## 📂 변경된 파일 목록

```
FCM_APP-Flutter-with-AOS-IOS-/
├── .env                                      # ✏️ 이미 존재
├── pubspec.yaml                              # ✏️ http 의존성 추가
├── lib/
│   ├── main.dart                             # ✅ 변경 없음 (dotenv 이미 로드 중)
│   ├── providers/
│   │   └── app_provider.dart                 # ✏️ API 연동 메서드 추가
│   └── services/                             # ✅ 신규 디렉토리
│       ├── travel_api_service.dart           # ✅ 신규
│       └── photo_card_storage_service.dart   # ✅ 신규
└── PHOTOCARD_API_INTEGRATION.md              # ✅ 신규 (이 문서)
```

---

**마지막 업데이트**: 2025-12-13
**작성자**: Claude
**브랜치**: `feature/photocard-api`
