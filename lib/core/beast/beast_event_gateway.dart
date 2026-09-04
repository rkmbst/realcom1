// lib/core/beast/beast_event_gateway.dart

import 'beast.dart';

/// البوابة الموحدة بين تطبيق SetRize و🐺 Beast.
///
/// الهدف:
/// - عزل بقية التطبيق عن تفاصيل BeastUltimate.
/// - توحيد أسماء وإرسال أحداث السلوك.
/// - منع كل شاشة من اختراع طريقة مختلفة للتواصل مع الوحش.
/// - إبقاء الترقية المستقبلية ممكنة بدون تعديل عشرات الشاشات.
class BeastEventGateway {
  BeastEventGateway._();

  static final BeastEventGateway instance =
      BeastEventGateway._();

  BeastUltimate get _beast => BeastUltimate();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  Future<void> appForeground() {
    return _beast.onForeground();
  }

  Future<void> appBackground() {
    return _beast.onBackground();
  }

  Future<void> appInactive() {
    return _beast.onInactive();
  }

  Future<void> appHidden() {
    return _beast.onHidden();
  }

  // ---------------------------------------------------------------------------
  // Navigation / screens
  // ---------------------------------------------------------------------------

  Future<void> screenViewed(
    String screenName,
  ) {
    return _beast.screen(screenName);
  }

  // ---------------------------------------------------------------------------
  // Content
  // ---------------------------------------------------------------------------

  Future<void> contentImpression({
    required String itemId,
    List<String> tags = const <String>[],
    String? category,
    String? creatorId,
    int position = 0,
    String source = 'unknown',
  }) {
    return _beast.impression(
      itemId: itemId,
      tags: tags,
      category: category,
      creatorId: creatorId,
      position: position,
      source: source,
    );
  }

  Future<void> contentOpened({
    required String itemId,
    List<String> tags = const <String>[],
    String? category,
    String? creatorId,
    int position = 0,
    String source = 'unknown',
  }) {
    return _beast.openContent(
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
    List<String> tags = const <String>[],
    String? category,
    String? creatorId,
  }) {
    return _beast.duration(
      itemId: itemId,
      durationMs: durationMs,
      tags: tags,
      category: category,
      creatorId: creatorId,
    );
  }

  Future<void> contentReaction({
    required String itemId,
    required String reaction,
    List<String> tags = const <String>[],
    String? category,
    String? creatorId,
  }) {
    return _beast.reaction(
      itemId: itemId,
      reaction: reaction,
      tags: tags,
      category: category,
      creatorId: creatorId,
    );
  }

  Future<void> contentSkipped({
    required String itemId,
    List<String> tags = const <String>[],
  }) {
    return _beast.skip(
      itemId,
      tags: tags,
    );
  }

  Future<void> contentHidden({
    required String itemId,
    String? reason,
  }) {
    return _beast.hide(
      itemId,
      reason: reason,
    );
  }

  // ---------------------------------------------------------------------------
  // Semantic reactions
  // ---------------------------------------------------------------------------

  Future<void> liked({
    required String itemId,
    List<String> tags = const <String>[],
    String? category,
    String? creatorId,
  }) {
    return contentReaction(
      itemId: itemId,
      reaction: 'like',
      tags: tags,
      category: category,
      creatorId: creatorId,
    );
  }

  Future<void> loved({
    required String itemId,
    List<String> tags = const <String>[],
    String? category,
    String? creatorId,
  }) {
    return contentReaction(
      itemId: itemId,
      reaction: 'love',
      tags: tags,
      category: category,
      creatorId: creatorId,
    );
  }

  Future<void> saved({
    required String itemId,
    List<String> tags = const <String>[],
    String? category,
    String? creatorId,
  }) {
    return contentReaction(
      itemId: itemId,
      reaction: 'save',
      tags: tags,
      category: category,
      creatorId: creatorId,
    );
  }

  Future<void> shared({
    required String itemId,
    List<String> tags = const <String>[],
    String? category,
    String? creatorId,
  }) {
    return contentReaction(
      itemId: itemId,
      reaction: 'share',
      tags: tags,
      category: category,
      creatorId: creatorId,
    );
  }

  Future<void> notInterested({
    required String itemId,
    List<String> tags = const <String>[],
    String? category,
    String? creatorId,
  }) {
    return contentReaction(
      itemId: itemId,
      reaction: 'not_interested',
      tags: tags,
      category: category,
      creatorId: creatorId,
    );
  }

  // ---------------------------------------------------------------------------
  // User actions
  // ---------------------------------------------------------------------------

  Future<void> followed({
    required String userId,
    String? category,
  }) {
    return _beast.follow(
      userId,
      category: category,
    );
  }

  Future<void> voted({
    required String itemId,
    String? option,
    String? category,
    String? creatorId,
  }) {
    return _beast.vote(
      itemId,
      option: option,
      category: category,
      creatorId: creatorId,
    );
  }

  Future<void> commented({
    required String itemId,
    String? category,
    String? creatorId,
  }) {
    return _beast.comment(
      itemId,
      category: category,
      creatorId: creatorId,
    );
  }

  Future<void> replied({
    required String itemId,
    String? category,
    String? creatorId,
    String? parentCommentId,
  }) {
    return _beast.reply(
      itemId,
      category: category,
      creatorId: creatorId,
      parentCommentId: parentCommentId,
    );
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  Future<void> searched({
    required String query,
    int resultCount = 0,
  }) {
    return _beast.search(
      query,
      resultCount: resultCount,
    );
  }

  // ---------------------------------------------------------------------------
  // Recommendation feedback
  // ---------------------------------------------------------------------------

  Future<void> recommendationFeedback({
    required String itemId,
    required String feedback,
  }) {
    return _beast.recommendationFeedback(
      itemId,
      feedback: feedback,
    );
  }
}
