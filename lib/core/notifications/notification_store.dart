import '../../models/notification.dart';

class NotificationStore {
  NotificationStore._();

  static final NotificationStore instance =
      NotificationStore._();

  final List<AppNotification>
      _notifications = <AppNotification>[];

  List<AppNotification>
      notificationsForUser(
    String userId,
  ) {
    return List.unmodifiable(
      _notifications
          .where(
            (notification) =>
                notification
                    .recipientUserId ==
                userId,
          )
          .toList(),
    );
  }

  int unreadCountForUser(
    String userId,
  ) {
    return _notifications
        .where(
          (notification) =>
              notification
                      .recipientUserId ==
                  userId &&
              !notification.isRead,
        )
        .length;
  }

  void add(
    AppNotification notification,
  ) {
    _notifications.insert(
      0,
      notification,
    );
  }

  void markAsRead(
    String notificationId,
  ) {
    final index =
        _notifications.indexWhere(
      (notification) =>
          notification.id ==
          notificationId,
    );

    if (index == -1) {
      return;
    }

    _notifications[index] =
        _notifications[index].copyWith(
      isRead: true,
    );
  }

  void markAllAsReadForUser(
    String userId,
  ) {
    for (var i = 0;
        i < _notifications.length;
        i++) {
      final notification =
          _notifications[i];

      if (notification
              .recipientUserId ==
          userId) {
        _notifications[i] =
            notification.copyWith(
          isRead: true,
        );
      }
    }
  }

  void remove(
    String notificationId,
  ) {
    _notifications.removeWhere(
      (notification) =>
          notification.id ==
          notificationId,
    );
  }

  void clearForUser(
    String userId,
  ) {
    _notifications.removeWhere(
      (notification) =>
          notification.recipientUserId ==
          userId,
    );
  }
}
