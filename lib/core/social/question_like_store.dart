import '../auth/auth_session.dart';

class QuestionLikeStore {
  QuestionLikeStore._();

  static final QuestionLikeStore instance =
      QuestionLikeStore._();

  final Map<String, Set<String>>
      _likesByQuestion =
      <String, Set<String>>{};

  String get _userId =>
      AuthSession.instance.currentUser.id;

  Set<String> _likesFor(
    String questionId,
  ) {
    return _likesByQuestion[
            questionId] ??=
        <String>{};
  }

  bool isLiked(
    String questionId,
  ) {
    return _likesFor(questionId)
        .contains(_userId);
  }

  int count(
    String questionId,
  ) {
    return _likesFor(questionId)
        .length;
  }

  bool toggle(
    String questionId,
  ) {
    final likes =
        _likesFor(questionId);

    if (likes.contains(_userId)) {
      likes.remove(_userId);
      return false;
    }

    likes.add(_userId);
    return true;
  }

  List<String> userIds(
    String questionId,
  ) {
    return List.unmodifiable(
      _likesFor(questionId),
    );
  }
}
