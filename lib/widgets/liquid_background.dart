import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Aurora atmosphere background.
/// Keeps the base screen dark while allowing category / spin colors
/// to breathe through a soft, low-opacity ambient field.
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
    final primary = primaryOrbColor ?? AppColors.primary;
    final secondary = secondaryOrbColor ?? AppColors.secondary;

    return RepaintBoundary(
      child: ColoredBox(
        color: AppColors.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Large top-right atmosphere.
            Align(
              alignment: Alignment.topRight,
              child: FractionallySizedBox(
                widthFactor: 0.95,
                heightFactor: 0.58,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.48, -0.10),
                      radius: 0.95,
                      colors: [
                        primary.withOpacity(0.34),
                        primary.withOpacity(0.14),
                        primary.withOpacity(0.035),
                        Colors.transparent,
                      ],
                      stops: const [
                        0.0,
                        0.34,
                        0.68,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom-left secondary atmosphere.
            Align(
              alignment: Alignment.bottomLeft,
              child: FractionallySizedBox(
                widthFactor: 0.92,
                heightFactor: 0.50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.36, 0.58),
                      radius: 1.0,
                      colors: [
                        secondary.withOpacity(0.24),
                        secondary.withOpacity(0.09),
                        secondary.withOpacity(0.025),
                        Colors.transparent,
                      ],
                      stops: const [
                        0.0,
                        0.36,
                        0.70,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Soft central glow.
            Align(
              alignment: const Alignment(0, 0.08),
              child: FractionallySizedBox(
                widthFactor: 0.72,
                heightFactor: 0.42,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        primary.withOpacity(0.14),
                        primary.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // A subtle dark veil keeps text readable.
            const IgnorePointer(
              child: ColoredBox(
                color: Color(0x120B0F14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
