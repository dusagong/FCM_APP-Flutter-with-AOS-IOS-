import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
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
  final List<String> _loadingMessages = [
    '개인화 데이트 코스를 추천해 드릴게요',
    '맞춤형 쿠폰을 불러오고 있어요',
    '특별한 장소들을 준비하고 있어요',
    '거의 다 됐어요!',
  ];

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    for (int i = 0; i < _loadingMessages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _currentStep = i);
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MeetingPlatformScreen(photoCard: widget.photoCard),
        ),
      );
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
