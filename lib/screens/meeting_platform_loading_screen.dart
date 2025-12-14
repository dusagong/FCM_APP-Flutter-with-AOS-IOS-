import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'meeting_platform_screen.dart';

class MeetingPlatformLoadingScreen extends StatefulWidget {
  final PhotoCard photoCard;

  const MeetingPlatformLoadingScreen({
    super.key,
    required this.photoCard,
  });

  @override
  State<MeetingPlatformLoadingScreen> createState() =>
      _MeetingPlatformLoadingScreenState();
}

class _MeetingPlatformLoadingScreenState
    extends State<MeetingPlatformLoadingScreen> {
  int _currentStep = 0;
  bool _hasError = false;
  bool _apiCompleted = false;
  RecommendationResponse? _apiResult;

  final List<String> _loadingMessages = [
    'AI가 여행 코스를 분석하고 있어요',
    '커플에게 딱 맞는 장소를 찾고 있어요',
    '특별한 데이트 코스를 준비하고 있어요',
    '맛집과 카페를 찾고 있어요',
    '동선을 최적화하고 있어요',
    '거의 다 됐어요!',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLoading();
    });
  }

  Future<void> _startLoading() async {
    if (!mounted) return;
    final provider = Provider.of<AppProvider>(context, listen: false);

    // 기본 쿼리 생성 (해시태그 기반)
    final query = _buildQueryFromPhotoCard(widget.photoCard);

    // 1. API 호출 시작 (백그라운드)
    _fetchRecommendations(provider, query);

    // 2. 로딩 애니메이션 반복 (API 완료될 때까지)
    await _runLoadingAnimation();

    // 3. API 결과 처리
    if (!mounted) return;

    if (_apiResult == null || !_apiResult!.success) {
      setState(() => _hasError = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.recommendationError ?? '추천 정보를 불러오지 못했습니다'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    // 성공 시 화면 전환
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MeetingPlatformScreen(photoCard: widget.photoCard),
        ),
      );
    }
  }

  /// API 호출 (백그라운드)
  Future<void> _fetchRecommendations(AppProvider provider, String query) async {
    _apiResult = await provider.fetchRecommendations(
      query: query,
      province: widget.photoCard.province,
      city: widget.photoCard.city,
    );
    _apiCompleted = true;
  }

  /// 로딩 애니메이션 (API 완료될 때까지 반복)
  Future<void> _runLoadingAnimation() async {
    int step = 0;
    while (!_apiCompleted && mounted) {
      setState(() => _currentStep = step % _loadingMessages.length);
      await Future.delayed(const Duration(milliseconds: 2000));
      step++;
    }
  }

  /// PhotoCard 정보로 추천 쿼리 생성
  String _buildQueryFromPhotoCard(PhotoCard photoCard) {
    final hashtags = photoCard.hashtags.join(' ');
    final message = photoCard.message;

    if (message.isNotEmpty) {
      return '$message $hashtags';
    } else if (hashtags.isNotEmpty) {
      return '${photoCard.city}에서 $hashtags 관련 데이트 코스 추천해줘';
    } else {
      return '${photoCard.city}에서 커플 데이트 코스 추천해줘';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.door_sliding_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 1000.ms,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.05, 1.05),
                      end: const Offset(1, 1),
                      duration: 1000.ms,
                    ),
                const SizedBox(height: 48),

                // 타이틀
                Text(
                  '만남승강장으로 이동 중',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 16),

                // 목적지 정보
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.photoCard.province} ${widget.photoCard.city}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 48),

                // 로딩 메시지
                SizedBox(
                  height: 60,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _loadingMessages[_currentStep],
                      key: ValueKey(_currentStep),
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 프로그레스 인디케이터
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / _loadingMessages.length,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),

                // 단계 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _loadingMessages.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index <= _currentStep
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
