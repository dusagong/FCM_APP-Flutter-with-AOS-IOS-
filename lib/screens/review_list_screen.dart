import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class ReviewListScreen extends StatelessWidget {
  final Place place;

  const ReviewListScreen({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '리뷰'),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final reviews = provider.getReviewsByPlace(place.id);
          final avgRating = provider.getAverageRating(place.id);

          return Column(
            children: [
              // Header
              _buildHeader(avgRating, reviews.length),
              // Reviews grid
              Expanded(
                child: reviews.isEmpty
                    ? const EmptyState(
                        icon: Icons.rate_review_rounded,
                        title: '아직 리뷰가 없습니다',
                        subtitle: '첫 번째 리뷰를 작성해보세요!',
                      )
                    : _buildReviewGrid(context, reviews),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(double avgRating, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (avgRating > 0) ...[
                      RatingStars(rating: avgRating, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '$count개의 리뷰',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewGrid(BuildContext context, List<Review> reviews) {
    // Collect all images from reviews
    final List<Map<String, dynamic>> imageData = [];
    for (var review in reviews) {
      for (var imageUrl in review.imageUrls) {
        imageData.add({
          'imageUrl': imageUrl,
          'review': review,
        });
      }
    }

    if (imageData.isEmpty) {
      // Show reviews without images as list
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          return _ReviewCard(review: reviews[index], index: index);
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: imageData.length,
      itemBuilder: (context, index) {
        final data = imageData[index];
        return _ReviewImageTile(
          imageUrl: data['imageUrl'],
          review: data['review'],
          index: index,
          onTap: () => _showReviewDetail(context, data['review']),
        );
      },
    );
  }

  void _showReviewDetail(BuildContext context, Review review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewDetailModal(review: review),
    );
  }
}

class _ReviewImageTile extends StatelessWidget {
  final String imageUrl;
  final Review review;
  final int index;
  final VoidCallback onTap;

  const _ReviewImageTile({
    required this.imageUrl,
    required this.review,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
        ),
        child: _buildImage(),
      ).animate().fadeIn(
            delay: Duration(milliseconds: 50 * index),
            duration: 200.ms,
          ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.image_rounded, color: AppColors.textTertiary),
        ),
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.image_not_supported_rounded, color: AppColors.textTertiary),
        ),
      );
    }
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2), // Sharp corners like paper? Or rounded paper. Let's go with slightly rounded.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Stamp-like rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toString(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                review.formattedDate,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontFamily: 'Monospace', // Typewriter feel? Or just simple
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            review.content,
            style: AppTypography.bodyMedium.copyWith(
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // User info or "Traveler" label
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'by Traveler',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 300.ms,
        );
  }
}

class _ReviewDetailModal extends StatefulWidget {
  final Review review;

  const _ReviewDetailModal({required this.review});

  @override
  State<_ReviewDetailModal> createState() => _ReviewDetailModalState();
}

class _ReviewDetailModalState extends State<_ReviewDetailModal> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
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
          // Rating and date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                RatingStars(rating: widget.review.rating.toDouble(), size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.review.rating.toString(),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.review.formattedDate,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Main image
          if (widget.review.imageUrls.isNotEmpty) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  child: _buildCurrentImage(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Thumbnails
            if (widget.review.imageUrls.length > 1)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.review.imageUrls.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentImageIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _currentImageIndex = index),
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppBorderRadius.sm - 2),
                          child: _buildThumbnail(widget.review.imageUrls[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              widget.review.content,
              style: AppTypography.bodyMedium,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCurrentImage() {
    if (widget.review.imageUrls.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(Icons.image_rounded, size: 64, color: AppColors.textTertiary),
        ),
      );
    }

    final imageUrl = widget.review.imageUrls[_currentImageIndex];
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.surfaceVariant,
            child: const Center(
              child: Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textTertiary),
            ),
          );
        },
      );
    }
  }

  Widget _buildThumbnail(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, fit: BoxFit.cover);
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image_rounded, size: 24, color: AppColors.textTertiary));
        },
      );
    }
  }
}
