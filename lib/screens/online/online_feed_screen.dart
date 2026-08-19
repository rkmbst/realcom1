import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/online/feed_interaction_store.dart';
import '../../core/online/question_pack_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_physics.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../data/mock_online_data.dart';
import '../../models/feed_card.dart';
import '../../models/publisher.dart';
import '../../models/question.dart';
import '../../models/question_pack.dart';
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

  late final PageController
      _pageController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController =
        PageController();

    _rebuildFeed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _rebuildFeed() {
    final cards = <FeedCard>[];

    // Mock packs.
    for (final pack
        in MockOnlineData.packs) {
      if (pack.questions.isEmpty) {
        continue;
      }

      final publisher =
          MockOnlineData.publishers
              .firstWhere(
        (item) =>
            item.id ==
            pack.publisherId,
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

    // User-created packs.
    for (final pack
        in _packStore.publishedPacks) {
      if (pack.questions.isEmpty) {
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
        pack.questions.first.categoryId,
      );

      final publisher = Publisher(
        id: author.id,
        name: author.displayName,
        handle: '@${author.username}',
        accentColor: category.color,
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

  void _nextPage() {
    if (_cards.isEmpty) {
      return;
    }

    if (_currentIndex >=
        _cards.length - 1) {
      return;
    }

    _pageController.nextPage(
      duration:
          const Duration(
        milliseconds: 220,
      ),
      curve:
          Curves.easeOutCubic,
    );
  }

  void _markInterested(
    FeedCard card,
  ) {
    _interactions.markInterested(
      card.id,
    );

    Haptics.light();

    _nextPage();
  }

  void _markNotInterested(
    FeedCard card,
  ) {
    _interactions.markNotInterested(
      card.id,
    );

    Haptics.light();

    _nextPage();
  }

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
          duration: const Duration(
            milliseconds: 1200,
          ),
          backgroundColor:
              AppColors.surface,
          content: Text(
            wasSaved
                ? 'تم الحذف من المحفوظات'
                : 'تم الحفظ للإجابة لاحقًا',
            style:
                AppTextStyles.bodyMedium,
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

    if (mounted) {
      setState(() {
        _rebuildFeed();
      });
    }
  }

  Future<void>
      _openPublisherWheel(
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
            question.hashtags.map(
          (tag) {
            return Text(
              '#$tag',
              style:
                  AppTextStyles.caption
                      .copyWith(
                color:
                    AppColors
                        .textSecondary,
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _feedPage(
    FeedCard card,
  ) {
    final category =
        AppCategories.byId(
      card.question.categoryId,
    );

    final saved =
        _interactions.isSaved(
      card.id,
    );

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16,
      ),
      child: Column(
        children: [
          // Publisher
          LiquidGlassContainer(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        _openPublisherProfile(
                      card,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 6,
                      ),
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            card.publisher.name,
                            style:
                                AppTextStyles
                                    .username,
                          ),
                          Text(
                            card.publisher.handle,
                            style:
                                AppTextStyles
                                    .caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Save button with visual state
                AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 250,
                  ),
                  curve:
                      Curves.easeOutCubic,
                  decoration:
                      BoxDecoration(
                    color: saved
                        ? AppColors
                            .secondary
                            .withOpacity(
                          0.12,
                        )
                        : Colors
                            .transparent,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: IconButton(
                    tooltip: saved
                        ? 'حذف من المحفوظات'
                        : 'سأجيب لاحقًا',
                    onPressed: () =>
                        _toggleSave(
                      card,
                    ),
                    icon: Icon(
                      saved
                          ? Icons
                              .bookmark_rounded
                          : Icons
                              .bookmark_border_rounded,
                    ),
                    color: saved
                        ? AppColors
                            .secondary
                        : AppColors
                            .textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Expanded(
            child:
                SwipeableCard(
              onSwipeLeft: () =>
                  _markNotInterested(
                card,
              ),
              onSwipeRight: () =>
                  _markInterested(
                card,
              ),
              child:
                  GestureDetector(
                onTap: () =>
                    _openQuestion(
                  card,
                ),
                child:
                    LiquidGlassContainer(
                  padding:
                      const EdgeInsets
                          .all(
                    24,
                  ),
                  child:
                      Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              category
                                  .color
                                  .withOpacity(
                            0.12,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            999,
                          ),
                          border:
                              Border.all(
                            color:
                                category
                                    .color
                                    .withOpacity(
                              0.65,
                            ),
                          ),
                        ),
                        child:
                            Text(
                          category.name,
                          style:
                              AppTextStyles
                                  .caption
                                  .copyWith(
                            color:
                                category
                                    .color,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      Text(
                        card.question.text,
                        textAlign:
                            TextAlign
                                .center,
                        style:
                            AppTextStyles
                                .displayLarge,
                      ),

                      _hashtags(
                        card.question,
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      Text(
                        'اضغط للإجابة',
                        style:
                            AppTextStyles
                                .caption,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Text(
                '${_currentIndex + 1} / ${_cards.length}',
                style:
                    AppTextStyles.caption,
              ),
              if (saved) ...[
                const SizedBox(
                  width: 8,
                ),
                const Icon(
                  Icons
                      .bookmark_rounded,
                  size: 14,
                  color:
                      AppColors
                          .secondary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_cards.isEmpty) {
      return Scaffold(
        backgroundColor:
            AppColors.background,
        body: const Center(
          child: Text(
            'لا توجد أسئلة حاليًا.',
            style:
                AppTextStyles.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title:
            const Text(
          'الرئيسية',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip:
                'العجلة',
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
            child:
                PageView.builder(
              controller:
                  _pageController,
              scrollDirection:
                  Axis.vertical,
              physics:
                  const VerticalFeedPhysics(),
              itemCount:
                  _cards.length,
              onPageChanged:
                  (index) {
                setState(() {
                  _currentIndex =
                      index;
                });
              },
              itemBuilder:
                  (context, index) {
                return _feedPage(
                  _cards[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
