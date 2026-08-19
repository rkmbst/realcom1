import 'package:flutter/material.dart';

import '../../core/online/feed_interaction_store.dart';
import '../../core/social/comment_store.dart';
import '../../core/social/question_social_service.dart';
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

  final _commentStore =
      CommentStore.instance;

  final _socialService =
      QuestionSocialService.instance;

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

  void _toggleLike() {
    final wasLiked =
        _feedInteractions.isLiked(
      widget.question.id,
    );

    setState(() {
      _feedInteractions.toggleLike(
        widget.question.id,
      );
    });

    if (!wasLiked) {
      _socialService.notifyLike(
        question: widget.question,
      );
    }

    Haptics.light();
  }

  void _openComments() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final comments = _commentStore.forQuestion(
              widget.question.id,
            );

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'التعليقات',
                            style: AppTextStyles.titleMedium,
                          ),
                          const Spacer(),
                          Text(
                            '${comments.length}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: comments.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا توجد تعليقات بعد.\nكن أول من يشارك رأيه.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.separated(
                                itemCount: comments.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, index) {
                                  final comment = comments[index];

                                  return LiquidGlassContainer(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.authorName,
                                          style: AppTextStyles.username,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment.text,
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              maxLength: 500,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) {
                                _submitComment(
                                  controller,
                                  setSheetState,
                                );
                              },
                              decoration: const InputDecoration(
                                hintText: 'اكتب تعليقك...',
                                counterText: '',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              _submitComment(
                                controller,
                                setSheetState,
                              );
                            },
                            icon: const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _submitComment(
    TextEditingController controller,
    StateSetter setSheetState,
  ) {
    final text = controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    _commentStore.add(
      questionId: widget.question.id,
      text: text,
    );

    _socialService.notifyComment(
      question: widget.question,
    );

    controller.clear();

    Haptics.light();

    setSheetState(() {});
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

    final isLiked = _feedInteractions.isLiked(
      widget.question.id,
    );

    final commentCount = _commentStore.countForQuestion(
      widget.question.id,
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
                  const SizedBox(height: 18),
                  Center(
                    child: InkWell(
                      onTap: _toggleLike,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isLiked
                              ? AppColors.like.withOpacity(0.12)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isLiked
                                ? AppColors.like.withOpacity(0.55)
                                : AppColors.divider,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 22,
                              color: isLiked
                                  ? AppColors.like
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isLiked
                                  ? 'أعجبني'
                                  : 'إعجاب',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: InkWell(
                      onTap: _openComments,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.divider,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 21,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$commentCount تعليقات',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
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
