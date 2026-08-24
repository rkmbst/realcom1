class QuestionComment {
  const QuestionComment({
    required this.id,
    required this.questionId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.parentCommentId,
  });

  final String id;
  final String questionId;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  /// Null = تعليق رئيسي.
  /// غير null = رد على تعليق آخر.
  final String? parentCommentId;

  bool get isReply => parentCommentId != null;
}
