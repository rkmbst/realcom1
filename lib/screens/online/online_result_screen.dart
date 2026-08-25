import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/online/feed_interaction_store.dart';
import '../../core/social/comment_store.dart';
import '../../core/social/question_social_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../data/mock_online_data.dart';
import '../../models/question.dart';
import '../../models/question_comment.dart';
import '../../models/question_option.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import '../profile/profile_screen.dart';

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
  State<OnlineResultScreen> createState() =>
      _OnlineResultScreenState();
}

class _OnlineResultScreenState
    extends State<OnlineResultScreen> {
  final _feedInteractions =
      FeedInteractionStore.instance;

  final _commentStore =
      CommentStore.instance;

  final _socialService =
      QuestionSocialService.instance;

  final _session =
      AuthSession.instance;

  final _commentController =
      TextEditingController();

  final _commentFocusNode =
      FocusNode();

  late final Map<String, int> _results;
  late final List<QuestionOption> _sortedOptions;
  late final Color _categoryColor;

  bool get _isQuestionOwner {
    return widget.question.authorId != null &&
        widget.question.authorId ==
            _session.currentUser.id;
  }

  @override
  void initState() {
    super.initState();

    _results =
        MockOnlineData.generateResults(
      widget.question,
      widget.selectedOptionId,
    );

    _sortedOptions =
        List<QuestionOption>.from(
      widget.question.options,
    )..sort(
        (a, b) =>
            (_results[b.id] ?? 0)
                .compareTo(
          _results[a.id] ?? 0,
        ),
      );

    _categoryColor =
        AppCategories.byId(
      widget.question.categoryId,
    ).color;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  bool get _isLiked =>
      _feedInteractions.isLiked(
    widget.question.id,
  );

  bool get _isQuiz =>
      widget.question.type ==
      QuestionType.quiz;

  bool get _hasCorrectAnswer =>
      widget.question.correctOptionId !=
      null;

  bool get _answerIsCorrect {
    return _isQuiz &&
        _hasCorrectAnswer &&
        widget.question.correctOptionId ==
            widget.selectedOptionId;
  }

  void _toggleLike() {
    if (_isQuestionOwner) {
      return;
    }

    final wasLiked =
        _feedInteractions.isLiked(
      widget.question.id,
    );

    _feedInteractions.toggleLike(
      widget.question.id,
    );

    if (!wasLiked) {
      _socialService.notifyLike(
        question: widget.question,
      );
    }

    Haptics.light();

    setState(() {});
  }

  void _addComment() {
    final text =
        _commentController.text.trim();

    if (text.isEmpty) {
      _commentFocusNode.requestFocus();
      return;
    }

    _commentStore.add(
      questionId:
          widget.question.id,
      text: text,
    );

    _socialService.notifyComment(
      question: widget.question,
    );

    _commentController.clear();
    _commentFocusNode.unfocus();

    Haptics.light();

    setState(() {});
  }

  void _backToPreviousScreen() {
    Navigator.pop(context, true);
  }

  String _questionTypeLabel() {
    switch (widget.question.type) {
      case QuestionType.quiz:
        return 'اختبار';
      case QuestionType.poll:
        return 'تصويت';
      case QuestionType.opinion:
        return 'رأي';
      case QuestionType.discussion:
        return 'نقاش';
    }
  }

  String _resultTitle() {
    switch (widget.question.type) {
      case QuestionType.quiz:
        return _answerIsCorrect
            ? 'إجابة صحيحة 🎯'
            : 'إجابة غير صحيحة';

      case QuestionType.poll:
        return 'نتيجة التصويت';

      case QuestionType.opinion:
        return 'نتيجة الآراء';

      case QuestionType.discussion:
        return 'نقاش المجتمع';
    }
  }

  String _resultSubtitle(
    int totalVotes,
    int selectedCount,
  ) {
    switch (widget.question.type) {
      case QuestionType.quiz:
        return _answerIsCorrect
            ? 'أحسنت، اخترت الإجابة الصحيحة.'
            : 'الإجابة الصحيحة مختلفة عن اختيارك.';

      case QuestionType.poll:
        return '$totalVotes صوتًا';

      case QuestionType.opinion:
        return '$totalVotes مشاركة';

      case QuestionType.discussion:
        return 'شارك برأيك وأكمل النقاش.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalVotes =
        _results.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );

    final selectedCount =
        _results[
              widget.selectedOptionId] ??
            0;

    final likeCount =
        _feedInteractions.likeCount(
      widget.question.id,
    );

    final commentCount =
        _commentStore.countForQuestion(
      widget.question.id,
    );

    final comments =
        _commentStore.forQuestion(
      widget.question.id,
    );

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isLastQuestion
              ? 'انتهت المجموعة'
              : 'النتيجة',
        ),
      ),
      body: Stack(
        children: [
          LiquidBackground(
            primaryOrbColor:
                _categoryColor,
            secondaryOrbColor:
                _categoryColor
                    .withOpacity(0.52),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child:
                      SingleChildScrollView(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      24,
                      8,
                      24,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch,
                      children: [
                        LiquidGlassContainer(
                          child: Column(
                            children: [
                              Text(
                                _questionTypeLabel(),
                                style:
                                    AppTextStyles
                                        .caption,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                _resultTitle(),
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
                                _resultSubtitle(
                                  totalVotes,
                                  selectedCount,
                                ),
                                style:
                                    AppTextStyles
                                        .bodyMedium,
                                textAlign:
                                    TextAlign
                                        .center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Text(
                          widget.question.text,
                          textAlign:
                              TextAlign.center,
                          style:
                              AppTextStyles
                                  .titleLarge,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        if (_isQuiz &&
                            _hasCorrectAnswer)
                          LiquidGlassContainer(
                            opacity: _answerIsCorrect
                                ? 0.12
                                : 0.08,
                            child:
                                Column(
                              children: [
                                Icon(
                                  _answerIsCorrect
                                      ? Icons
                                          .check_circle_rounded
                                      : Icons
                                          .cancel_rounded,
                                  size: 42,
                                  color:
                                      _answerIsCorrect
                                          ? AppColors
                                              .success
                                          : AppColors
                                              .error,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  _answerIsCorrect
                                      ? 'اختيارك صحيح'
                                      : 'اختيارك غير صحيح',
                                  style:
                                      AppTextStyles
                                          .titleMedium,
                                  textAlign:
                                      TextAlign
                                          .center,
                                ),
                              ],
                            ),
                          ),

                        if (widget.question.type !=
                            QuestionType.discussion) ...[
                          const SizedBox(
                            height: 20,
                          ),
                          ..._buildResults(
                            totalVotes,
                          ),
                        ],

                        const SizedBox(
                          height: 24,
                        ),

                        // Combined Like + Comment bar
                        Center(
                          child: Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .surface
                                  .withOpacity(0.72),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                999,
                              ),
                              border:
                                  Border.all(
                                color:
                                    AppColors
                                        .divider,
                              ),
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize
                                      .min,
                              children: [
                                InkWell(
                                  onTap:
                                      _isQuestionOwner
                                          ? null
                                          : _toggleLike,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    999,
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    child: Row(
                                      mainAxisSize:
                                          MainAxisSize
                                              .min,
                                      children: [
                                        Icon(
                                          _isLiked
                                              ? Icons
                                                  .favorite_rounded
                                              : Icons
                                                  .favorite_border_rounded,
                                          size: 19,
                                          color: _isLiked
                                              ? AppColors
                                                  .like
                                              : AppColors
                                                  .textSecondary,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '$likeCount',
                                          style:
                                              AppTextStyles
                                                  .caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 18,
                                  color:
                                      AppColors
                                          .divider,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize
                                            .min,
                                    children: [
                                      const Icon(
                                        Icons
                                            .chat_bubble_outline_rounded,
                                        size: 18,
                                        color:
                                            AppColors
                                                .textSecondary,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '$commentCount',
                                        style:
                                            AppTextStyles
                                                .caption,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        LiquidGlassContainer(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .end,
                            children: [
                              Expanded(
                                child:
                                    TextField(
                                  controller:
                                      _commentController,
                                  focusNode:
                                      _commentFocusNode,
                                  minLines: 1,
                                  maxLines: 4,
                                  textInputAction:
                                      TextInputAction
                                          .newline,
                                  style:
                                      AppTextStyles
                                          .bodyMedium,
                                  decoration:
                                      const InputDecoration(
                                    hintText:
                                        'أضف تعليقًا...',
                                    hintStyle:
                                        AppTextStyles
                                            .caption,
                                    border:
                                        InputBorder
                                            .none,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed:
                                    _addComment,
                                icon:
                                    const Icon(
                                  Icons
                                      .send_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (comments
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'التعليقات',
                            style:
                                AppTextStyles
                                    .titleMedium,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ...comments.map(
                            (comment) =>
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom: 10,
                              ),
                              child:
                                  LiquidGlassContainer(
                                opacity:
                                    0.055,
                                child:
                                    Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    InkWell(
                                      onTap:
                                          () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    ProfileScreen(
                                              userId:
                                                  comment.authorId,
                                            ),
                                          ),
                                        );
                                      },
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        8,
                                      ),
                                      child:
                                          Padding(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          vertical:
                                              2,
                                        ),
                                        child:
                                            Text(
                                          comment
                                              .authorName,
                                          style:
                                              AppTextStyles
                                                  .username
                                                  .copyWith(
                                            color:
                                                AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      comment
                                          .text,
                                      style:
                                          AppTextStyles
                                              .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    24,
                    8,
                    24,
                    20,
                  ),
                  child: SizedBox(
                    width:
                        double.infinity,
                    height: 52,
                    child:
                        OutlinedButton
                            .icon(
                      onPressed:
                          _backToPreviousScreen,
                      icon: Icon(
                        widget.isLastQuestion
                            ? Icons
                                .arrow_back_rounded
                            : Icons
                                .arrow_forward_rounded,
                      ),
                      label: Text(
                        widget.isLastQuestion
                            ? 'العودة إلى Feed'
                            : 'التالي',
                      ),
                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            AppColors
                                .textPrimary,
                        side:
                            BorderSide(
                          color: AppColors
                              .titaniumBorder
                              .withOpacity(
                            0.65,
                          ),
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
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

  List<Widget> _buildResults(
    int totalVotes,
  ) {
    return _sortedOptions.map(
      (option) {
        final count =
            _results[option.id] ?? 0;

        final percent =
            totalVotes == 0
                ? 0.0
                : count / totalVotes;

        final isSelected =
            option.id ==
            widget.selectedOptionId;

        final isCorrect =
            _isQuiz &&
            widget.question
                    .correctOptionId ==
                option.id;

        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 14,
          ),
          child:
              LiquidGlassContainer(
            opacity:
                isSelected
                    ? 0.12
                    : 0.055,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (isCorrect)
                            const Padding(
                              padding:
                                  EdgeInsets
                                      .only(
                                right: 6,
                              ),
                              child: Icon(
                                Icons
                                    .check_circle_rounded,
                                size: 18,
                                color:
                                    AppColors
                                        .success,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              option.text,
                              style:
                                  AppTextStyles
                                      .bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(percent * 100).round()}%',
                      style:
                          AppTextStyles
                              .titleMedium
                              .copyWith(
                        color: isSelected
                            ? _categoryColor
                            : AppColors
                                .textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                ClipRRect(
                  borderRadius:
                      BorderRadius
                          .circular(
                    999,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: 10,
                        color: Colors
                            .white
                            .withOpacity(
                          0.07,
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor:
                            percent,
                        child:
                            Container(
                          height: 10,
                          color: isSelected
                              ? _categoryColor
                              : Colors
                                  .white
                                  .withOpacity(
                                0.42,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  '$count صوت',
                  style:
                      AppTextStyles
                          .caption,
                ),
              ],
            ),
          ),
        );
      },
    ).toList();
  }
}
