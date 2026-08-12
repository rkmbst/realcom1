import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../models/publisher.dart';
import '../../models/question.dart';
import '../../models/question_option.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import 'online_result_screen.dart';

class OnlineQuestionScreen extends StatefulWidget {
  final Question question;
  final Publisher publisher;

  const OnlineQuestionScreen({
    super.key,
    required this.question,
    required this.publisher,
  });

  @override
  State<OnlineQuestionScreen> createState() => _OnlineQuestionScreenState();
}

class _OnlineQuestionScreenState extends State<OnlineQuestionScreen> {
  late final List<QuestionOption> _options;
  String? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.question.options)..shuffle();
  }

  void _confirm() {
    final selectedOptionId = _selectedOptionId;

    if (selectedOptionId == null) return;

    Haptics.light();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineResultScreen(
          question: widget.question,
          selectedOptionId: selectedOptionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = AppCategories.byId(widget.question.categoryId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('سؤال أونلاين'),
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
                            color: widget.publisher.accentColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.publisher.name,
                            style: AppTextStyles.titleMedium,
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
                            border: Border.all(color: category.color),
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
                  const SizedBox(height: 24),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
