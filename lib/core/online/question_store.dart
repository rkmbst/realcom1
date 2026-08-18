import '../../core/notifications/notification_store.dart';
import '../../core/social/follow_store.dart';
import '../../models/notification.dart';
import '../../models/question.dart';

class QuestionStore {
  QuestionStore._();

  static final QuestionStore instance =
      QuestionStore._();

  final List<Question>
      _publishedQuestions =
      <Question>[];

  List<Question>
      get publishedQuestions =>
          List.unmodifiable(
        _publishedQuestions,
      );

  void add(
    Question question,
  ) {
    _publishedQuestions.add(
      question,
    );

    final authorId =
        question.authorId;

    final authorName =
        question.authorName;

    if (authorId == null ||
        authorName == null) {
      return;
    }

    final followerIds =
        FollowStore.instance
            .followerIds(
      authorId,
    );

    for (final followerId
        in followerIds) {
      NotificationStore
          .instance
          .add(
        AppNotification(
          id:
              'question-$authorId-${question.id}-$followerId',
          type:
              NotificationType
                  .newQuestion,
          recipientUserId:
              followerId,
          actorUserId:
              authorId,
          actorName:
              authorName,
          message:
              '$authorName نشر سؤالًا جديدًا',
          targetId:
              question.id,
          createdAt:
              DateTime.now(),
        ),
      );
    }
  }

  List<Question> byAuthor(
    String authorId,
  ) {
    return _publishedQuestions
        .where(
          (question) =>
              question.authorId ==
              authorId,
        )
        .toList(
          growable: false,
        );
  }

  int countByAuthor(
    String authorId,
  ) {
    return _publishedQuestions
        .where(
          (question) =>
              question.authorId ==
              authorId,
        )
        .length;
  }

  List<Question> byHashtag(
    String hashtag,
  ) {
    final normalized =
        _normalizeHashtag(
      hashtag,
    );

    return _publishedQuestions
        .where(
          (question) =>
              question.hashtags
                  .contains(
            normalized,
          ),
        )
        .toList(
          growable: false,
        );
  }

  List<Question> byCategory(
    int categoryId,
  ) {
    return _publishedQuestions
        .where(
          (question) =>
              question.categoryId ==
              categoryId,
        )
        .toList(
          growable: false,
        );
  }

  String _normalizeHashtag(
    String value,
  ) {
    return value
        .trim()
        .replaceFirst(
          '#',
          '',
        )
        .toLowerCase();
  }
}
