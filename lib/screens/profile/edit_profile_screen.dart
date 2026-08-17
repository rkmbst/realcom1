import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import '../../widgets/user_avatar.dart';

class EditProfileScreen
    extends StatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _session =
      AuthSession.instance;

  late final TextEditingController
      _nameController;

  late final TextEditingController
      _usernameController;

  late final TextEditingController
      _bioController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final user =
        _session.currentUser;

    _nameController =
        TextEditingController(
      text: user.displayName,
    );

    _usernameController =
        TextEditingController(
      text: user.username,
    );

    _bioController =
        TextEditingController(
      text: user.bio,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 220),
    );

    _session.updateProfile(
      username:
          _usernameController.text,
      displayName:
          _nameController.text,
      bio: _bioController.text,
    );

    if (!mounted) return;

    setState(() {
      _saving = false;
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final user =
        _session.currentUser;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title:
            const Text('تعديل الملف'),
      ),
      body: Stack(
        children: [
          const LiquidBackground(),
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                  AppSpacing.x24,
                ),
                child: Column(
                  children: [
                    UserAvatar(
                      imageUrl:
                          user.avatarUrl,
                      size: 96,
                    ),

                    const SizedBox(
                      height: AppSpacing.x24,
                    ),

                    LiquidGlassContainer(
                      padding:
                          const EdgeInsets.all(
                        AppSpacing.x16,
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller:
                                _nameController,
                            textInputAction:
                                TextInputAction
                                    .next,
                            style:
                                AppTextStyles
                                    .bodyLarge,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'الاسم',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'اكتب اسمك';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: AppSpacing.x16,
                          ),

                          TextFormField(
                            controller:
                                _usernameController,
                            textInputAction:
                                TextInputAction
                                    .next,
                            style:
                                AppTextStyles
                                    .bodyLarge,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'اسم المستخدم',
                              prefixText: '@ ',
                            ),
                            validator: (value) {
                              final text =
                                  value?.trim() ??
                                      '';

                              if (text.isEmpty) {
                                return 'اكتب اسم المستخدم';
                              }

                              if (text.length < 3) {
                                return '3 أحرف على الأقل';
                              }

                              if (text.contains(
                                ' ',
                              )) {
                                return 'لا تستخدم مسافات';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: AppSpacing.x16,
                          ),

                          TextFormField(
                            controller:
                                _bioController,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 160,
                            style:
                                AppTextStyles
                                    .bodyMedium,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'نبذة',
                              alignLabelWithHint:
                                  true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.x24,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 52,
                      child:
                          ElevatedButton(
                        onPressed:
                            _saving
                                ? null
                                : _save,
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
                              AppRadius.button,
                            ),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors
                                      .onPrimary,
                                ),
                              )
                            : Text(
                                'حفظ التغييرات',
                                style:
                                    AppTextStyles
                                        .button
                                        .copyWith(
                                  color:
                                      AppColors
                                          .onPrimary,
                                ),
                              ),
                      ),
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
