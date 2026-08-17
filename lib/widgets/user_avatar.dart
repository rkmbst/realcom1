import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.size = 88,
    this.showBorder = true,
  });

  final String? imageUrl;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final avatar = ClipOval(
      child: Container(
        width: size,
        height: size,
        color: AppColors.surfaceVariant,
        child: imageUrl == null ||
                imageUrl!.trim().isEmpty
            ? Icon(
                Icons.person_outline_rounded,
                size: size * 0.46,
                color: AppColors.textSecondary,
              )
            : Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) {
                  return Icon(
                    Icons.person_outline_rounded,
                    size: size * 0.46,
                    color:
                        AppColors.textSecondary,
                  );
                },
              ),
      ),
    );

    if (!showBorder) {
      return avatar;
    }

    return Container(
      width: size + 4,
      height: size + 4,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: avatar,
    );
  }
}
