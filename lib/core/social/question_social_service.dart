import '../auth/auth_session.dart';
import '../notifications/notification_store.dart';
import '../../models/notification.dart';
import '../../models/question.dart';

class QuestionSocialService {
  QuestionSocialService._();

  static final QuestionSocialService instance =
      QuestionSocialService._();

  void notifyLike({
    required Question question,
  }) {
    final authorId = question.authorId;
    final authorName = question.authorName;

    if (authorId == null ||
        authorName == null) {
      return;
    }

    final actor =
        AuthSession.instance.currentUser;

    if (actor.id == authorId) {
      return;
    }

    NotificationStore.instance.add(
      AppNotification(
        id:
            'like-${question.id}-${actor.id}-${DateTime.now().microsecondsSinceEpoch}',
        type:
            NotificationType.like,
        recipientUserId:
            authorId,
        actorUserId:
            actor.id,
        actorName:
            actor.displayName,
        message:
            '${actor.displayName} أعجب بسؤالك',
        targetId:
            question.id,
        createdAt:
            DateTime.now(),
      ),
    );
  }

  void notifyComment({
    required Question question,
  }) {
    final authorId = question.authorId;
    final authorName = question.authorName;

    if (authorId == null ||
        authorName == null) {
      return;
    }

    final actor =
        AuthSession.instance.currentUser;

    if (actor.id == authorId) {
      return;
    }

    NotificationStore.instance.add(
      AppNotification(
        id:
            'comment-${question.id}-${actor.id}-${DateTime.now().microsecondsSinceEpoch}',
        type:
            NotificationType.comment,
        recipientUserId:
            authorId,
        actorUserId:
            actor.id,
        actorName:
            actor.displayName,
        message:
            '${actor.displayName} علّق على سؤالك',
        targetId:
            question.id,
        createdAt:
            DateTime.now(),
      ),
    );
  }
}
