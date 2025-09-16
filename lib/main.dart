import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

/// FCM 백그라운드 메시지 핸들러
/// 앱이 백그라운드나 종료 상태일 때 푸시 알림을 받을 때 실행됩니다.
/// @pragma('vm:entry-point')는 Flutter 엔진이 이 함수를 찾을 수 있도록 하는 어노테이션입니다.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서도 Firebase를 사용하기 위해 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 백그라운드 메시지 정보를 콘솔에 출력 (디버깅용)
  print('Background message received: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

/// 앱의 메인 진입점
void main() async {
  // Flutter 위젯 바인딩을 초기화 (async main에서 필요)
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Core 초기화 - 모든 Firebase 서비스의 기본 설정
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // FCM 백그라운드 메시지 핸들러 등록
  // 앱이 백그라운드나 종료 상태일 때 받은 메시지를 처리
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FCM Push Notification Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String? _fcmToken;
  String _lastMessage = 'No messages yet';
  final List<Map<String, String>> _messageHistory = [];

  /// 로컬 알림 플러그인 인스턴스
  /// 에뮬레이터에서 FCM 알림을 시각적으로 표시하기 위해 사용
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // 로컬 알림 시스템 초기화
    _initializeLocalNotifications();
    // Firebase 메시징 설정 및 토큰 획득
    _setupFirebaseMessaging();
  }

  /// 로컬 알림 시스템 초기화
  /// 에뮬레이터에서 FCM 메시지를 시각적으로 표시하기 위한 설정
  Future<void> _initializeLocalNotifications() async {
    // Android 로컬 알림 설정
    // '@mipmap/ic_launcher'는 앱 아이콘을 알림 아이콘으로 사용
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS 로컬 알림 설정 및 권한 요청
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,  // 알림 팝업 권한
      requestBadgePermission: true,  // 앱 아이콘 배지 권한
      requestSoundPermission: true,  // 알림 소리 권한
    );

    // 플랫폼별 설정을 통합
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 로컬 알림 플러그인 초기화
    await _localNotifications.initialize(initializationSettings);
  }

  /// 로컬 알림 표시 함수
  /// FCM 메시지를 에뮬레이터에서 시각적으로 보여주기 위해 사용
  Future<void> _showLocalNotification(String title, String body) async {
    // Android 알림 상세 설정
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'fcm_default_channel',              // 채널 ID
      'FCM Default Channel',              // 채널 이름
      channelDescription: 'Default FCM notifications channel', // 채널 설명
      importance: Importance.max,         // 중요도 최대 (헤드업 알림)
      priority: Priority.high,            // 우선순위 높음
      showWhen: true,                     // 알림 시간 표시
    );

    // iOS/macOS 알림 상세 설정
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,   // 알림 팝업 표시
      presentBadge: true,   // 앱 아이콘 배지 표시
      presentSound: true,   // 알림 소리 재생
    );

    // 플랫폼별 알림 설정을 통합
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // 로컬 알림 실제 표시
    await _localNotifications.show(
      0,                              // 알림 ID (0은 기본값)
      title,                          // 알림 제목
      body,                           // 알림 내용
      platformChannelSpecifics,       // 플랫폼별 설정
    );
  }

  /// Firebase 메시징 설정 및 이벤트 리스너 등록
  /// FCM 토큰 획득, 권한 요청, 메시지 처리 설정을 담당
  Future<void> _setupFirebaseMessaging() async {
    // iOS에서 푸시 알림 권한 요청
    // Android는 기본적으로 권한이 허용되어 있음
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,    // 알림 팝업 권한
      badge: true,    // 앱 아이콘 배지 권한
      sound: true,    // 알림 소리 권한
    );

    // 권한 승인 여부 확인
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    }

    // FCM 토큰 획득 (디바이스 고유 식별자)
    // 서버에서 이 토큰으로 특정 디바이스에 푸시 메시지를 전송
    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _fcmToken = token;
    });
    debugPrint('FCM Token: $token');

    // 토큰 갱신 리스너 등록
    // 앱 재설치, 디바이스 변경 등으로 토큰이 변경될 때 호출
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      setState(() {
        _fcmToken = newToken;
      });
      debugPrint('Token refreshed: $newToken');
    });

    // 포그라운드(앱 실행 중) 메시지 처리
    // 앱이 실행 중일 때 FCM 메시지가 도착하면 호출
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title}');

      // 에뮬레이터에서 시각적 확인을 위해 로컬 알림 표시
      final title = message.notification?.title ?? 'FCM Message';
      final body = message.notification?.body ?? 'New message received';
      _showLocalNotification(title, body);

      // UI 업데이트 (메시지 히스토리에 추가)
      setState(() {
        _lastMessage = 'Foreground: $title';
        _messageHistory.insert(0, {
          'type': 'Foreground',
          'title': title,
          'body': body,
          'time': DateTime.now().toString().substring(0, 19),
        });
        if (_messageHistory.length > 10) _messageHistory.removeLast();
      });
    });

    // 알림 클릭으로 앱이 열릴 때 처리
    // 앱이 백그라운드에 있을 때 알림을 클릭해서 앱이 활성화되면 호출
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened app: ${message.notification?.title}');
      setState(() {
        _lastMessage = 'Opened from: ${message.notification?.title ?? 'No title'}';
      });
    });

    // 앱이 완전히 종료된 상태에서 알림으로 실행될 때 처리
    // 알림을 클릭해서 앱이 처음 시작되는 경우의 메시지 처리
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Initial message: ${initialMessage.notification?.title}');
      setState(() {
        _lastMessage = 'Launched from: ${initialMessage.notification?.title ?? 'No title'}';
      });
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _copyToken() async {
    if (_fcmToken != null) {
      await Clipboard.setData(ClipboardData(text: _fcmToken!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('토큰이 클립보드에 복사되었습니다!')),
        );
      }
    }
  }

  /// 로컬 알림 테스트 함수
  /// 에뮬레이터에서 알림이 정상 작동하는지 확인하기 위한 테스트 버튼
  void _testLocalNotification() {
    // 테스트 알림 표시
    _showLocalNotification(
      '테스트 알림',
      '에뮬레이터에서 알림이 정상 작동하는지 테스트합니다.',
    );

    // UI 업데이트 (테스트 메시지를 히스토리에 추가)
    setState(() {
      _lastMessage = 'Test: 로컬 알림 테스트';
      _messageHistory.insert(0, {
        'type': 'Test',
        'title': '테스트 알림',
        'body': '에뮬레이터에서 알림이 정상 작동하는지 테스트합니다.',
        'time': DateTime.now().toString().substring(0, 19),
      });
      if (_messageHistory.length > 10) _messageHistory.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FCM Token:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _fcmToken ?? 'Loading...',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _copyToken,
                              child: const Text('Copy Token'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _testLocalNotification,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Test Notification'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Message:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_lastMessage),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Counter:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_counter',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Message History:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: _messageHistory.isEmpty
                            ? const Center(child: Text('No messages yet'))
                            : ListView.builder(
                                itemCount: _messageHistory.length,
                                itemBuilder: (context, index) {
                                  final message = _messageHistory[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      '${message['type']}: ${message['title']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message['body']!,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          message['time']!,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
