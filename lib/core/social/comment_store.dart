import '../../core/auth/auth_session.dart';
import '../../models/question_comment.dart';

class CommentStore {
  CommentStore._();

  static final CommentStore instance =
      CommentStore._();

  final List<QuestionComment> _comments =
      <QuestionComment>[];

  List<QuestionComment> forQuestion(
    String questionId,
  ) {
    return _comments
        .where(
          (comment) =>
              comment.questionId ==
              questionId,
        )
        .toList(
          growable: false,
        );
  }

  List<QuestionComment> rootComments(
    String questionId,
  ) {
    return _comments
        .where(
          (comment) =>
              comment.questionId ==
                  questionId &&
              comment.parentCommentId ==
                  null,
        )
        .toList(
          growable: false,
        );
  }

  List<QuestionComment> repliesFor(
    String commentId,
  ) {
    return _comments
        .where(
          (comment) =>
              comment.parentCommentId ==
              commentId,
        )
        .toList(
          growable: false,
        );
  }

  int countForQuestion(
    String questionId,
  ) {
    return _comments
        .where(
          (comment) =>
              comment.questionId ==
              questionId,
        )
        .length;
  }

  int replyCount(
    String commentId,
  ) {
    return _comments
        .where(
          (comment) =>
              comment.parentCommentId ==
              commentId,
        )
        .length;
  }

  QuestionComment add({
    required String questionId,
    required String text,
    String? parentCommentId,
  }) {
    final trimmed =
        text.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError(
        'Comment text cannot be empty.',
      );
    }

    final user =
        AuthSession.instance.currentUser;

    final comment =
        QuestionComment(
      id:
          'comment-${DateTime.now().microsecondsSinceEpoch}',
      questionId:
          questionId,
      authorId:
          user.id,
      authorName:
          user.displayName,
      text:
          trimmed,
      createdAt:
          DateTime.now(),
      parentCommentId:
          parentCommentId,
    );

    _comments.add(comment);

    return comment;
  }

  void remove(
    String commentId,
  ) {
    final childIds = _comments
        .where(
          (comment) =>
              comment.parentCommentId ==
              commentId,
        )
        .map(
          (comment) =>
              comment.id,
        )
        .toSet();

    _comments.removeWhere(
      (comment) =>
          comment.id ==
              commentId ||
          childIds.contains(
            comment.id,
          ),
    );
  }

  void clear() {
    _comments.clear();
  }
}
