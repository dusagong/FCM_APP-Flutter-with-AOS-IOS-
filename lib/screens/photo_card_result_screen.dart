import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'meeting_platform_loading_screen.dart';

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
  bool _isSharing = false;
  final GlobalKey _cardKey = GlobalKey();

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

  Future<void> _shareCard(BuildContext context) async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      // 다음 프레임까지 기다림
      await SchedulerBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 200));

      // 카드 위젯을 이미지로 캡처
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('캡처할 수 없습니다');
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('이미지 변환 실패');
      }

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final fileName = 'photocard_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // 파일이 존재하는지 확인
      final fileSize = await file.length();
      debugPrint('File created: ${file.path}, size: $fileSize bytes');

      if (fileSize == 0) {
        throw Exception('파일이 비어있습니다');
      }

      // 공유
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.photoCard.message}\n\n#코레일동행열차 #${widget.photoCard.city} ${widget.photoCard.hashtags.map((t) => '#$t').join(' ')}',
      );
    } catch (e) {
      debugPrint('Share error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공유에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _goToMeetingPlatform() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MeetingPlatformLoadingScreen(
          photoCard: widget.photoCard,
        ),
      ),
    );
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
                  child: RepaintBoundary(
                    key: _cardKey,
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
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
            margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
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
                Flexible(
                  child: Text(
                    widget.photoCard.destination,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
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
          SecondaryButton(
            text: _isSharing ? '공유 준비 중...' : 'SNS 공유하기',
            icon: _isSharing ? Icons.hourglass_empty_rounded : Icons.share_rounded,
            onPressed: _isSharing ? null : () => _shareCard(context),
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
