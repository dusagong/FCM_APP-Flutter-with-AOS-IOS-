import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'photo_card_result_screen.dart';

class PhotoCardLoadingScreen extends StatefulWidget {
  final String imagePath;
  final String message;
  final List<String> hashtags;
  final String province;
  final String city;

  const PhotoCardLoadingScreen({
    super.key,
    required this.imagePath,
    required this.message,
    required this.hashtags,
    required this.province,
    required this.city,
  });

  @override
  State<PhotoCardLoadingScreen> createState() => _PhotoCardLoadingScreenState();
}

class _PhotoCardLoadingScreenState extends State<PhotoCardLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _generatePhotoCard();
  }

  Future<void> _generatePhotoCard() async {
    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final provider = context.read<AppProvider>();
    final aiQuote = provider.generateAIQuote();
    final id = provider.generateId();

    final photoCard = PhotoCard(
      id: id,
      imagePath: widget.imagePath,
      message: widget.message.isEmpty ? '특별한 여행의 순간' : widget.message,
      hashtags: widget.hashtags,
      province: widget.province,
      city: widget.city,
      aiQuote: aiQuote,
      createdAt: DateTime.now(),
    );

    provider.addPhotoCard(photoCard);
    provider.setCurrentPhotoCard(photoCard);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoCardResultScreen(photoCard: photoCard),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading Animation
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: AppShadows.colored,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 56,
                color: Colors.white,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms, color: Colors.white30)
                .animate()
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: 1000.ms,
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(0.9, 0.9),
                  duration: 1000.ms,
                ),
            const SizedBox(height: 40),
            Text(
              'AI가 특별한 글귀를\n생성하고 있습니다...',
              style: AppTypography.headlineMedium.copyWith(
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            const SizedBox(height: 16),
            Text(
              '잠시만 기다려주세요',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms),
          ],
        ),
      ),
    );
  }
}
