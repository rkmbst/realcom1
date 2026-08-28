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
  const PublisherWheelScreen({
    super.key,
    required this.publisher,
    required this.pack,
    required this.questions,
  });

  final Publisher publisher;
  final QuestionPack pack;
  final List<Question> questions;

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

  final Set<String> _usedQuestionIds =
      <String>{};

  double _rotation = 0;

  bool _isSpinning = false;

  bool _roundCompleted = false;

  int? _selectedSlot;

  Color _ambientColor =
      AppColors.secondary;

  int get _totalQuestions =>
      widget.questions.length;

  int get _completedQuestions =>
      _usedQuestionIds.length;

  int get _remainingQuestions =>
      max(
        0,
        _totalQuestions -
            _completedQuestions,
      );

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController.unbounded(
      vsync: this,
      value: _rotation,
    )..addListener(() {
        if (!mounted) {
          return;
        }

        setState(() {
          _rotation =
              _controller.value;
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

    return ((questionIndex *
                wheelSlotCount) /
            questionCount)
        .floor()
        .clamp(
          0,
          wheelSlotCount - 1,
        );
  }

  Color _spinningAmbientColor() {
    const colors = <Color>[
      AppColors.secondary,
      Color(0xFF3D8BFF),
      AppColors.success,
      AppColors.warning,
      AppColors.error,
    ];

    const speed = 0.48;

    final raw =
        (_rotation * speed) %
            colors.length;

    final index = raw.floor();

    final nextIndex =
        (index + 1) %
            colors.length;

    final t =
        Curves.easeInOut.transform(
      raw - index,
    );

    return Color.lerp(
      colors[index],
      colors[nextIndex],
      t,
    )!;
  }

  Future<void> _spin() async {
    if (_isSpinning ||
        _roundCompleted ||
        widget.questions.isEmpty) {
      return;
    }

    final unusedIndexes =
        <int>[];

    for (
      int i = 0;
      i < widget.questions.length;
      i++
    ) {
      if (!_usedQuestionIds
          .contains(
        widget.questions[i].id,
      )) {
        unusedIndexes.add(i);
      }
    }

    if (unusedIndexes.isEmpty) {
      _completeRound();

      return;
    }

    final selectedIndex =
        unusedIndexes[
            _random.nextInt(
          unusedIndexes.length,
        )];

    final selectedSlot =
        _questionIndexToSlot(
      selectedIndex,
      widget.questions.length,
    );

    const slotAngle =
        2 * pi /
            wheelSlotCount;

    final selectedTargetAngle =
        -(selectedSlot *
            slotAngle);

    final currentTurns =
        (_rotation /
                (2 * pi))
            .floor();

    var targetRotation =
        currentTurns *
                2 *
                pi +
            selectedTargetAngle;

    while (
        targetRotation <=
            _rotation) {
      targetRotation +=
          2 * pi;
    }

    targetRotation +=
        (7 +
                _random
                    .nextInt(3)) *
            2 *
            pi;

    setState(() {
      _isSpinning = true;
      _selectedSlot = null;
    });

    Haptics.medium();

    await _controller.animateTo(
      targetRotation,
      duration:
          const Duration(
        milliseconds: 5600,
      ),
      curve:
          Curves.easeOutCubic,
    );

    if (!mounted) {
      return;
    }

    _controller.value =
        targetRotation;

    final selectedQuestion =
        widget.questions[
            selectedIndex];

    final category =
        AppCategories.byId(
      selectedQuestion
          .categoryId,
    );

    // Last means: this is the final
    // remaining question before the
    // user answers it.
    final isLastQuestion =
        _remainingQuestions == 1;

    setState(() {
      _rotation =
          targetRotation;

      _selectedSlot =
          selectedSlot;

      _ambientColor =
          category.color;

      _isSpinning = false;
    });

    Haptics.light();

    await Future.delayed(
      const Duration(
        milliseconds: 420,
      ),
    );

    if (!mounted) {
      return;
    }

    final completed =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OnlineQuestionScreen(
          question:
              selectedQuestion,
          publisher:
              widget.publisher,
          isLastQuestion:
              isLastQuestion,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    // Only consume the question
    // after the user actually
    // completes the question flow.
    if (completed == true) {
      _usedQuestionIds.add(
        selectedQuestion.id,
      );
    }

    setState(() {
      _selectedSlot = null;
    });

    if (completed == true &&
        _usedQuestionIds.length >=
            widget.questions.length) {
      _completeRound();
    }
  }

  void _completeRound() {
    if (!mounted) {
      return;
    }

    setState(() {
      _roundCompleted = true;
      _selectedSlot = null;
      _isSpinning = false;
      _ambientColor =
          AppColors.secondary;
    });

    Haptics.medium();

    Future<void>.delayed(
      const Duration(
        milliseconds: 280,
      ),
      () {
        if (!mounted) {
          return;
        }

        _showRoundCompleteDialog();
      },
    );
  }

  void _showRoundCompleteDialog() {
    if (!mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              AppColors.surface,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              22,
            ),
          ),
          title: const Text(
            'اكتملت الجولة 🎯',
            style:
                AppTextStyles.titleLarge,
            textAlign:
                TextAlign.center,
          ),
          content: Text(
            'أكملت جميع أسئلة مجموعة «${widget.pack.title}».',
            style:
                AppTextStyles.bodyMedium,
            textAlign:
                TextAlign.center,
          ),
          actionsAlignment:
              MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'العودة',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _usedQuestionIds
                      .clear();

                  _selectedSlot = null;

                  _roundCompleted =
                      false;

                  _ambientColor =
                      AppColors
                          .secondary;
                });

                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'إعادة الجولة',
                style: TextStyle(
                  color:
                      AppColors.titanium,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _progressLabel() {
    if (_totalQuestions == 0) {
      return 'لا توجد أسئلة';
    }

    if (_roundCompleted) {
      return 'اكتملت الجولة';
    }

    return '$_completedQuestions / $_totalQuestions';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final screenWidth =
        MediaQuery.of(context)
            .size
            .width;

    final wheelSize = min(
      screenWidth * 0.84,
      390.0,
    );

    final backgroundColor =
        _isSpinning
            ? _spinningAmbientColor()
            : _ambientColor;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.publisher.name,
        ),
        actions: [
          IconButton(
            tooltip: 'خروج',
            onPressed:
                _isSpinning
                    ? null
                    : () {
                        Navigator.pop(
                          context,
                        );
                      },
            icon:
                const Icon(
              Icons
                  .close_rounded,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          LiquidBackground(
            primaryOrbColor:
                backgroundColor,
            secondaryOrbColor:
                backgroundColor
                    .withOpacity(
              0.55,
            ),
          ),
          SafeArea(
            child:
                Center(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child:
                    Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    Text(
                      widget
                          .pack
                          .title,
                      style:
                          AppTextStyles
                              .titleLarge,
                      textAlign:
                          TextAlign
                              .center,
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      '${widget.questions.length} أسئلة',
                      style:
                          AppTextStyles
                              .caption,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    LiquidGlassContainer(
                      opacity:
                          0.07,
                      borderRadius:
                          999,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child:
                          Row(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          const Icon(
                            Icons
                                .check_circle_outline_rounded,
                            size: 17,
                            color:
                                AppColors
                                    .primary,
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            _progressLabel(),
                            style:
                                AppTextStyles
                                    .caption,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    LiquidGlassContainer(
                      borderRadius:
                          999,
                      padding:
                          const EdgeInsets
                              .all(
                        6,
                      ),
                      child:
                          AuroraTitaniumWheel(
                        rotation:
                            _rotation,
                        selectedSlot:
                            _selectedSlot,
                        size:
                            wheelSize,
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    if (!_roundCompleted)
                      SizedBox(
                        width:
                            double.infinity,
                        height: 54,
                        child:
                            ElevatedButton(
                          onPressed:
                              _isSpinning
                                  ? null
                                  : _spin,
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                AppColors
                                    .titanium,
                            foregroundColor:
                                AppColors
                                    .onTitanium,
                            elevation:
                                0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),
                          ),
                          child:
                              Text(
                            _isSpinning
                                ? 'جاري الدوران...'
                                : _completedQuestions ==
                                        0
                                    ? 'ابدأ الجولة'
                                    : 'السؤال التالي',
                          ),
                        ),
                      )
                    else
                      Text(
                        'اكتملت جميع الأسئلة',
                        style:
                            AppTextStyles
                                .titleMedium,
                        textAlign:
                            TextAlign
                                .center,
                      ),

                    const SizedBox(
                      height: 14,
                    ),

                    Text(
                      'كل دورة تختار سؤالًا لم يُستخدم بعد.',
                      style:
                          AppTextStyles
                              .caption,
                      textAlign:
                          TextAlign.center,
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
