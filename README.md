# FCM Test App

Flutter 앱에서 Firebase Cloud Messaging(FCM) 푸시 알림을 테스트하기 위한 템플릿 프로젝트입니다.

## 기능

- FCM 토큰 발급 및 표시
- 포그라운드/백그라운드 푸시 알림 수신
- 알림 클릭 처리
- 토픽 구독/해제

## 사전 준비

1. **Flutter 개발 환경 설정**
2. **Firebase 프로젝트 생성**
   - [Firebase Console](https://console.firebase.google.com/)에서 새 프로젝트 생성
   - Android/iOS 앱 추가

## 설정 방법

### 1. Firebase 설정 파일 추가

**Android:**
```
android/app/google-services.json
```

**iOS:**
```
ios/Runner/GoogleService-Info.plist
```

### 2. Firebase CLI 설정 (선택사항)

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# Firebase 프로젝트 초기화
firebase init

# FlutterFire CLI 설치 및 설정
dart pub global activate flutterfire_cli
flutterfire configure
```

### 3. 의존성 설치

```bash
flutter pub get
```

### 4. 앱 실행

```bash
flutter run
```

## FCM 토큰 확인

앱 실행 후 메인 화면에서 FCM 토큰을 확인할 수 있습니다. 이 토큰을 사용하여 서버에서 푸시 알림을 전송할 수 있습니다.

## 푸시 알림 테스트

1. **Firebase Console에서 테스트**
   - Firebase Console > Cloud Messaging
   - "첫 번째 캠페인 만들기" 또는 "새 알림"
   - 앱의 FCM 토큰 입력하여 테스트

2. **서버에서 테스트**
   - 별도의 Node.js 서버 또는 Postman 사용
   - FCM API를 통해 알림 전송

## 주요 파일

- `lib/main.dart` - 메인 앱 코드 및 FCM 설정
- `lib/firebase_options.dart` - Firebase 설정 (자동 생성)
- `android/app/google-services.json` - Android Firebase 설정
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase 설정

## 주의사항

- Firebase 설정 파일들은 `.gitignore`에 포함되어 있습니다
- 실제 프로덕션에서는 보안을 위해 민감한 정보를 별도 관리하세요
- iOS에서는 푸시 알림 권한 요청이 필요합니다

## 문제 해결

### Android
- `google-services.json` 파일이 올바른 위치에 있는지 확인
- 앱 패키지명이 Firebase 프로젝트와 일치하는지 확인

### iOS
- `GoogleService-Info.plist` 파일이 Xcode 프로젝트에 추가되었는지 확인
- 푸시 알림 권한이 허용되었는지 확인
- Capabilities에서 Push Notifications가 활성화되었는지 확인
