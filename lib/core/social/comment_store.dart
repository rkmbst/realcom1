import 'package:flutter/foundation.dart';

import '../../core/auth/auth_session.dart';
import '../../models/question_comment.dart';

class CommentStore extends ChangeNotifier {
  CommentStore._();

  static final CommentStore instance =
      CommentStore._();

  final List<QuestionComment> _comments =
      <QuestionComment>[];

  // ─────────────────────────────────────
  // Queries
  // ─────────────────────────────────────

  List<QuestionComment> forQuestion(
    String questionId,
  ) {
    return List.unmodifiable(
      _comments.where(
        (comment) =>
            comment.questionId ==
            questionId,
      ),
    );
  }

  List<QuestionComment> rootComments(
    String questionId,
  ) {
    return List.unmodifiable(
      _comments.where(
        (comment) =>
            comment.questionId ==
                questionId &&
            comment.parentCommentId ==
                null,
      ),
    );
  }

  List<QuestionComment> repliesFor(
    String commentId,
  ) {
    return List.unmodifiable(
      _comments.where(
        (comment) =>
            comment.parentCommentId ==
            commentId,
      ),
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

  QuestionComment? findById(
    String commentId,
  ) {
    for (final comment in _comments) {
      if (comment.id == commentId) {
        return comment;
      }
    }

    return null;
  }

  // ─────────────────────────────────────
  // Create
  // ─────────────────────────────────────

  QuestionComment add({
    required String questionId,
    required String text,
    String? parentCommentId,
  }) {
    final trimmed = text.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError(
        'Comment text cannot be empty.',
      );
    }

    QuestionComment? parent;

    if (parentCommentId != null) {
      parent = findById(
        parentCommentId,
      );

      if (parent == null) {
        throw ArgumentError(
          'Parent comment does not exist.',
        );
      }

      if (parent.questionId !=
          questionId) {
        throw ArgumentError(
          'Parent comment belongs to another question.',
        );
      }
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
          parent?.id,
    );

    _comments.add(comment);

    notifyListeners();

    return comment;
  }

  // ─────────────────────────────────────
  // Remove
  // ─────────────────────────────────────

  void remove(
    String commentId,
  ) {
    final idsToRemove =
        <String>{commentId};

    bool foundNewChild;

    do {
      foundNewChild = false;

      for (final comment
          in _comments) {
        final parentId =
            comment.parentCommentId;

        if (parentId != null &&
            idsToRemove.contains(
              parentId,
            ) &&
            !idsToRemove.contains(
              comment.id,
            )) {
          idsToRemove.add(
            comment.id,
          );

          foundNewChild = true;
        }
      }
    } while (foundNewChild);

    final before =
        _comments.length;

    _comments.removeWhere(
      (comment) =>
          idsToRemove.contains(
        comment.id,
      ),
    );

    if (_comments.length != before) {
      notifyListeners();
    }
  }

  // ─────────────────────────────────────
  // Reset
  // ─────────────────────────────────────

  void clear() {
    if (_comments.isEmpty) {
      return;
    }

    _comments.clear();

    notifyListeners();
  }
}
