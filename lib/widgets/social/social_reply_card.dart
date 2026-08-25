import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/question_comment.dart';
import 'social_user_name.dart';

class SocialReplyCard extends StatelessWidget {
  const SocialReplyCard({
    super.key,
    required this.reply,
    required this.parent,
    required this.likeCount,
    required this.isLiked,
    required this.onLike,
    required this.onReply,
  });

  final QuestionComment reply;
  final QuestionComment parent;
  final int likeCount;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(
        start: 20,
      ),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SocialUserName(
                  userId: reply.authorId,
                  userName: reply.authorName,
                ),
              ),
              Text(
                '↳ @${parent.authorName}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            reply.text,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              InkWell(
                onTap: onLike,
                borderRadius:
                    BorderRadius.circular(999),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons
                                .favorite_border_rounded,
                        size: 17,
                        color: isLiked
                            ? AppColors.like
                            : AppColors
                                .textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$likeCount',
                        style:
                            AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onReply,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  minimumSize:
                      const Size(0, 30),
                  tapTargetSize:
                      MaterialTapTargetSize
                          .shrinkWrap,
                ),
                child:
                    const Text('رد'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
