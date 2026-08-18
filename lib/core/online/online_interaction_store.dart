import '../auth/auth_session.dart';
import '../notifications/notification_store.dart';
import '../../models/notification.dart';

class OnlineInteractionStore {
  OnlineInteractionStore._();

  static final OnlineInteractionStore instance =
      OnlineInteractionStore._();

  final Map<String, bool> _likedQuestions =
      <String, bool>{};

  final Map<String, List<String>> _comments =
      <String, List<String>>{};

  bool isLiked(
    String questionId,
  ) {
    return _likedQuestions[
            questionId] ??
        false;
  }

  int likeCount(
    String questionId,
  ) {
    return _likedQuestions[
                questionId] ==
            true
        ? 1
        : 0;
  }

  bool toggleLike(
    String questionId, {
    String? authorId,
    String? authorName,
  }) {
    final current =
        isLiked(questionId);

    final next = !current;

    _likedQuestions[
        questionId] = next;

    if (next &&
        authorId != null &&
        authorName != null) {
      final currentUser =
          AuthSession.instance
              .currentUser;

      if (currentUser.id !=
          authorId) {
        NotificationStore
            .instance
            .add(
          AppNotification(
            id:
                'like-${currentUser.id}-$questionId-${DateTime.now().microsecondsSinceEpoch}',
            type:
                NotificationType.like,
            actorUserId:
                currentUser.id,
            actorName:
                currentUser.displayName,
            message:
                '${currentUser.displayName} أعجب بسؤالك',
            targetId:
                questionId,
            createdAt:
                DateTime.now(),
          ),
        );
      }
    }

    return next;
  }

  List<String> comments(
    String questionId,
  ) {
    return List.unmodifiable(
      _comments[questionId] ??
          const <String>[],
    );
  }

  void addComment(
    String questionId,
    String comment, {
    String? authorId,
    String? authorName,
  }) {
    final text =
        comment.trim();

    if (text.isEmpty) {
      return;
    }

    (_comments[
                questionId] ??=
            <String>[])
        .add(text);

    if (authorId != null &&
        authorName != null) {
      final currentUser =
          AuthSession.instance
              .currentUser;

      if (currentUser.id !=
          authorId) {
        NotificationStore
            .instance
            .add(
          AppNotification(
            id:
                'comment-${currentUser.id}-$questionId-${DateTime.now().microsecondsSinceEpoch}',
            type:
                NotificationType
                    .comment,
            actorUserId:
                currentUser.id,
            actorName:
                currentUser.displayName,
            message:
                '${currentUser.displayName} علّق على سؤالك',
            targetId:
                questionId,
            createdAt:
                DateTime.now(),
          ),
        );
      }
    }
  }

  int commentCount(
    String questionId,
  ) {
    return _comments[
                questionId]
            ?.length ??
        0;
  }
}
