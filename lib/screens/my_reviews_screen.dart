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

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _ReviewGridItem(
                review: review,
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}

class _ReviewGridItem extends StatelessWidget {
  final Review review;
  final int index;

  const _ReviewGridItem({
    required this.review,
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
          builder: (_) => _ReviewDetailModal(review: review),
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
                  child: review.imageUrls.isNotEmpty
                      ? _buildImage(review.imageUrls.first)
                      : Center(
                          child: Icon(
                            Icons.rate_review_rounded,
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
                          review.placeName,
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
                  Row(
                    children: [
                      RatingStars(rating: review.rating.toDouble(), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        review.formattedDate,
                        style: AppTypography.labelSmall,
                      ),
                    ],
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

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surfaceVariant,
          child: const Icon(Icons.image_rounded, color: AppColors.textTertiary),
        ),
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surfaceVariant,
          child: const Icon(Icons.image_rounded, color: AppColors.textTertiary),
        ),
      );
    }
  }
}

class _ReviewDetailModal extends StatelessWidget {
  final Review review;

  const _ReviewDetailModal({required this.review});

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
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images
                  if (review.imageUrls.isNotEmpty) ...[
                    SizedBox(
                      height: 250,
                      child: PageView.builder(
                        itemCount: review.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                              child: _buildImage(review.imageUrls[index]),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Place name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          review.placeName,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rating
                  Row(
                    children: [
                      RatingStars(rating: review.rating.toDouble(), size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '${review.rating}.0',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.formattedDate,
                    style: AppTypography.labelSmall,
                  ),
                  const SizedBox(height: 24),
                  // Review content
                  Text(
                    review.content,
                    style: AppTypography.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surfaceVariant,
          child: const Center(
            child: Icon(Icons.image_rounded, color: AppColors.textTertiary, size: 48),
          ),
        ),
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surfaceVariant,
          child: const Center(
            child: Icon(Icons.image_rounded, color: AppColors.textTertiary, size: 48),
          ),
        ),
      );
    }
  }
}
