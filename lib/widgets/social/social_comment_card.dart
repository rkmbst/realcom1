import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/question_comment.dart';
import 'social_replies_sheet.dart';
import 'social_user_name.dart';

class SocialCommentCard extends StatelessWidget {
  const SocialCommentCard({
    super.key,
    required this.comment,
    required this.replyCount,
    required this.likeCount,
    required this.isLiked,
    required this.onLike,
    required this.onReply,
  });

  final QuestionComment comment;
  final int replyCount;
  final int likeCount;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SocialUserName(
            userId: comment.authorId,
            userName: comment.authorName,
          ),
          const SizedBox(height: 7),
          Text(
            comment.text,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: onLike,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: isLiked
                            ? AppColors.like
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$likeCount',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onReply,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  minimumSize: const Size(0, 30),
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('رد'),
              ),
              if (replyCount > 0) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    SocialRepliesSheet.show(
                      context,
                      rootComment: comment,
                    );
                  },
                  borderRadius:
                      BorderRadius.circular(999),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Text(
                      '$replyCount ${replyCount == 1 ? 'رد' : 'ردود'}',
                      style:
                          AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
