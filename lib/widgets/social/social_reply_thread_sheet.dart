import 'package:flutter/material.dart';

import '../../core/social/comment_like_store.dart';
import '../../core/social/comment_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/question_comment.dart';
import '../liquid_glass_container.dart';
import 'social_reply_card.dart';
import 'social_user_name.dart';

class SocialReplyThreadSheet extends StatefulWidget {
  const SocialReplyThreadSheet({
    super.key,
    required this.parentComment,
  });

  final QuestionComment parentComment;

  static Future<void> show(
    BuildContext context, {
    required QuestionComment parentComment,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor:
          Colors.black.withOpacity(0.55),
      builder: (_) {
        return SocialReplyThreadSheet(
          parentComment: parentComment,
        );
      },
    );
  }

  @override
  State<SocialReplyThreadSheet> createState() =>
      _SocialReplyThreadSheetState();
}

class _SocialReplyThreadSheetState
    extends State<SocialReplyThreadSheet> {
  final _commentStore =
      CommentStore.instance;

  final _likeStore =
      CommentLikeStore.instance;

  final _controller =
      TextEditingController();

  QuestionComment? _replyTarget;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startReply(
    QuestionComment comment,
  ) {
    setState(() {
      _replyTarget = comment;
      _controller.clear();
    });
  }

  void _cancelReply() {
    setState(() {
      _replyTarget = null;
      _controller.clear();
    });
  }

  void _submitReply() {
    final text =
        _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    final currentParent =
        _replyTarget ??
            widget.parentComment;

    _commentStore.add(
      questionId:
          widget.parentComment.questionId,
      text: text,
      parentCommentId:
          currentParent.id,
    );

    _controller.clear();

    setState(() {
      _replyTarget = null;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final currentParent =
        _replyTarget ??
            widget.parentComment;

    final replies =
        _commentStore.repliesFor(
      currentParent.id,
    );

    final isRootThread =
        currentParent.id ==
            widget.parentComment.id;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom:
              MediaQuery.of(context)
                      .viewInsets
                      .bottom +
                  12,
        ),
        child: Container(
          height:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.76,
          decoration:
              BoxDecoration(
            color:
                AppColors.surface
                    .withOpacity(
              0.97,
            ),
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(28),
              bottom: Radius.circular(28),
            ),
            border: Border.all(
              color: AppColors
                  .titaniumBorder
                  .withOpacity(0.55),
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.all(16),
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
                        BorderRadius.circular(
                      999,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .forum_outlined,
                      size: 20,
                      color:
                          AppColors.primary,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        isRootThread
                            ? 'الردود على @${widget.parentComment.authorName}'
                            : 'الردود على @${currentParent.authorName}',
                        style:
                            AppTextStyles
                                .titleMedium,
                      ),
                    ),
                    if (!isRootThread)
                      TextButton(
                        onPressed:
                            () {
                          setState(() {
                            _replyTarget =
                                null;
                          });
                        },
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
                          'الرئيسي',
                        ),
                      ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                LiquidGlassContainer(
                  opacity: 0.045,
                  borderRadius: 16,
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      SocialUserName(
                        userId:
                            currentParent
                                .authorId,
                        userName:
                            currentParent
                                .authorName,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        currentParent.text,
                        style:
                            AppTextStyles
                                .bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Expanded(
                  child: replies.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد ردود بعد.',
                            style:
                                AppTextStyles
                                    .bodyMedium,
                          ),
                        )
                      : ListView.separated(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior
                                  .onDrag,
                          itemCount:
                              replies.length,
                          separatorBuilder:
                              (_, __) =>
                                  const SizedBox(
                            height: 10,
                          ),
                          itemBuilder:
                              (_, index) {
                            final reply =
                                replies[index];

                            final isLiked =
                                _likeStore
                                    .isLiked(
                              reply.id,
                            );

                            final likeCount =
                                _likeStore
                                    .likeCount(
                              reply.id,
                            );

                            final replyCount =
                                _commentStore
                                    .replyCount(
                              reply.id,
                            );

                            return SocialReplyCard(
                              reply:
                                  reply,
                              parent:
                                  currentParent,
                              likeCount:
                                  likeCount,
                              replyCount:
                                  replyCount,
                              isLiked:
                                  isLiked,
                              onLike:
                                  () {
                                setState(() {
                                  _likeStore
                                      .toggleLike(
                                    reply.id,
                                  );
                                });
                              },
                              onReply:
                                  () {
                                _startReply(
                                  reply,
                                );
                              },
                            );
                          },
                        ),
                ),

                if (_replyTarget != null) ...[
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .primary
                          .withOpacity(
                        0.08,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                      border: Border.all(
                        color: AppColors
                            .primary
                            .withOpacity(
                          0.30,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .reply_rounded,
                          size: 18,
                          color:
                              AppColors.primary,
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Expanded(
                          child: Text(
                            'الرد على @${_replyTarget!.authorName}',
                            style:
                                AppTextStyles
                                    .caption,
                          ),
                        ),
                        IconButton(
                          visualDensity:
                              VisualDensity.compact,
                          onPressed:
                              _cancelReply,
                          icon:
                              const Icon(
                            Icons
                                .close_rounded,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(
                  height: 10,
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
                        child:
                            TextField(
                          controller:
                              _controller,
                          maxLength: 500,
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
                                'الرد على @${currentParent.authorName}...',
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
                                Colors
                                    .transparent,
                            border:
                                InputBorder
                                    .none,
                            enabledBorder:
                                InputBorder
                                    .none,
                            focusedBorder:
                                InputBorder
                                    .none,
                            errorBorder:
                                InputBorder
                                    .none,
                            focusedErrorBorder:
                                InputBorder
                                    .none,
                            contentPadding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted:
                              (_) =>
                                  _submitReply(),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Material(
                        color: Colors
                            .transparent,
                        child: InkWell(
                          onTap:
                              _submitReply,
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
                                  AppColors
                                      .primary,
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
    );
  }
}
