import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/beast/beast_event_gateway.dart';
import '../../core/online/feed_interaction_store.dart';
import '../../core/online/vote_store.dart';
import '../../core/social/comment_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../models/publisher.dart';
import '../../models/question.dart';
import '../../models/question_option.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import '../../widgets/social/comment_sheet.dart';
import '../profile/profile_screen.dart';
import 'online_result_screen.dart';

class OnlineQuestionScreen extends StatefulWidget {
  const OnlineQuestionScreen({
    super.key,
    required this.question,
    required this.publisher,
    required this.isLastQuestion,
  });

  final Question question;
  final Publisher publisher;
  final bool isLastQuestion;

  @override
  State<OnlineQuestionScreen> createState() =>
      _OnlineQuestionScreenState();
}

class _OnlineQuestionScreenState
    extends State<OnlineQuestionScreen> {
  final _session =
      AuthSession.instance;

  final _feedInteractions =
      FeedInteractionStore.instance;

  final _voteStore =
      VoteStore.instance;

  late final List<QuestionOption> _options;

  String? _selectedOptionId;

  late final Color _categoryColor;

  bool get _isQuestionOwner {
    return widget.question.authorId != null &&
        widget.question.authorId ==
            _session.currentUser.id;
  }

  bool get _hasVoted {
    return _voteStore.hasVoted(
      widget.question.id,
    );
  }

  String? get _savedVoteOptionId {
    return _voteStore.selectedOptionFor(
      widget.question.id,
    );
  }

  @override
  void initState() {
    super.initState();

    _options = List<QuestionOption>.from(
      widget.question.options,
    )..shuffle();

    _categoryColor =
        AppCategories.byId(
      widget.question.categoryId,
    ).color;

    if (!_isQuestionOwner &&
        _hasVoted) {
      _selectedOptionId =
          _savedVoteOptionId;
    }
  }

  void _toggleLike() {
    if (_isQuestionOwner) {
      return;
    }

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
      BeastEventGateway.instance.liked(
        itemId: widget.question.id,
        tags: widget.question.hashtags,
        category:
            widget.question.categoryId.toString(),
        creatorId:
            widget.question.authorId,
      );
    }

    Haptics.light();
  }

  Future<void> _confirm() async {
    if (_isQuestionOwner ||
        _hasVoted) {
      return;
    }

    final selectedOptionId =
        _selectedOptionId;

    if (selectedOptionId == null) {
      return;
    }

    final authorId =
        widget.question.authorId;

    if (authorId == null) {
      return;
    }

    final recorded =
        _voteStore.recordVote(
      questionId:
          widget.question.id,
      optionId:
          selectedOptionId,
      authorId:
          authorId,
    );

    if (!recorded) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'تم تسجيل تصويتك مسبقًا.',
          ),
        ),
      );

      return;
    }

    _feedInteractions.markAnswered(
      widget.question.id,
    );

    BeastEventGateway.instance.voted(
      itemId: widget.question.id,
      option: selectedOptionId,
      category:
          widget.question.categoryId.toString(),
      creatorId:
          authorId,
    );

    Haptics.light();

    final result =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OnlineResultScreen(
          question:
              widget.question,
          selectedOptionId:
              selectedOptionId,
          isLastQuestion:
              widget.isLastQuestion,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      Navigator.pop(
        context,
        true,
      );
    }
  }

  void _openResults() {
    BeastEventGateway.instance.contentOpened(
      itemId: widget.question.id,
      tags: widget.question.hashtags,
      category:
          widget.question.categoryId.toString(),
      creatorId:
          widget.question.authorId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OnlineResultScreen(
          question:
              widget.question,
          selectedOptionId:
              '',
          isLastQuestion:
              widget.isLastQuestion,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final category =
        AppCategories.byId(
      widget.question.categoryId,
    );

    final isLiked =
        _feedInteractions.isLiked(
      widget.question.id,
    );

    final likeCount =
        _feedInteractions.likeCount(
      widget.question.id,
    );

    final commentCount =
        CommentStore.instance
            .countForQuestion(
      widget.question.id,
    );

    final isOwner =
        _isQuestionOwner;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title:
            const Text(
          'سؤال أونلاين',
        ),
      ),
      body: Stack(
        children: [
          LiquidBackground(
            primaryOrbColor:
                _categoryColor,
            secondaryOrbColor:
                _categoryColor.withOpacity(
              0.6,
            ),
          ),
          SafeArea(
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  LiquidGlassContainer(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape.circle,
                            color: widget
                                .publisher
                                .accentColor,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child:
                              InkWell(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProfileScreen(
                                    userId:
                                        widget
                                            .publisher
                                            .id,
                                  ),
                                ),
                              );
                            },
                            child:
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 8,
                              ),
                              child:
                                  Text(
                                widget.publisher.name,
                                style:
                                    AppTextStyles
                                        .username,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration:
                              BoxDecoration(
                            color: category
                                .color
                                .withOpacity(
                              0.15,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              999,
                            ),
                            border:
                                Border.all(
                              color:
                                  category.color,
                            ),
                          ),
                          child:
                              Text(
                            category.name,
                            style:
                                AppTextStyles
                                    .caption
                                    .copyWith(
                              color:
                                  category.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  Text(
                    widget.question.text,
                    textAlign:
                        TextAlign.center,
                    style:
                        AppTextStyles
                            .displayLarge,
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  Center(
                    child:
                        Container(
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
                            .withOpacity(
                          0.72,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          999,
                        ),
                        border:
                            Border.all(
                          color:
                              AppColors.divider,
                        ),
                      ),
                      child:
                          Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap:
                                isOwner
                                    ? null
                                    : _toggleLike,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              999,
                            ),
                            child:
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              child:
                                  Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Icon(
                                    isLiked
                                        ? Icons
                                            .favorite_rounded
                                        : Icons
                                            .favorite_border_rounded,
                                    size: 19,
                                    color:
                                        isLiked
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
                                AppColors.divider,
                          ),
                          InkWell(
                            onTap: () {
                              SocialCommentSheet
                                  .show(
                                context,
                                question:
                                    widget
                                        .question,
                                onChanged:
                                    () {
                                  if (mounted) {
                                    setState(
                                      () {},
                                    );
                                  }
                                },
                              );
                            },
                            borderRadius:
                                BorderRadius
                                    .circular(
                              999,
                            ),
                            child:
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              child:
                                  Row(
                                mainAxisSize:
                                    MainAxisSize.min,
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
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  if (isOwner) ...[
                    LiquidGlassContainer(
                      opacity: 0.06,
                      padding:
                          const EdgeInsets
                              .all(
                        18,
                      ),
                      child:
                          Column(
                        children: [
                          const Icon(
                            Icons
                                .visibility_outlined,
                            size: 30,
                            color:
                                AppColors
                                    .textSecondary,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'هذا سؤالك',
                            style:
                                AppTextStyles
                                    .titleMedium,
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            'يمكنك مشاهدة النتائج والتعليقات والرد عليها، لكن لا يمكنك التصويت.',
                            textAlign:
                                TextAlign
                                    .center,
                            style:
                                AppTextStyles
                                    .caption,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    ElevatedButton.icon(
                      onPressed:
                          _openResults,
                      icon:
                          const Icon(
                        Icons
                            .bar_chart_rounded,
                      ),
                      label:
                          const Text(
                        'عرض النتائج',
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            AppColors
                                .titanium,
                        foregroundColor:
                            AppColors
                                .onTitanium,
                        elevation: 0,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
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
                  ] else if (_hasVoted) ...[
                    LiquidGlassContainer(
                      opacity: 0.08,
                      padding:
                          const EdgeInsets
                              .all(
                        18,
                      ),
                      child:
                          Column(
                        children: [
                          const Icon(
                            Icons
                                .check_circle_outline_rounded,
                            size: 34,
                            color:
                                AppColors
                                    .success,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'تم تسجيل تصويتك',
                            style:
                                AppTextStyles
                                    .titleMedium,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'يمكنك مشاهدة النتيجة، ولا يمكن تغيير التصويت.',
                            textAlign:
                                TextAlign
                                    .center,
                            style:
                                AppTextStyles
                                    .caption,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    OutlinedButton.icon(
                      onPressed:
                          _openResults,
                      icon:
                          const Icon(
                        Icons
                            .bar_chart_rounded,
                      ),
                      label:
                          const Text(
                        'عرض النتيجة',
                      ),
                    ),
                  ] else ...[
                    ..._options.map(
                      (option) {
                        final isSelected =
                            _selectedOptionId ==
                                option.id;

                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 12,
                          ),
                          child:
                              GestureDetector(
                            onTap: () {
                              setState(
                                () {
                                  _selectedOptionId =
                                      option
                                          .id;
                                },
                              );
                            },
                            child:
                                LiquidGlassContainer(
                              opacity:
                                  isSelected
                                      ? 0.14
                                      : 0.06,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    20,
                                vertical: 16,
                              ),
                              child:
                                  Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons
                                            .radio_button_checked
                                        : Icons
                                            .radio_button_off,
                                    color:
                                        isSelected
                                            ? _categoryColor
                                            : AppColors
                                                .textSecondary,
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child:
                                        Text(
                                      option
                                          .text,
                                      style:
                                          AppTextStyles
                                              .bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    ElevatedButton(
                      onPressed:
                          _selectedOptionId ==
                                  null
                              ? null
                              : _confirm,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            AppColors
                                .titanium,
                        foregroundColor:
                            AppColors
                                .onTitanium,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        'تأكيد التصويت',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
