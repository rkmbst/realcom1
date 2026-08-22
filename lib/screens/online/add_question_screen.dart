import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/online/question_pack_store.dart';
import '../../core/online/question_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/categories.dart';
import '../../core/utils/haptics.dart';
import '../../models/question.dart';
import '../../models/question_option.dart';
import '../../models/question_pack.dart';
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
  static const int minQuestions = 3;
  static const int maxQuestions = 5;

  static const int maxHashtags = 5;
  static const int maxHashtagLength = 24;

  final _session =
      AuthSession.instance;

  final _questionStore =
      QuestionStore.instance;

  final _packStore =
      QuestionPackStore.instance;

  final _packTitleController =
      TextEditingController();

  final _hashtagController =
      TextEditingController();

  final _formKey =
      GlobalKey<FormState>();

  final List<String> _hashtags =
      <String>[];

  int _selectedCategoryId =
      AppCategories.all.first.id;

  final List<_DraftQuestion>
      _draftQuestions =
      <_DraftQuestion>[];

  bool _publishing = false;

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < minQuestions; i++) {
      _draftQuestions.add(
        _DraftQuestion(
          textController:
              TextEditingController(),
          option1Controller:
              TextEditingController(),
          option2Controller:
              TextEditingController(),
          option3Controller:
              TextEditingController(),
          type: QuestionType.poll,
        ),
      );
    }
  }

  @override
  void dispose() {
    _packTitleController.dispose();
    _hashtagController.dispose();

    for (final draft
        in _draftQuestions) {
      draft.dispose();
    }

    super.dispose();
  }

  String _newId(
    String prefix,
  ) {
    return '$prefix-'
        '${DateTime.now().microsecondsSinceEpoch}-'
        '${_draftQuestions.length}';
  }

  String _normalizeHashtag(
    String value,
  ) {
    return value
        .trim()
        .replaceFirst('#', '')
        .toLowerCase();
  }

  void _addHashtag() {
    if (_hashtags.length >=
        maxHashtags) {
      _showMessage(
        'يمكنك إضافة 5 هاشتاقات كحد أقصى.',
      );
      return;
    }

    final hashtag =
        _normalizeHashtag(
      _hashtagController.text,
    );

    if (hashtag.isEmpty) {
      return;
    }

    if (hashtag.length >
        maxHashtagLength) {
      _showMessage(
        'الهاشتاق طويل جدًا.',
      );
      return;
    }

    if (hashtag.contains(' ')) {
      _showMessage(
        'الهاشتاق لا يمكن أن يحتوي على مسافات.',
      );
      return;
    }

    if (hashtag.contains('#')) {
      _showMessage(
        'اكتب هاشتاقًا واحدًا فقط.',
      );
      return;
    }

    if (_hashtags.contains(
      hashtag,
    )) {
      _showMessage(
        'هذا الهاشتاق مضاف بالفعل.',
      );
      return;
    }

    setState(() {
      _hashtags.add(hashtag);
      _hashtagController.clear();
    });
  }

  void _removeHashtag(
    String hashtag,
  ) {
    setState(() {
      _hashtags.remove(hashtag);
    });
  }

  void _addQuestion() {
    if (_draftQuestions.length >=
        maxQuestions) {
      _showMessage(
        'يمكنك إضافة 5 أسئلة كحد أقصى.',
      );
      return;
    }

    setState(() {
      _draftQuestions.add(
        _DraftQuestion(
          textController:
              TextEditingController(),
          option1Controller:
              TextEditingController(),
          option2Controller:
              TextEditingController(),
          option3Controller:
              TextEditingController(),
          type: QuestionType.poll,
        ),
      );
    });
  }

  void _removeQuestion(
    int index,
  ) {
    if (_draftQuestions.length <=
        minQuestions) {
      _showMessage(
        'يجب أن تحتوي المجموعة على 3 أسئلة على الأقل.',
      );
      return;
    }

    final draft =
        _draftQuestions.removeAt(
      index,
    );

    draft.dispose();

    setState(() {});
  }

  Future<void> _publish() async {
    if (_publishing) {
      return;
    }

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_draftQuestions.length <
        minQuestions) {
      _showMessage(
        'أضف 3 أسئلة على الأقل.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _publishing = true;
    });

    try {
      final currentUser =
          _session.currentUser;

      final packId =
          _newId('pack');

      final createdQuestions =
          <Question>[];

      for (
        var index = 0;
        index < _draftQuestions.length;
        index++
      ) {
        final draft =
            _draftQuestions[index];

        if (draft.type ==
                QuestionType.quiz &&
            draft.correctOptionIndex ==
                null) {
          _showMessage(
            'حدد الإجابة الصحيحة في السؤال ${index + 1}.',
          );

          setState(() {
            _publishing = false;
          });

          return;
        }

        final optionTexts =
            <String>[
          draft.option1Controller
              .text
              .trim(),
          draft.option2Controller
              .text
              .trim(),
          draft.option3Controller
              .text
              .trim(),
        ];

        final options =
            List<QuestionOption>.generate(
          optionTexts.length,
          (optionIndex) =>
              QuestionOption(
            id: _newId('option'),
            text:
                optionTexts[
                    optionIndex],
          ),
        );

        String? correctOptionId;

        if (draft.type ==
            QuestionType.quiz) {
          correctOptionId =
              options[
                draft.correctOptionIndex!
              ].id;
        }

        createdQuestions.add(
          Question(
            id:
                _newId('question'),
            text:
                draft
                    .textController
                    .text
                    .trim(),
            categoryId:
                _selectedCategoryId,
            options:
                options,
            authorName:
                currentUser.displayName,
            authorId:
                currentUser.id,
            type:
                draft.type,
            correctOptionId:
                correctOptionId,
            hashtags:
                List.unmodifiable(
              _hashtags,
            ),
          ),
        );
      }

      final pack =
          QuestionPack(
        id:
            packId,
        publisherId:
            currentUser.id,
        title: _packTitleController
                .text
                .trim()
                .isEmpty
            ? 'مجموعة ${currentUser.displayName}'
            : _packTitleController
                .text
                .trim(),
        questions:
            List.unmodifiable(
          createdQuestions,
        ),
      );

      // Store questions first.
      for (final question
          in createdQuestions) {
        _questionStore.add(
          question,
        );
      }

      // Publish the pack through the
      // single publishing path.
      _packStore.publish(
        pack: pack,
        authorName:
            currentUser.displayName,
      );

      if (!mounted) {
        return;
      }

      Haptics.medium();

      setState(() {
        _publishing = false;
      });

      _showMessage(
        'تم نشر المجموعة بنجاح.',
        success: true,
      );

      await Future.delayed(
        const Duration(
          milliseconds: 300,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        pack,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _publishing = false;
      });

      _showMessage(
        'حدث خطأ أثناء نشر المجموعة.',
      );

      debugPrint(
        'AddQuestionScreen publish error: $error',
      );
    }
  }

  void _showMessage(
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          backgroundColor:
              success
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
      labelText:
          label,
      hintText:
          hint,
    );
  }

  Widget _questionEditor({
    required int index,
  }) {
    final draft =
        _draftQuestions[index];

    return LiquidGlassContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          Row(
            children: [
              Text(
                'السؤال ${index + 1}',
                style:
                    AppTextStyles
                        .titleMedium,
              ),
              const Spacer(),
              if (_draftQuestions
                      .length >
                  minQuestions)
                IconButton(
                  onPressed:
                      _publishing
                          ? null
                          : () =>
                              _removeQuestion(
                                index,
                              ),
                  tooltip:
                      'حذف السؤال',
                  icon:
                      const Icon(
                    Icons
                        .delete_outline_rounded,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height:
                AppSpacing.x12,
          ),

          TextFormField(
            controller:
                draft.textController,
            minLines: 3,
            maxLines: 5,
            maxLength: 240,
            style:
                AppTextStyles
                    .bodyLarge,
            decoration:
                _decoration(
              label:
                  'السؤال',
              hint:
                  'اكتب السؤال هنا...',
            ),
            validator: (
              value,
            ) {
              final text =
                  value?.trim() ??
                      '';

              if (text.isEmpty) {
                return 'اكتب السؤال ${index + 1}';
              }

              if (text.length < 5) {
                return 'السؤال قصير جدًا';
              }

              return null;
            },
          ),

          const SizedBox(
            height:
                AppSpacing.x12,
          ),

          Text(
            'نوع السؤال',
            style:
                AppTextStyles
                    .caption,
          ),

          const SizedBox(
            height:
                AppSpacing.x8,
          ),

          Row(
            children: [
              _typeButton(
                draft,
                QuestionType.poll,
                'تصويت',
                Icons.poll_outlined,
              ),
              const SizedBox(
                width: 6,
              ),
              _typeButton(
                draft,
                QuestionType.quiz,
                'اختبار',
                Icons.school_outlined,
              ),
              const SizedBox(
                width: 6,
              ),
              _typeButton(
                draft,
                QuestionType.opinion,
                'رأي',
                Icons.psychology_outlined,
              ),
              const SizedBox(
                width: 6,
              ),
              _typeButton(
                draft,
                QuestionType.discussion,
                'نقاش',
                Icons.forum_outlined,
              ),
            ],
          ),

          const SizedBox(
            height:
                AppSpacing.x16,
          ),

          _draftOptionField(
            draft:
                draft,
            label:
                'الخيار الأول',
            controller:
                draft.option1Controller,
          ),

          const SizedBox(
            height:
                AppSpacing.x10,
          ),

          _draftOptionField(
            draft:
                draft,
            label:
                'الخيار الثاني',
            controller:
                draft.option2Controller,
          ),

          const SizedBox(
            height:
                AppSpacing.x10,
          ),

          _draftOptionField(
            draft:
                draft,
            label:
                'الخيار الثالث',
            controller:
                draft.option3Controller,
          ),

          if (draft.type ==
              QuestionType.quiz) ...[
            const SizedBox(
              height:
                  AppSpacing.x16,
            ),

            Text(
              'الإجابة الصحيحة',
              style:
                  AppTextStyles
                      .titleMedium,
            ),

            const SizedBox(
              height:
                  AppSpacing.x10,
            ),

            _draftCorrectChoice(
              draft:
                  draft,
              index: 0,
            ),

            const SizedBox(
              height:
                  AppSpacing.x8,
            ),

            _draftCorrectChoice(
              draft:
                  draft,
              index: 1,
            ),

            const SizedBox(
              height:
                  AppSpacing.x8,
            ),

            _draftCorrectChoice(
              draft:
                  draft,
              index: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _typeButton(
    _DraftQuestion draft,
    QuestionType type,
    String label,
    IconData icon,
  ) {
    final selected =
        draft.type == type;

    return Expanded(
      child: InkWell(
        onTap:
            _publishing
                ? null
                : () {
                    setState(() {
                      draft.type =
                          type;

                      if (type !=
                          QuestionType
                              .quiz) {
                        draft.correctOptionIndex =
                            null;
                      }
                    });
                  },
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        child:
            Container(
          constraints:
              const BoxConstraints(
            minHeight: 60,
          ),
          padding:
              const EdgeInsets.symmetric(
            vertical: 8,
          ),
          decoration:
              BoxDecoration(
            color: selected
                ? AppColors.primary
                    .withOpacity(
                  0.10,
                )
                : AppColors
                    .surface,
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            border:
                Border.all(
              color: selected
                  ? AppColors
                      .primary
                  : AppColors
                      .divider,
            ),
          ),
          child:
              Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                icon,
                size: 19,
                color: selected
                    ? AppColors
                        .primary
                    : AppColors
                        .textSecondary,
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                label,
                style:
                    AppTextStyles
                        .caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _draftOptionField({
    required _DraftQuestion draft,
    required String label,
    required TextEditingController
        controller,
  }) {
    return TextFormField(
      controller:
          controller,
      maxLength:
          120,
      style:
          AppTextStyles
              .bodyLarge,
      decoration:
          _decoration(
        label:
            label,
        hint:
            'اكتب الإجابة...',
      ),
      validator: (
        value,
      ) {
        if (value ==
                null ||
            value
                .trim()
                .isEmpty) {
          return 'هذا الخيار مطلوب';
        }

        return null;
      },
    );
  }

  Widget _draftCorrectChoice({
    required _DraftQuestion draft,
    required int index,
  }) {
    final selected =
        draft.correctOptionIndex ==
            index;

    final controllers = <
        TextEditingController>[
      draft.option1Controller,
      draft.option2Controller,
      draft.option3Controller,
    ];

    return InkWell(
      onTap:
          _publishing
              ? null
              : () {
                  setState(() {
                    draft.correctOptionIndex =
                        index;
                  });
                },
      borderRadius:
          BorderRadius.circular(
        AppRadius.button,
      ),
      child:
          Container(
        constraints:
            const BoxConstraints(
          minHeight: 50,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? AppColors.primary
                  .withOpacity(
                0.10,
              )
              : AppColors
                  .surface,
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
          border:
              Border.all(
            color: selected
                ? AppColors
                    .primary
                : AppColors
                    .divider,
          ),
        ),
        child:
            Row(
          children: [
            Icon(
              selected
                  ? Icons
                      .radio_button_checked_rounded
                  : Icons
                      .radio_button_off_rounded,
              color: selected
                  ? AppColors
                      .primary
                  : AppColors
                      .textSecondary,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child:
                  Text(
                controllers[
                            index]
                        .text
                        .trim()
                        .isEmpty
                    ? 'الخيار ${index + 1}'
                    : controllers[
                            index]
                        .text
                        .trim(),
                style:
                    AppTextStyles
                        .bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashtagSection() {
    return LiquidGlassContainer(
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          Text(
            'الهاشتاقات',
            style:
                AppTextStyles
                    .titleMedium,
          ),
          const SizedBox(
            height:
                AppSpacing.x4,
          ),
          Text(
            'اختياري — حتى 5 هاشتاقات للمجموعة.',
            style:
                AppTextStyles
                    .caption,
          ),
          const SizedBox(
            height:
                AppSpacing.x12,
          ),
          Row(
            children: [
              Expanded(
                child:
                    TextField(
                  controller:
                      _hashtagController,
                  maxLength:
                      maxHashtagLength,
                  textInputAction:
                      TextInputAction
                          .done,
                  onSubmitted:
                      (_) =>
                          _addHashtag(),
                  decoration:
                      const InputDecoration(
                    labelText:
                        'أضف هاشتاق',
                    hintText:
                        'مثال: رياضيات',
                    counterText:
                        '',
                  ),
                ),
              ),
              const SizedBox(
                width:
                    AppSpacing.x8,
              ),
              SizedBox(
                width: 48,
                height: 48,
                child:
                    IconButton(
                  onPressed:
                      _publishing
                          ? null
                          : _addHashtag,
                  icon:
                      const Icon(
                    Icons
                        .add_rounded,
                  ),
                ),
              ),
            ],
          ),
          if (_hashtags
              .isNotEmpty) ...[
            const SizedBox(
              height:
                  AppSpacing.x8,
            ),
            Wrap(
              spacing: 8,
              runSpacing:
                  8,
              children:
                  _hashtags.map(
                (
                  hashtag,
                ) {
                  return InputChip(
                    label:
                        Text(
                      '#$hashtag',
                    ),
                    onDeleted:
                        _publishing
                            ? null
                            : () =>
                                _removeHashtag(
                                  hashtag,
                                ),
                    backgroundColor:
                        AppColors
                            .surfaceVariant,
                    side:
                        BorderSide(
                      color:
                          AppColors
                              .divider,
                    ),
                  );
                },
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final category =
        AppCategories.byId(
      _selectedCategoryId,
    );

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar:
          AppBar(
        title:
            const Text(
          'إنشاء مجموعة',
        ),
      ),
      body:
          Stack(
        children: [
          LiquidBackground(
            primaryOrbColor:
                category.color,
            secondaryOrbColor:
                category.color
                    .withOpacity(
              0.4,
            ),
          ),
          SafeArea(
            child:
                Form(
              key:
                  _formKey,
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets
                        .all(
                  AppSpacing.x16,
                ),
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: [
                    LiquidGlassContainer(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'أنشئ مجموعة أسئلة',
                            style:
                                AppTextStyles
                                    .titleLarge,
                          ),
                          const SizedBox(
                            height:
                                AppSpacing.x8,
                          ),
                          Text(
                            'أضف من 3 إلى 5 أسئلة. لكل سؤال نوع مستقل.',
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
                      child:
                          TextFormField(
                        controller:
                            _packTitleController,
                        maxLength:
                            80,
                        enabled:
                            !_publishing,
                        decoration:
                            _decoration(
                          label:
                              'اسم المجموعة',
                          hint:
                              'مثال: أسئلة رياضية',
                        ),
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppSpacing.x16,
                    ),

                    LiquidGlassContainer(
                      child:
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
                          (
                            item,
                          ) {
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
                                : (
                                    value,
                                  ) {
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
                    ),

                    const SizedBox(
                      height:
                          AppSpacing.x16,
                    ),

                    _buildHashtagSection(),

                    const SizedBox(
                      height:
                          AppSpacing.x16,
                    ),

                    ...List.generate(
                      _draftQuestions.length,
                      (
                        index,
                      ) =>
                          Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom:
                              AppSpacing.x12,
                        ),
                        child:
                            _questionEditor(
                          index:
                              index,
                        ),
                      ),
                    ),

                    if (_draftQuestions
                            .length <
                        maxQuestions)
                      OutlinedButton
                          .icon(
                        onPressed:
                            _publishing
                                ? null
                                : _addQuestion,
                        icon:
                            const Icon(
                          Icons
                              .add_rounded,
                        ),
                        label:
                            const Text(
                          'إضافة سؤال آخر',
                        ),
                        style:
                            OutlinedButton
                                .styleFrom(
                          foregroundColor:
                              AppColors
                                  .textPrimary,
                          side:
                              BorderSide(
                            color: AppColors
                                .titaniumBorder
                                .withOpacity(
                              0.65,
                            ),
                          ),
                          minimumSize:
                              const Size
                                  .fromHeight(
                            50,
                          ),
                        ),
                      ),

                    const SizedBox(
                      height:
                          AppSpacing.x16,
                    ),

                    SizedBox(
                      height:
                          54,
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
                                : Text(
                                    'نشر المجموعة (${_draftQuestions.length})',
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

class _DraftQuestion {
  _DraftQuestion({
    required this.textController,
    required this.option1Controller,
    required this.option2Controller,
    required this.option3Controller,
    required this.type,
  });

  final TextEditingController
      textController;

  final TextEditingController
      option1Controller;

  final TextEditingController
      option2Controller;

  final TextEditingController
      option3Controller;

  QuestionType type;

  int? correctOptionIndex;

  void dispose() {
    textController.dispose();
    option1Controller.dispose();
    option2Controller.dispose();
    option3Controller.dispose();
  }
}
