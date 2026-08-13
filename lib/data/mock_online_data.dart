import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/feed_card.dart';
import '../models/publisher.dart';
import '../models/question.dart';
import '../models/question_option.dart';
import '../models/question_pack.dart';

/// Mock online publishers, packs, cards, and results.
class MockOnlineData {
  static final List<Publisher> publishers = [
    const Publisher(
      id: 'publisher_1',
      name: 'اعترافات هادئة',
      handle: '@quiet_confessions',
      accentColor: AppColors.primary,
    ),
    const Publisher(
      id: 'publisher_2',
      name: 'خيارات سريعة',
      handle: '@quick_choices',
      accentColor: AppColors.secondary,
    ),
    const Publisher(
      id: 'publisher_3',
      name: 'رأي صريح',
      handle: '@honest_opinion',
      accentColor: AppColors.success,
    ),
  ];

  static final List<QuestionPack> packs = [
    QuestionPack(
      id: 'pack_1',
      publisherId: 'publisher_1',
      title: 'اعترافات',
      questions: const [
        Question(
          id: 'online_q1',
          text: 'هل ندمت على شيء فعلته هذا الأسبوع؟',
          categoryId: 5,
          options: [
            QuestionOption(id: 'online_q1_o1', text: 'نعم'),
            QuestionOption(id: 'online_q1_o2', text: 'لا'),
            QuestionOption(id: 'online_q1_o3', text: 'قليلًا'),
          ],
        ),
        Question(
          id: 'online_q2',
          text: 'هل سبق أن تظاهرت بشيء ليس فيك؟',
          categoryId: 5,
          options: [
            QuestionOption(id: 'online_q2_o1', text: 'نعم'),
            QuestionOption(id: 'online_q2_o2', text: 'لا'),
            QuestionOption(id: 'online_q2_o3', text: 'أحيانًا'),
          ],
        ),
        Question(
          id: 'online_q3',
          text: 'ما أكثر شيء تخاف منه؟',
          categoryId: 5,
          options: [
            QuestionOption(id: 'online_q3_o1', text: 'الفقد'),
            QuestionOption(id: 'online_q3_o2', text: 'الفشل'),
            QuestionOption(id: 'online_q3_o3', text: 'المجهول'),
          ],
        ),
      ],
    ),
    QuestionPack(
      id: 'pack_2',
      publisherId: 'publisher_2',
      title: 'اختر بسرعة',
      questions: const [
        Question(
          id: 'online_q4',
          text: 'هل تفضل قراءة كتاب أم مشاهدة فيلم؟',
          categoryId: 4,
          options: [
            QuestionOption(id: 'online_q4_o1', text: 'كتاب'),
            QuestionOption(id: 'online_q4_o2', text: 'فيلم'),
            QuestionOption(id: 'online_q4_o3', text: 'الاثنان'),
          ],
        ),
        Question(
          id: 'online_q5',
          text: 'هل تفضل السفر إلى الماضي أم المستقبل؟',
          categoryId: 4,
          options: [
            QuestionOption(id: 'online_q5_o1', text: 'الماضي'),
            QuestionOption(id: 'online_q5_o2', text: 'المستقبل'),
            QuestionOption(id: 'online_q5_o3', text: 'الحاضر'),
          ],
        ),
        Question(
          id: 'online_q6',
          text: 'هل تفضل الصيف أم الشتاء؟',
          categoryId: 4,
          options: [
            QuestionOption(id: 'online_q6_o1', text: 'الصيف'),
            QuestionOption(id: 'online_q6_o2', text: 'الشتاء'),
            QuestionOption(id: 'online_q6_o3', text: 'الربيع'),
          ],
        ),
      ],
    ),
    QuestionPack(
      id: 'pack_3',
      publisherId: 'publisher_3',
      title: 'آراء صريحة',
      questions: const [
        Question(
          id: 'online_q7',
          text: 'هل تفضل العمل عن بُعد؟',
          categoryId: 2,
          options: [
            QuestionOption(id: 'online_q7_o1', text: 'نعم'),
            QuestionOption(id: 'online_q7_o2', text: 'لا'),
            QuestionOption(id: 'online_q7_o3', text: 'أحيانًا'),
          ],
        ),
        Question(
          id: 'online_q8',
          text: 'هل تثق بالقرارات السريعة؟',
          categoryId: 2,
          options: [
            QuestionOption(id: 'online_q8_o1', text: 'نعم'),
            QuestionOption(id: 'online_q8_o2', text: 'لا'),
            QuestionOption(id: 'online_q8_o3', text: 'حسب الموقف'),
          ],
        ),
        Question(
          id: 'online_q9',
          text: 'هل استخدام الهاتف قبل النوم عادة سيئة؟',
          categoryId: 1,
          options: [
            QuestionOption(id: 'online_q9_o1', text: 'نعم'),
            QuestionOption(id: 'online_q9_o2', text: 'لا'),
            QuestionOption(id: 'online_q9_o3', text: 'عادي'),
          ],
        ),
      ],
    ),
  ];

  static List<FeedCard> buildFeedCards() {
    final List<FeedCard> cards = [];

    for (final pack in packs) {
      final publisher = publishers.firstWhere(
        (publisher) => publisher.id == pack.publisherId,
      );

      for (final question in pack.questions) {
        cards.add(
          FeedCard(
            id: 'card_${question.id}',
            publisher: publisher,
            pack: pack,
            question: question,
          ),
        );
      }
    }

    return cards;
  }

  static Map<String, int> generateResults(
    Question question,
    String selectedOptionId,
  ) {
    final random = Random(question.id.hashCode.abs());
    final results = <String, int>{};

    for (final option in question.options) {
      results[option.id] = 3 + random.nextInt(18);
    }

    results[selectedOptionId] = (results[selectedOptionId] ?? 0) + 1;

    return results;
  }
}
