import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class QuestionCategory {
  final int id;
  final String name;
  final Color color;

  const QuestionCategory({
    required this.id,
    required this.name,
    required this.color,
  });
}

class AppCategories {
  static const List<QuestionCategory> all = [
    QuestionCategory(
      id: 1,
      name: 'نعم / لا',
      color: AppColors.primary,
    ),
    QuestionCategory(
      id: 2,
      name: 'رأي',
      color: AppColors.secondary,
    ),
    QuestionCategory(
      id: 3,
      name: 'تصويت جماعي',
      color: AppColors.success,
    ),
    QuestionCategory(
      id: 4,
      name: 'اختر بين اثنين',
      color: AppColors.warning,
    ),
    QuestionCategory(
      id: 5,
      name: 'اعتراف',
      color: AppColors.error,
    ),
    QuestionCategory(
      id: 6,
      name: 'تحدي',
      color: Color(0xFFFDCB6E),
    ),
  ];

  static QuestionCategory byId(int id) {
    return all.firstWhere(
      (category) => category.id == id,
      orElse: () => all.first,
    );
  }
}
