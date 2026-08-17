import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.onPressed,
    this.expanded = false,
  });

  final bool isFollowing;
  final VoidCallback onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: 44,
      width: expanded ? double.infinity : null,
      child: isFollowing
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(
                Icons.check_rounded,
                size: 20,
              ),
              label: const Text('تتابعه'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    AppColors.textPrimary,
                side: BorderSide(
                  color: AppColors.titaniumBorder
                      .withOpacity(0.75),
                  width: 1,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                textStyle:
                    AppTextStyles.button,
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(
                Icons.person_add_alt_1_rounded,
                size: 20,
              ),
              label: const Text('متابعة'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    AppColors.onPrimary,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                textStyle:
                    AppTextStyles.button,
              ),
            ),
    );

    return button;
  }
}
