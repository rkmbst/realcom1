import '../../core/auth/auth_session.dart';
import '../../models/follow.dart';

class FollowStore {
  FollowStore._();

  static final FollowStore instance =
      FollowStore._();

  final Set<String> _followingIds = <String>{};
  final List<Follow> _follows = <Follow>[];

  bool isFollowing(String userId) {
    return _followingIds.contains(userId);
  }

  int followerCount(String userId) {
    return _follows
        .where((follow) =>
            follow.followingId == userId)
        .length;
  }

  int followingCount(String userId) {
    return _follows
        .where((follow) =>
            follow.followerId == userId)
        .length;
  }

  bool toggleFollow(String userId) {
    final currentUserId =
        AuthSession.instance.currentUser.id;

    if (currentUserId == userId) {
      return false;
    }

    if (_followingIds.contains(userId)) {
      _followingIds.remove(userId);

      _follows.removeWhere(
        (follow) =>
            follow.followerId ==
                currentUserId &&
            follow.followingId ==
                userId,
      );

      return false;
    }

    _followingIds.add(userId);

    _follows.add(
      Follow(
        followerId: currentUserId,
        followingId: userId,
        createdAt: DateTime.now(),
      ),
    );

    return true;
  }

  List<String> followingIds() {
    return List.unmodifiable(
      _followingIds,
    );
  }
}
