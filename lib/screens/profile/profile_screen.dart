import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/follow_button.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import '../../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen
    extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.userId,
  });

  final String? userId;

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _session =
      AuthSession.instance;

  late final TabController
      _tabController;

  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  Future<void> _editProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const EditProfileScreen(),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        _session.currentUser;

    final isOwnProfile =
        widget.userId == null ||
            widget.userId ==
                user.id;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title:
            Text(user.username),
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              size: 24,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const LiquidBackground(),
          SafeArea(
            child: NestedScrollView(
              headerSliverBuilder:
                  (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child:
                        Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        AppSpacing.x24,
                        AppSpacing.x16,
                        AppSpacing.x24,
                        AppSpacing.x24,
                      ),
                      child:
                          LiquidGlassContainer(
                        padding:
                            const EdgeInsets.all(
                          AppSpacing.x16,
                        ),
                        child:
                            Column(
                          children: [
                            UserAvatar(
                              imageUrl:
                                  user.avatarUrl,
                              size: 96,
                            ),

                            const SizedBox(
                              height:
                                  AppSpacing.x16,
                            ),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Text(
                                  user.displayName,
                                  style:
                                      AppTextStyles
                                          .titleLarge,
                                ),
                                if (user
                                    .isVerified) ...[
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  const Icon(
                                    Icons
                                        .verified_rounded,
                                    size: 18,
                                    color: AppColors
                                        .secondary,
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(
                              height:
                                  AppSpacing.x4,
                            ),

                            Text(
                              '@${user.username}',
                              style:
                                  AppTextStyles
                                      .username,
                            ),

                            if (user.bio
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(
                                height:
                                    AppSpacing.x12,
                              ),
                              Text(
                                user.bio,
                                textAlign:
                                    TextAlign.center,
                                style:
                                    AppTextStyles
                                        .bodyMedium,
                              ),
                            ],

                            const SizedBox(
                              height:
                                  AppSpacing.x24,
                            ),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceEvenly,
                              children: [
                                _Stat(
                                  value:
                                      '${user.questionCount}',
                                  label:
                                      'أسئلة',
                                ),
                                _Stat(
                                  value:
                                      '${user.followersCount}',
                                  label:
                                      'متابعون',
                                ),
                                _Stat(
                                  value:
                                      '${user.followingCount}',
                                  label:
                                      'يتابع',
                                ),
                              ],
                            ),

                            const SizedBox(
                              height:
                                  AppSpacing.x16,
                            ),

                            if (isOwnProfile)
                              SizedBox(
                                width:
                                    double.infinity,
                                height: 44,
                                child:
                                    OutlinedButton(
                                  onPressed:
                                      _editProfile,
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
                                      const Text(
                                    'تعديل الملف',
                                  ),
                                ),
                              )
                            else
                              FollowButton(
                                isFollowing:
                                    _isFollowing,
                                expanded: true,
                                onPressed:
                                    _toggleFollow,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate:
                        _ProfileTabsDelegate(
                      TabBar(
                        controller:
                            _tabController,
                        indicatorColor:
                            AppColors.primary,
                        indicatorWeight: 2,
                        labelColor:
                            AppColors.textPrimary,
                        unselectedLabelColor:
                            AppColors.textSecondary,
                        tabs: const [
                          Tab(
                            text: 'الأسئلة',
                          ),
                          Tab(
                            text: 'الإعجابات',
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller:
                    _tabController,
                children: [
                  _QuestionGrid(
                    emptyText:
                        'لا توجد أسئلة بعد',
                  ),
                  _QuestionGrid(
                    emptyText:
                        'لا توجد إعجابات بعد',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style:
              AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style:
              AppTextStyles.caption,
        ),
      ],
    );
  }
}

class _QuestionGrid
    extends StatelessWidget {
  const _QuestionGrid({
    required this.emptyText,
  });

  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding:
          const EdgeInsets.all(
        AppSpacing.x16,
      ),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing:
            AppSpacing.x12,
        mainAxisSpacing:
            AppSpacing.x12,
        childAspectRatio: 0.92,
      ),
      itemCount: 6,
      itemBuilder: (_, index) {
        return LiquidGlassContainer(
          borderRadius:
              AppRadius.shop,
          padding:
              const EdgeInsets.all(
            AppSpacing.x12,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width:
                      double.infinity,
                  decoration:
                      BoxDecoration(
                    color: AppColors
                        .surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.shop,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.help_outline_rounded,
                      color:
                          AppColors.textDisabled,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'سؤال ${index + 1}',
                style:
                    AppTextStyles
                        .bodyMedium,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'عام',
                style:
                    AppTextStyles.caption,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileTabsDelegate
    extends SliverPersistentHeaderDelegate {
  const _ProfileTabsDelegate(
    this.tabBar,
  );

  final TabBar tabBar;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color:
          AppColors.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(
    covariant _ProfileTabsDelegate oldDelegate,
  ) {
    return false;
  }
}
