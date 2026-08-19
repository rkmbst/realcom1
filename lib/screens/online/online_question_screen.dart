import 'package:flutter/material.dart';

import '../../core/online/feed_interaction_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../models/publisher.dart';
import '../../models/question.dart';
import '../../models/question_option.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import '../profile/profile_screen.dart';
import 'online_result_screen.dart';

class OnlineQuestionScreen extends StatefulWidget {
  final Question question;
  final Publisher publisher;
  final bool isLastQuestion;

  const OnlineQuestionScreen({
    super.key,
    required this.question,
    required this.publisher,
    required this.isLastQuestion,
  });

  @override
  State<OnlineQuestionScreen> createState() =>
      _OnlineQuestionScreenState();
}

class _OnlineQuestionScreenState
    extends State<OnlineQuestionScreen> {
  final _feedInteractions =
      FeedInteractionStore.instance;

  late final List<QuestionOption> _options;

  String? _selectedOptionId;

  late final Color _categoryColor;

  @override
  void initState() {
    super.initState();

    _options = List<QuestionOption>.from(
      widget.question.options,
    )..shuffle();

    _categoryColor = AppCategories.byId(
      widget.question.categoryId,
    ).color;
  }

  void _confirm() {
    final selectedOptionId = _selectedOptionId;

    if (selectedOptionId == null) {
      return;
    }

    _feedInteractions.markAnswered(
      widget.question.id,
    );

    Haptics.light();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineResultScreen(
          question: widget.question,
          selectedOptionId: selectedOptionId,
          isLastQuestion: widget.isLastQuestion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = AppCategories.byId(
      widget.question.categoryId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('سؤال أونلاين'),
      ),
      body: Stack(
        children: [
          LiquidBackground(
            primaryOrbColor: _categoryColor,
            secondaryOrbColor: _categoryColor.withOpacity(0.6),
          ),
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
                            color: widget.publisher.accentColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileScreen(
                                    userId: widget.publisher.id,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: Text(
                                widget.publisher.name,
                                style: AppTextStyles.username,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: category.color,
                            ),
                          ),
                          child: Text(
                            category.name,
                            style: AppTextStyles.caption.copyWith(
                              color: category.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    widget.question.text,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayLarge,
                  ),
                  const SizedBox(height: 32),
                  ..._options.map(
                    (option) {
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
                                      ? _categoryColor
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
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _selectedOptionId == null ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.titanium,
                      foregroundColor: AppColors.onTitanium,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('تأكيد الإجابة'),
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
