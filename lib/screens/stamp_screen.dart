import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class StampScreen extends StatelessWidget {
  const StampScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '스탬프 컬렉션'),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final photoCards = provider.photoCards;

          if (photoCards.isEmpty) {
            return const EmptyState(
              icon: Icons.approval_rounded,
              title: '아직 스탬프가 없습니다',
              subtitle: '레일필름을 만들고 코스를 완료해보세요!',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: photoCards.length,
            itemBuilder: (context, index) {
              final card = photoCards[index];
              final stamps = provider.getStampsByPhotoCard(card.id);

              return _PhotoCardStampSection(
                photoCard: card,
                stamps: stamps,
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}

class _PhotoCardStampSection extends StatelessWidget {
  final PhotoCard photoCard;
  final List<CourseStamp> stamps;
  final int index;

  const _PhotoCardStampSection({
    required this.photoCard,
    required this.stamps,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 포토카드 헤더
          _buildPhotoCardHeader(),

          // 스탬프 목록
          if (stamps.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.approval_outlined,
                      size: 48,
                      color: AppColors.textTertiary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '코스를 추천받고 완료하면\n스탬프를 받을 수 있어요!',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...stamps.asMap().entries.map((entry) {
              return _StampCard(
                stamp: entry.value,
                stampIndex: entry.key,
              );
            }),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 300.ms,
        ).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPhotoCardHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.lg),
        ),
      ),
      child: Row(
        children: [
          // 이미지 썸네일
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: photoCard.imagePath != null
                  ? Image.file(
                      File(photoCard.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.photo_rounded,
                        color: AppColors.textTertiary,
                      ),
                    )
                  : const Icon(
                      Icons.photo_rounded,
                      color: AppColors.textTertiary,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${photoCard.province} ${photoCard.city}',
                        style: AppTypography.titleSmall.copyWith(
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
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // 스탬프 개수 (전체 정차지 완료 / 전체 정차지)
          Builder(
            builder: (context) {
              final totalStops = stamps.fold<int>(
                0, (sum, s) => sum + s.totalStopCount);
              final completedStops = stamps.fold<int>(
                0, (sum, s) => sum + s.completedStopCount);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: stamps.isEmpty
                      ? AppColors.textTertiary.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.approval_rounded,
                      size: 16,
                      color: stamps.isEmpty
                          ? AppColors.textTertiary
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$completedStops/$totalStops',
                      style: AppTypography.labelMedium.copyWith(
                        color: stamps.isEmpty
                            ? AppColors.textTertiary
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StampCard extends StatelessWidget {
  final CourseStamp stamp;
  final int stampIndex;

  const _StampCard({
    required this.stamp,
    required this.stampIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5), // Slightly warmer paper color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 코스 타이틀 & 완료 상태
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COURSE ${stampIndex + 1}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stamp.courseTitle,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (stamp.isCompleted) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'COMPLETED',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 24),

          // 스탬프 그리드 (Ink Stamps)
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: stamp.stopProgresses.map((progress) {
                return _InkStamp(stop: progress);
              }).toList(),
            ),
          ),

          // 완료 날짜
          if (stamp.completedAt != null) ...[
            const SizedBox(height: 24),
            Divider(color: AppColors.border.withOpacity(0.5)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Stamped on ${stamp.completedAt!.year}.${stamp.completedAt!.month.toString().padLeft(2,'0')}.${stamp.completedAt!.day.toString().padLeft(2,'0')}',
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InkStamp extends StatelessWidget {
  final StopProgress stop;

  const _InkStamp({required this.stop});

  @override
  Widget build(BuildContext context) {
    // Generate a consistent random seed based on stop name to keep visual consistent
    // We use a predefined seed so it doesn't jitter on rebuilds
    final random = math.Random(stop.stopName.hashCode);
    final rotation = (random.nextDouble() - 0.5) * 0.4; // -0.2 to 0.2 rad
    final isBlue = random.nextBool(); // Randomize ink color slightly (Blue vs Red)
    
    // Completed: Vivid Ink. Incomplete: Faint Gray Outline.
    final inkColor = stop.isCompleted
        ? (isBlue ? const Color(0xFF1A237E) : const Color(0xFFB71C1C)).withOpacity(0.8)
        : AppColors.textTertiary.withOpacity(0.2);
    
    final borderColor = stop.isCompleted
        ? inkColor
        : AppColors.textTertiary.withOpacity(0.15);

    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: 2.5,
          ),
          borderRadius: _getShape(random.nextInt(3)), // Random shape
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (stop.isCompleted) ...[
              Icon(
                _getIconForCategory(stop.category),
                size: 20,
                color: inkColor.withOpacity(0.9),
              ),
              const SizedBox(height: 2),
            ] else ...[
              // Placeholder icon for incomplete
               Icon(
                Icons.help_outline_rounded,
                size: 20,
                color: inkColor,
              ),
              const SizedBox(height: 2),
            ],
            
            Text(
              stop.stopName.substring(0, math.min(stop.stopName.length, 8)).toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.w900,
                fontSize: 10,
                color: inkColor,
                height: 1.0,
              ),
            ),
            
            if (stop.isCompleted) 
              Text(
                'VISITED',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 7,
                  color: inkColor.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }

  BorderRadius _getShape(int type) {
    switch (type) {
      case 0: return BorderRadius.circular(50); // Circle
      case 1: return BorderRadius.circular(10); // Rounded Rect
      case 2: return BorderRadius.circular(4); // Sharp Rect
      default: return BorderRadius.circular(50);
    }
  }

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case '역': return Icons.train;
      case '관광지': return Icons.camera_alt;
      case '식당': return Icons.restaurant;
      case '카페': return Icons.coffee;
      default: return Icons.place;
    }
  }
}
