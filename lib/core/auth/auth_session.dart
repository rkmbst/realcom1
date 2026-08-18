import '../../models/app_user.dart';

class AuthSession {
  AuthSession._();

  static final AuthSession instance =
      AuthSession._();

  late final Map<String, AppUser>
      _users = <String, AppUser>{
    'user_1': const AppUser(
      id: 'user_1',
      username: 'welibre_user',
      displayName: 'WeLibre User',
      bio: 'أحب الأسئلة والأفكار الجميلة.',
      followersCount: 0,
      followingCount: 0,
      questionCount: 0,
    ),

    'user_2': const AppUser(
      id: 'user_2',
      username: 'mindspace',
      displayName: 'Mind Space',
      bio: 'أسئلة وأفكار تستحق التفكير.',
      followersCount: 128,
      followingCount: 42,
      questionCount: 18,
    ),

    'user_3': const AppUser(
      id: 'user_3',
      username: 'dailyfacts',
      displayName: 'Daily Facts',
      bio: 'معلومات وأسئلة عامة كل يوم.',
      followersCount: 286,
      followingCount: 31,
      questionCount: 27,
    ),
  };

  String? _currentUserId = 'user_1';

  bool get isAuthenticated =>
      _currentUserId != null;

  AppUser get currentUser {
    final id = _currentUserId;

    if (id == null) {
      throw StateError(
        'No authenticated user.',
      );
    }

    final user = _users[id];

    if (user == null) {
      throw StateError(
        'Authenticated user was not found.',
      );
    }

    return user;
  }

  AppUser? findUser(
    String userId,
  ) {
    return _users[userId];
  }

  List<AppUser> get users =>
      List.unmodifiable(
        _users.values,
      );

  void addUser(
    AppUser user,
  ) {
    _users[user.id] = user;
  }

  bool login(
    String userId,
  ) {
    if (!_users.containsKey(userId)) {
      return false;
    }

    _currentUserId = userId;
    return true;
  }

  void logout() {
    _currentUserId = null;
  }

  void updateProfile({
    required String username,
    required String displayName,
    required String bio,
    String? avatarUrl,
  }) {
    final current =
        currentUser;

    _users[current.id] =
        current.copyWith(
      username: username.trim(),
      displayName:
          displayName.trim(),
      bio: bio.trim(),
      avatarUrl: avatarUrl,
    );
  }

  void setFollowingCount(
    int value,
  ) {
    final current =
        currentUser;

    _users[current.id] =
        current.copyWith(
      followingCount:
          value < 0 ? 0 : value,
    );
  }

  void setFollowersCount(
    int value,
  ) {
    final current =
        currentUser;

    _users[current.id] =
        current.copyWith(
      followersCount:
          value < 0 ? 0 : value,
    );
  }

  void setQuestionCount(
    int value,
  ) {
    final current =
        currentUser;

    _users[current.id] =
        current.copyWith(
      questionCount:
          value < 0 ? 0 : value,
    );
  }
}
