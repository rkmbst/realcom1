import '../../models/app_user.dart';

class AuthSession {
  AuthSession._();

  static final AuthSession instance =
      AuthSession._();

  AppUser _currentUser = const AppUser(
    id: 'local_current_user',
    username: 'welibre_user',
    displayName: 'WeLibre User',
    bio: 'أحب الأسئلة والأفكار الجميلة.',
    followersCount: 0,
    followingCount: 0,
    questionCount: 0,
  );

  bool _authenticated = true;

  AppUser get currentUser => _currentUser;

  bool get isAuthenticated => _authenticated;

  void updateProfile({
    required String username,
    required String displayName,
    required String bio,
    String? avatarUrl,
  }) {
    _currentUser = _currentUser.copyWith(
      username: username.trim(),
      displayName: displayName.trim(),
      bio: bio.trim(),
      avatarUrl: avatarUrl,
    );
  }

  void setFollowingCount(int value) {
    _currentUser =
        _currentUser.copyWith(
      followingCount: value < 0 ? 0 : value,
    );
  }

  void setFollowersCount(int value) {
    _currentUser =
        _currentUser.copyWith(
      followersCount: value < 0 ? 0 : value,
    );
  }

  void logOut() {
    _authenticated = false;
  }

  void logIn() {
    _authenticated = true;
  }
}
