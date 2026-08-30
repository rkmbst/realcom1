import '../../models/notification.dart';
import 'notification_store.dart';

abstract interface class NotificationRepository {
  void add(AppNotification notification);

  void markAsRead(String notificationId);

  void markAllAsReadForUser(String userId);

  void remove(String notificationId);

  void clearForUser(String userId);

  List<AppNotification> notificationsForUser(
    String userId,
  );

  int unreadCountForUser(String userId);
}

/// Local implementation for the current prototype.
///
/// The contract is intentionally separated so it can later
/// be replaced by a realtime/backend implementation.
class LocalNotificationRepository
    implements NotificationRepository {
  LocalNotificationRepository({
    NotificationStore? store,
  }) : _store = store ?? NotificationStore.instance;

  final NotificationStore _store;

  @override
  void add(AppNotification notification) {
    _store.add(notification);
  }

  @override
  void markAsRead(String notificationId) {
    _store.markAsRead(notificationId);
  }

  @override
  void markAllAsReadForUser(String userId) {
    _store.markAllAsReadForUser(userId);
  }

  @override
  void remove(String notificationId) {
    _store.remove(notificationId);
  }

  @override
  void clearForUser(String userId) {
    _store.clearForUser(userId);
  }

  @override
  List<AppNotification> notificationsForUser(
    String userId,
  ) {
    return _store.notificationsForUser(userId);
  }

  @override
  int unreadCountForUser(String userId) {
    return _store.unreadCountForUser(userId);
  }
}
