import 'package:flutter/material.dart';

import '../../core/social/comment_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/question_comment.dart';
import 'social_reply_card.dart';

class SocialRepliesSheet extends StatefulWidget {
  const SocialRepliesSheet({
    super.key,
    required this.rootComment,
  });

  final QuestionComment rootComment;

  static Future<void> show(
    BuildContext context, {
    required QuestionComment rootComment,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor:
          Colors.black.withOpacity(0.55),
      builder: (_) {
        return SocialRepliesSheet(
          rootComment: rootComment,
        );
      },
    );
  }

  @override
  State<SocialRepliesSheet> createState() =>
      _SocialRepliesSheetState();
}

class _SocialRepliesSheetState
    extends State<SocialRepliesSheet> {
  final _store = CommentStore.instance;

  @override
  Widget build(BuildContext context) {
    final replies =
        _store.repliesFor(
      widget.rootComment.id,
    );

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
                  0.72,
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
                        BorderRadius.circular(
                      999,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                Align(
                  alignment:
                      AlignmentDirectional
                          .centerStart,
                  child: Text(
                    'الردود على @${widget.rootComment.authorName}',
                    style:
                        AppTextStyles
                            .titleMedium,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Text(
                    widget.rootComment.text,
                    style:
                        AppTextStyles.bodyMedium,
                  ),
                ),

                const SizedBox(
                  height: 14,
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

                            return SocialReplyCard(
                              reply: reply,
                              parent:
                                  widget
                                      .rootComment,
                              likeCount: 0,
                              isLiked: false,
                              onLike: () {},
                              onReply: () {},
                            );
                          },
                        ),
                ),

                const SizedBox(
                  height: 10,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 48,
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon:
                        const Icon(
                      Icons.reply_rounded,
                    ),
                    label:
                        const Text(
                      'الرد على هذا التعليق',
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
                          0.55,
                        ),
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
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
