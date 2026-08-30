import '../auth/auth_session.dart';
import 'notification_store.dart';
import '../../models/notification.dart';
import '../../models/question.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final _session = AuthSession.instance;
  final _store = NotificationStore.instance;

  /// Creates a notification for a new follow.
  void followCreated({
    required String recipientUserId,
    required String recipientName,
  }) {
    final actor = _session.currentUser;

    if (actor.id == recipientUserId) {
      return;
    }

    _add(
      type: NotificationType.follow,
      recipientUserId: recipientUserId,
      actorUserId: actor.id,
      actorName: actor.displayName,
      message:
          '${actor.displayName} بدأ بمتابعتك',
      targetId: actor.id,
    );
  }

  /// Creates a notification when someone likes
  /// a question.
  void questionLiked({
    required Question question,
  }) {
    final recipientId = question.authorId;

    if (recipientId == null ||
        recipientId.isEmpty) {
      return;
    }

    final actor = _session.currentUser;

    if (actor.id == recipientId) {
      return;
    }

    _add(
      type: NotificationType.like,
      recipientUserId: recipientId,
      actorUserId: actor.id,
      actorName: actor.displayName,
      message:
          '${actor.displayName} أعجب بسؤالك',
      targetId: question.id,
    );
  }

  /// Creates a notification when someone comments
  /// on a question.
  void questionCommented({
    required Question question,
  }) {
    final recipientId = question.authorId;

    if (recipientId == null ||
        recipientId.isEmpty) {
      return;
    }

    final actor = _session.currentUser;

    if (actor.id == recipientId) {
      return;
    }

    _add(
      type: NotificationType.comment,
      recipientUserId: recipientId,
      actorUserId: actor.id,
      actorName: actor.displayName,
      message:
          '${actor.displayName} علّق على سؤالك',
      targetId: question.id,
    );
  }

  /// Creates a notification for a newly published pack.
  void questionPackPublished({
    required String recipientUserId,
    required String packId,
    required String message,
  }) {
    final actor = _session.currentUser;

    if (actor.id == recipientUserId) {
      return;
    }

    _add(
      type: NotificationType.newQuestion,
      recipientUserId: recipientUserId,
      actorUserId: actor.id,
      actorName: actor.displayName,
      message: message,
      targetId: packId,
    );
  }

  /// Central notification creation point.
  void _add({
    required NotificationType type,
    required String recipientUserId,
    required String actorUserId,
    required String actorName,
    required String message,
    String? targetId,
  }) {
    final now =
        DateTime.now();

    final id = [
      type.name,
      recipientUserId,
      actorUserId,
      targetId ?? 'none',
      now.microsecondsSinceEpoch,
    ].join('-');

    _store.add(
      AppNotification(
        id: id,
        type: type,
        recipientUserId:
            recipientUserId,
        actorUserId:
            actorUserId,
        actorName:
            actorName,
        message:
            message,
        targetId:
            targetId,
        createdAt:
            now,
      ),
    );
  }
}
