import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../data/mock_online_data.dart';
import '../../models/feed_card.dart';
import '../../models/question.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import '../../widgets/swipeable_card.dart';
import 'publisher_wheel_screen.dart';

class OnlineFeedScreen extends StatefulWidget {
  const OnlineFeedScreen({super.key});

  @override
  State<OnlineFeedScreen> createState() => _OnlineFeedScreenState();
}

class _OnlineFeedScreenState extends State<OnlineFeedScreen> {
  late final List<FeedCard> _cards;
  int _currentIndex = 0;
  int _cardNonce = 0;

  @override
  void initState() {
    super.initState();
    _cards = MockOnlineData.buildFeedCards();
  }

  void _skip() {
    if (_cards.isEmpty) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % _cards.length;
    });
  }

  Future<void> _openPublisherWheel(FeedCard card) async {
    final shuffled = List<Question>.from(card.pack.questions)..shuffle();
    final wheelQuestions = shuffled.take(7).toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublisherWheelScreen(
          publisher: card.publisher,
          pack: card.pack,
          questions: wheelQuestions,
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _cardNonce++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('التصفح الأونلاين')),
        body: const Center(
          child: Text(
            'لا توجد بطاقات.',
            style: AppTextStyles.bodyLarge,
          ),
        ),
      );
    }

    final current = _cards[_currentIndex];
    final category = AppCategories.byId(current.question.categoryId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('التصفح الأونلاين'),
      ),
      body: Stack(
        children: [
          const LiquidBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  LiquidGlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: current.publisher.accentColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current.publisher.name,
                                style: AppTextStyles.titleMedium,
                              ),
                              Text(
                                current.publisher.handle,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          current.pack.title,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SwipeableCard(
                      key: ValueKey('feed_card_${current.id}_$_cardNonce'),
                      onSwipeLeft: _skip,
                      onSwipeRight: () => _openPublisherWheel(current),
                      child: LiquidGlassContainer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: category.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: category.color),
                              ),
                              child: Text(
                                category.name,
                                style: AppTextStyles.caption.copyWith(
                                  color: category.color,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              current.question.text,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.displayLarge,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'اسحب يمينًا للدخول إلى عجلة الناشر',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _skip,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('تخطي'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceVariant,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openPublisherWheel(current),
                          icon: const Icon(Icons.check),
                          label: const Text('موافق'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_currentIndex + 1} / ${_cards.length}',
                    style: AppTextStyles.caption,
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
