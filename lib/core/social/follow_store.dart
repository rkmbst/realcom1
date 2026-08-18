import '../../core/auth/auth_session.dart';
import '../../core/notifications/notification_store.dart';
import '../../models/follow.dart';
import '../../models/notification.dart';

class FollowStore {
  FollowStore._();

  static final FollowStore instance =
      FollowStore._();

  final Set<String> _followingIds =
      <String>{};

  final List<Follow> _follows =
      <Follow>[];

  bool isFollowing(
    String userId,
  ) {
    return _followingIds.contains(
      '${AuthSession.instance.currentUser.id}:$userId',
    );
  }

  int followerCount(
    String userId,
  ) {
    return _follows
        .where(
          (follow) =>
              follow.followingId ==
              userId,
        )
        .length;
  }

  int followingCount(
    String userId,
  ) {
    final currentUserId =
        AuthSession.instance.currentUser.id;

    return _follows
        .where(
          (follow) =>
              follow.followerId ==
              currentUserId,
        )
        .length;
  }

  List<String> followerIds(
    String userId,
  ) {
    return _follows
        .where(
          (follow) =>
              follow.followingId ==
              userId,
        )
        .map(
          (follow) =>
              follow.followerId,
        )
        .toList(
          growable: false,
        );
  }

  List<String> followingIds() {
    final currentUserId =
        AuthSession.instance.currentUser.id;

    return _follows
        .where(
          (follow) =>
              follow.followerId ==
              currentUserId,
        )
        .map(
          (follow) =>
              follow.followingId,
        )
        .toList(
          growable: false,
        );
  }

  bool toggleFollow(
    String userId,
  ) {
    final currentUser =
        AuthSession.instance.currentUser;

    if (currentUser.id == userId) {
      return false;
    }

    final key =
        '${currentUser.id}:$userId';

    final alreadyFollowing =
        _followingIds.contains(key);

    if (alreadyFollowing) {
      _followingIds.remove(key);

      _follows.removeWhere(
        (follow) =>
            follow.followerId ==
                currentUser.id &&
            follow.followingId ==
                userId,
      );

      return false;
    }

    _followingIds.add(key);

    _follows.add(
      Follow(
        followerId:
            currentUser.id,
        followingId:
            userId,
        createdAt:
            DateTime.now(),
      ),
    );

    NotificationStore.instance.add(
      AppNotification(
        id:
            'follow-${currentUser.id}-$userId-${DateTime.now().microsecondsSinceEpoch}',
        type:
            NotificationType.follow,
        recipientUserId:
            userId,
        actorUserId:
            currentUser.id,
        actorName:
            currentUser.displayName,
        message:
            '${currentUser.displayName} بدأ بمتابعتك',
        targetId:
            userId,
        createdAt:
            DateTime.now(),
      ),
    );

    return true;
  }
}
