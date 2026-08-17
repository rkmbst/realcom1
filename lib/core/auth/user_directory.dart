import 'package:flutter/material.dart';

import '../../models/app_user.dart';

class UserDirectory {
  UserDirectory._();

  static final UserDirectory instance =
      UserDirectory._();

  final Map<String, AppUser> _users = {
    'publisher_1': AppUser(
      id: 'publisher_1',
      username: 'mindspace',
      displayName: 'Mind Space',
      bio: 'أسئلة وأفكار تستحق التفكير.',
      followersCount: 128,
      followingCount: 42,
      questionCount: 18,
    ),
    'publisher_2': AppUser(
      id: 'publisher_2',
      username: 'dailyfacts',
      displayName: 'Daily Facts',
      bio: 'معلومات وأسئلة عامة كل يوم.',
      followersCount: 286,
      followingCount: 31,
      questionCount: 27,
    ),
  };

  AppUser? find(String userId) {
    return _users[userId];
  }

  AppUser fromPublisher({
    required String id,
    required String name,
    required String handle,
    Color? accentColor,
  }) {
    final existing = _users[id];

    if (existing != null) {
      return existing;
    }

    final user = AppUser(
      id: id,
      username: handle.replaceFirst('@', ''),
      displayName: name,
      bio: '',
      followersCount: 0,
      followingCount: 0,
      questionCount: 0,
    );

    _users[id] = user;

    return user;
  }
}
