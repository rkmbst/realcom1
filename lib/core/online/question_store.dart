import '../../models/question.dart';

class QuestionStore {
  QuestionStore._();

  static final QuestionStore instance =
      QuestionStore._();

  final List<Question> _publishedQuestions =
      <Question>[];

  /// All questions currently published
  /// during this app session.
  List<Question> get publishedQuestions =>
      List.unmodifiable(
        _publishedQuestions,
      );

  /// Add a newly published question.
  void add(Question question) {
    _publishedQuestions.add(question);
  }

  /// Get all questions created by one user.
  List<Question> byAuthor(
    String authorId,
  ) {
    return _publishedQuestions
        .where(
          (question) =>
              question.authorId == authorId,
        )
        .toList(growable: false);
  }

  /// Count questions created by one user.
  int countByAuthor(
    String authorId,
  ) {
    return _publishedQuestions
        .where(
          (question) =>
              question.authorId == authorId,
        )
        .length;
  }

  /// Get all questions containing
  /// a specific hashtag.
  ///
  /// Hashtags are stored without '#'
  /// and normalized to lowercase.
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
        .toList(growable: false);
  }

  /// Get all questions in one category.
  List<Question> byCategory(
    int categoryId,
  ) {
    return _publishedQuestions
        .where(
          (question) =>
              question.categoryId ==
              categoryId,
        )
        .toList(growable: false);
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
