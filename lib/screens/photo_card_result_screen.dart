import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import '../widgets/train_door_page_route.dart';
import '../services/travel_api_service.dart';
import '../widgets/photo_card_widget.dart';
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
  final GlobalKey _shareKey = GlobalKey();

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
          TrainDoorPageRoute(
            page: MeetingPlatformLoadingScreen(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '코레일 러브레일필름',
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                              ? PhotoCardWidget(
                                  photoCard: widget.photoCard,
                                  isFront: true,
                                )
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(math.pi),
                                  child: PhotoCardWidget(
                                    photoCard: widget.photoCard,
                                    isFront: false,
                                  ),
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
          Container(
            key: _shareKey,
            width: double.infinity,
            child: SecondaryButton(
              text: _isSharing ? '공유 준비 중...' : 'SNS 공유하기',
              icon: _isSharing ? Icons.hourglass_empty_rounded : Icons.share_rounded,
              onPressed: _isSharing ? null : () => _shareCard(context),
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


