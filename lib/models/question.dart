import 'question_option.dart';

class Question {
  final String id;
  final String text;
  final int categoryId;
  final List<QuestionOption> options;
  final String? authorName;

  /// User id of the author.
  final String? authorId;

  /// Id of the correct option.
  ///
  /// Optional for backwards compatibility with
  /// older poll-style questions.
  final String? correctOptionId;

  /// Optional discovery hashtags.
  ///
  /// Stored without the leading '#'.
  final List<String> hashtags;

  const Question({
    required this.id,
    required this.text,
    required this.categoryId,
    required this.options,
    this.authorName,
    this.authorId,
    this.correctOptionId,
    this.hashtags = const [],
  });
}
