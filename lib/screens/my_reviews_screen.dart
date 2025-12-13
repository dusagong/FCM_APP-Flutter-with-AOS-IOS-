import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '내가 쓴 리뷰'),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final reviews = provider.myReviews;

          if (reviews.isEmpty) {
            return const EmptyState(
              icon: Icons.rate_review_rounded,
              title: '작성한 리뷰가 없습니다',
              subtitle: '장소를 방문하고 리뷰를 작성해보세요!',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return _ReviewCard(
                review: reviews[index],
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final int index;

  const _ReviewCard({
    required this.review,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with place name
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppBorderRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.placeName,
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        review.formattedDate,
                        style: AppTypography.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating
                Row(
                  children: [
                    RatingStars(rating: review.rating.toDouble(), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      review.rating.toString(),
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Images
                if (review.imageUrls.isNotEmpty) ...[
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: review.imageUrls.length,
                      itemBuilder: (context, imgIndex) {
                        return Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                            child: _buildImage(review.imageUrls[imgIndex]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Review content
                Text(
                  review.content,
                  style: AppTypography.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 300.ms,
        ).slideY(begin: 0.1, end: 0);
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surfaceVariant,
          child: const Icon(Icons.image_rounded, color: AppColors.textTertiary),
        ),
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surfaceVariant,
          child: const Icon(Icons.image_rounded, color: AppColors.textTertiary),
        ),
      );
    }
  }
}
