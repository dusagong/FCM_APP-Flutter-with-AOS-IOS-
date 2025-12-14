import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class PhotoCardWidget extends StatelessWidget {
  final PhotoCard photoCard;
  final bool isFront;
  final double scale;

  const PhotoCardWidget({
    super.key,
    required this.photoCard,
    this.isFront = true,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: AspectRatio(
        aspectRatio: 3 / 5, // Standard photocard ratio roughly
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            child: isFront ? _buildFront(context) : _buildBack(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: const Color(0xFF1A1A1A),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                photoCard.destination.split(' ').first,
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.train_rounded, color: Colors.white, size: 16),
              ),
              Text(
                photoCard.city,
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        // Photo Area
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF5F5F5),
            child: photoCard.imagePath != null
                ? Image.file(
                    File(photoCard.imagePath!),
                    fit: BoxFit.cover,
                  )
                : CustomPaint(
                    painter: _PlaceholderPainter(),
                  ),
          ),
        ),

        // Details Area
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Hashtags
                if (photoCard.hashtags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: photoCard.hashtags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const Spacer(),

                // Date & Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabelValue('DATE', photoCard.formattedDate),
                    _buildLabelValue('LOC', photoCard.city),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 12),

                // Footer with QR
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: QrImageView(
                        data: 'ticket-${photoCard.id}',
                        version: QrVersions.auto,
                        size: 40,
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            photoCard.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBack(BuildContext context) {
    return Stack(
      children: [
        // Background Pattern
        Positioned.fill(
          child: CustomPaint(
            painter: _BackgroundPatternPainter(),
          ),
        ),
        
        Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: const Color(0xFF1A1A1A),
              width: double.infinity,
              child: Text(
                'TRAVEL RECORD',
                textAlign: TextAlign.center,
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 32,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      photoCard.aiQuote,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Transform.rotate(
                      angle: math.pi,
                      child: Icon(
                        Icons.format_quote_rounded,
                        size: 32,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Route Info
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRouteItem('FROM', photoCard.destination.split(' ').first),
                  Icon(Icons.arrow_right_alt_rounded, color: Colors.black26),
                  _buildRouteItem('TO', photoCard.city),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.black45,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.black45,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 20.0;
    for (var i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
