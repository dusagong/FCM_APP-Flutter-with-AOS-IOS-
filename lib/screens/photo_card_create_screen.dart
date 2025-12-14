import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'photo_card_loading_screen.dart';

class PhotoCardCreateScreen extends StatefulWidget {
  final String imagePath;

  const PhotoCardCreateScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<PhotoCardCreateScreen> createState() => _PhotoCardCreateScreenState();
}

class _PhotoCardCreateScreenState extends State<PhotoCardCreateScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _customTagController = TextEditingController();
  final Set<String> _selectedHashtags = {};
  String? _selectedProvince;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  void _toggleHashtag(String tag) {
    setState(() {
      if (_selectedHashtags.contains(tag)) {
        _selectedHashtags.remove(tag);
      } else {
        if (_selectedHashtags.length < 10) {
          _selectedHashtags.add(tag);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('해시태그는 최대 10개까지 선택 가능합니다')),
          );
        }
      }
    });
  }

  void _addCustomHashtag() {
    final tag = _customTagController.text.trim();
    if (tag.isEmpty) return;

    if (_selectedHashtags.contains(tag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 추가된 해시태그입니다')),
      );
      return;
    }

    if (_selectedHashtags.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('해시태그는 최대 10개까지 선택 가능합니다')),
      );
      return;
    }

    setState(() {
      _selectedHashtags.add(tag);
      _customTagController.clear();
    });
  }

  void _removeHashtag(String tag) {
    setState(() {
      _selectedHashtags.remove(tag);
    });
  }

  bool get _canCreate {
    return _messageController.text.trim().isNotEmpty &&
        _selectedProvince != null &&
        _selectedCity != null;
  }

  void _createPhotoCard() {
    if (!_canCreate) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoCardLoadingScreen(
          imagePath: widget.imagePath,
          message: _messageController.text.trim(),
          hashtags: _selectedHashtags.toList(),
          province: _selectedProvince!,
          city: _selectedCity!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '레일필름 생성'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            _buildImagePreview(),
            const SizedBox(height: 24),

            // Message Input
            _buildMessageSection(),
            const SizedBox(height: 24),

            // Hashtag Selection
            _buildHashtagSection(),
            const SizedBox(height: 24),

            // Destination Selection
            _buildDestinationSection(),
            const SizedBox(height: 32),

            // Create Button
            PrimaryButton(
              text: '레일필름 생성하기',
              onPressed: _canCreate ? _createPhotoCard : null,
              icon: Icons.auto_awesome_rounded,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.medium,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        );
  }

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('여행 메시지', style: AppTypography.titleMedium),
            const SizedBox(width: 8),
            Text('(필수)', style: AppTypography.bodySmall.copyWith(color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          maxLength: 50,
          maxLines: 3,
          minLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildHashtagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tag_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('여행 스타일', style: AppTypography.titleMedium),
            const SizedBox(width: 8),
            Text('(선택)', style: AppTypography.bodySmall),
          ],
        ),
        const SizedBox(height: 12),

        // Preset hashtags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HashtagPresets.presets.map((tag) {
            final isSelected = _selectedHashtags.contains(tag);
            return HashTagChip(
              label: tag,
              isSelected: isSelected,
              onTap: () => _toggleHashtag(tag),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Custom hashtag input
        Row(
          children: [
            const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Text('직접 입력', style: AppTypography.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customTagController,
                decoration: InputDecoration(
                  hintText: '해시태그 입력',
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onSubmitted: (_) => _addCustomHashtag(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addCustomHashtag,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
              child: const Text('추가'),
            ),
          ],
        ),

        // Selected hashtags
        if (_selectedHashtags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('선택된 해시태그:', style: AppTypography.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedHashtags.map((tag) {
              return HashTagChip(
                label: tag,
                isSelected: true,
                showRemove: true,
                onRemove: () => _removeHashtag(tag),
              );
            }).toList(),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildDestinationSection() {
    final cities = _selectedProvince != null
        ? RegionData.provinces[_selectedProvince] ?? []
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('여행 목적지', style: AppTypography.titleMedium),
            const SizedBox(width: 8),
            Text('(필수)', style: AppTypography.bodySmall.copyWith(color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: 12),

        // Province Dropdown
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedProvince,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            hint: const Text('도/광역시 선택'),
            items: RegionData.provinces.keys.map((province) {
              return DropdownMenuItem(
                value: province,
                child: Text(province),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProvince = value;
                _selectedCity = null;
              });
            },
          ),
        ),
        const SizedBox(height: 12),

        // City Dropdown
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            hint: const Text('시/군/구 선택'),
            items: cities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: _selectedProvince == null
                ? null
                : (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }
}
