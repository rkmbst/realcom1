import 'package:flutter/material.dart';

import '../../core/social/comment_like_store.dart';
import '../../core/social/comment_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/question_comment.dart';
import 'social_reply_thread_sheet.dart';
import 'social_user_name.dart';

class SocialCommentCard extends StatefulWidget {
  const SocialCommentCard({
    super.key,
    required this.comment,
    required this.onReply,
    this.onLike,
  });

  final QuestionComment comment;
  final VoidCallback onReply;
  final VoidCallback? onLike;

  @override
  State<SocialCommentCard> createState() =>
      _SocialCommentCardState();
}

class _SocialCommentCardState
    extends State<SocialCommentCard> {
  final _likeStore =
      CommentLikeStore.instance;

  bool get _isLiked =>
      _likeStore.isLiked(
    widget.comment.id,
  );

  int get _likeCount =>
      _likeStore.likeCount(
    widget.comment.id,
  );

  int get _replyCount =>
      CommentStore.instance.replyCount(
    widget.comment.id,
  );

  void _toggleLike() {
    setState(() {
      _likeStore.toggleLike(
        widget.comment.id,
      );
    });

    widget.onLike?.call();
  }

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
            userId: widget.comment.authorId,
            userName: widget.comment.authorName,
          ),
          const SizedBox(height: 7),
          Text(
            widget.comment.text,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: _toggleLike,
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
                        _isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: _isLiked
                            ? AppColors.like
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_likeCount',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: widget.onReply,
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
              if (_replyCount > 0) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    SocialReplyThreadSheet.show(
                      context,
                      parentComment: widget.comment,
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
                      '$_replyCount ${_replyCount == 1 ? 'رد' : 'ردود'}',
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
