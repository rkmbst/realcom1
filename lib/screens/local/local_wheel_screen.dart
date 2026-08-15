import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/session/app_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../widgets/aurora_titanium_wheel.dart';
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
  static const int wheelSlotCount = 12;

  final AppSession _session = AppSession.instance;
  final Random _random = Random();

  late final AnimationController _controller;

  double _rotation = 0;
  bool _isSpinning = false;

  int? _selectedSlot;

  // Default atmosphere is Cyan rather than Purple.
  Color _ambientColor = AppColors.secondary;

  @override
  void initState() {
    super.initState();

    if (_session.roundQuestions.isEmpty) {
      _session.prepareRound();
    }

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

  /// Maps a question index onto one of the fixed 12 wheel positions.
  ///
  /// Examples:
  /// 6 questions  -> 0,2,4,6,8,10
  /// 8 questions  -> 0,1,3,4,6,7,9,10
  /// 12 questions -> 0...11
  int _questionIndexToSlot(
    int questionIndex,
    int questionCount,
  ) {
    if (questionCount <= 1) {
      return 0;
    }

    return ((questionIndex * wheelSlotCount) / questionCount)
        .floor()
        .clamp(0, wheelSlotCount - 1);
  }

  /// Aurora colors used only during wheel motion.
  ///
  /// Purple is intentionally excluded:
  /// Cyan -> Blue -> Green -> Amber -> Red -> Cyan
  Color _spinningAmbientColor() {
    const colors = <Color>[
      AppColors.secondary,
      Color(0xFF3D8BFF),
      AppColors.success,
      AppColors.warning,
      AppColors.error,
    ];

    const double speed = 0.48;

    final raw = (_rotation * speed) % colors.length;

    final index = raw.floor();
    final nextIndex = (index + 1) % colors.length;
    final t = raw - index;

    return Color.lerp(
      colors[index],
      colors[nextIndex],
      Curves.easeInOut.transform(t),
    )!;
  }

  Future<void> _spin() async {
    if (_isSpinning || _session.roundQuestions.isEmpty) {
      return;
    }

    final unusedIndexes = _session.unusedRoundIndexes();

    if (unusedIndexes.isEmpty) {
      _showRoundCompleteDialog();
      return;
    }

    final selectedIndex =
        unusedIndexes[_random.nextInt(unusedIndexes.length)];

    final selectedSlot = _questionIndexToSlot(
      selectedIndex,
      _session.roundQuestions.length,
    );

    const slotAngle = 2 * pi / wheelSlotCount;

    // Slot 0 / I is at 12 o'clock.
    final selectedTargetAngle = -(selectedSlot * slotAngle);

    final currentTurns =
        (_rotation / (2 * pi)).floor();

    var targetRotation =
        currentTurns * 2 * pi + selectedTargetAngle;

    while (targetRotation <= _rotation) {
      targetRotation += 2 * pi;
    }

    // 7–9 full turns.
    targetRotation +=
        (7 + _random.nextInt(3)) * 2 * pi;

    setState(() {
      _isSpinning = true;
      _selectedSlot = null;
    });

    Haptics.medium();

    // Slow premium spin.
    await _controller.animateTo(
      targetRotation,
      duration: const Duration(milliseconds: 5600),
      curve: Curves.easeOutCubic,
    );

    if (!mounted) return;

    _controller.value = targetRotation;

    final selectedQuestion =
        _session.roundQuestions[selectedIndex];

    final category =
        AppCategories.byId(
      selectedQuestion.categoryId,
    );

    _session.markQuestionUsed(
      selectedQuestion.id,
    );

    setState(() {
      _rotation = targetRotation;
      _selectedSlot = selectedSlot;

      // After landing, keep the category atmosphere.
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
        builder: (_) => LocalQuestionScreen(
          question: selectedQuestion,
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
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _session.resetRound();

                Navigator.pop(context);

                setState(() {
                  _selectedSlot = null;
                  _ambientColor = AppColors.secondary;
                });
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
    final screenWidth =
        MediaQuery.of(context).size.width;

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
        title: const Text('عجلة الجلسة'),
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
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      'اختر سؤالك',
                      style:
                          AppTextStyles.titleLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${_session.roundQuestions.length} أسئلة في الجولة',
                      style:
                          AppTextStyles.caption,
                    ),

                    const SizedBox(height: 22),

                    LiquidGlassContainer(
                      borderRadius: 999,
                      padding:
                          const EdgeInsets.all(6),
                      child:
                          AuroraTitaniumWheel(
                        rotation: _rotation,
                        selectedSlot:
                            _selectedSlot,
                        size: wheelSize,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 32,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child:
                            ElevatedButton(
                          onPressed: _isSpinning
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
                                    .withOpacity(
                              0.35,
                            ),
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
