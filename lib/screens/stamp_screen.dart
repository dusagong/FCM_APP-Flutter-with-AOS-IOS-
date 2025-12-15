import 'dart:io';
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stamp.isCompleted
            ? AppColors.secondary.withOpacity(0.05)
            : AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stamp.isCompleted
              ? AppColors.secondary.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 코스 타이틀 & 완료 상태
          Row(
            children: [
              Expanded(
                child: Text(
                  stamp.courseTitle,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (stamp.isCompleted) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '완료',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // 진행률 바
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '진행률',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${stamp.completedStopCount}/${stamp.totalStopCount} 완료 (${stamp.progressPercent}%)',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: stamp.progressRate,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stamp.isCompleted ? AppColors.secondary : AppColors.primary,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 정차지 진행상황
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stamp.stopProgresses.map((progress) {
              return _StopProgressChip(progress: progress);
            }).toList(),
          ),

          // 완료 날짜
          if (stamp.completedAt != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: 14,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${stamp.completedAt!.year}.${stamp.completedAt!.month}.${stamp.completedAt!.day} 완료',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
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

class _StopProgressChip extends StatelessWidget {
  final StopProgress progress;

  const _StopProgressChip({required this.progress});

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress.isCompleted;
    final isTourist = progress.category == '관광지';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.secondary.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppColors.secondary.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 순서 번호
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.secondary
                  : AppColors.textTertiary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${progress.order}',
                style: TextStyle(
                  color: isCompleted ? Colors.white : AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // 장소명
          Text(
            progress.stopName,
            style: AppTypography.labelSmall.copyWith(
              color: isCompleted
                  ? AppColors.secondary
                  : AppColors.textPrimary,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 6),
          // 상태 아이콘들
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 쿠폰 (관광지가 아닌 경우만)
              if (!isTourist)
                Icon(
                  progress.hasCoupon
                      ? Icons.local_offer_rounded
                      : Icons.local_offer_outlined,
                  size: 14,
                  color: progress.hasCoupon
                      ? AppColors.secondary
                      : AppColors.textTertiary.withOpacity(0.5),
                ),
              if (!isTourist) const SizedBox(width: 4),
              // 리뷰
              Icon(
                progress.hasReview
                    ? Icons.rate_review_rounded
                    : Icons.rate_review_outlined,
                size: 14,
                color: progress.hasReview
                    ? AppColors.secondary
                    : AppColors.textTertiary.withOpacity(0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
