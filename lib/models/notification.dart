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
    required this.recipientUserId,
    required this.actorUserId,
    required this.actorName,
    required this.message,
    required this.createdAt,
    this.targetId,
    this.isRead = false,
  });

  final String id;

  final NotificationType type;

  /// The user who receives this notification.
  final String recipientUserId;

  /// The user who caused this notification.
  final String actorUserId;

  final String actorName;

  final String message;

  /// Question/profile/other target.
  final String? targetId;

  final DateTime createdAt;

  final bool isRead;

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      type: type,
      recipientUserId:
          recipientUserId,
      actorUserId:
          actorUserId,
      actorName:
          actorName,
      message:
          message,
      targetId:
          targetId,
      createdAt:
          createdAt,
      isRead:
          isRead ?? this.isRead,
    );
  }
}
