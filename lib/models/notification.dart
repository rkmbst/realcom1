enum NotificationType {
  follow,
  like,
  comment,
  newQuestion,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.actorUserId,
    required this.actorName,
    required this.message,
    required this.createdAt,
    this.targetId,
    this.isRead = false,
  });

  final String id;

  final NotificationType type;

  /// The user who caused the notification.
  final String actorUserId;

  /// Display name of the actor.
  final String actorName;

  /// Short human-readable notification text.
  final String message;

  /// Optional target:
  /// question id, profile id, etc.
  final String? targetId;

  final DateTime createdAt;

  final bool isRead;

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      type: type,
      actorUserId: actorUserId,
      actorName: actorName,
      message: message,
      targetId: targetId,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
