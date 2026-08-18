import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import 'auth_session.dart';

class UserDirectory {
  UserDirectory._();

  static final UserDirectory instance =
      UserDirectory._();

  final AuthSession _session =
      AuthSession.instance;

  /// Find a user from the single source of truth.
  AppUser? find(String userId) {
    return _session.findUser(userId);
  }

  /// Return all registered local users.
  List<AppUser> get users {
    return _session.users;
  }

  /// Convert a Publisher into a real AppUser.
  ///
  /// If the user already exists, return the
  /// existing instance instead of creating
  /// a duplicate record.
  AppUser fromPublisher({
    required String id,
    required String name,
    required String handle,
    Color? accentColor,
  }) {
    final existing = _session.findUser(id);

    if (existing != null) {
      return existing;
    }

    final username =
        handle.trim().replaceFirst('@', '');

    final user = AppUser(
      id: id,
      username: username,
      displayName: name.trim(),
      bio: '',
      followersCount: 0,
      followingCount: 0,
      questionCount: 0,
    );

    _session.addUser(user);

    return user;
  }
}
