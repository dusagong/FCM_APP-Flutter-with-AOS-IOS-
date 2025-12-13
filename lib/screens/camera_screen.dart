import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import 'photo_card_create_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  bool _isCapturing = false;

  Future<void> _takePicture() async {
    setState(() => _isCapturing = true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (photo != null) {
        setState(() => _capturedImage = photo);
      }
    } catch (e) {
      // If camera not available, try gallery
      _pickFromGallery();
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (photo != null) {
        setState(() => _capturedImage = photo);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 선택할 수 없습니다')),
        );
      }
    }
  }

  void _retake() {
    setState(() => _capturedImage = null);
  }

  void _usePhoto() {
    if (_capturedImage == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoCardCreateScreen(imagePath: _capturedImage!.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          _capturedImage == null ? '사진 촬영' : '사진 확인',
          style: AppTypography.headlineSmall.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _capturedImage == null
          ? _buildCameraView()
          : _buildPreviewView(),
    );
  }

  Widget _buildCameraView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    size: 80,
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '커플 사진을 촬영해보세요',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '특별한 추억을 포토카드로 만들어 드려요',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms),
            ),
          ),
        ),
        _buildCameraControls(),
      ],
    );
  }

  Widget _buildCameraControls() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          _buildControlButton(
            icon: Icons.photo_library_rounded,
            onTap: _pickFromGallery,
          ),
          // Capture button
          GestureDetector(
            onTap: _isCapturing ? null : _takePicture,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCapturing ? Colors.grey : Colors.white,
                  ),
                  child: _isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
          // Flip camera (placeholder)
          _buildControlButton(
            icon: Icons.flip_camera_ios_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildPreviewView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              boxShadow: AppShadows.large,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              child: Image.file(
                File(_capturedImage!.path),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
              ),
        ),
        _buildPreviewControls(),
      ],
    );
  }

  Widget _buildPreviewControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _retake,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
              ),
              child: const Text('다시 찍기'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _usePhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
              ),
              child: const Text('사용하기'),
            ),
          ),
        ],
      ),
    );
  }
}
