import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class GlassWheelPainter extends CustomPainter {
  final int segmentCount;
  final double rotation;
  final Set<int> usedIndexes;

  GlassWheelPainter({
    required this.segmentCount,
    required this.rotation,
    required this.usedIndexes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segmentCount <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = (2 * pi) / segmentCount;

    final glassPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.02),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, glassPaint);

    final linePaint = Paint()
      ..color = AppColors.divider.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < segmentCount; i++) {
      final angle = rotation + i * segmentAngle;

      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        linePaint,
      );
    }

    for (int i = 0; i < segmentCount; i++) {
      final textAngle = rotation + i * segmentAngle + segmentAngle / 2;
      final textRadius = radius * 0.72;

      final textOffset = Offset(
        center.dx + textRadius * cos(textAngle),
        center.dy + textRadius * sin(textAngle),
      );

      final isUsed = usedIndexes.contains(i);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: AppTextStyles.titleLarge.copyWith(
            color: isUsed ? AppColors.textDisabled : AppColors.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    final borderPaint = Paint()
      ..color = AppColors.glassBorder
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant GlassWheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.segmentCount != segmentCount ||
        oldDelegate.usedIndexes != usedIndexes;
  }
}
