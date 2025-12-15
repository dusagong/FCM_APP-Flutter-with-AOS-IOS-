# 코레일 동행열차

사랑하는 사람과 함께하는 특별한 기차 여행을 위한 Flutter 앱입니다.

## 주요 기능

### 레일필름 (포토카드)
- 여행 사진으로 레일필름 생성
- AI 기반 여행 메시지 및 해시태그 자동 생성
- QR 코드가 포함된 티켓 스타일 디자인
- 앞/뒷면 카드 뒤집기 애니메이션
- SNS 공유 기능

### 만남승강장
- AI 기반 맞춤형 코스 추천
- 지도에서 코스 경로 및 정차지 확인
- 카테고리별 정차지 구분 (관광지, 식당, 카페 등)
- 정차지별 쿠폰 받기 및 리뷰 작성

### 스탬프 컬렉션
- 코스 완료 시 스탬프 적립
- 정차지별 진행상황 추적 (쿠폰/리뷰)
- 관광지: 리뷰 작성으로 완료
- 식당/카페 등: 쿠폰 받기 + 리뷰 작성으로 완료
- 전체 진행률 시각화

### 쿠폰
- 지역 제휴 쿠폰 발급
- QR 코드 스캔을 통한 쿠폰 사용
- 사용 후 리뷰 작성 유도
- 사용 내역 관리

### 리뷰
- 방문 장소 리뷰 작성
- 사진 첨부 기능
- 내가 쓴 리뷰 관리
- 리뷰 작성 가능한 장소 목록

### 마이페이지
- 프로필 이미지 설정
- 레일필름/쿠폰/리뷰 통계
- 스탬프 컬렉션 확인

## 기술 스택

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Backend API**: REST API (Travel API Service)
- **Local Storage**: SharedPreferences
- **Image Processing**: image_picker, image_cropper
- **Maps**: flutter_naver_map
- **QR Code**: qr_flutter
- **Animations**: flutter_animate

## 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# iOS 설정 (macOS)
cd ios && pod install && cd ..

# 앱 실행
flutter run
```

## 환경 설정

### Naver Map API
`lib/main.dart`에서 Naver Map 클라이언트 ID 설정 필요:
```dart
await NaverMapSdk.instance.initialize(clientId: 'YOUR_CLIENT_ID');
```

## 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── models/
│   ├── models.dart              # 데이터 모델 (PhotoCard, Coupon, Review 등)
│   └── stamp.dart               # 스탬프 모델 (CourseStamp, StopProgress)
├── providers/
│   └── app_provider.dart        # 전역 상태 관리
├── screens/
│   ├── home_screen.dart         # 홈 화면
│   ├── camera_screen.dart       # 카메라/갤러리
│   ├── photo_card_result_screen.dart  # 레일필름 결과
│   ├── photo_card_list_screen.dart    # 레일필름 목록
│   ├── meeting_platform_screen.dart   # 만남승강장 (코스 추천)
│   ├── coupon_screen.dart       # 쿠폰함
│   ├── stamp_screen.dart        # 스탬프 컬렉션
│   ├── review_write_screen.dart # 리뷰 작성
│   ├── review_list_screen.dart  # 리뷰 목록
│   ├── my_page_screen.dart      # 마이페이지
│   └── my_reviews_screen.dart   # 내가 쓴 리뷰
├── services/
│   ├── travel_api_service.dart       # 여행 API 서비스
│   ├── photo_card_storage_service.dart # 포토카드 로컬 저장
│   └── stamp_storage_service.dart    # 스탬프 로컬 저장
├── theme/
│   └── app_theme.dart           # 앱 테마 및 스타일
└── widgets/
    └── common_widgets.dart      # 공통 위젯
```

## 주요 화면 플로우

```
홈 → 카메라 → 레일필름 생성 → 만남승강장
                                    ↓
                            코스 추천 받기
                                    ↓
                    ┌───────────────┼───────────────┐
                    ↓               ↓               ↓
                관광지          식당/카페        기타 장소
                    ↓               ↓               ↓
               리뷰 작성      쿠폰 받기 →      쿠폰 받기 →
                    ↓         쿠폰 사용 →      쿠폰 사용 →
                    ↓         리뷰 작성        리뷰 작성
                    ↓               ↓               ↓
                    └───────────────┼───────────────┘
                                    ↓
                            스탬프 적립!
                                    ↓
                        스탬프 컬렉션에서 확인
```

## 라이센스

This project is proprietary software.
