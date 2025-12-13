import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import '../services/travel_api_service.dart';
import 'meeting_platform_screen.dart';

class PhotoCardResultScreen extends StatefulWidget {
  final PhotoCard photoCard;
  final bool showMeetingPlatformButton;

  const PhotoCardResultScreen({
    super.key,
    required this.photoCard,
    this.showMeetingPlatformButton = true,
  });

  @override
  State<PhotoCardResultScreen> createState() => _PhotoCardResultScreenState();
}

class _PhotoCardResultScreenState extends State<PhotoCardResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  void _shareCard(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      '코레일 동행열차와 함께한 특별한 여행!\n\n'
      '${widget.photoCard.message}\n\n'
      '"${widget.photoCard.aiQuote}"\n\n'
      '📍 ${widget.photoCard.destination}\n'
      '${widget.photoCard.hashtags.map((t) => '#$t').join(' ')}\n\n'
      '#코레일동행열차 #러브포토카드',
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.zero,
    );
  }

  Future<void> _goToMeetingPlatform() async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // PhotoCard 검증 API 호출
      final isValid = await TravelApiService.verifyPhotoCard(widget.photoCard.id);

      if (!mounted) return;

      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      if (isValid) {
        // 검증 성공: 만남승강장으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingPlatformScreen(
              photoCard: widget.photoCard,
            ),
          ),
        );
      } else {
        // 검증 실패: 사용자에게 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('유효하지 않은 포토카드입니다. 다시 생성해주세요.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('포토카드 검증 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '코레일 러브포토카드',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = _flipAnimation.value * math.pi;
                      final isFront = angle < math.pi / 2;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isFront
                            ? _buildFrontCard()
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: _buildBackCard(),
                              ),
                      );
                    },
                  ),
                ).animate().fadeIn(duration: 500.ms).scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                    ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppBorderRadius.xl),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.train_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'KORAIL LOVE PHOTO CARD',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                boxShadow: AppShadows.small,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                child: widget.photoCard.imagePath != null
                    ? Image.file(
                        File(widget.photoCard.imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: Icon(
                            Icons.photo_rounded,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '"${widget.photoCard.message}"',
              style: AppTypography.titleMedium.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),

          // Hashtags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: widget.photoCard.hashtags.take(4).map((tag) {
                return Text(
                  '#$tag',
                  style: AppTypography.hashTag,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Destination
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppBorderRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.photoCard.destination,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.twilightGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Quote
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '"${widget.photoCard.aiQuote}"',
              style: AppTypography.photoCardQuote.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(flex: 2),
          // Korail Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.train_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'KORAIL',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.photoCard.formattedDate,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white70,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Flip hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                '카드를 탭하면 뒤집어집니다',
                style: AppTypography.labelSmall,
              ),
            ],
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn().then().fadeOut(),
          const SizedBox(height: 16),

          // Button to flip
          SecondaryButton(
            text: _showFront ? '뒷면 보기' : '앞면 보기',
            icon: Icons.flip_rounded,
            onPressed: _flipCard,
          ),
          const SizedBox(height: 12),

          // Share Button
          Builder(
            builder: (buttonContext) => SecondaryButton(
              text: 'SNS 공유하기',
              icon: Icons.share_rounded,
              onPressed: () => _shareCard(buttonContext),
            ),
          ),

          if (widget.showMeetingPlatformButton) ...[
            const SizedBox(height: 12),
            PrimaryButton(
              text: '만남승강장으로 이동',
              icon: Icons.door_sliding_rounded,
              onPressed: _goToMeetingPlatform,
            ),
          ],
        ],
      ),
    );
  }
}
