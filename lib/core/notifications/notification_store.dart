import '../../models/notification.dart';

class NotificationStore {
  NotificationStore._();

  static final NotificationStore instance =
      NotificationStore._();

  final List<AppNotification> _notifications =
      <AppNotification>[];

  List<AppNotification> get notifications =>
      List.unmodifiable(
        _notifications,
      );

  int get unreadCount {
    return _notifications
        .where(
          (notification) =>
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

  void markAllAsRead() {
    for (var i = 0;
        i < _notifications.length;
        i++) {
      _notifications[i] =
          _notifications[i].copyWith(
        isRead: true,
      );
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

  void clear() {
    _notifications.clear();
  }

  List<AppNotification>
      notificationsForUser(
    String userId,
  ) {
    // This is the local-session version.
    // Later the backend will filter server-side.
    return List.unmodifiable(
      _notifications,
    );
  }
}
