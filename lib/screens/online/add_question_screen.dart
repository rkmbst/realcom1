import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/online/question_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../models/question.dart';
import '../../models/question_option.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({
    super.key,
  });

  @override
  State<AddQuestionScreen> createState() =>
      _AddQuestionScreenState();
}

class _AddQuestionScreenState
    extends State<AddQuestionScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _questionController =
      TextEditingController();

  final _option1Controller =
      TextEditingController();

  final _option2Controller =
      TextEditingController();

  final _option3Controller =
      TextEditingController();

  final _session =
      AuthSession.instance;

  final _questionStore =
      QuestionStore.instance;

  int _selectedCategoryId =
      AppCategories.all.first.id;

  int? _correctOptionIndex;

  bool _publishing = false;

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    super.dispose();
  }

  String _newId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_correctOptionIndex == null) {
      _showMessage(
        'حدد الإجابة الصحيحة أولًا.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _publishing = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 220),
    );

    final optionTexts = [
      _option1Controller.text.trim(),
      _option2Controller.text.trim(),
      _option3Controller.text.trim(),
    ];

    final options = List<QuestionOption>.generate(
      optionTexts.length,
      (index) => QuestionOption(
        id: _newId('option'),
        text: optionTexts[index],
      ),
    );

    final question = Question(
      id: _newId('question'),
      text: _questionController.text.trim(),
      categoryId: _selectedCategoryId,
      options: options,
      authorName:
          _session.currentUser.displayName,
      authorId:
          _session.currentUser.id,
      correctOptionId:
          options[_correctOptionIndex!].id,
    );

    _questionStore.add(question);

    if (!mounted) return;

    Haptics.medium();

    setState(() {
      _publishing = false;
    });

    _showMessage(
      'تم نشر السؤال بنجاح.',
      success: true,
    );

    await Future.delayed(
      const Duration(milliseconds: 350),
    );

    if (!mounted) return;

    Navigator.pop(
      context,
      question,
    );
  }

  void _showMessage(
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success
            ? AppColors.success
            : AppColors.surface,
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
    );
  }

  Widget _optionField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction:
          TextInputAction.next,
      maxLength: 120,
      style: AppTextStyles.bodyLarge,
      decoration: _decoration(
        label: label,
        hint: 'اكتب الإجابة...',
      ),
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'هذا الخيار مطلوب';
        }

        return null;
      },
    );
  }

  Widget _correctChoice({
    required int index,
    required String text,
  }) {
    final selected =
        _correctOptionIndex == index;

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        AppRadius.button,
      ),
      onTap: () {
        setState(() {
          _correctOptionIndex = index;
        });
      },
      child: Container(
        constraints:
            const BoxConstraints(
          minHeight: 52,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
                  .withOpacity(0.10)
              : AppColors.surface,
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons
                      .radio_button_checked_rounded
                  : Icons
                      .radio_button_off_rounded,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text.isEmpty
                    ? 'الخيار ${index + 1}'
                    : text,
                style:
                    AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category =
        AppCategories.byId(
      _selectedCategoryId,
    );

    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title:
            const Text('إضافة سؤال'),
      ),

      body: Stack(
        children: [
          LiquidBackground(
            primaryOrbColor:
                category.color,
            secondaryOrbColor:
                category.color
                    .withOpacity(0.45),
          ),

          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                  AppSpacing.x24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: [
                    LiquidGlassContainer(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'أنشئ سؤالًا جديدًا',
                            style:
                                AppTextStyles
                                    .titleLarge,
                          ),

                          const SizedBox(
                            height:
                                AppSpacing.x8,
                          ),

                          Text(
                            'اكتب سؤالًا واضحًا بثلاث إجابات وحدد الإجابة الصحيحة.',
                            style:
                                AppTextStyles
                                    .bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppSpacing.x16,
                    ),

                    LiquidGlassContainer(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .stretch,
                        children: [
                          TextFormField(
                            controller:
                                _questionController,
                            minLines: 3,
                            maxLines: 6,
                            maxLength: 240,
                            textInputAction:
                                TextInputAction
                                    .newline,
                            style:
                                AppTextStyles
                                    .bodyLarge,
                            decoration:
                                _decoration(
                              label:
                                  'السؤال',
                              hint:
                                  'اكتب سؤالك هنا...',
                            ),
                            validator:
                                (value) {
                              final text =
                                  value?.trim() ??
                                      '';

                              if (text.isEmpty) {
                                return 'اكتب السؤال';
                              }

                              if (text.length <
                                  5) {
                                return 'السؤال قصير جدًا';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height:
                                AppSpacing.x16,
                          ),

                          DropdownButtonFormField<
                              int>(
                            value:
                                _selectedCategoryId,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'الفئة',
                            ),
                            items:
                                AppCategories
                                    .all
                                    .map(
                              (item) {
                                return DropdownMenuItem<
                                    int>(
                                  value:
                                      item.id,
                                  child:
                                      Text(
                                    item.name,
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged:
                                _publishing
                                    ? null
                                    : (value) {
                                        if (value ==
                                            null) {
                                          return;
                                        }

                                        setState(() {
                                          _selectedCategoryId =
                                              value;
                                        });
                                      },
                          ),

                          const SizedBox(
                            height:
                                AppSpacing.x16,
                          ),

                          _optionField(
                            label:
                                'الخيار الأول',
                            controller:
                                _option1Controller,
                          ),

                          const SizedBox(
                            height:
                                AppSpacing.x12,
                          ),

                          _optionField(
                            label:
                                'الخيار الثاني',
                            controller:
                                _option2Controller,
                          ),

                          const SizedBox(
                            height:
                                AppSpacing.x12,
                          ),

                          _optionField(
                            label:
                                'الخيار الثالث',
                            controller:
                                _option3Controller,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppSpacing.x16,
                    ),

                    LiquidGlassContainer(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .stretch,
                        children: [
                          Text(
                            'الإجابة الصحيحة',
                            style:
                                AppTextStyles
                                    .titleMedium,
                          ),

                          const SizedBox(
                            height:
                                AppSpacing.x12,
                          ),

                          _correctChoice(
                            index: 0,
                            text:
                                _option1Controller
                                    .text,
                          ),

                          const SizedBox(
                            height:
                                AppSpacing.x8,
                          ),

                          _correctChoice(
                            index: 1,
                            text:
                                _option2Controller
                                    .text,
                          ),

                          const SizedBox(
                            height:
                                AppSpacing.x8,
                          ),

                          _correctChoice(
                            index: 2,
                            text:
                                _option3Controller
                                    .text,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppSpacing.x24,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 54,
                      child:
                          ElevatedButton(
                        onPressed:
                            _publishing
                                ? null
                                : _publish,
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              AppColors
                                  .primary,
                          foregroundColor:
                              AppColors
                                  .onPrimary,
                          disabledBackgroundColor:
                              AppColors
                                  .primary
                                  .withOpacity(
                                0.32,
                              ),
                          disabledForegroundColor:
                              AppColors
                                  .onPrimary
                                  .withOpacity(
                                0.50,
                              ),
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              AppRadius
                                  .button,
                            ),
                          ),
                        ),
                        child:
                            _publishing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color:
                                          AppColors
                                              .onPrimary,
                                    ),
                                  )
                                : const Text(
                                    'نشر السؤال',
                                  ),
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppSpacing.x24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
