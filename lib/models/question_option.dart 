import 'question_option.dart';

class Question {
  final String id;
  final String text;
  final int categoryId;
  final List<QuestionOption> options;
  final String? authorName;

  const Question({
    required this.id,
    required this.text,
    required this.categoryId,
    required this.options,
    this.authorName,
  }) : assert(options.length == 3, 'Question must have exactly 3 options');
}
