import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'camera_screen.dart';
import 'photo_card_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WaveBackground(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo and Title
                _buildHeader(),
                const SizedBox(height: 48),
                // Description
                _buildDescription(),
                const Spacer(flex: 3),
                // Buttons
                _buildButtons(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Train Icon with animation
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.colored,
          ),
          child: const Icon(
            Icons.train_rounded,
            size: 56,
            color: Colors.white,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        const SizedBox(height: 24),
        // Title
        Text(
          '코레일 동행열차',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
          child: Text(
            '특별한 여행의 시작',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      children: [
        Text(
          '여정사진관에서\n추억을 담아보세요',
          style: AppTypography.headlineLarge.copyWith(
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.credit_card_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '포토카드가 만남승강장의 티켓이 됩니다',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: '사진 촬영하기',
          icon: Icons.camera_alt_rounded,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CameraScreen()),
            );
          },
        ).animate().fadeIn(delay: 700.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        SecondaryButton(
          text: '포토카드 목록',
          icon: Icons.photo_library_rounded,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PhotoCardListScreen()),
            );
          },
        ).animate().fadeIn(delay: 800.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 24),
        // Stats
        Consumer<AppProvider>(
          builder: (context, provider, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem(
                  Icons.credit_card_rounded,
                  '${provider.photoCardCount}',
                  '포토카드',
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.border,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
                _buildStatItem(
                  Icons.local_offer_rounded,
                  '${provider.couponCount}',
                  '쿠폰',
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.border,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
                _buildStatItem(
                  Icons.star_rounded,
                  '${provider.reviewCount}',
                  '리뷰',
                ),
              ],
            ).animate().fadeIn(delay: 900.ms, duration: 500.ms);
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              count,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelSmall,
        ),
      ],
    );
  }
}
