import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AuroraTitaniumWheel extends StatelessWidget {
  const AuroraTitaniumWheel({
    super.key,
    required this.rotation,
    this.size = 340,
    this.selectedSlot,
  });

  final double rotation;
  final double size;
  final int? selectedSlot;

  static const int slotCount = 12;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Very subtle Aurora atmosphere behind the wheel.
          IgnorePointer(
            child: Container(
              width: size * 0.86,
              height: size * 0.86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 42,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          // Titanium wheel.
          RepaintBoundary(
            child: Transform.rotate(
              angle: rotation,
              child: Image.asset(
                'assets/images/aurora_titanium_wheel.png',
                width: size,
                height: size,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),

          // Fixed pointer at 12 o'clock.
          const Positioned(
            top: 0,
            child: _WheelPointer(),
          ),

          // Highlight the selected position after the wheel settles.
          if (selectedSlot != null)
            _SelectedSlotGlow(
              slot: selectedSlot!,
              size: size,
            ),
        ],
      ),
    );
  }
}

class _WheelPointer extends StatelessWidget {
  const _WheelPointer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 34),
      painter: _PointerPainter(),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(2, 2)
      ..lineTo(size.width - 2, 2)
      ..close();

    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    final highlight = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final highlightPath = Path()
      ..moveTo(size.width / 2, size.height - 5)
      ..lineTo(7, 5)
      ..lineTo(size.width / 2, 5)
      ..close();

    canvas.drawPath(highlightPath, highlight);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) => false;
}

class _SelectedSlotGlow extends StatelessWidget {
  const _SelectedSlotGlow({
    required this.slot,
    required this.size,
  });

  final int slot;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Slot I is at 12 o'clock.
    final angle = -pi / 2 + slot * (2 * pi / 12);

    // Approximate center of the engraved-number ring.
    final radius = size * 0.38;
    final center = size / 2;

    final x = center + cos(angle) * radius;
    final y = center + sin(angle) * radius;

    return Positioned(
      left: x - 18,
      top: y - 18,
      child: IgnorePointer(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.32),
                blurRadius: 18,
                spreadRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
