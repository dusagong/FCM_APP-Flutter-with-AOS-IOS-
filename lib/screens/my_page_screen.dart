import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'photo_card_list_screen.dart';
import 'coupon_screen.dart';
import 'reviewable_places_screen.dart';
import 'my_reviews_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '내 정보'),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Stats Section
                _buildStatsSection(provider),
                const SizedBox(height: 24),

                // Menu Section
                _buildMenuSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.credit_card_rounded,
            count: provider.photoCardCount,
            label: '포토카드',
            color: AppColors.primary,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          _StatItem(
            icon: Icons.local_offer_rounded,
            count: provider.couponCount,
            label: '쿠폰',
            color: AppColors.secondary,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          _StatItem(
            icon: Icons.star_rounded,
            count: provider.reviewCount,
            label: '리뷰',
            color: AppColors.accent,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.credit_card_rounded,
          title: '나의 포토카드',
          color: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PhotoCardListScreen()),
            );
          },
        ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
        const SizedBox(height: 12),
        _MenuItem(
          icon: Icons.local_offer_rounded,
          title: '쿠폰함',
          color: AppColors.secondary,  // 녹색 - 혜택
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CouponScreen()),
            );
          },
        ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
        const SizedBox(height: 12),
        _MenuItem(
          icon: Icons.rate_review_rounded,
          title: '내가 쓴 리뷰',
          color: AppColors.accent,  // 노란색 - 리뷰
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyReviewsScreen()),
            );
          },
        ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
        const SizedBox(height: 12),
        _MenuItem(
          icon: Icons.edit_note_rounded,
          title: '리뷰 작성 가능한 곳',
          color: AppColors.accentTeal,  // 청록색
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReviewablePlacesScreen()),
            );
          },
        ).animate().fadeIn(delay: 350.ms, duration: 300.ms),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: AppTypography.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall,
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            boxShadow: AppShadows.small,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
