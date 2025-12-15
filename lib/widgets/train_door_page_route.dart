import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TrainDoorPageRoute extends PageRouteBuilder {
  final Widget page;

  TrainDoorPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 1400), // Slightly slower for elegance
          reverseTransitionDuration: const Duration(milliseconds: 1200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _TrainDoorTransition(
              animation: animation,
              child: child,
            );
          },
        );
}

class _TrainDoorTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _TrainDoorTransition({
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
            
            // Left Door
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
                child: _DoorPanel(isLeft: true),
              ),
            ),
            
            // Right Door
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
                child: _DoorPanel(isLeft: false),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DoorPanel extends StatelessWidget {
  final bool isLeft;

  const _DoorPanel({required this.isLeft});

  @override
  Widget build(BuildContext context) {
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
          // 1. Soft Decorative Lines (Top/Bottom)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            height: 1,
            child: Container(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            height: 1,
            child: Container(color: AppColors.primary.withValues(alpha: 0.2)),
          ),

          // 2. Window (Soft Rounded)
          Positioned(
            top: 160,
            left: isLeft ? 40 : 20,
            right: isLeft ? 20 : 40,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // Very rounded
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Outside view (Gradient Sky)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF87CEEB).withValues(alpha: 0.3), // Sky blue
                          const Color(0xFFFFE4E1).withValues(alpha: 0.3), // Misty rose
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.train_rounded, // Use rounded icon
                      size: 48,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  // Shine Reflection
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Branding (Soft Typography)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'KORAIL',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // 4. Handle (Minimalist Vertical Bar)
          Positioned(
            top: 0,
            bottom: 0,
            right: isLeft ? 10 : null,
            left: !isLeft ? 10 : null,
            width: 8, // Thinner
            child: Center( // Centered handle instead of full height
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
