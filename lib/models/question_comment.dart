class QuestionComment {
  const QuestionComment({
    required this.id,
    required this.questionId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String questionId;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;
}
