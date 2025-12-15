import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    return Stack(
      children: [
        Column(
          children: [
            // Header
            // Header (Rail Film Style)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFD4AF37), width: 2), // Gold accent
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, 
                        color: Colors.white54, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'RAIL FILM',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white70,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'NO. ${photoCard.id.substring(0, 4).toUpperCase()}',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white38,
                          fontFamily: 'Monospace',
                        ),
                      ),
                    ],
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
                        key: ValueKey('${photoCard.id}_image'), // Force rebuild mechanism
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded, color: Colors.grey),
                            ),
                          );
                        },
                      )
                      .animate(
                        onPlay: (controller) => controller.forward(from: 0),
                      )
                      .saturate(duration: 3000.ms, begin: 0, end: 1, curve: Curves.easeInOutCubic)
                      .fadeIn(duration: 2500.ms, curve: Curves.easeIn)
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
                              color: Colors.white.withOpacity(0.8), // Slightly transparent
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
                    
                    // (Inline stamp removed from here)

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
                            data: 'KORAIL RAIL FILM\nDATE: ${photoCard.formattedDate}\nSTATION: ${photoCard.city}\n"${photoCard.message}"',
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
        ),
        
        // Floating Destination Stamp
        Positioned(
          bottom: 80, // Positioned above the footer area
          left: 0,
          right: 0,
          child: Center(
            child: Transform.rotate(
              angle: 0.1, // Slight varying tilt
              child: _buildDestinationStamp(scale: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBack(BuildContext context) {
    return Stack(
      children: [
        // Background Pattern (Film Sprockets below header)
        Positioned.fill(
          child: CustomPaint(
            painter: _PostcardBackgroundPainter(),
          ),
        ),

        // Postmark (Below header)
        Positioned(
          top: 80,
          right: 30,
          child: Transform.rotate(
            angle: -0.2, 
            child: Opacity(
              opacity: 0.8,
              child: _PostmarkWidget(date: photoCard.formattedDate),
            ),
          ),
        ),

        // Watermark (Compass)
        Positioned(
          bottom: 20,
          left: 20,
          child: Opacity(
            opacity: 0.1,
            child: Icon(
              Icons.explore_outlined,
              size: 80,
              color: AppColors.primary,
            ),
          ),
        ),

        Column(
          children: [
            // Header (Rail Film Style) - No margin to keep full width feel or match front
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFD4AF37), width: 2), // Gold accent
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, 
                        color: Colors.white54, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'RAIL FILM',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white70,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'NO. ${photoCard.id.substring(0, 4).toUpperCase()}',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white38,
                          fontFamily: 'Monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24), // Padding to avoid sprockets
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      photoCard.aiQuote,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        height: 1.6,
                        fontFamily: 'Courier', // Typewriter style
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Destination Stamp
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 36, bottom: 24),
                child: _buildDestinationStamp(),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }

  // ... (keep existing methods)

  Widget _buildDestinationStamp({double scale = 1.0}) {
    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: -0.2, // Slight tilt
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DESTINATION',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                photoCard.city.toUpperCase(),
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                photoCard.formattedDate,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary.withOpacity(0.6),
                  fontFamily: 'Monospace',
                ),
              ),
            ],
          ),
        ),
      ),
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

class _PostcardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Film Sprockets (Left & Right) - Start below header (~60px)
    final sprocketPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double sprocketWidth = 12.0;
    const double sprocketHeight = 16.0;
    const double sprocketSpacing = 12.0;
    const double sideMargin = 6.0;

    // Draw background texture fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height), 
      Paint()..color = const Color(0xFFF9F9F9)
    );

    // Left & Right Sprockets - Start below header
    double y = 70; // Header is roughly 50-60, so 70 is safe spacing
    while (y < size.height - 20) {
      // Left
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sideMargin, y, sprocketWidth, sprocketHeight),
          const Radius.circular(2),
        ),
        sprocketPaint,
      );
      
      // Right
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - sideMargin - sprocketWidth, y, sprocketWidth, sprocketHeight),
          const Radius.circular(2),
        ),
        sprocketPaint,
      );
      
      y += sprocketHeight + sprocketSpacing;
    }

    // 2. Vintage Border (Inset)
    // Adjust top to be below header
    final borderRect = Rect.fromLTWH(
      30, 
      70, // Start below sprockets start
      size.width - 60, 
      size.height - 90
    );
    
    // Outer thin line
    canvas.drawRect(borderRect, borderPaint);
    
    // Inner thin line
    final innerBorderRect = borderRect.deflate(3);
    canvas.drawRect(
      innerBorderRect, 
      Paint()
        ..color = const Color(0xFFD4AF37).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PostmarkWidget extends StatelessWidget {
  final String date;

  const _PostmarkWidget({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner Circle
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12, width: 1),
            ),
          ),
          // Text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'RAIL FILM',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Colors.black38,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  date,
                  maxLines: 1,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'CHECKED',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
          // Waves
          Positioned(
            left: 0, 
            right: 0,
            top: 20,
            child: Divider(color: Colors.black12, thickness: 1),
          ),
          Positioned(
            left: 0, 
            right: 0,
            bottom: 20,
            child: Divider(color: Colors.black12, thickness: 1),
          ),
        ],
      ),
    );
  }
}


