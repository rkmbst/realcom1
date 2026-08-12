import 'package:flutter/material.dart';

import '../../core/session/app_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../models/question.dart';
import '../../models/question_option.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';

class LocalResultScreen extends StatelessWidget {
  final Question question;

  const LocalResultScreen({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final session = AppSession.instance;

    final results = session.getResults(question.id);

    final totalVotes = session.getTotalVotes(question.id);

    final sortedOptions = List<QuestionOption>.from(question.options)
      ..sort(
        (a, b) => (results[b.id] ?? 0).compareTo(results[a.id] ?? 0),
      );

    final category = AppCategories.byId(question.categoryId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('النتيجة'),
      ),
      body: Stack(
        children: [
          LiquidBackground(
            primaryOrbColor: category.color,
            secondaryOrbColor: category.color.withOpacity(0.6),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    question.text,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalVotes لاعبين صوتوا',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: sortedOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final option = sortedOptions[index];
                        final count = results[option.id] ?? 0;
                        final percent = totalVotes == 0
                            ? 0.0
                            : (count / totalVotes) * 100;

                        return LiquidGlassContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      option.text,
                                      style: AppTextStyles.bodyLarge,
                                    ),
                                  ),
                                  Text(
                                    '${percent.toStringAsFixed(0)}%',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 12,
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: percent / 100,
                                      child: Container(
                                        height: 12,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.secondary,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$count صوت',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('متابعة'),
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
