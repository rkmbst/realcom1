import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/question_comment.dart';
import '../liquid_glass_container.dart';
import 'user_name.dart';

class SocialReplyCard extends StatelessWidget {
  const SocialReplyCard({
    super.key,
    required this.reply,
    required this.parentComment,
    this.onReply,
  });

  final QuestionComment reply;
  final QuestionComment parentComment;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 24,
      ),
      child: LiquidGlassContainer(
        opacity: 0.04,
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SocialUserName(
              userId: reply.authorId,
              userName: reply.authorName,
              fontWeight: FontWeight.w700,
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(
                  Icons.subdirectory_arrow_left_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '@${parentComment.authorName}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              reply.text,
              style: AppTextStyles.bodyMedium,
            ),

            if (onReply != null) ...[
              const SizedBox(height: 6),
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
            ],
          ],
        ),
      ),
    );
  }
}
