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
              pack.publisherId == publisherId,
        )
        .toList(growable: false);
  }

  QuestionPack? find(String packId) {
    for (final pack in _packs) {
      if (pack.id == packId) {
        return pack;
      }
    }

    return null;
  }
}
