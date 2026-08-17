import '../../models/question.dart';

class QuestionStore {
  QuestionStore._();

  static final QuestionStore instance =
      QuestionStore._();

  final List<Question> _publishedQuestions =
      <Question>[];

  List<Question> get publishedQuestions =>
      List.unmodifiable(
        _publishedQuestions,
      );

  void add(Question question) {
    _publishedQuestions.add(question);
  }

  List<Question> byAuthor(String authorId) {
    return _publishedQuestions
        .where(
          (question) =>
              question.authorId == authorId,
        )
        .toList(growable: false);
  }

  int countByAuthor(String authorId) {
    return _publishedQuestions
        .where(
          (question) =>
              question.authorId == authorId,
        )
        .length;
  }
}
