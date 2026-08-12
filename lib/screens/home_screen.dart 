import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/glass_button.dart';
import '../widgets/liquid_background.dart';
import '../widgets/liquid_glass_container.dart';
import 'local/local_players_screen.dart';
import 'online/online_feed_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const LiquidBackground(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LiquidGlassContainer(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.casino_outlined,
                            size: 56,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'عجلة الأسئلة',
                            style: AppTextStyles.displayLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أونلاين بالسحب، أو محلي مع الأصدقاء',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    GlassButton(
                      text: 'التصفح الأونلاين',
                      icon: Icons.swipe_outlined,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OnlineFeedScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    GlassButton(
                      text: 'الوضع المحلي',
                      icon: Icons.people_outline,
                      isPrimary: false,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LocalPlayersScreen(),
                          ),
                        );
                      },
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
