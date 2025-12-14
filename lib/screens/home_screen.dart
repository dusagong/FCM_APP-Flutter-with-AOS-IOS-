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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _RailBackground(
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
        // Ticket Station Icon with animation
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ticket booth stripes
              Positioned(
                top: 0,
                child: Container(
                  width: 120,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
              ),
              // Main Icon
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.train_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'STATION',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              // Bottom perforation
              Positioned(
                bottom: -10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    8,
                    (index) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
            .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.white.withOpacity(0.5)),
        const SizedBox(height: 32),
        // Title
        Text(
          '코레일 동행열차',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          '사랑하는 사람과 함께하는 특별한 여행',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
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
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: AppShadows.small,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '레일필름이 만남승강장의 티켓이 됩니다',
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
          text: '레일필름 목록',
          icon: Icons.confirmation_number_rounded, // Changed to ticket icon
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
                  Icons.confirmation_number_rounded,
                  '${provider.photoCardCount}',
                  '레일필름',
                  color: AppColors.primary,
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
                  color: AppColors.secondary,  // 녹색 - 혜택
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
                  color: AppColors.accent,  // 노란색 - 별점
                ),
              ],
            ).animate().fadeIn(delay: 900.ms, duration: 500.ms);
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label, {Color? color}) {
    final itemColor = color ?? AppColors.primary;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: itemColor),
            const SizedBox(width: 4),
            Text(
              count,
              style: AppTypography.titleMedium.copyWith(
                color: itemColor,
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

class _RailBackground extends StatelessWidget {
  final Widget child;

  const _RailBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Sky
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE3F2FD), // Light Blue
                Color(0xFFF3E5F5), // Light Purple
                AppColors.background, // Normal Background
              ],
              stops: [0.0, 0.4, 0.6],
            ),
          ),
        ),
        // Rail Tracks Pattern
        Positioned.fill(
          child: Opacity(
            opacity: 0.05,
            child: CustomPaint(
              painter: _RailTrackPainter(),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _RailTrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw simple curves representing tracks
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.3,
      size.width,
      size.height * 0.1,
    );

    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.85,
      size.width,
      size.height * 0.7,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
