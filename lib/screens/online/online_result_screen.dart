import 'package:flutter/material.dart';

import '../../core/online/online_interaction_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../data/mock_online_data.dart';
import '../../models/question.dart';
import '../../models/question_option.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import 'online_feed_screen.dart';

class OnlineResultScreen extends StatefulWidget {
  final Question question;
  final String selectedOptionId;
  final bool isLastQuestion;

  const OnlineResultScreen({
    super.key,
    required this.question,
    required this.selectedOptionId,
    required this.isLastQuestion,
  });

  @override
  State<OnlineResultScreen> createState() => _OnlineResultScreenState();
}

class _OnlineResultScreenState extends State<OnlineResultScreen> {
  final OnlineInteractionStore _interactions = OnlineInteractionStore.instance;

  final TextEditingController _commentController = TextEditingController();

  final FocusNode _commentFocusNode = FocusNode();

  late final Map<String, int> _results;
  late final List<QuestionOption> _sortedOptions;

  late final Color _categoryColor;

  bool _liked = false;

  @override
  void initState() {
    super.initState();

    _results = MockOnlineData.generateResults(
      widget.question,
      widget.selectedOptionId,
    );

    _sortedOptions = List<QuestionOption>.from(
      widget.question.options,
    )..sort(
        (a, b) => (_results[b.id] ?? 0).compareTo(_results[a.id] ?? 0),
      );

    _categoryColor = AppCategories.byId(
      widget.question.categoryId,
    ).color;

    if (widget.isLastQuestion) {
      _liked = _interactions.isLiked(
        widget.question.id,
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _toggleLike() {
    final liked = _interactions.toggleLike(
      widget.question.id,
      authorId: widget.question.authorId,
      authorName: widget.question.authorName,
    );

    Haptics.light();

    setState(() {
      _liked = liked;
    });
  }

  void _addComment() {
    final text = _commentController.text.trim();

    if (text.isEmpty) {
      _commentFocusNode.requestFocus();
      return;
    }

    _interactions.addComment(
      widget.question.id,
      text,
      authorId: widget.question.authorId,
      authorName: widget.question.authorName,
    );

    _commentController.clear();
    _commentFocusNode.unfocus();

    Haptics.light();

    setState(() {});
  }

  void _backToWheel() {
    Navigator.pop(context);
  }

  void _backToFeed() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const OnlineFeedScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalVotes = _results.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );

    final agreedCount = _results[widget.selectedOptionId] ?? 0;

    final comments = widget.isLastQuestion
        ? _interactions.comments(widget.question.id)
        : const <String>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isLastQuestion ? 'انتهت الجولة' : 'النتيجة',
        ),
      ),
      body: Stack(
        children: [
          LiquidBackground(
            primaryOrbColor: _categoryColor,
            secondaryOrbColor: _categoryColor.withOpacity(0.52),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.isLastQuestion)
                          LiquidGlassContainer(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 44,
                                  color: AppColors.success,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'انتهت جميع الأسئلة',
                                  style: AppTextStyles.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        if (widget.isLastQuestion) const SizedBox(height: 18),
                        Text(
                          widget.question.text,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalVotes صوتًا',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 18),
                        LiquidGlassContainer(
                          child: Text(
                            'وافقك $agreedCount شخصًا في إجابتك',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: _categoryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ..._buildResults(totalVotes),
                        if (widget.isLastQuestion) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _SocialButton(
                                  icon: _liked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  label: _liked ? 'أعجبني' : 'إعجاب',
                                  iconColor: _liked
                                      ? AppColors.like
                                      : AppColors.textPrimary,
                                  onTap: _toggleLike,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SocialButton(
                                  icon: Icons.chat_bubble_outline,
                                  label: '${comments.length} تعليق',
                                  iconColor: AppColors.textPrimary,
                                  onTap: () {
                                    _commentFocusNode.requestFocus();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          LiquidGlassContainer(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    focusNode: _commentFocusNode,
                                    minLines: 1,
                                    maxLines: 4,
                                    textInputAction: TextInputAction.newline,
                                    style: AppTextStyles.bodyMedium,
                                    decoration: const InputDecoration(
                                      hintText: 'أضف تعليقًا...',
                                      hintStyle: AppTextStyles.caption,
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _addComment,
                                  icon: const Icon(Icons.send),
                                  color: AppColors.textPrimary,
                                ),
                              ],
                            ),
                          ),
                          if (comments.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              'التعليقات',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            ...comments.map(
                              (comment) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: LiquidGlassContainer(
                                  opacity: 0.055,
                                  child: Text(
                                    comment,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: widget.isLastQuestion ? _backToFeed : _backToWheel,
                      icon: Icon(
                        widget.isLastQuestion
                            ? Icons.arrow_back_rounded
                            : Icons.casino_outlined,
                      ),
                      label: Text(
                        widget.isLastQuestion
                            ? 'العودة إلى Feed'
                            : 'العودة إلى العجلة',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: AppColors.titaniumBorder.withOpacity(0.65),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResults(int totalVotes) {
    return _sortedOptions.map(
      (option) {
        final count = _results[option.id] ?? 0;

        final percent = totalVotes == 0 ? 0.0 : count / totalVotes;

        final isSelected = option.id == widget.selectedOptionId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: LiquidGlassContainer(
            opacity: isSelected ? 0.12 : 0.055,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.text,
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                    Text(
                      '${(percent * 100).round()}%',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isSelected
                            ? _categoryColor
                            : AppColors.textSecondary,
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
                        height: 10,
                        color: Colors.white.withOpacity(0.07),
                      ),
                      FractionallySizedBox(
                        widthFactor: percent,
                        child: Container(
                          height: 10,
                          color: isSelected
                              ? _categoryColor
                              : Colors.white.withOpacity(0.42),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$count صوت',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        );
      },
    ).toList();
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: iconColor,
          size: 21,
        ),
        label: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: AppColors.titaniumBorder.withOpacity(0.50),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
