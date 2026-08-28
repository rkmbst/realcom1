import 'package:flutter/foundation.dart';

import '../../models/notification.dart';

class NotificationStore extends ChangeNotifier {
  NotificationStore._();

  static final NotificationStore instance =
      NotificationStore._();

  final List<AppNotification> _notifications =
      <AppNotification>[];

  List<AppNotification> notificationsForUser(
    String userId,
  ) {
    return List.unmodifiable(
      _notifications
          .where(
            (notification) =>
                notification.recipientUserId ==
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
              notification.recipientUserId ==
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

    notifyListeners();
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

    if (_notifications[index].isRead) {
      return;
    }

    _notifications[index] =
        _notifications[index].copyWith(
      isRead: true,
    );

    notifyListeners();
  }

  void markAllAsReadForUser(
    String userId,
  ) {
    var changed = false;

    for (var i = 0;
        i < _notifications.length;
        i++) {
      final notification =
          _notifications[i];

      if (notification.recipientUserId ==
              userId &&
          !notification.isRead) {
        _notifications[i] =
            notification.copyWith(
          isRead: true,
        );

        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  void remove(
    String notificationId,
  ) {
    final before =
        _notifications.length;

    _notifications.removeWhere(
      (notification) =>
          notification.id ==
          notificationId,
    );

    if (_notifications.length != before) {
      notifyListeners();
    }
  }

  void clearForUser(
    String userId,
  ) {
    final before =
        _notifications.length;

    _notifications.removeWhere(
      (notification) =>
          notification.recipientUserId ==
          userId,
    );

    if (_notifications.length != before) {
      notifyListeners();
    }
  }

  void clearAll() {
    if (_notifications.isEmpty) {
      return;
    }

    _notifications.clear();

    notifyListeners();
  }
}
