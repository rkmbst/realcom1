import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../screens/profile/profile_screen.dart';

class SocialUserName extends StatelessWidget {
  const SocialUserName({
    super.key,
    required this.userId,
    required this.userName,
    this.color,
    this.fontWeight,
  });

  final String userId;
  final String userName;
  final Color? color;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(
              userId: userId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
        child: Text(
          '@$userName',
          style: AppTextStyles.username.copyWith(
            color: color ?? AppColors.primary,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
