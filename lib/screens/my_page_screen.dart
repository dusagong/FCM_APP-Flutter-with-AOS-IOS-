import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'photo_card_list_screen.dart';
import 'coupon_screen.dart';
import 'reviewable_places_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
                // Stats Section (Pass context for picker)
                _buildStatsSection(context, provider),
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

  Future<void> _pickProfileImage(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );

      if (image != null && context.mounted) {
        await context.read<AppProvider>().updateUserProfileImage(image.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('여권 사진이 등록되었습니다!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진을 불러올 수 없습니다')),
        );
      }
    }
  }

  Widget _buildStatsSection(BuildContext context, AppProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A), // Deep Navy like real passport
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: _HologramPatternPainter(),
              ),
            ),
          ),
          
          Column(
            children: [
              // Passport Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/korail_logo.png', // Assuming asset exists, fallback to icon if not
                      width: 24,
                      height: 24,
                      errorBuilder: (_,__,___) => const Icon(Icons.train_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KORAIL PASSPORT',
                            style: AppTypography.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'REPUBLIC OF TRAVELER',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white70,
                              letterSpacing: 1.5,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ID Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Area
                    GestureDetector(
                      onTap: () => _pickProfileImage(context as BuildContext), // Context workaround needed? No, need to pass context or use proper build method context.
                      // Wait, I am inside a method, 'context' is not available unless passed.
                      // _buildStatsSection calls are inside Consumer builder, context is available there BUT _buildStatsSection signature needs context or I use a Builder widget.
                      // The current signature is (AppProvider provider). I should change it to (BuildContext context, AppProvider provider).
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: provider.userProfileImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: Image.file(
                                      File(provider.userProfileImage!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.person, color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.add_a_photo_rounded, 
                                      size: 32, 
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                          ),
                          if (provider.userProfileImage == null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '사진 등록',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    // User Info & Stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPassportField('SURNAME / NIVEN NAME', 'TRAVELER / JOY'),
                          const SizedBox(height: 16),
                          _buildPassportField('NATIONALITY', 'SOUTH KOREA'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StatItem(
                                icon: Icons.photo_camera_rounded,
                                count: provider.photoCardCount,
                                label: 'FILMS',
                                color: Colors.white,
                              ),
                              _StatItem(
                                icon: Icons.confirmation_number_rounded,
                                count: provider.couponCount,
                                label: 'COUPONS',
                                color: Colors.white,
                              ),
                              _StatItem(
                                icon: Icons.rate_review_rounded,
                                count: provider.reviewCount,
                                label: 'REVIEWS',
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Decorative Area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'P<KOR<<TRAVELER<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n8282828M2512315KOR<<<<<<<<<<<<<<<<<<<<<<<',
                        style: TextStyle(
                          fontFamily: 'Monospace',
                          fontSize: 10, // Slightly reduced font size
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 2.0, // Increased spacing for real look
                          height: 1.2,
                        ),
                        overflow: TextOverflow.clip,
                        softWrap: false, // Force single line per line defined by \n? Actually MRZ is fixed width.
                        // Better to let it clip if it's too long, or use FittedBox?
                        // Let's use flexible with text overflow clip.
                        maxLines: 2,
                      ),
                    ),
                    Opacity(
                      opacity: 0.5,
                      child: Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPassportField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.credit_card_rounded,
          title: '나의 레일필름',
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
          style: AppTypography.labelSmall.copyWith(
            color: color.withOpacity(0.8),
          ),
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

class _HologramPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw curves
    final path = Path();
    for (double i = -50; i < size.width + 50; i += 20) {
      path.moveTo(i, 0);
      path.quadraticBezierTo(
        i + 50, size.height / 2,
        i, size.height,
      );
    }
    canvas.drawPath(path, paint);

    // Draw circles
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 60, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 40, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
