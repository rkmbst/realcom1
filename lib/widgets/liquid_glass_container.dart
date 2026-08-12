import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double opacity;
  final double blur;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(20),
    this.opacity = 0.06,
    this.blur = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.glassHighlight,
                blurRadius: 18,
                spreadRadius: -6,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
