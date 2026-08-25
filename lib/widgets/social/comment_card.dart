import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/question_comment.dart';
import '../liquid_glass_container.dart';
import 'reply_card.dart';
import 'user_name.dart';

class SocialCommentCard extends StatelessWidget {
  const SocialCommentCard({
    super.key,
    required this.comment,
    required this.replies,
    required this.onReply,
  });

  final QuestionComment comment;
  final List<QuestionComment> replies;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LiquidGlassContainer(
          opacity: 0.055,
          borderRadius: 18,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SocialUserName(
                userId: comment.authorId,
                userName: comment.authorName,
                fontWeight: FontWeight.w700,
              ),

              const SizedBox(height: 6),

              Text(
                comment.text,
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: 7),

              Row(
                children: [
                  TextButton(
                    onPressed: onReply,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 30),
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('رد'),
                  ),

                  if (replies.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Text(
                      '${replies.length} رد',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        if (replies.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...replies.map(
            (reply) => Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
              ),
              child: SocialReplyCard(
                reply: reply,
                parentComment: comment,
                onReply: onReply,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
