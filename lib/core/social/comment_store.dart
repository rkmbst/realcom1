import '../../core/auth/auth_session.dart';
import '../../models/question_comment.dart';

class CommentStore {
  CommentStore._();

  static final CommentStore instance =
      CommentStore._();

  final List<QuestionComment>
      _comments = <QuestionComment>[];

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

  QuestionComment add({
    required String questionId,
    required String text,
  }) {
    final user =
        AuthSession.instance.currentUser;

    final comment = QuestionComment(
      id:
          'comment-${DateTime.now().microsecondsSinceEpoch}',
      questionId: questionId,
      authorId: user.id,
      authorName: user.displayName,
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    _comments.add(comment);

    return comment;
  }

  void remove(
    String commentId,
  ) {
    _comments.removeWhere(
      (comment) =>
          comment.id == commentId,
    );
  }

  void clear() {
    _comments.clear();
  }
}
