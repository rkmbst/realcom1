import '../auth/auth_session.dart';
import '../../models/notification.dart';
import '../../models/question.dart';
import '../../models/question_comment.dart';
import 'notification_repository.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final _session = AuthSession.instance;

  final NotificationRepository _repository =
      LocalNotificationRepository();

  // ─────────────────────────────────────
  // Follow
  // ─────────────────────────────────────

  void followCreated({
    required String recipientUserId,
  }) {
    final actor = _session.currentUser;

    if (_invalidRecipient(
      recipientUserId,
      actor.id,
    )) {
      return;
    }

    _emit(
      id:
          'follow-$recipientUserId-${actor.id}',
      type:
          NotificationType.follow,
      recipientUserId:
          recipientUserId,
      actorUserId:
          actor.id,
      actorName:
          actor.displayName,
      message:
          '${actor.displayName} بدأ بمتابعتك',
      targetId:
          actor.id,
    );
  }

  // ─────────────────────────────────────
  // Question Like
  // ─────────────────────────────────────

  void questionLiked({
    required Question question,
  }) {
    final recipientId =
        question.authorId;

    if (recipientId == null ||
        recipientId.isEmpty) {
      return;
    }

    final actor = _session.currentUser;

    if (_invalidRecipient(
      recipientId,
      actor.id,
    )) {
      return;
    }

    _emit(
      id:
          'question-like-${question.id}-${actor.id}',
      type:
          NotificationType.like,
      recipientUserId:
          recipientId,
      actorUserId:
          actor.id,
      actorName:
          actor.displayName,
      message:
          '${actor.displayName} أعجب بسؤالك',
      targetId:
          question.id,
    );
  }

  // ─────────────────────────────────────
  // Question Comment
  // ─────────────────────────────────────

  void questionCommented({
    required Question question,
    required QuestionComment comment,
  }) {
    final recipientId =
        question.authorId;

    if (recipientId == null ||
        recipientId.isEmpty) {
      return;
    }

    final actor = _session.currentUser;

    if (_invalidRecipient(
      recipientId,
      actor.id,
    )) {
      return;
    }

    _emit(
      id:
          'question-comment-${comment.id}',
      type:
          NotificationType.comment,
      recipientUserId:
          recipientId,
      actorUserId:
          actor.id,
      actorName:
          actor.displayName,
      message:
          '${actor.displayName} علّق على سؤالك',
      targetId:
          question.id,
    );
  }

  // ─────────────────────────────────────
  // Reply to comment
  // ─────────────────────────────────────

  void commentReplied({
    required QuestionComment parentComment,
    required QuestionComment reply,
  }) {
    final recipientId =
        parentComment.authorId;

    final actor = _session.currentUser;

    if (_invalidRecipient(
      recipientId,
      actor.id,
    )) {
      return;
    }

    _emit(
      id:
          'comment-reply-${reply.id}',
      type:
          NotificationType.reply,
      recipientUserId:
          recipientId,
      actorUserId:
          actor.id,
      actorName:
          actor.displayName,
      message:
          '${actor.displayName} رد على تعليقك',
      targetId:
          reply.id,
      parentTargetId:
          parentComment.id,
    );
  }

  // ─────────────────────────────────────
  // New question / pack
  // ─────────────────────────────────────

  void questionPackPublished({
    required String recipientUserId,
    required String packId,
    required String message,
  }) {
    final actor = _session.currentUser;

    if (_invalidRecipient(
      recipientUserId,
      actor.id,
    )) {
      return;
    }

    _emit(
      id:
          'new-question-$packId-$recipientUserId',
      type:
          NotificationType.newQuestion,
      recipientUserId:
          recipientUserId,
      actorUserId:
          actor.id,
      actorName:
          actor.displayName,
      message:
          message,
      targetId:
          packId,
    );
  }

  // ─────────────────────────────────────
  // Internal
  // ─────────────────────────────────────

  bool _invalidRecipient(
    String recipientUserId,
    String actorUserId,
  ) {
    return recipientUserId.isEmpty ||
        recipientUserId ==
            actorUserId;
  }

  void _emit({
    required String id,
    required NotificationType type,
    required String recipientUserId,
    required String actorUserId,
    required String actorName,
    required String message,
    String? targetId,
    String? parentTargetId,
  }) {
    _repository.add(
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
        parentTargetId:
            parentTargetId,
        createdAt:
            DateTime.now(),
      ),
    );
  }
}
