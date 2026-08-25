import 'package:flutter/material.dart';

import '../../core/social/comment_store.dart';
import '../../core/social/question_social_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/haptics.dart';
import '../../models/question.dart';
import '../../models/question_comment.dart';
import 'comment_card.dart';
import '../liquid_glass_container.dart';

class SocialCommentSheet extends StatefulWidget {
  const SocialCommentSheet({
    super.key,
    required this.question,
    this.onChanged,
  });

  final Question question;
  final VoidCallback? onChanged;

  static Future<void> show(
    BuildContext context, {
    required Question question,
    VoidCallback? onChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) {
        return SocialCommentSheet(
          question: question,
          onChanged: onChanged,
        );
      },
    );
  }

  @override
  State<SocialCommentSheet> createState() =>
      _SocialCommentSheetState();
}

class _SocialCommentSheetState
    extends State<SocialCommentSheet> {
  final _commentStore = CommentStore.instance;

  final _socialService =
      QuestionSocialService.instance;

  final _controller =
      TextEditingController();

  String? _replyToCommentId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _controller.clear();
    });
  }

  void _startReply(
    QuestionComment comment,
  ) {
    setState(() {
      _replyToCommentId = comment.id;
    });
  }

  void _submit() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    final parentId = _replyToCommentId;

    _commentStore.add(
      questionId: widget.question.id,
      text: text,
      parentCommentId: parentId,
    );

    if (parentId == null) {
      _socialService.notifyComment(
        question: widget.question,
      );
    }

    _controller.clear();

    setState(() {
      _replyToCommentId = null;
    });

    widget.onChanged?.call();

    Haptics.light();
  }

  @override
  Widget build(BuildContext context) {
    final rootComments =
        _commentStore.rootComments(
      widget.question.id,
    );

    final totalCount =
        _commentStore.countForQuestion(
      widget.question.id,
    );

    QuestionComment? replyTarget;

    if (_replyToCommentId != null) {
      for (final comment
          in _commentStore.forQuestion(
        widget.question.id,
      )) {
        if (comment.id ==
            _replyToCommentId) {
          replyTarget = comment;
          break;
        }
      }
    }

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
              MediaQuery.of(context).size.height *
                  0.72,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(
              0.96,
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
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 30,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors
                        .textSecondary
                        .withOpacity(0.45),
                    borderRadius:
                        BorderRadius.circular(
                      999,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Text(
                      'التعليقات',
                      style:
                          AppTextStyles.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      '$totalCount',
                      style:
                          AppTextStyles.caption,
                    ),
                  ],
                ),

                if (replyTarget != null) ...[
                  const SizedBox(height: 10),
                  LiquidGlassContainer(
                    opacity: 0.06,
                    borderRadius: 14,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
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
                        Expanded(
                          child: Text(
                            'الرد على @${replyTarget.authorName}',
                            style:
                                AppTextStyles.caption,
                          ),
                        ),
                        IconButton(
                          visualDensity:
                              VisualDensity.compact,
                          onPressed:
                              _cancelReply,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                Expanded(
                  child: rootComments.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد تعليقات بعد.\nكن أول من يشارك رأيه.',
                            textAlign:
                                TextAlign.center,
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
                              rootComments.length,
                          separatorBuilder:
                              (_, __) =>
                                  const SizedBox(
                            height: 10,
                          ),
                          itemBuilder:
                              (_, index) {
                            final comment =
                                rootComments[index];

                            return SocialCommentCard(
                              comment: comment,
                              onReply: () =>
                                  _startReply(
                                comment,
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 12),

                LiquidGlassContainer(
                  opacity: 0.08,
                  borderRadius: 20,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                              _controller,
                          maxLength: 500,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction:
                              TextInputAction.send,
                          style:
                              AppTextStyles.bodyMedium
                                  .copyWith(
                            color:
                                AppColors.textPrimary,
                          ),
                          cursorColor:
                              AppColors.primary,
                          decoration:
                              InputDecoration(
                            hintText:
                                replyTarget == null
                                    ? 'اكتب تعليقك...'
                                    : 'الرد على @${replyTarget.authorName}...',
                            hintStyle:
                                AppTextStyles.bodyMedium
                                    .copyWith(
                              color: AppColors
                                  .textSecondary
                                  .withOpacity(
                                0.72,
                              ),
                            ),
                            counterText: '',
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
                          onSubmitted: (_) =>
                              _submit(),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _submit,
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors
                                  .primary
                                  .withOpacity(
                                0.14,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                              border: Border.all(
                                color: AppColors
                                    .primary
                                    .withOpacity(
                                  0.45,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.send_rounded,
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
    );
  }
}
