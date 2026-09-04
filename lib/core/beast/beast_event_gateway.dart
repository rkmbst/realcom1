import 'beast.dart';

/// البوابة الموحدة بين التطبيق و🐺 Beast.
///
/// لا تجعل الشاشات تعرف تفاصيل BeastUltimate الداخلية.
/// كل التطبيق يرسل أحداثه من هنا.
class BeastEventGateway {
  BeastEventGateway._();

  static final BeastEventGateway instance =
      BeastEventGateway._();

  BeastUltimate get _beast =>
      BeastUltimate.instance;

  Future<void> contentImpression({
    required String itemId,
    List<String> tags = const [],
    String? category,
    String? creatorId,
    int? position,
    String? source,
  }) async {
    await _beast.impression(
      itemId: itemId,
      tags: tags,
      category: category,
      creatorId: creatorId,
      position: position,
      source: source,
    );
  }

  Future<void> contentOpen({
    required String itemId,
    List<String> tags = const [],
    String? category,
    String? creatorId,
    int? position,
    String? source,
  }) async {
    await _beast.openContent(
      itemId: itemId,
      tags: tags,
      category: category,
      creatorId: creatorId,
      position: position,
      source: source,
    );
  }

  Future<void> contentDuration({
    required String itemId,
    required int durationMs,
    List<String> tags = const [],
    String? category,
    String? creatorId,
  }) async {
    await _beast.duration(
      itemId: itemId,
      durationMs: durationMs,
      tags: tags,
      category: category,
      creatorId: creatorId,
    );
  }

  Future<void> reaction({
    required String itemId,
    required String reaction,
    List<String> tags = const [],
    String? category,
    String? creatorId,
  }) async {
    await _beast.reaction(
      itemId: itemId,
      reaction: reaction,
      tags: tags,
      category: category,
      creatorId: creatorId,
    );
  }
}
