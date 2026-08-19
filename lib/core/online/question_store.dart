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

  void addAll(
    Iterable<Question> questions,
  ) {
    _publishedQuestions.addAll(
      questions,
    );
  }

  Question? find(String questionId) {
    for (final question
        in _publishedQuestions) {
      if (question.id == questionId) {
        return question;
      }
    }

    return null;
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
        _normalizeHashtag(hashtag);

    return _publishedQuestions
        .where(
          (question) =>
              question.hashtags.contains(
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
        .replaceFirst('#', '')
        .toLowerCase();
  }
}
