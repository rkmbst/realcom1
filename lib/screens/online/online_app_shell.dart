import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/question_pack.dart';
import '../../widgets/liquid_background.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import 'add_question_screen.dart';
import 'online_feed_screen.dart';

class OnlineAppShell extends StatefulWidget {
  const OnlineAppShell({
    super.key,
  });

  @override
  State<OnlineAppShell> createState() =>
      _OnlineAppShellState();
}

class _OnlineAppShellState
    extends State<OnlineAppShell> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const OnlineFeedScreen(),
      const NotificationsScreen(),
      const _ExplorePlaceholder(),
      const ProfileScreen(),
    ];
  }

  void _selectTab(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _openAddQuestion() async {
    final QuestionPack? pack =
        await Navigator.of(context).push<QuestionPack>(
      MaterialPageRoute(
        builder: (_) =>
            const AddQuestionScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (pack != null) {
      // Recreate the Feed so the newly
      // published pack appears immediately.
      setState(() {
        _pages[0] =
            const OnlineFeedScreen();
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          const LiquidBackground(),

          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          _OnlineBottomNavigation(
        currentIndex:
            _currentIndex,
        onChanged:
            _selectTab,
        onAdd:
            _openAddQuestion,
      ),
    );
  }
}

class _OnlineBottomNavigation
    extends StatelessWidget {
  const _OnlineBottomNavigation({
    required this.currentIndex,
    required this.onChanged,
    required this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum:
          const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 8,
      ),
      child: Container(
        height: 70,
        decoration:
            BoxDecoration(
          color: AppColors.surface
              .withOpacity(0.78),
          borderRadius:
              BorderRadius.circular(24),
          border: Border.all(
            color: AppColors
                .titaniumBorder
                .withOpacity(0.55),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon:
                    Icons.home_outlined,
                activeIcon:
                    Icons.home_rounded,
                label: 'الرئيسية',
                selected:
                    currentIndex == 0,
                onTap: () =>
                    onChanged(0),
              ),
            ),

            Expanded(
              child: _NavItem(
                icon: Icons
                    .notifications_outlined,
                activeIcon: Icons
                    .notifications_rounded,
                label: 'الإشعارات',
                selected:
                    currentIndex == 1,
                onTap: () =>
                    onChanged(1),
              ),
            ),

            SizedBox(
              width: 76,
              child: Center(
                child: _AddNavButton(
                  onTap: onAdd,
                ),
              ),
            ),

            Expanded(
              child: _NavItem(
                icon:
                    Icons.explore_outlined,
                activeIcon:
                    Icons.explore_rounded,
                label: 'استكشاف',
                selected:
                    currentIndex == 2,
                onTap: () =>
                    onChanged(2),
              ),
            ),

            Expanded(
              child: _NavItem(
                icon: Icons
                    .person_outline_rounded,
                activeIcon:
                    Icons.person_rounded,
                label: 'الملف',
                selected:
                    currentIndex == 3,
                onTap: () =>
                    onChanged(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem
    extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                selected
                    ? activeIcon
                    : icon,
                size: 24,
                color: selected
                    ? AppColors.primary
                    : AppColors
                        .textSecondary,
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                label,
                style:
                    AppTextStyles.caption
                        .copyWith(
                  color: selected
                      ? AppColors
                          .textPrimary
                      : AppColors
                          .textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddNavButton
    extends StatelessWidget {
  const _AddNavButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'إضافة سؤال',
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: Container(
          width: 48,
          height: 48,
          decoration:
              BoxDecoration(
            color:
                AppColors.surfaceVariant,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors
                  .titaniumBorder
                  .withOpacity(0.65),
            ),
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 26,
            color:
                AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ExplorePlaceholder
    extends StatelessWidget {
  const _ExplorePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent,
      appBar: AppBar(
        title:
            const Text('استكشاف'),
        backgroundColor:
            Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(32),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.explore_outlined,
                size: 48,
                color:
                    AppColors
                        .textSecondary,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'استكشاف',
                style:
                    AppTextStyles
                        .titleLarge,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'سنضيف هنا البحث والهاشتاقات والفئات والترند والمستخدمين المقترحين.',
                textAlign:
                    TextAlign.center,
                style:
                    AppTextStyles
                        .bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
