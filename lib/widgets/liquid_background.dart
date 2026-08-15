import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Aurora atmosphere background.
///
/// The background remains dark and readable while semantic colors
/// create a soft ambient field behind the content.
class LiquidBackground extends StatelessWidget {
  final Color? primaryOrbColor;
  final Color? secondaryOrbColor;

  const LiquidBackground({
    super.key,
    this.primaryOrbColor,
    this.secondaryOrbColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryOrbColor ?? AppColors.secondary;
    final secondary = secondaryOrbColor ?? primary;

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main Aurora atmosphere.
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.15),
                radius: 1.05,
                colors: [
                  primary.withOpacity(0.24),
                  primary.withOpacity(0.10),
                  Colors.transparent,
                ],
                stops: const [
                  0.0,
                  0.42,
                  1.0,
                ],
              ),
            ),
          ),

          // Secondary softer atmosphere.
          AnimatedContainer(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.65, 0.85),
                radius: 1.0,
                colors: [
                  secondary.withOpacity(0.12),
                  secondary.withOpacity(0.035),
                  Colors.transparent,
                ],
                stops: const [
                  0.0,
                  0.45,
                  1.0,
                ],
              ),
            ),
          ),

          // Very subtle central breathing glow.
          AnimatedContainer(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.08),
                radius: 0.72,
                colors: [
                  primary.withOpacity(0.08),
                  primary.withOpacity(0.025),
                  Colors.transparent,
                ],
                stops: const [
                  0.0,
                  0.38,
                  1.0,
                ],
              ),
            ),
          ),

          // Dark readability veil.
          const IgnorePointer(
            child: ColoredBox(
              color: Color(0x220B0F14),
            ),
          ),
        ],
      ),
    );
  }
}
