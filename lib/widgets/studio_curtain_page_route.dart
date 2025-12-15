import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StudioCurtainPageRoute extends PageRouteBuilder {
  final Widget page;

  StudioCurtainPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 1400),
          reverseTransitionDuration: const Duration(milliseconds: 1200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _CurtainTransition(
              animation: animation,
              child: child,
            );
          },
        );
}

class _CurtainTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _CurtainTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final val = animation.value;
        double slidePercent;
        
        if (val < 0.4) {
          slidePercent = val / 0.4; 
        } else if (val < 0.6) {
          slidePercent = 1.0;
        } else {
          slidePercent = 1.0 - ((val - 0.6) / 0.4);
        }

        final showNewPage = val > 0.5;

        return Stack(
          children: [
            if (showNewPage) child,
            
            // Left Panel
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: MediaQuery.of(context).size.width / 2,
              child: Transform.translate(
                offset: Offset(
                  (-1.0 + slidePercent) * (MediaQuery.of(context).size.width / 2),
                  0,
                ),
                child: _StudioPanel(isLeft: true),
              ),
            ),
            
            // Right Panel
            Positioned(
              top: 0,
              bottom: 0,
              left: MediaQuery.of(context).size.width / 2,
              right: 0,
              child: Transform.translate(
                offset: Offset(
                  (1.0 - slidePercent) * (MediaQuery.of(context).size.width / 2),
                  0,
                ),
                child: _StudioPanel(isLeft: false),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StudioPanel extends StatelessWidget {
  final bool isLeft;

  const _StudioPanel({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    // Matching the TrainDoorPageRoute color palette for consistency
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF), // Very light soft blue/white
        border: Border(
           right: isLeft 
             ? BorderSide(color: AppColors.primary.withValues(alpha: 0.1), width: 1) 
             : BorderSide.none,
           left: !isLeft 
             ? BorderSide(color: AppColors.primary.withValues(alpha: 0.1), width: 1) 
             : BorderSide.none,
        ),
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            Colors.white,
            const Color(0xFFE3F2FD), // Light Blue
            const Color(0xFFE1EBF5),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 1. Decorative Lines (Matching Train Door style but purely cosmetic)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            height: 1,
            child: Container(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            height: 1,
            child: Container(color: AppColors.primary.withValues(alpha: 0.1)),
          ),

          // 2. The "Studio Frame" (Similar to Train Window, but rectangular portrait)
          Positioned(
            top: 180, // Slightly lower
            left: isLeft ? 40 : 20,
            right: isLeft ? 20 : 40,
            height: 240, // Height of a photo frame
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), // Less rounded than train window (Photo Card shape)
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                   // Inner Content: Soft Flash Gradient
                   Container(
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(16),
                       gradient: LinearGradient(
                         begin: Alignment.topLeft,
                         end: Alignment.bottomRight,
                         colors: [
                           Colors.white,
                           const Color(0xFFF5F9FF),
                         ],
                       ),
                     ),
                   ),
                   // Icon
                   Center(
                     child: Icon(
                       Icons.camera_rounded, // Rounded Camera
                       size: 56, // Slightly larger
                       color: AppColors.primary.withValues(alpha: 0.6), // Much more visible
                     ),
                   ),
                   // Corner Accents (Like a viewfinder/photo corners)
                   Positioned(
                     top: 10, left: 10,
                     child: _CornerMark(),
                   ),
                   Positioned(
                     top: 10, right: 10,
                     child: _CornerMark(),
                   ),
                   Positioned(
                     bottom: 10, left: 10,
                     child: _CornerMark(),
                   ),
                   Positioned(
                     bottom: 10, right: 10,
                     child: _CornerMark(),
                   ),
                ],
              ),
            ),
          ),

          // 3. Typography (Consistent with Train Door)
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '여정사진관',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
    );
  }
}
