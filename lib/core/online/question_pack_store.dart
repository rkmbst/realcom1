import '../../core/notifications/notification_store.dart';
import '../../core/social/follow_store.dart';
import '../../models/notification.dart';
import '../../models/question_pack.dart';

class QuestionPackStore {
  QuestionPackStore._();

  static final QuestionPackStore instance =
      QuestionPackStore._();

  final List<QuestionPack> _packs =
      <QuestionPack>[];

  List<QuestionPack> get publishedPacks =>
      List.unmodifiable(_packs);

  void add(QuestionPack pack) {
    _packs.add(pack);
  }

  List<QuestionPack> byPublisher(
    String publisherId,
  ) {
    return _packs
        .where(
          (pack) =>
              pack.publisherId ==
              publisherId,
        )
        .toList(
          growable: false,
        );
  }

  QuestionPack? find(String packId) {
    for (final pack in _packs) {
      if (pack.id == packId) {
        return pack;
      }
    }

    return null;
  }

  void publish({
    required QuestionPack pack,
    required String authorName,
  }) {
    _packs.add(pack);

    final followerIds =
        FollowStore.instance.followerIds(
      pack.publisherId,
    );

    for (final followerId
        in followerIds) {
      NotificationStore.instance.add(
        AppNotification(
          id:
              'pack-${pack.id}-$followerId',
          type:
              NotificationType.newQuestion,
          recipientUserId:
              followerId,
          actorUserId:
              pack.publisherId,
          actorName:
              authorName,
          message:
              '$authorName نشر مجموعة جديدة: ${pack.title}',
          targetId:
              pack.id,
          createdAt:
              DateTime.now(),
        ),
      );
    }
  }
}
