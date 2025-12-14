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
- 레일필름을 통한 다른 여행자와의 매칭
- 실시간 채팅 기능
- 상대방 프로필 확인

### 쿠폰
- 지역 제휴 쿠폰 발급
- QR 코드 스캔을 통한 쿠폰 사용
- 사용 내역 관리

### 리뷰
- 방문 장소 리뷰 작성
- 별점 및 사진 첨부
- 내가 쓴 리뷰 관리

## 기술 스택

- **Framework**: Flutter
- **State Management**: Provider
- **Backend API**: REST API (Travel API Service)
- **Image Processing**: image_picker, image_cropper
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

## 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점
├── models/                # 데이터 모델
├── providers/             # 상태 관리
├── screens/               # 화면 UI
│   ├── home_screen.dart
│   ├── camera_screen.dart
│   ├── photo_card_result_screen.dart
│   ├── photo_card_list_screen.dart
│   ├── meeting_platform_screen.dart
│   ├── coupon_screen.dart
│   └── ...
├── services/              # API 서비스
├── theme/                 # 앱 테마
└── widgets/               # 공통 위젯
```

## 주요 화면

| 홈 | 레일필름 생성 | 레일필름 목록 |
|:---:|:---:|:---:|
| 메인 화면 | 사진 촬영 후 카드 생성 | 저장된 카드 목록 |

## 라이센스

This project is proprietary software.
