import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isPrimary = true,
  });

  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final button = isPrimary
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon != null
                ? Icon(
                    icon,
                    size: 20,
                  )
                : const SizedBox.shrink(),
            label: Text(text),
            style: ElevatedButton.styleFrom(
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
                  AppTextStyles.button
                      .copyWith(
                color:
                    AppColors.onPrimary,
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon != null
                ? Icon(
                    icon,
                    size: 20,
                  )
                : const SizedBox.shrink(),
            label: Text(text),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  Colors.transparent,
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
          );

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}
