import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'camera_screen.dart';

class PhotoCardListScreen extends StatelessWidget {
  const PhotoCardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '나의 포토카드'),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final photoCards = provider.photoCards;

          if (photoCards.isEmpty) {
            return EmptyState(
              icon: Icons.photo_camera_rounded,
              title: '아직 포토카드가 없습니다',
              subtitle: '여정사진관에서 첫 포토카드를 만들어보세요!',
              actionLabel: '첫 포토카드 만들기',
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

  void _toggleCard() {
    setState(() => _showFront = !_showFront);
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _toggleCard,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _showFront
                      ? _buildFrontCard()
                      : _buildBackCard(),
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

  Widget _buildFrontCard() {
    return Container(
      key: const ValueKey('front'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppBorderRadius.xl),
              ),
            ),
            child: Center(
              child: Text(
                'KORAIL LOVE PHOTO CARD',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          // Image
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                child: widget.photoCard.imagePath != null
                    ? Image.file(
                        File(widget.photoCard.imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.photo_rounded, size: 48),
                      ),
              ),
            ),
          ),
          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '"${widget.photoCard.message}"',
              style: AppTypography.bodyMedium.copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 8),
          // Hashtags
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            children: widget.photoCard.hashtags.take(3).map((tag) {
              return Text('#$tag', style: AppTypography.hashTag.copyWith(fontSize: 12));
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Location
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppBorderRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  widget.photoCard.destination,
                  style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
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
      key: const ValueKey('back'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.twilightGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '"${widget.photoCard.aiQuote}"',
              style: AppTypography.photoCardQuote.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.train_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'KORAIL',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
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
          SecondaryButton(
            text: 'SNS 공유하기',
            icon: Icons.share_rounded,
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
    );
  }
}
