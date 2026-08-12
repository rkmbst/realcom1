import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Animated liquid background with dynamic color support.
class LiquidBackground extends StatefulWidget {
  final Color? primaryOrbColor;
  final Color? secondaryOrbColor;

  const LiquidBackground({
    super.key,
    this.primaryOrbColor,
    this.secondaryOrbColor,
  });

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground> {
  late Color _primaryColor;
  late Color _secondaryColor;

  @override
  void initState() {
    super.initState();
    _primaryColor = widget.primaryOrbColor ?? AppColors.primary;
    _secondaryColor = widget.secondaryOrbColor ?? AppColors.secondary;
  }

  @override
  void didUpdateWidget(LiquidBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.primaryOrbColor != oldWidget.primaryOrbColor ||
        widget.secondaryOrbColor != oldWidget.secondaryOrbColor) {
      setState(() {
        _primaryColor = widget.primaryOrbColor ?? AppColors.primary;
        _secondaryColor = widget.secondaryOrbColor ?? AppColors.secondary;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      color: AppColors.background,
      child: Stack(
        children: [
          // Primary orb (top-right)
          Positioned(
            top: -120,
            right: -100,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _primaryColor.withOpacity(0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Secondary orb (bottom-left)
          Positioned(
            bottom: -140,
            left: -120,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _secondaryColor.withOpacity(0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Center subtle glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.3,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _primaryColor.withOpacity(0.10),
                    Colors.transparent,
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
