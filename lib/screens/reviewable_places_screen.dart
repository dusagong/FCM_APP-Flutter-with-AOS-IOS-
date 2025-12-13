import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'review_write_screen.dart';
import 'review_list_screen.dart';

class ReviewablePlacesScreen extends StatelessWidget {
  const ReviewablePlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '리뷰 작성 가능한 곳'),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final reviewablePlaces = provider.reviewablePlaces;

          if (reviewablePlaces.isEmpty) {
            return EmptyState(
              icon: Icons.edit_note_rounded,
              title: '리뷰 작성 가능한 장소가 없습니다',
              subtitle: '쿠폰을 사용하고 리뷰를 작성해보세요!',
              actionLabel: '만남승강장 둘러보기',
              onAction: () => Navigator.pop(context),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviewablePlaces.length,
            itemBuilder: (context, index) {
              return _ReviewablePlaceCard(
                reviewablePlace: reviewablePlaces[index],
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}

class _ReviewablePlaceCard extends StatelessWidget {
  final ReviewablePlace reviewablePlace;
  final int index;

  const _ReviewablePlaceCard({
    required this.reviewablePlace,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final place = provider.getPlaceById(reviewablePlace.placeId);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            boxShadow: AppShadows.small,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Place info
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reviewablePlace.placeName,
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '방문: ${reviewablePlace.formattedVisitDate}',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.full),
                      ),
                      child: Text(
                        '미작성',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: place != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReviewListScreen(place: place),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.rate_review_outlined, size: 18),
                        label: const Text('리뷰보기'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: place != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReviewWriteScreen(
                                      place: place,
                                      fromReviewablePlaces: true,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('리뷰작성'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(
              delay: Duration(milliseconds: 100 * index),
              duration: 300.ms,
            ).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
