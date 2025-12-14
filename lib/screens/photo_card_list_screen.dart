import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/photo_card_widget.dart';
import '../services/travel_api_service.dart';
import 'camera_screen.dart';
import 'meeting_platform_loading_screen.dart';

class PhotoCardListScreen extends StatelessWidget {
  const PhotoCardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '나의 레일필름'),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final photoCards = provider.photoCards;

          if (photoCards.isEmpty) {
            return EmptyState(
              icon: Icons.photo_camera_rounded,
              title: '아직 레일필름이 없습니다',
              subtitle: '여정사진관에서 첫 레일필름를 만들어보세요!',
              actionLabel: '첫 레일필름 만들기',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CameraScreen()),
                );
              },
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: photoCards.length,
            itemBuilder: (context, index) {
              final card = photoCards[index];
              return _PhotoCardGridItem(
                photoCard: card,
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}

class _PhotoCardGridItem extends StatelessWidget {
  final PhotoCard photoCard;
  final int index;

  const _PhotoCardGridItem({
    required this.photoCard,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _PhotoCardDetailModal(photoCard: photoCard),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppBorderRadius.lg),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppBorderRadius.lg),
                  ),
                  child: photoCard.imagePath != null
                      ? Image.file(
                          File(photoCard.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 40,
                                color: AppColors.textTertiary.withValues(alpha: 0.5),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.photo_rounded,
                            size: 48,
                            color: AppColors.textTertiary.withValues(alpha: 0.5),
                          ),
                        ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          photoCard.city,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    photoCard.formattedDate,
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(
            delay: Duration(milliseconds: 100 * index),
            duration: 300.ms,
          ).slideY(begin: 0.1, end: 0),
    );
  }
}

class _PhotoCardDetailModal extends StatefulWidget {
  final PhotoCard photoCard;

  const _PhotoCardDetailModal({required this.photoCard});

  @override
  State<_PhotoCardDetailModal> createState() => _PhotoCardDetailModalState();
}

class _PhotoCardDetailModalState extends State<_PhotoCardDetailModal> {
  bool _showFront = true;
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;
  final GlobalKey _shareKey = GlobalKey();

  void _toggleCard() {
    setState(() => _showFront = !_showFront);
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
        // 검증 성공: 모달 닫고 만남승강장으로 이동
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingPlatformLoadingScreen(
              photoCard: widget.photoCard,
            ),
          ),
        );
      } else {
        // 검증 실패: 사용자에게 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('유효하지 않은 레일필름입니다. 다시 생성해주세요.'),
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
          content: Text('레일필름 검증 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _sharePhotoCard(BuildContext context) async {
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

      // 공유 버튼 위치 계산
      final box = _shareKey.currentContext?.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null 
          ? box.localToGlobal(Offset.zero) & box.size 
          : null;

      // 공유
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.photoCard.message}\n\n#코레일동행열차 #${widget.photoCard.city} ${widget.photoCard.hashtags.map((t) => '#$t').join(' ')}',
        sharePositionOrigin: sharePositionOrigin,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xxl),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: GestureDetector(
                onTap: _toggleCard,
                child: RepaintBoundary(
                  key: _cardKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: PhotoCardWidget(
                      key: ValueKey(_showFront),
                      photoCard: widget.photoCard,
                      isFront: _showFront,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Actions
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SecondaryButton(
            text: _showFront ? '뒷면 보기' : '앞면 보기',
            icon: Icons.flip_rounded,
            onPressed: _toggleCard,
          ),
          const SizedBox(height: 12),
          Container(
            key: _shareKey,
            width: double.infinity,
            child: SecondaryButton(
              text: _isSharing ? '공유 준비 중...' : 'SNS 공유하기',
              icon: _isSharing ? Icons.hourglass_empty_rounded : Icons.share_rounded,
              onPressed: _isSharing ? null : () => _sharePhotoCard(context),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: '만남승강장으로 이동',
            icon: Icons.door_sliding_rounded,
            onPressed: _goToMeetingPlatform,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
