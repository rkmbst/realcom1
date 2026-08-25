import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/online/feed_interaction_store.dart';
import '../../core/social/comment_store.dart';
import '../../core/social/question_social_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../models/publisher.dart';
import '../../models/question.dart';
import '../../models/question_comment.dart';
import '../../models/question_option.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
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
  final _session = AuthSession.instance;

  final _feedInteractions =
      FeedInteractionStore.instance;

  final _commentStore =
      CommentStore.instance;

  final _socialService =
      QuestionSocialService.instance;

  late final List<QuestionOption> _options;

  String? _selectedOptionId;

  late final Color _categoryColor;

  bool get _isQuestionOwner {
    return widget.question.authorId != null &&
        widget.question.authorId ==
            _session.currentUser.id;
  }

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
      _socialService.notifyLike(
        question: widget.question,
      );
    }

    Haptics.light();
  }

  void _openComments() {
    final controller =
        TextEditingController();

    String? replyToCommentId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      barrierColor:
          Colors.black.withOpacity(
        0.55,
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            final rootComments =
                _commentStore.rootComments(
              widget.question.id,
            );

            void submitComment() {
              final text =
                  controller.text.trim();

              if (text.isEmpty) {
                return;
              }

              final wasReply =
                  replyToCommentId != null;

              _commentStore.add(
                questionId:
                    widget.question.id,
                text: text,
                parentCommentId:
                    replyToCommentId,
              );

              if (!wasReply) {
                _socialService.notifyComment(
                  question:
                      widget.question,
                );
              }

              controller.clear();

              setSheetState(() {
                replyToCommentId = null;
              });

              Haptics.light();
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom:
                      MediaQuery.of(
                            context,
                          ).viewInsets.bottom +
                          12,
                ),
                child: Container(
                  decoration:
                      BoxDecoration(
                    color: AppColors.surface
                        .withOpacity(
                      0.96,
                    ),
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(
                        28,
                      ),
                      bottom: Radius.circular(
                        28,
                      ),
                    ),
                    border: Border.all(
                      color: AppColors
                          .titaniumBorder
                          .withOpacity(
                        0.55,
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color:
                            Colors.black38,
                        blurRadius: 30,
                        offset: Offset(
                          0,
                          -8,
                        ),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height:
                        MediaQuery.of(
                              context,
                            ).size.height *
                            0.72,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 42,
                            height: 4,
                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .textSecondary
                                  .withOpacity(
                                0.45,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                999,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          Row(
                            children: [
                              Text(
                                'التعليقات',
                                style:
                                    AppTextStyles
                                        .titleMedium,
                              ),
                              const Spacer(),
                              Text(
                                '${_commentStore.countForQuestion(widget.question.id)}',
                                style:
                                    AppTextStyles
                                        .caption,
                              ),
                            ],
                          ),

                          if (replyToCommentId !=
                              null) ...[
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width:
                                  double.infinity,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: AppColors
                                    .primary
                                    .withOpacity(
                                  0.08,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                                border:
                                    Border.all(
                                  color: AppColors
                                      .primary
                                      .withOpacity(
                                    0.35,
                                  ),
                                ),
                              ),
                              child:
                                  Row(
                                children: [
                                  const Icon(
                                    Icons.reply_rounded,
                                    size: 18,
                                    color:
                                        AppColors.primary,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'الرد على التعليق',
                                      style:
                                          AppTextStyles.caption,
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity:
                                        VisualDensity.compact,
                                    onPressed:
                                        () {
                                      setSheetState(
                                        () {
                                          replyToCommentId =
                                              null;
                                        },
                                      );
                                    },
                                    icon:
                                        const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(
                            height: 12,
                          ),

                          Expanded(
                            child:
                                rootComments.isEmpty
                                    ? const Center(
                                        child:
                                            Text(
                                          'لا توجد تعليقات بعد.\nكن أول من يشارك رأيه.',
                                          textAlign:
                                              TextAlign.center,
                                          style:
                                              AppTextStyles.bodyMedium,
                                        ),
                                      )
                                    : ListView.separated(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        itemCount:
                                            rootComments.length,
                                        separatorBuilder:
                                            (_, __) =>
                                                const SizedBox(
                                          height: 10,
                                        ),
                                        itemBuilder:
                                            (_, index) {
                                          final comment =
                                              rootComments[
                                                  index];

                                          final replies =
                                              _commentStore
                                                  .repliesFor(
                                            comment.id,
                                          );

                                          return _CommentThread(
                                            comment:
                                                comment,
                                            replies:
                                                replies,
                                            onReply:
                                                () {
                                              setSheetState(
                                                () {
                                                  replyToCommentId =
                                                      comment.id;
                                                },
                                              );
                                            },
                                            onOpenProfile:
                                                (userId) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          ProfileScreen(
                                                    userId:
                                                        userId,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          LiquidGlassContainer(
                            opacity: 0.08,
                            borderRadius: 20,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .end,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        controller,
                                    maxLength:
                                        500,
                                    minLines: 1,
                                    maxLines: 4,
                                    textInputAction:
                                        TextInputAction
                                            .send,
                                    style:
                                        AppTextStyles
                                            .bodyMedium
                                            .copyWith(
                                      color: AppColors
                                          .textPrimary,
                                    ),
                                    cursorColor:
                                        AppColors
                                            .primary,
                                    decoration:
                                        InputDecoration(
                                      hintText:
                                          replyToCommentId ==
                                                  null
                                              ? 'اكتب تعليقك...'
                                              : 'اكتب ردك...',
                                      hintStyle:
                                          AppTextStyles
                                              .bodyMedium
                                              .copyWith(
                                        color: AppColors
                                            .textSecondary
                                            .withOpacity(
                                          0.72,
                                        ),
                                      ),
                                      counterText:
                                          '',
                                      filled: false,
                                      fillColor:
                                          Colors.transparent,
                                      border:
                                          InputBorder.none,
                                      enabledBorder:
                                          InputBorder.none,
                                      focusedBorder:
                                          InputBorder.none,
                                      errorBorder:
                                          InputBorder.none,
                                      focusedErrorBorder:
                                          InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                    ),
                                    onSubmitted:
                                        (_) =>
                                            submitComment(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Material(
                                  color:
                                      Colors.transparent,
                                  child: InkWell(
                                    onTap:
                                        submitComment,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                    child:
                                        Container(
                                      width: 44,
                                      height: 44,
                                      decoration:
                                          BoxDecoration(
                                        color: AppColors
                                            .primary
                                            .withOpacity(
                                          0.14,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          14,
                                        ),
                                        border:
                                            Border.all(
                                          color: AppColors
                                              .primary
                                              .withOpacity(
                                            0.45,
                                          ),
                                        ),
                                      ),
                                      child:
                                          const Icon(
                                        Icons
                                            .send_rounded,
                                        size: 20,
                                        color:
                                            AppColors.primary,
                                      ),
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
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(
      controller.dispose,
    );
  }

  Future<void> _confirm() async {
    if (_isQuestionOwner) {
      return;
    }

    final selectedOptionId =
        _selectedOptionId;

    if (selectedOptionId == null) {
      return;
    }

    _feedInteractions.markAnswered(
      widget.question.id,
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
        _commentStore.countForQuestion(
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
                                    AppTextStyles.username,
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
                            BorderRadius.circular(
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
                                BorderRadius.circular(
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
                                    color: isLiked
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
                                        AppTextStyles.caption,
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
                            onTap:
                                _openComments,
                            borderRadius:
                                BorderRadius.circular(
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
                                        AppColors.textSecondary,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '$commentCount',
                                    style:
                                        AppTextStyles.caption,
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

                  if (isOwner)
                    LiquidGlassContainer(
                      opacity: 0.06,
                      padding:
                          const EdgeInsets.all(
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
                                AppColors.textSecondary,
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
                            height: 5,
                          ),
                          Text(
                            'يمكنك قراءة النتائج والتعليقات والرد عليها، لكن لا يمكنك الإجابة عن سؤالك.',
                            textAlign:
                                TextAlign.center,
                            style:
                                AppTextStyles
                                    .caption,
                          ),
                        ],
                      ),
                    )
                  else ...[
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
                              setState(() {
                                _selectedOptionId =
                                    option.id;
                              });
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
                                horizontal: 20,
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
                                      option.text,
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
                          ElevatedButton.styleFrom(
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
                        'تأكيد الإجابة',
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

class _CommentThread
    extends StatelessWidget {
  const _CommentThread({
    required this.comment,
    required this.replies,
    required this.onReply,
    required this.onOpenProfile,
  });

  final QuestionComment comment;
  final List<QuestionComment> replies;
  final VoidCallback onReply;
  final ValueChanged<String> onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        LiquidGlassContainer(
          opacity: 0.055,
          padding:
              const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () =>
                    onOpenProfile(
                  comment.authorId,
                ),
                borderRadius:
                    BorderRadius.circular(
                  8,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 2,
                  ),
                  child: Text(
                    comment.authorName,
                    style:
                        AppTextStyles.username
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
                comment.text,
                style:
                    AppTextStyles.bodyMedium,
              ),
              const SizedBox(
                height: 7,
              ),
              TextButton(
                onPressed: onReply,
                style:
                    TextButton.styleFrom(
                  padding:
                      EdgeInsets.zero,
                  minimumSize:
                      const Size(
                    0,
                    32,
                  ),
                  tapTargetSize:
                      MaterialTapTargetSize
                          .shrinkWrap,
                ),
                child:
                    const Text(
                  'رد',
                ),
              ),
            ],
          ),
        ),

        if (replies.isNotEmpty)
          Padding(
            padding:
                const EdgeInsetsDirectional.only(
              start: 20,
              top: 8,
            ),
            child: Column(
              children: replies
                  .map(
                (reply) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child:
                        LiquidGlassContainer(
                      opacity:
                          0.035,
                      padding:
                          const EdgeInsets.all(
                        10,
                      ),
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          InkWell(
                            onTap: () =>
                                onOpenProfile(
                              reply.authorId,
                            ),
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
                                vertical: 2,
                              ),
                              child:
                                  Text(
                                reply.authorName,
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
                            height: 4,
                          ),
                          Text(
                            reply.text,
                            style:
                                AppTextStyles
                                    .bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
      ],
    );
  }
}
