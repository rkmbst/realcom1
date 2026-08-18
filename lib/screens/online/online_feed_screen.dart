import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/online/question_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../data/mock_online_data.dart';
import '../../models/feed_card.dart';
import '../../models/publisher.dart';
import '../../models/question.dart';
import '../../models/question_pack.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import '../../widgets/swipeable_card.dart';
import '../profile/profile_screen.dart';
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
  final _questionStore =
      QuestionStore.instance;

  final _session =
      AuthSession.instance;

  late List<FeedCard> _cards;

  int _currentIndex = 0;
  int _cardNonce = 0;

  @override
  void initState() {
    super.initState();
    _rebuildFeed();
  }

  void _rebuildFeed() {
    final mockCards =
        MockOnlineData.buildFeedCards();

    final userCards =
        _buildUserQuestionCards();

    _cards = [
      ...userCards,
      ...mockCards,
    ];

    if (_cards.isEmpty) {
      _currentIndex = 0;
      return;
    }

    if (_currentIndex >= _cards.length) {
      _currentIndex = 0;
    }
  }

  List<FeedCard> _buildUserQuestionCards() {
    final questions =
        _questionStore.publishedQuestions;

    final cards = <FeedCard>[];

    final currentUser =
        _session.currentUser;

    for (final question in questions) {
      final authorId =
          question.authorId;

      if (authorId == null) {
        continue;
      }

      final authorName =
          question.authorName ??
              currentUser.displayName;

      final handle =
          '@${currentUser.username}';

      final publisher =
          Publisher(
        id: authorId,
        name: authorName,
        handle: handle,
        accentColor:
            AppCategories.byId(
          question.categoryId,
        ).color,
      );

      final pack =
          QuestionPack(
        id: 'user_pack_$authorId',
        publisherId: authorId,
        title: 'أسئلة $authorName',
        questions: [
          question,
        ],
      );

      cards.add(
        FeedCard(
          id: 'user_card_${question.id}',
          publisher: publisher,
          pack: pack,
          question: question,
        ),
      );
    }

    return cards;
  }

  void _refreshFeed() {
    setState(() {
      _rebuildFeed();
      _cardNonce++;
    });
  }

  void _skip() {
    if (_cards.isEmpty) {
      return;
    }

    setState(() {
      _currentIndex =
          (_currentIndex + 1) %
              _cards.length;
      _cardNonce++;
    });
  }

  Future<void> _openPublisherWheel(
    FeedCard card,
  ) async {
    final shuffled =
        List<Question>.from(
          card.pack.questions,
        )..shuffle();

    final wheelQuestions =
        shuffled.take(7).toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PublisherWheelScreen(
          publisher:
              card.publisher,
          pack: card.pack,
          questions:
              wheelQuestions,
        ),
      ),
    );

    if (mounted) {
      _refreshFeed();
    }
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

  Widget _buildHashtags(
    Question question,
  ) {
    if (question.hashtags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding:
          const EdgeInsets.only(
        top: 16,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment:
            WrapAlignment.center,
        children:
            question.hashtags.map(
          (hashtag) {
            return Text(
              '#$hashtag',
              style:
                  AppTextStyles.caption
                      .copyWith(
                color:
                    AppColors.textSecondary,
              ),
            );
          },
        ).toList(),
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
        appBar: AppBar(
          title:
              const Text(
            'التصفح الأونلاين',
          ),
        ),
        body: const Center(
          child: Text(
            'لا توجد أسئلة حاليًا.',
            style:
                AppTextStyles.bodyLarge,
          ),
        ),
      );
    }

    final current =
        _cards[_currentIndex];

    final category =
        AppCategories.byId(
      current.question.categoryId,
    );

    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title:
            const Text(
          'التصفح الأونلاين',
        ),
      ),

      body: Stack(
        children: [
          LiquidBackground(
            primaryOrbColor:
                category.color,
            secondaryOrbColor:
                category.color
                    .withOpacity(0.42),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ─────────────────────────
                  // Publisher header
                  // ─────────────────────────

                  LiquidGlassContainer(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape.circle,
                            color: current
                                .publisher
                                .accentColor,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child:
                              InkWell(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                            onTap: () =>
                                _openPublisherProfile(
                              current,
                            ),
                            child:
                                Padding(
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
                                    current
                                        .publisher
                                        .name,
                                    style:
                                        AppTextStyles
                                            .username,
                                  ),
                                  Text(
                                    current
                                        .publisher
                                        .handle,
                                    style:
                                        AppTextStyles
                                            .caption,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Text(
                          current.pack.title,
                          style:
                              AppTextStyles
                                  .caption,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ─────────────────────────
                  // Main feed card
                  // ─────────────────────────

                  Expanded(
                    child:
                        SwipeableCard(
                      key: ValueKey(
                        'feed_card_${current.id}_$_cardNonce',
                      ),
                      onSwipeLeft:
                          _skip,
                      onSwipeRight: () =>
                          _openPublisherWheel(
                        current,
                      ),
                      child:
                          LiquidGlassContainer(
                        child: Column(
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
                                color: category
                                    .color
                                    .withOpacity(
                                  0.15,
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
                                          .color,
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
                              height: 24,
                            ),

                            Text(
                              current
                                  .question
                                  .text,
                              textAlign:
                                  TextAlign
                                      .center,
                              style:
                                  AppTextStyles
                                      .displayLarge,
                            ),

                            _buildHashtags(
                              current.question,
                            ),

                            const SizedBox(
                              height: 24,
                            ),

                            Text(
                              'اسحب يمينًا للدخول إلى عجلة الناشر',
                              style:
                                  AppTextStyles
                                      .caption,
                              textAlign:
                                  TextAlign
                                      .center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ─────────────────────────
                  // Actions
                  // ─────────────────────────

                  Row(
                    children: [
                      Expanded(
                        child:
                            ElevatedButton
                                .icon(
                          onPressed:
                              _skip,
                          icon:
                              const Icon(
                            Icons
                                .arrow_back,
                          ),
                          label:
                              const Text(
                            'تخطي',
                          ),
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                AppColors
                                    .surfaceVariant,
                            foregroundColor:
                                AppColors
                                    .textPrimary,
                            elevation: 0,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 14,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                18,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 16,
                      ),

                      Expanded(
                        child:
                            ElevatedButton
                                .icon(
                          onPressed:
                              () =>
                                  _openPublisherWheel(
                            current,
                          ),
                          icon:
                              const Icon(
                            Icons.check,
                          ),
                          label:
                              const Text(
                            'موافق',
                          ),
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                AppColors
                                    .primary,
                            foregroundColor:
                                AppColors
                                    .onPrimary,
                            elevation: 0,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 14,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Text(
                    '${_currentIndex + 1} / ${_cards.length}',
                    style:
                        AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
