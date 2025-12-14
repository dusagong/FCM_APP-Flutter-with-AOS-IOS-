import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class ReviewWriteScreen extends StatefulWidget {
  final Place? place;
  final String? placeName;
  final String? placeCategory;
  final bool fromReviewablePlaces;

  const ReviewWriteScreen({
    super.key,
    this.place,
    this.placeName,
    this.placeCategory,
    this.fromReviewablePlaces = false,
  }) : assert(place != null || placeName != null, 'place 또는 placeName 중 하나는 필수입니다');

  String get displayName => place?.name ?? placeName ?? '';
  String get placeId => place?.id ?? 'api_$displayName';
  String get displayLocation => place?.location ?? '';

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진은 최대 5장까지 추가할 수 있습니다')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _selectedImages.add(image));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 선택할 수 없습니다')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  bool get _canSubmit {
    return _rating > 0 && _contentController.text.trim().isNotEmpty;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final provider = context.read<AppProvider>();
    final review = Review(
      id: const Uuid().v4(),
      placeId: widget.placeId,
      placeName: widget.displayName,
      rating: _rating,
      content: _contentController.text.trim(),
      imageUrls: _selectedImages.map((x) => x.path).toList(),
      createdAt: DateTime.now(),
    );

    provider.addReview(review);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('리뷰가 등록되었습니다!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '리뷰 작성'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Place info
            _buildPlaceInfo(),
            const SizedBox(height: 24),

            // Rating
            _buildRatingSection(),
            const SizedBox(height: 24),

            // Photos
            _buildPhotoSection(),
            const SizedBox(height: 24),

            // Content
            _buildContentSection(),
            const SizedBox(height: 32),

            // Submit button
            PrimaryButton(
              text: '등록하기',
              onPressed: _canSubmit ? _submit : null,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.displayName,
                  style: AppTypography.titleMedium,
                ),
                if (widget.displayLocation.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.displayLocation,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Text('별점을 선택해주세요', style: AppTypography.titleMedium),
            const SizedBox(width: 8),
            Text('(필수)', style: AppTypography.bodySmall.copyWith(color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = starIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  starIndex <= _rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: AppColors.accent,
                  size: 48,
                ),
              ),
            );
          }),
        ),
        if (_rating > 0) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              _getRatingText(_rating),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return '별로예요';
      case 2:
        return '그저 그래요';
      case 3:
        return '괜찮아요';
      case 4:
        return '좋아요';
      case 5:
        return '최고예요!';
      default:
        return '';
    }
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_camera_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('사진 추가', style: AppTypography.titleMedium),
            const SizedBox(width: 8),
            Text('(선택, 최대 5장)', style: AppTypography.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_rounded,
                        color: AppColors.textSecondary,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedImages.length}/5',
                        style: AppTypography.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
              // Selected images
              ...List.generate(_selectedImages.length, (index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        boxShadow: AppShadows.small,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image_rounded, size: 24, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('리뷰 작성', style: AppTypography.titleMedium), // Reverted back to explicit Review Write
            const SizedBox(width: 8),
            Text('(필수)', style: AppTypography.bodySmall.copyWith(color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200, // Fixed height for diary look
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF5), // Warm paper color
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            boxShadow: AppShadows.small,
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              // Lined Paper Pattern
              IgnorePointer(
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: _LinedPaperPainter(),
                ),
              ),
              // Text Field
              TextField(
                controller: _contentController,
                maxLines: null, // Allow unlimited lines
                expands: true,
                style: AppTypography.bodyMedium.copyWith(
                  height: 1.8, // Match line height
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '이곳에서의 추억을 기록해보세요...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary.withOpacity(0.5),
                    height: 1.8,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 300.ms);
  }
}

class _LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.5)
      ..strokeWidth = 1;

    // Line height must match TextField style height * fontSize
    // Assuming bodyMedium size is 14 or 16. Let's say 16 * 1.8 = ~28.8
    // We might need to tune this to match exact text alignment.
    // Standard approach: just draw lines at regular intervals.
    
    double lineHeight = 28.0; // Approx match
    double startY = 36.0; // Initial padding top
    
    while (startY < size.height) {
      canvas.drawLine(Offset(20, startY), Offset(size.width - 20, startY), paint);
      startY += lineHeight;
    }
    
    // Vertical margin line (red)
    final marginPaint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(60, 0), Offset(60, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
