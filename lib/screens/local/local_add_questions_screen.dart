import 'package:flutter/material.dart';

import '../../core/session/app_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../models/question.dart';
import '../../models/question_option.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import 'local_wheel_screen.dart';

class LocalAddQuestionsScreen extends StatefulWidget {
  const LocalAddQuestionsScreen({super.key});

  @override
  State<LocalAddQuestionsScreen> createState() =>
      _LocalAddQuestionsScreenState();
}

class _LocalAddQuestionsScreenState extends State<LocalAddQuestionsScreen> {
  final AppSession _session = AppSession.instance;

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _option1Controller = TextEditingController();
  final TextEditingController _option2Controller = TextEditingController();
  final TextEditingController _option3Controller = TextEditingController();

  int _categoryId = 1;

  void _addQuestion() {
    final text = _questionController.text.trim();
    final option1 = _option1Controller.text.trim();
    final option2 = _option2Controller.text.trim();
    final option3 = _option3Controller.text.trim();

    if (text.isEmpty || option1.isEmpty || option2.isEmpty || option3.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جميع الحقول مطلوبة.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final questionId = 'user_q_${DateTime.now().millisecondsSinceEpoch}';

    _session.addQuestion(
      Question(
        id: questionId,
        text: text,
        categoryId: _categoryId,
        authorName: _session.currentAdder?.name,
        options: [
          QuestionOption(id: '${questionId}_o1', text: option1),
          QuestionOption(id: '${questionId}_o2', text: option2),
          QuestionOption(id: '${questionId}_o3', text: option3),
        ],
      ),
    );

    _questionController.clear();
    _option1Controller.clear();
    _option2Controller.clear();
    _option3Controller.clear();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إضافة السؤال.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _addBuiltIn() {
    final count = _session.addBuiltInQuestions();

    setState(() {});

    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الأسئلة الجاهزة مضافة مسبقًا.'),
          backgroundColor: AppColors.warning,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة $count سؤالًا جاهزًا.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _nextPlayer() {
    _session.nextAdder();
    setState(() {});
  }

  void _startWheel() {
    if (_session.allQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أضف سؤالًا واحدًا على الأقل.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _session.prepareRound();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LocalWheelScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAdder = _session.currentAdder;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إضافة الأسئلة'),
      ),
      body: Stack(
        children: [
          const LiquidBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (currentAdder != null)
                    LiquidGlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentAdder.color,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${currentAdder.name} يضيف الآن',
                              style: AppTextStyles.titleMedium,
                            ),
                          ),
                          Text(
                            '${_session.allQuestions.length} سؤالًا',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildField(_questionController, 'نص السؤال', 3),
                  const SizedBox(height: 12),
                  LiquidGlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _categoryId,
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        items: AppCategories.all.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _categoryId = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('الخيارات الثلاثة', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  _buildField(_option1Controller, 'الخيار 1', 1),
                  const SizedBox(height: 12),
                  _buildField(_option2Controller, 'الخيار 2', 1),
                  const SizedBox(height: 12),
                  _buildField(_option3Controller, 'الخيار 3', 1),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة السؤال'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addBuiltIn,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('إضافة أسئلة جاهزة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _nextPlayer,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('اللاعب التالي'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _startWheel,
                    icon: const Icon(Icons.casino),
                    label: const Text('بدء العجلة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint,
    int maxLines,
  ) {
    return LiquidGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
