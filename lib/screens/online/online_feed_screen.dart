import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/online/feed_interaction_store.dart';
import '../../core/online/question_pack_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../data/mock_online_data.dart';
import '../../models/feed_card.dart';
import '../../models/publisher.dart';
import '../../models/question.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import '../../widgets/swipeable_card.dart';
import '../profile/profile_screen.dart';
import 'pack_question_flow_screen.dart';
import 'publisher_wheel_screen.dart';

class OnlineFeedScreen extends StatefulWidget {
  const OnlineFeedScreen({
    super.key,
  });

  @override
  State<OnlineFeedScreen> createState() =>
      _OnlineFeedScreenState();
}

class _OnlineFeedScreenState
    extends State<OnlineFeedScreen> {
  final _packStore =
      QuestionPackStore.instance;

  final _session =
      AuthSession.instance;

  final _interactions =
      FeedInteractionStore.instance;

  late List<FeedCard> _cards;

  int _currentIndex = 0;

  bool _isTransitioning = false;

  double _dragProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _rebuildFeed();
  }

  // ─────────────────────────────────────
  // Feed data
  // ─────────────────────────────────────

  void _rebuildFeed() {
    final cards = <FeedCard>[];

    // Built-in packs.
    for (final pack
        in MockOnlineData.packs) {
      if (pack.questions.isEmpty) {
        continue;
      }

      if (_interactions.isNotInterested(
        'pack_card_${pack.id}',
      )) {
        continue;
      }

      Publisher? publisher;

      for (final item
          in MockOnlineData.publishers) {
        if (item.id ==
            pack.publisherId) {
          publisher = item;
          break;
        }
      }

      if (publisher == null) {
        continue;
      }

      cards.add(
        FeedCard(
          id:
              'pack_card_${pack.id}',
          publisher:
              publisher,
          pack:
              pack,
          question:
              pack.questions.first,
        ),
      );
    }

    // User-created packs.
    for (final pack
        in _packStore.publishedPacks) {
      if (pack.questions.isEmpty) {
        continue;
      }

      if (_interactions.isNotInterested(
        'pack_card_${pack.id}',
      )) {
        continue;
      }

      final author =
          _session.findUser(
        pack.publisherId,
      );

      if (author == null) {
        continue;
      }

      final category =
          AppCategories.byId(
        pack.questions
            .first
            .categoryId,
      );

      final publisher =
          Publisher(
        id: author.id,
        name:
            author.displayName,
        handle:
            '@${author.username}',
        accentColor:
            category.color,
      );

      cards.add(
        FeedCard(
          id:
              'pack_card_${pack.id}',
          publisher:
              publisher,
          pack:
              pack,
          question:
              pack.questions.first,
        ),
      );
    }

    _cards = cards;

    if (_cards.isEmpty) {
      _currentIndex = 0;
      return;
    }

    if (_currentIndex >=
        _cards.length) {
      _currentIndex =
          _cards.length - 1;
    }
  }

  // ─────────────────────────────────────
  // Swipe
  // ─────────────────────────────────────

  void _markInterested(
    FeedCard card,
  ) {
    if (_isTransitioning) {
      return;
    }

    _interactions.markInterested(
      card.id,
    );

    Haptics.light();

    _showNextPack();
  }

  void _markNotInterested(
    FeedCard card,
  ) {
    if (_isTransitioning) {
      return;
    }

    _interactions.markNotInterested(
      card.id,
    );

    Haptics.light();

    _showNextPack();
  }

  void _showNextPack() {
    if (_isTransitioning) {
      return;
    }

    setState(() {
      _isTransitioning = true;
    });

    if (_currentIndex <
        _cards.length) {
      setState(() {
        _currentIndex++;
        _dragProgress = 0.0;
        _isTransitioning = false;
      });
    }
  }

  // ─────────────────────────────────────
  // Save
  // ─────────────────────────────────────

  void _toggleSave(
    FeedCard card,
  ) {
    final wasSaved =
        _interactions.isSaved(
      card.id,
    );

    setState(() {
      _interactions.toggleSave(
        card.id,
      );
    });

    Haptics.medium();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration:
              const Duration(
            milliseconds: 1200,
          ),
          backgroundColor:
              AppColors.surface,
          content: Text(
            wasSaved
                ? 'تم الحذف من المحفوظات'
                : 'تم الحفظ للإجابة لاحقًا',
            style:
                AppTextStyles
                    .bodyMedium,
          ),
          behavior:
              SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
        ),
      );
  }

  // ─────────────────────────────────────
  // Open Pack
  // ─────────────────────────────────────

  Future<void> _openQuestion(
    FeedCard card,
  ) async {
    _interactions.markOpened(
      card.id,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PackQuestionFlowScreen(
          publisher:
              card.publisher,
          pack:
              card.pack,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _rebuildFeed();
    });
  }

  // ─────────────────────────────────────
  // Wheel
  // ─────────────────────────────────────

  Future<void> _openPublisherWheel(
    FeedCard card,
  ) async {
    final questions =
        List<Question>.from(
      card.pack.questions,
    )..shuffle();

    final selected =
        questions
            .take(7)
            .toList();

    if (selected.isEmpty) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PublisherWheelScreen(
          publisher:
              card.publisher,
          pack:
              card.pack,
          questions:
              selected,
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // Profile
  // ─────────────────────────────────────

  void _openPublisherProfile(
    FeedCard card,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProfileScreen(
          userId:
              card.publisher.id,
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // Hashtags
  // ─────────────────────────────────────

  Widget _hashtags(
    Question question,
  ) {
    if (question.hashtags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding:
          const EdgeInsets.only(
        top: 14,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment:
            WrapAlignment.center,
        children:
            question.hashtags
                .map(
          (tag) {
            return Text(
              '#$tag',
              style:
                  AppTextStyles
                      .caption
                      .copyWith(
                color:
                    AppColors
                        .textSecondary,
              ),
            );
          },
        )
                .toList(),
      ),
    );
  }

  // ─────────────────────────────────────
  // Pack Card
  // ─────────────────────────────────────

  Widget _buildPackCard(
    FeedCard card,
  ) {
    final category =
        AppCategories.byId(
      card.question.categoryId,
    );

    return LiquidGlassContainer(
      padding:
          const EdgeInsets.all(
        24,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment
                .center,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration:
                BoxDecoration(
              color:
                  category.color
                      .withOpacity(
                0.12,
              ),
              borderRadius:
                  BorderRadius.circular(
                999,
              ),
              border:
                  Border.all(
                color:
                    category.color
                        .withOpacity(
                  0.65,
                ),
              ),
            ),
            child: Text(
              category.name,
              style:
                  AppTextStyles
                      .caption
                      .copyWith(
                color:
                    category.color,
              ),
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          Text(
            card.pack.title,
            textAlign:
                TextAlign.center,
            style:
                AppTextStyles
                    .titleMedium,
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            card.question.text,
            textAlign:
                TextAlign.center,
            style:
                AppTextStyles
                    .displayLarge,
          ),

          _hashtags(
            card.question,
          ),

          const SizedBox(
            height: 26,
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration:
                BoxDecoration(
              color: AppColors
                  .surface
                  .withOpacity(
                0.58,
              ),
              borderRadius:
                  BorderRadius.circular(
                999,
              ),
              border:
                  Border.all(
                color:
                    AppColors
                        .divider,
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons
                      .layers_outlined,
                  size: 18,
                  color:
                      AppColors
                          .textSecondary,
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  '${card.pack.questions.length} أسئلة',
                  style:
                      AppTextStyles
                          .caption,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Text(
            'اضغط لفتح المجموعة',
            style:
                AppTextStyles
                    .caption,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // Card stack
  // ─────────────────────────────────────

  Widget _buildStack() {
    final visibleCards =
        <Widget>[];

    final end =
        (_currentIndex + 3)
            .clamp(
      0,
      _cards.length,
    );

    for (
      var index = end - 1;
      index >= _currentIndex;
      index--
    ) {
      final card =
          _cards[index];

      final depth =
          index - _currentIndex;

      final baseScale =
          1.0 -
              (depth * 0.035);

      final baseOffset =
          depth * 12.0;

      final baseInset =
          depth * 10.0;

      final reveal =
          depth == 1
              ? _dragProgress
              : _dragProgress * 0.65;

      final scale =
          baseScale +
              (reveal * 0.035);

      final verticalOffset =
          baseOffset -
              (reveal * 10.0);

      final horizontalInset =
          baseInset -
              (reveal * 8.0);

      final isCurrent =
          depth == 0;

      Widget content =
          Padding(
        padding:
            EdgeInsets.fromLTRB(
          16 + horizontalInset,
          12 + verticalOffset,
          16 + horizontalInset,
          16,
        ),
        child: _buildPackCard(
          card,
        ),
      );

      if (isCurrent) {
        content =
            SwipeableCard(
          key: ValueKey(
            card.id,
          ),
          onDragProgress: (progress) {
            if (!mounted) {
              return;
            }

            setState(() {
              _dragProgress = progress;
            });
          },
          onSwipeLeft:
              () =>
                  _markNotInterested(
            card,
          ),
          onSwipeRight:
              () =>
                  _markInterested(
            card,
          ),
          child:
              GestureDetector(
            behavior:
                HitTestBehavior.opaque,
            onTap: () =>
                _openQuestion(
              card,
            ),
            child: content,
          ),
        );
      } else {
        content =
            IgnorePointer(
          child:
              Transform.scale(
            scale: scale,
            alignment:
                Alignment.topCenter,
            child: content,
          ),
        );
      }

      visibleCards.add(
        content,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children:
          visibleCards,
    );
  }

  // ─────────────────────────────────────
  // Empty / Finished state
  // ─────────────────────────────────────

  Widget _buildFinishedState(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          32,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .done_all_rounded,
              size: 58,
              color:
                  AppColors.primary,
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              'انتهى الاستكشاف',
              style:
                  AppTextStyles
                      .titleLarge,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'مررت على جميع المجموعات المتاحة حاليًا.',
              style:
                  AppTextStyles
                      .bodyMedium,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 22,
            ),

            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                  _dragProgress = 0.0;
                  _rebuildFeed();
                });
              },
              icon:
                  const Icon(
                Icons.refresh_rounded,
              ),
              label:
                  const Text(
                'ابدأ من جديد',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // Build
  // ─────────────────────────────────────

  @override
  Widget build(
    BuildContext context,
  ) {
    final hasCards =
        _cards.isNotEmpty;

    final finished =
        hasCards &&
            _currentIndex >=
                _cards.length;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title:
            const Text('الرئيسية'),
        centerTitle: true,
        actions: [
          if (hasCards &&
              !finished)
            IconButton(
              tooltip: 'العجلة',
              onPressed: () =>
                  _openPublisherWheel(
                _cards[
                    _currentIndex],
              ),
              icon:
                  const Icon(
                Icons.casino_outlined,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          const LiquidBackground(),

          SafeArea(
            child: !hasCards
                ? Center(
                    child:
                        Padding(
                      padding:
                          const EdgeInsets
                              .all(
                        32,
                      ),
                      child:
                          Column(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          const Icon(
                            Icons
                                .inbox_outlined,
                            size: 56,
                            color:
                                AppColors
                                    .textSecondary,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            'لا توجد مجموعات حاليًا',
                            style:
                                AppTextStyles
                                    .titleLarge,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'أنشئ أول مجموعة لتظهر هنا.',
                            textAlign:
                                TextAlign
                                    .center,
                            style:
                                AppTextStyles
                                    .bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                : finished
                    ? _buildFinishedState(
                        context,
                      )
                    : Column(
                        children: [
                          Expanded(
                            child:
                                _buildStack(),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            '${_currentIndex + 1} / ${_cards.length}',
                            style:
                                AppTextStyles
                                    .caption,
                          ),

                          const SizedBox(
                            height: 12,
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
