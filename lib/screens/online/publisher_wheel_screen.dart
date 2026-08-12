import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/haptics.dart';
import '../../models/publisher.dart';
import '../../models/question.dart';
import '../../models/question_pack.dart';
import '../../widgets/glass_wheel_painter.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import 'online_question_screen.dart';

class PublisherWheelScreen extends StatefulWidget {
  final Publisher publisher;
  final QuestionPack pack;
  final List<Question> questions;

  const PublisherWheelScreen({
    super.key,
    required this.publisher,
    required this.pack,
    required this.questions,
  });

  @override
  State<PublisherWheelScreen> createState() => _PublisherWheelScreenState();
}

class _PublisherWheelScreenState extends State<PublisherWheelScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final Random _random = Random();
  final Set<String> _usedQuestionIds = {};

  double _rotation = 0;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() {
          _rotation = _controller.value;
        });
      });
  }

  Future<void> _spin() async {
    if (_isSpinning || widget.questions.isEmpty) return;

    final unusedIndexes = <int>[];

    for (int i = 0; i < widget.questions.length; i++) {
      if (!_usedQuestionIds.contains(widget.questions[i].id)) {
        unusedIndexes.add(i);
      }
    }

    if (unusedIndexes.isEmpty) {
      _showRoundCompleteDialog();
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    Haptics.medium();

    final selectedIndex = unusedIndexes[_random.nextInt(unusedIndexes.length)];
    final segmentAngle = (2 * pi) / widget.questions.length;

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

    _usedQuestionIds.add(widget.questions[selectedIndex].id);

    setState(() {
      _isSpinning = false;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineQuestionScreen(
          question: widget.questions[selectedIndex],
          publisher: widget.publisher,
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
            'اكتملت أسئلة الناشر',
            style: AppTextStyles.titleLarge,
          ),
          content: const Text(
            'تم استخدام جميع الأسئلة في هذه الجولة.',
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
                setState(() {
                  _usedQuestionIds.clear();
                });
                Navigator.pop(context);
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
        title: Text(widget.publisher.name),
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
                          segmentCount: widget.questions.length,
                          rotation: _rotation,
                          usedIndexes: _usedIndexes(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    widget.pack.title,
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.questions.length} أسئلة',
                    style: AppTextStyles.caption,
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

  Set<int> _usedIndexes() {
    final indexes = <int>{};

    for (int i = 0; i < widget.questions.length; i++) {
      if (_usedQuestionIds.contains(widget.questions[i].id)) {
        indexes.add(i);
      }
    }

    return indexes;
  }
}
