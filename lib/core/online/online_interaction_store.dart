class OnlineInteractionStore {
  OnlineInteractionStore._();

  static final OnlineInteractionStore instance =
      OnlineInteractionStore._();

  final Map<String, bool> _likedQuestions = {};
  final Map<String, List<String>> _comments = {};

  bool isLiked(String questionId) {
    return _likedQuestions[questionId] ?? false;
  }

  int likeCount(String questionId) {
    return _likedQuestions[questionId] == true ? 1 : 0;
  }

  bool toggleLike(String questionId) {
    final current = isLiked(questionId);
    final next = !current;

    _likedQuestions[questionId] = next;

    return next;
  }

  List<String> comments(String questionId) {
    return List.unmodifiable(
      _comments[questionId] ?? const [],
    );
  }

  void addComment(
    String questionId,
    String comment,
  ) {
    final text = comment.trim();

    if (text.isEmpty) {
      return;
    }

    (_comments[questionId] ??= <String>[])
        .add(text);
  }

  int commentCount(String questionId) {
    return _comments[questionId]?.length ?? 0;
  }
}
