import '../auth/auth_session.dart';
import '../notifications/notification_store.dart';
import '../../models/notification.dart';

class OnlineInteractionStore {
  OnlineInteractionStore._();

  static final OnlineInteractionStore instance =
      OnlineInteractionStore._();

  final Map<String, Set<String>>
      _likedQuestionsByUser =
      <String, Set<String>>{};

  final Map<String, List<String>>
      _comments =
      <String, List<String>>{};

  bool isLiked(
    String questionId,
  ) {
    final userId =
        AuthSession.instance
            .currentUser.id;

    return _likedQuestionsByUser[
              userId]
          ?.contains(
        questionId,
      ) ??
        false;
  }

  int likeCount(
    String questionId,
  ) {
    return _likedQuestionsByUser.values
        .where(
          (questions) =>
              questions.contains(
            questionId,
          ),
        )
        .length;
  }

  bool toggleLike(
    String questionId, {
    String? authorId,
    String? authorName,
  }) {
    final currentUser =
        AuthSession.instance.currentUser;

    final likes =
        _likedQuestionsByUser[
                currentUser.id] ??=
            <String>{};

    final alreadyLiked =
        likes.contains(
      questionId,
    );

    if (alreadyLiked) {
      likes.remove(questionId);
      return false;
    }

    likes.add(questionId);

    if (authorId != null &&
        authorName != null &&
        currentUser.id != authorId) {
      NotificationStore.instance.add(
        AppNotification(
          id:
              'like-${currentUser.id}-$questionId-${DateTime.now().microsecondsSinceEpoch}',
          type:
              NotificationType.like,
          recipientUserId:
              authorId,
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

    return true;
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

    (_comments[questionId] ??=
            <String>[])
        .add(text);

    final currentUser =
        AuthSession.instance.currentUser;

    if (authorId != null &&
        authorName != null &&
        currentUser.id != authorId) {
      NotificationStore.instance.add(
        AppNotification(
          id:
              'comment-${currentUser.id}-$questionId-${DateTime.now().microsecondsSinceEpoch}',
          type:
              NotificationType.comment,
          recipientUserId:
              authorId,
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

  int commentCount(
    String questionId,
  ) {
    return _comments[
                questionId]
            ?.length ??
        0;
  }
}
