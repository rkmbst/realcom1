import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/session/app_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/haptics.dart';
import '../../widgets/glass_wheel_painter.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import 'local_question_screen.dart';

class LocalWheelScreen extends StatefulWidget {
  const LocalWheelScreen({super.key});

  @override
  State<LocalWheelScreen> createState() => _LocalWheelScreenState();
}

class _LocalWheelScreenState extends State<LocalWheelScreen>
    with SingleTickerProviderStateMixin {
  final AppSession _session = AppSession.instance;

  late final AnimationController _controller;

  final Random _random = Random();

  double _rotation = 0;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();

    if (_session.roundQuestions.isEmpty) {
      _session.prepareRound();
    }

    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() {
          _rotation = _controller.value;
        });
      });
  }

  Future<void> _spin() async {
    if (_isSpinning || _session.roundQuestions.isEmpty) return;

    final unusedIndexes = _session.unusedRoundIndexes();

    if (unusedIndexes.isEmpty) {
      _showRoundCompleteDialog();
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    Haptics.medium();

    final selectedIndex = unusedIndexes[_random.nextInt(unusedIndexes.length)];
    final segmentAngle = (2 * pi) / _session.roundQuestions.length;

    final targetAngle = -pi / 2 - (selectedIndex + 0.5) * segmentAngle;
    final extraTurns = 5 + _random.nextInt(4);

    final currentMod = _rotation % (2 * pi);

    double delta = (targetAngle - currentMod) % (2 * pi);

    if (delta < 0) {
      delta += 2 * pi;
    }

    final targetRotation = _rotation + extraTurns * 2 * pi + delta;

    final simulation = SpringSimulation(
      const SpringDescription(
        mass: 1,
        stiffness: 90,
        damping: 18,
      ),
      _rotation,
      targetRotation,
      0,
    );

    _controller.animateWith(simulation);

    await Future.delayed(const Duration(milliseconds: 4200));

    if (!mounted) return;

    _controller.stop();

    _session.markQuestionUsed(_session.roundQuestions[selectedIndex].id);

    setState(() {
      _isSpinning = false;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocalQuestionScreen(
          question: _session.roundQuestions[selectedIndex],
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _showRoundCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'اكتملت الجولة',
            style: AppTextStyles.titleLarge,
          ),
          content: const Text(
            'تم استخدام جميع أسئلة هذه الجولة.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'خروج',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                _session.resetRound();
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text(
                'إعادة الجولة',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wheelSize = MediaQuery.of(context).size.width * 0.82;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('عجلة الجلسة'),
      ),
      body: Stack(
        children: [
          const LiquidBackground(),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  LiquidGlassContainer(
                    borderRadius: 999,
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      width: wheelSize,
                      height: wheelSize,
                      child: CustomPaint(
                        painter: GlassWheelPainter(
                          segmentCount: _session.roundQuestions.length,
                          rotation: _rotation,
                          usedIndexes: _session.usedRoundIndexes(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '${_session.roundQuestions.length} أسئلة في الجولة',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ElevatedButton.icon(
                      onPressed: _isSpinning ? null : _spin,
                      icon: const Icon(Icons.casino),
                      label: Text(_isSpinning ? 'جاري الدوران...' : 'دور العجلة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
