import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ═════════════════════════════════════════════
  // DARK
  // ═════════════════════════════════════════════

  static ThemeData dark() {
    final scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,

      secondary: AppColors.secondary,

      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,

      error: AppColors.error,
      onError: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      fontFamily:
          AppTextStyles.fontFamily,

      scaffoldBackgroundColor:
          AppColors.background,

      colorScheme: scheme,

      // ───────────────────────────────────────
      // App Bar
      // ───────────────────────────────────────

      appBarTheme:
          const AppBarTheme(
        backgroundColor:
            Colors.transparent,
        foregroundColor:
            AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTextStyles.titleLarge,
        iconTheme:
            IconThemeData(
          color:
              AppColors.textPrimary,
          size: 24,
        ),
      ),

      // ───────────────────────────────────────
      // Elevated Button
      // ───────────────────────────────────────

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,

          foregroundColor:
              AppColors.onPrimary,

          disabledBackgroundColor:
              AppColors.primary
                  .withOpacity(0.32),

          disabledForegroundColor:
              AppColors.onPrimary
                  .withOpacity(0.50),

          elevation: 0,

          minimumSize:
              const Size(44, 44),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppRadius.button,
            ),
          ),

          textStyle:
              AppTextStyles.button,
        ),
      ),

      // ───────────────────────────────────────
      // Outlined Button
      // ───────────────────────────────────────

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              AppColors.textPrimary,

          minimumSize:
              const Size(44, 44),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          side: BorderSide(
            color:
                AppColors.titaniumBorder
                    .withOpacity(0.65),
            width: 1,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppRadius.button,
            ),
          ),

          textStyle:
              AppTextStyles.button,
        ),
      ),

      // ───────────────────────────────────────
      // Text Button
      // ───────────────────────────────────────

      textButtonTheme:
          TextButtonThemeData(
        style:
            TextButton.styleFrom(
          foregroundColor:
              AppColors.textPrimary,

          minimumSize:
              const Size(44, 44),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),

          textStyle:
              AppTextStyles.button,
        ),
      ),

      // ───────────────────────────────────────
      // Input
      // ───────────────────────────────────────

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,

        fillColor:
            AppColors.surface,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.divider,
            width: 1.5,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.divider,
            width: 1.5,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.primary,
            width: 1.5,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.error,
            width: 1.5,
          ),
        ),

        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.error,
            width: 1.5,
          ),
        ),

        labelStyle:
            AppTextStyles.bodyMedium
                .copyWith(
          color:
              AppColors.textSecondary,
        ),

        hintStyle:
            AppTextStyles.bodyMedium
                .copyWith(
          color:
              AppColors.textDisabled,
        ),
      ),

      // ───────────────────────────────────────
      // SnackBar
      // ───────────────────────────────────────

      snackBarTheme:
          SnackBarThemeData(
        backgroundColor:
            AppColors.surface,

        contentTextStyle:
            AppTextStyles.bodyMedium,

        behavior:
            SnackBarBehavior.floating,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
        ),
      ),

      // ───────────────────────────────────────
      // Divider
      // ───────────────────────────────────────

      dividerTheme:
          const DividerThemeData(
        color:
            AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ───────────────────────────────────────
      // Icon
      // ───────────────────────────────────────

      iconTheme:
          const IconThemeData(
        color:
            AppColors.textPrimary,
        size: 24,
      ),

      // ───────────────────────────────────────
      // Bottom sheets
      // ───────────────────────────────────────

      bottomSheetTheme:
          const BottomSheetThemeData(
        backgroundColor:
            AppColors.surface,
        modalBackgroundColor:
            AppColors.surface,
        elevation: 0,
        showDragHandle: true,
      ),
    );
  }

  // ═════════════════════════════════════════════
  // LIGHT
  // ═════════════════════════════════════════════

  static ThemeData light() {
    final scheme =
        ColorScheme.light(
      primary:
          AppColors.lightPrimary,

      onPrimary:
          AppColors.lightOnPrimary,

      secondary:
          AppColors.lightSecondary,

      surface:
          AppColors.lightSurface,

      onSurface:
          AppColors.lightTextPrimary,

      error:
          AppColors.lightError,

      onError:
          AppColors.lightOnPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      fontFamily:
          AppTextStyles.fontFamily,

      scaffoldBackgroundColor:
          AppColors.lightBackground,

      colorScheme:
          scheme,

      appBarTheme:
          const AppBarTheme(
        backgroundColor:
            Colors.transparent,
        foregroundColor:
            AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            TextStyle(
          fontFamily:
              AppTextStyles.fontFamily,
          fontSize: 20,
          fontWeight:
              FontWeight.w600,
          color:
              AppColors.lightTextPrimary,
        ),
        iconTheme:
            IconThemeData(
          color:
              AppColors.lightTextPrimary,
          size: 24,
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.lightPrimary,

          foregroundColor:
              AppColors.lightOnPrimary,

          elevation: 0,

          minimumSize:
              const Size(44, 44),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppRadius.button,
            ),
          ),

          textStyle:
              AppTextStyles.button
                  .copyWith(
            color:
                AppColors.lightOnPrimary,
          ),
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              AppColors.lightTextPrimary,

          minimumSize:
              const Size(44, 44),

          side: BorderSide(
            color:
                AppColors.lightDivider,
            width: 1,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppRadius.button,
            ),
          ),

          textStyle:
              AppTextStyles.button,
        ),
      ),

      textButtonTheme:
          TextButtonThemeData(
        style:
            TextButton.styleFrom(
          foregroundColor:
              AppColors.lightTextPrimary,

          minimumSize:
              const Size(44, 44),

          textStyle:
              AppTextStyles.button,
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,

        fillColor:
            AppColors.lightSurface,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.lightDivider,
            width: 1.5,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.lightDivider,
            width: 1.5,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.lightPrimary,
            width: 1.5,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.lightError,
            width: 1.5,
          ),
        ),

        labelStyle:
            AppTextStyles.bodyMedium
                .copyWith(
          color:
              AppColors.lightTextSecondary,
        ),

        hintStyle:
            AppTextStyles.bodyMedium
                .copyWith(
          color:
              AppColors.lightTextDisabled,
        ),
      ),

      dividerTheme:
          const DividerThemeData(
        color:
            AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      iconTheme:
          const IconThemeData(
        color:
            AppColors.lightTextPrimary,
        size: 24,
      ),

      bottomSheetTheme:
          const BottomSheetThemeData(
        backgroundColor:
            AppColors.lightSurface,
        modalBackgroundColor:
            AppColors.lightSurface,
        elevation: 0,
        showDragHandle: true,
      ),
    );
  }
}
