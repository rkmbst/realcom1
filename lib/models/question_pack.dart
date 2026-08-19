import 'question.dart';

class QuestionPack {
  final String id;
  final String publisherId;
  final String title;
  final List<Question> questions;

  const QuestionPack({
    required this.id,
    required this.publisherId,
    required this.title,
    required this.questions,
  });

  /// Whether this pack contains at least one quiz question.
  bool get containsQuiz {
    return questions.any(
      (question) =>
          question.type == QuestionType.quiz,
    );
  }

  /// Whether every question in this pack
  /// is a poll/opinion/discussion question.
  bool get isOpinionPack {
    return questions.every(
      (question) =>
          question.type != QuestionType.quiz,
    );
  }
}
