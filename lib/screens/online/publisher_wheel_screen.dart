import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../models/publisher.dart';
import '../../models/question.dart';
import '../../models/question_pack.dart';
import '../../widgets/aurora_titanium_wheel.dart';
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
  State<PublisherWheelScreen> createState() =>
      _PublisherWheelScreenState();
}

class _PublisherWheelScreenState
    extends State<PublisherWheelScreen>
    with SingleTickerProviderStateMixin {
  static const int wheelSlotCount = 12;

  late final AnimationController _controller;

  final Random _random = Random();
  final Set<String> _usedQuestionIds = {};

  double _rotation = 0;
  bool _isSpinning = false;

  int? _selectedSlot;
  Color _ambientColor = AppColors.primary;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController.unbounded(
      vsync: this,
      value: _rotation,
    )..addListener(() {
        if (!mounted) return;

        setState(() {
          _rotation = _controller.value;
        });
      });
  }

  int _questionIndexToSlot(
    int questionIndex,
    int questionCount,
  ) {
    if (questionCount <= 1) {
      return 0;
    }

    return ((questionIndex * wheelSlotCount) /
            questionCount)
        .floor()
        .clamp(0, wheelSlotCount - 1);
  }

  Color _spinningAmbientColor() {
    final phase = (sin(_rotation * 0.55) + 1) / 2;

    return Color.lerp(
      AppColors.primary,
      AppColors.secondary,
      phase * 0.35,
    )!;
  }

  Future<void> _spin() async {
    if (_isSpinning || widget.questions.isEmpty) {
      return;
    }

    final unusedIndexes = <int>[];

    for (int i = 0; i < widget.questions.length; i++) {
      if (!_usedQuestionIds.contains(
        widget.questions[i].id,
      )) {
        unusedIndexes.add(i);
      }
    }

    if (unusedIndexes.isEmpty) {
      _showRoundCompleteDialog();
      return;
    }

    final selectedIndex =
        unusedIndexes[_random.nextInt(
      unusedIndexes.length,
    )];

    final selectedSlot = _questionIndexToSlot(
      selectedIndex,
      widget.questions.length,
    );

    const slotAngle = 2 * pi / wheelSlotCount;

    final selectedTargetAngle =
        -(selectedSlot * slotAngle);

    final currentTurns =
        (_rotation / (2 * pi)).floor();

    var targetRotation =
        currentTurns * 2 * pi +
            selectedTargetAngle;

    while (targetRotation <= _rotation) {
      targetRotation += 2 * pi;
    }

    targetRotation +=
        (5 + _random.nextInt(3)) * 2 * pi;

    setState(() {
      _isSpinning = true;
      _selectedSlot = null;
    });

    Haptics.medium();

    await _controller.animateTo(
      targetRotation,
      duration: const Duration(milliseconds: 3200),
      curve: Curves.easeOutCubic,
    );

    if (!mounted) return;

    _controller.value = targetRotation;

    final selectedQuestion =
        widget.questions[selectedIndex];

    final category =
        AppCategories.byId(
      selectedQuestion.categoryId,
    );

    _usedQuestionIds.add(selectedQuestion.id);

    setState(() {
      _rotation = targetRotation;
      _selectedSlot = selectedSlot;
      _ambientColor = category.color;
      _isSpinning = false;
    });

    Haptics.light();

    await Future.delayed(
      const Duration(milliseconds: 420),
    );

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineQuestionScreen(
          question: selectedQuestion,
          publisher: widget.publisher,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      _selectedSlot = null;
    });
  }

  void _showRoundCompleteDialog() {
    showDialog<void>(
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
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _usedQuestionIds.clear();
                  _selectedSlot = null;
                  _ambientColor = AppColors.primary;
                });

                Navigator.pop(context);
              },
              child: const Text(
                'إعادة الجولة',
                style: TextStyle(
                  color: AppColors.primary,
                ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    final wheelSize = min(
      screenWidth * 0.84,
      390.0,
    );

    final backgroundColor = _isSpinning
        ? _spinningAmbientColor()
        : _ambientColor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.publisher.name),
      ),
      body: Stack(
        children: [
          LiquidBackground(
            primaryOrbColor: backgroundColor,
            secondaryOrbColor:
                backgroundColor.withOpacity(0.55),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.pack.title,
                      style:
                          AppTextStyles.titleLarge,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${widget.questions.length} أسئلة',
                      style: AppTextStyles.caption,
                    ),

                    const SizedBox(height: 22),

                    LiquidGlassContainer(
                      borderRadius: 999,
                      padding: const EdgeInsets.all(6),
                      child: AuroraTitaniumWheel(
                        rotation: _rotation,
                        selectedSlot: _selectedSlot,
                        size: wheelSize,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'I  ·  II  ·  III  ·  IV  ·  V  ·  VI  ·  VII  ·  VIII  ·  IX  ·  X  ·  XI  ·  XII',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 28),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 32,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              _isSpinning
                                  ? null
                                  : _spin,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary,
                            foregroundColor:
                                AppColors.textPrimary,
                            disabledBackgroundColor:
                                AppColors.primary
                                    .withOpacity(0.35),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isSpinning
                                ? 'جاري الدوران...'
                                : 'دور العجلة',
                            style:
                                AppTextStyles.button,
                          ),
                        ),
                      ),
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
