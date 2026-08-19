import 'question_option.dart';

enum QuestionType {
  quiz,
  poll,
  opinion,
  discussion,
}

class Question {
  final String id;
  final String text;
  final int categoryId;
  final List<QuestionOption> options;

  final String? authorName;
  final String? authorId;

  /// Defines what kind of interaction this question represents.
  final QuestionType type;

  /// Id of the correct option.
  ///
  /// Only used when [type] is [QuestionType.quiz].
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
    this.type = QuestionType.poll,
    this.correctOptionId,
    this.hashtags = const [],
  });

  bool get hasCorrectAnswer {
    return type == QuestionType.quiz &&
        correctOptionId != null;
  }
}
