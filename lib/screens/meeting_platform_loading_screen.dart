import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/travel_api_service.dart';
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
  bool _isCompleted = false;
  String _statusMessage = '';

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
      _startPolling();
    });
  }

  /// 세션 상태 polling 시작
  Future<void> _startPolling() async {
    if (!mounted) return;

    // 1. 로딩 애니메이션 + Polling 동시 시작
    _runLoadingAnimation();
    await _pollSessionStatus();
  }

  /// 세션 상태 Polling
  Future<void> _pollSessionStatus() async {
    const maxRetries = 600; // 최대 10분 (1초 간격) - LLM 응답 지연 대응
    int retryCount = 0;

    while (retryCount < maxRetries && mounted && !_isCompleted && !_hasError) {
      try {
        final status = await TravelApiService.getSessionStatus(widget.photoCard.id);
        final sessionStatus = status['status'] as String?;

        print('📊 [Polling] Status: $sessionStatus (retry: $retryCount)');

        if (sessionStatus == 'completed') {
          // 추천 완료 - 결과 가져오기
          await _loadRecommendationResult();
          return;
        } else if (sessionStatus == 'failed') {
          // 추천 실패
          setState(() {
            _hasError = true;
            _statusMessage = status['message'] ?? '추천 요청 실패';
          });
          await _showErrorAndPop();
          return;
        } else if (sessionStatus == 'not_found') {
          // 세션이 없음 - 기존 방식으로 직접 요청
          print('⚠️ [Polling] 세션이 없습니다. 기존 방식으로 직접 요청합니다.');
          await _fetchRecommendationsDirectly();
          return;
        }

        // pending 또는 processing 상태 - 대기 후 재시도
        await Future.delayed(const Duration(seconds: 1));
        retryCount++;
      } catch (e) {
        print('💥 [Polling] Error: $e');
        // 에러 시 기존 방식으로 직접 요청
        await _fetchRecommendationsDirectly();
        return;
      }
    }

    // 타임아웃 - 기존 방식으로 직접 요청
    if (!_isCompleted && !_hasError && mounted) {
      print('⏱️ [Polling] Timeout - 기존 방식으로 직접 요청합니다.');
      await _fetchRecommendationsDirectly();
    }
  }

  /// 추천 결과 로드 (completed 상태일 때)
  Future<void> _loadRecommendationResult() async {
    if (!mounted) return;

    try {
      final result = await TravelApiService.getSessionRecommendation(widget.photoCard.id);

      // Provider에 결과 저장
      final provider = Provider.of<AppProvider>(context, listen: false);
      final response = RecommendationResponse.fromJson(result);

      // Provider의 _recommendationResponse 설정을 위해 fetchRecommendations 결과를 직접 설정
      // (현재 AppProvider에 setRecommendationResponse가 없으므로 직접 화면 전환)

      setState(() => _isCompleted = true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingPlatformScreen(
              photoCard: widget.photoCard,
              preloadedResponse: response, // 미리 로드된 결과 전달
            ),
          ),
        );
      }
    } catch (e) {
      print('💥 [LoadResult] Error: $e');
      setState(() {
        _hasError = true;
        _statusMessage = '추천 결과를 불러오지 못했습니다';
      });
      await _showErrorAndPop();
    }
  }

  /// 기존 방식으로 직접 추천 요청 (세션이 없을 때 폴백)
  Future<void> _fetchRecommendationsDirectly() async {
    if (!mounted) return;

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final query = _buildQueryFromPhotoCard(widget.photoCard);

      final result = await provider.fetchRecommendations(
        query: query,
        province: widget.photoCard.province,
        city: widget.photoCard.city,
      );

      setState(() => _isCompleted = true);

      if (result == null || !result.success) {
        setState(() {
          _hasError = true;
          _statusMessage = provider.recommendationError ?? '추천 요청 실패';
        });
        await _showErrorAndPop();
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingPlatformScreen(photoCard: widget.photoCard),
          ),
        );
      }
    } catch (e) {
      print('💥 [DirectFetch] Error: $e');
      setState(() {
        _hasError = true;
        _statusMessage = '추천 요청 중 오류가 발생했습니다';
      });
      await _showErrorAndPop();
    }
  }

  /// 에러 표시 후 이전 화면으로 돌아가기
  Future<void> _showErrorAndPop() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_statusMessage),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  /// 로딩 애니메이션 (완료될 때까지 반복)
  Future<void> _runLoadingAnimation() async {
    int step = 0;
    while (!_isCompleted && !_hasError && mounted) {
      setState(() => _currentStep = step % _loadingMessages.length);
      await Future.delayed(const Duration(milliseconds: 2000));
      step++;
    }
  }

  /// PhotoCard 정보로 추천 쿼리 생성
  String _buildQueryFromPhotoCard(PhotoCard photoCard) {
    final message = photoCard.message;

    if (message.isNotEmpty) {
      return message;
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
                SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Steam effects
                      ...List.generate(3, (index) {
                        return Positioned(
                          top: 20,
                          right: 140.0 + (index * 20),
                          child: Icon(
                            Icons.cloud,
                            size: 20 + (index * 10),
                            color: Colors.white.withOpacity(0.5),
                          )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .moveY(
                                begin: 0,
                                end: -30,
                                duration: 1000.ms,
                                delay: (300 * index).ms,
                                curve: Curves.easeOut,
                              )
                              .fadeOut(
                                begin: 1,
                                duration: 1000.ms,
                                delay: (300 * index).ms,
                              ),
                        );
                      }),
                      // Train Icon Shadow
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      // Train Icon with Shimmer (Clipped)
                      ClipOval(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.primaryGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.train_rounded,
                            size: 56,
                            color: Colors.white,
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(
                                duration: 1500.ms,
                                color: Colors.white.withOpacity(0.5)) // Shine effect
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .moveY(
                              begin: 0,
                              end: -5,
                              duration: 500.ms,
                              curve: Curves.easeInOut) // Gentle bounce
                          .then()
                          .moveY(
                              begin: -5,
                              end: 0,
                              duration: 500.ms,
                              curve: Curves.easeInOut),
                    ],
                  ),
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
