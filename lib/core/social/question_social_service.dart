import '../auth/auth_session.dart';
import '../notifications/notification_service.dart';
import '../../models/question.dart';
import '../../models/question_comment.dart';

class QuestionSocialService {
  QuestionSocialService._();

  static final QuestionSocialService instance =
      QuestionSocialService._();

  final _session =
      AuthSession.instance;

  final _notifications =
      NotificationService.instance;

  void notifyLike({
    required Question question,
  }) {
    final authorId =
        question.authorId;

    if (authorId == null ||
        authorId.isEmpty ||
        authorId ==
            _session.currentUser.id) {
      return;
    }

    _notifications.questionLiked(
      question: question,
    );
  }

  void notifyComment({
    required Question question,
    required QuestionComment comment,
  }) {
    final authorId =
        question.authorId;

    if (authorId == null ||
        authorId.isEmpty ||
        authorId ==
            _session.currentUser.id) {
      return;
    }

    _notifications.questionCommented(
      question: question,
      comment: comment,
    );
  }

  void notifyReply({
    required QuestionComment parentComment,
    required QuestionComment reply,
  }) {
    if (parentComment.authorId ==
        _session.currentUser.id) {
      return;
    }

    _notifications.commentReplied(
      parentComment:
          parentComment,
      reply:
          reply,
    );
  }
}
