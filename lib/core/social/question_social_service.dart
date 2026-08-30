import '../auth/auth_session.dart';
import '../notifications/notification_service.dart';
import '../../models/question.dart';

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
    final actor = _session.currentUser;

    final authorId =
        question.authorId;

    if (authorId == null ||
        authorId.isEmpty) {
      return;
    }

    if (actor.id == authorId) {
      return;
    }

    _notifications.questionLiked(
      question: question,
    );
  }

  void notifyComment({
    required Question question,
  }) {
    final actor = _session.currentUser;

    final authorId =
        question.authorId;

    if (authorId == null ||
        authorId.isEmpty) {
      return;
    }

    if (actor.id == authorId) {
      return;
    }

    _notifications.questionCommented(
      question: question,
    );
  }
}
