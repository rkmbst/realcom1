import '../auth/auth_session.dart';

class FeedInteractionStore {
  FeedInteractionStore._();

  static final FeedInteractionStore instance =
      FeedInteractionStore._();

  final Map<String, Set<String>>
      _interestedByUser =
      <String, Set<String>>{};

  final Map<String, Set<String>>
      _notInterestedByUser =
      <String, Set<String>>{};

  final Map<String, Set<String>>
      _savedByUser =
      <String, Set<String>>{};

  String get _currentUserId =>
      AuthSession.instance.currentUser.id;

  Set<String> get _interested {
    return _interestedByUser[
            _currentUserId] ??=
        <String>{};
  }

  Set<String> get _notInterested {
    return _notInterestedByUser[
            _currentUserId] ??=
        <String>{};
  }

  Set<String> get _saved {
    return _savedByUser[
            _currentUserId] ??=
        <String>{};
  }

  void markInterested(
    String contentId,
  ) {
    _notInterested.remove(
      contentId,
    );

    _interested.add(
      contentId,
    );
  }

  void markNotInterested(
    String contentId,
  ) {
    _interested.remove(
      contentId,
    );

    _notInterested.add(
      contentId,
    );
  }

  bool isInterested(
    String contentId,
  ) {
    return _interested.contains(
      contentId,
    );
  }

  bool isNotInterested(
    String contentId,
  ) {
    return _notInterested.contains(
      contentId,
    );
  }

  bool isSaved(
    String contentId,
  ) {
    return _saved.contains(
      contentId,
    );
  }

  void toggleSave(
    String contentId,
  ) {
    if (_saved.contains(
      contentId,
    )) {
      _saved.remove(
        contentId,
      );
      return;
    }

    _saved.add(
      contentId,
    );
  }

  List<String> savedContentIds() {
    return List.unmodifiable(
      _saved,
    );
  }

  void clearCurrentUser() {
    _interestedByUser.remove(
      _currentUserId,
    );

    _notInterestedByUser.remove(
      _currentUserId,
    );

    _savedByUser.remove(
      _currentUserId,
    );
  }
}
