import '../auth/auth_session.dart';

class CommentLikeStore {
  CommentLikeStore._();

  static final CommentLikeStore instance =
      CommentLikeStore._();

  // userId -> commentIds
  final Map<String, Set<String>>
      _likedCommentsByUser =
      <String, Set<String>>{};

  String get _currentUserId =>
      AuthSession
          .instance
          .currentUser
          .id;

  Set<String> get _currentUserLikes {
    return _likedCommentsByUser[
            _currentUserId] ??=
        <String>{};
  }

  bool isLiked(
    String commentId,
  ) {
    return _currentUserLikes.contains(
      commentId,
    );
  }

  bool toggleLike(
    String commentId,
  ) {
    final likes =
        _currentUserLikes;

    if (likes.contains(commentId)) {
      likes.remove(commentId);
      return false;
    }

    likes.add(commentId);
    return true;
  }

  int likeCount(
    String commentId,
  ) {
    var count = 0;

    for (final likedIds
        in _likedCommentsByUser.values) {
      if (likedIds.contains(commentId)) {
        count++;
      }
    }

    return count;
  }

  List<String> likedCommentIds() {
    return List.unmodifiable(
      _currentUserLikes,
    );
  }

  bool hasLikedAnyComment() {
    return _currentUserLikes.isNotEmpty;
  }

  void clearCurrentUser() {
    _likedCommentsByUser.remove(
      _currentUserId,
    );
  }

  void clearAll() {
    _likedCommentsByUser.clear();
  }
}
