import 'package:flutter/material.dart';

import '../../core/session/app_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../models/player.dart';
import '../../models/question.dart';
import '../../models/question_option.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import 'local_result_screen.dart';

class LocalQuestionScreen extends StatefulWidget {
  final Question question;

  const LocalQuestionScreen({
    super.key,
    required this.question,
  });

  @override
  State<LocalQuestionScreen> createState() => _LocalQuestionScreenState();
}

class _LocalQuestionScreenState extends State<LocalQuestionScreen> {
  final AppSession _session = AppSession.instance;

  late final List<QuestionOption> _options;

  int _voterIndex = 0;
  String? _selectedOptionId;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.question.options)..shuffle();
  }

  Player get currentVoter => _session.players[_voterIndex];

  void _confirm() {
    final selectedOptionId = _selectedOptionId;

    if (selectedOptionId == null) return;

    _session.castVote(
      questionId: widget.question.id,
      playerId: currentVoter.id,
      optionId: selectedOptionId,
    );

    Haptics.light();

    if (_voterIndex >= _session.players.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LocalResultScreen(question: widget.question),
        ),
      );
      return;
    }

    setState(() {
      _confirmed = true;
    });
  }

  void _nextPlayer() {
    setState(() {
      _voterIndex++;
      _selectedOptionId = null;
      _confirmed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final category = AppCategories.byId(widget.question.categoryId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('سؤال محلي'),
      ),
      body: Stack(
        children: [
          const LiquidBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LiquidGlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentVoter.color,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${currentVoter.name} يجيب الآن',
                            style: AppTextStyles.titleMedium,
                          ),
                        ),
                        Text(
                          '${_voterIndex + 1}/${_session.players.length}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.question.text,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: category.color),
                      ),
                      child: Text(
                        category.name,
                        style: AppTextStyles.caption.copyWith(
                          color: category.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_confirmed)
                    ..._options.map((option) {
                      final isSelected = _selectedOptionId == option.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedOptionId = option.id;
                            });
                          },
                          child: LiquidGlassContainer(
                            opacity: isSelected ? 0.14 : 0.06,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option.text,
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  if (!_confirmed)
                    const SizedBox(height: 24),
                  if (!_confirmed)
                    ElevatedButton.icon(
                      onPressed: _selectedOptionId == null ? null : _confirm,
                      icon: const Icon(Icons.check),
                      label: const Text('تأكيد الإجابة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  if (_confirmed)
                    LiquidGlassContainer(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'تم تسجيل الإجابة.',
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'مرر الجهاز إلى اللاعب التالي.',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _nextPlayer,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('اللاعب التالي'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ],
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
