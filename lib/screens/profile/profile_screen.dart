hereimport 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/auth/user_directory.dart';
import '../../core/social/follow_store.dart';
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

  final _directory =
      UserDirectory.instance;

  final _followStore =
      FollowStore.instance;

  late final TabController
      _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _toggleFollow(String userId) {
    _followStore.toggleFollow(userId);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        _session.currentUser;

    final viewedUser =
        widget.userId == null ||
                widget.userId ==
                    currentUser.id
            ? currentUser
            : _directory.find(
                widget.userId!,
              );

    if (viewedUser == null) {
      return Scaffold(
        backgroundColor:
            AppColors.background,
        appBar: AppBar(
          title:
              const Text('الملف الشخصي'),
        ),
        body: const Center(
          child: Text(
            'لم يتم العثور على المستخدم.',
            style:
                AppTextStyles.bodyLarge,
          ),
        ),
      );
    }

    final isOwnProfile =
        viewedUser.id ==
            currentUser.id;

    final isFollowing =
        _followStore.isFollowing(
      viewedUser.id,
    );

    final followerCount =
        viewedUser.followersCount +
            _followStore.followerCount(
              viewedUser.id,
            );

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title:
            Text(viewedUser.username),
      ),
      body: Stack(
        children: [
          const LiquidBackground(),

          SafeArea(
            child:
                NestedScrollView(
              headerSliverBuilder:
                  (
                context,
                innerBoxIsScrolled,
              ) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
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
                                  viewedUser
                                      .avatarUrl,
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
                                  viewedUser
                                      .displayName,
                                  style:
                                      AppTextStyles
                                          .titleLarge,
                                ),

                                if (viewedUser
                                    .isVerified) ...[
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  const Icon(
                                    Icons
                                        .verified_rounded,
                                    size: 18,
                                    color:
                                        AppColors
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
                              '@${viewedUser.username}',
                              style:
                                  AppTextStyles
                                      .username,
                            ),

                            if (viewedUser
                                .bio
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(
                                height:
                                    AppSpacing.x12,
                              ),
                              Text(
                                viewedUser
                                    .bio,
                                textAlign:
                                    TextAlign
                                        .center,
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
                                      '${viewedUser.questionCount}',
                                  label:
                                      'أسئلة',
                                ),
                                _Stat(
                                  value:
                                      '$followerCount',
                                  label:
                                      'متابعون',
                                ),
                                _Stat(
                                  value:
                                      '${viewedUser.followingCount}',
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
                                    isFollowing,
                                expanded: true,
                                onPressed: () =>
                                    _toggleFollow(
                                  viewedUser.id,
                                ),
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
                            AppColors
                                .textPrimary,
                        unselectedLabelColor:
                            AppColors
                                .textSecondary,
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
              body:
                  TabBarView(
                controller:
                    _tabController,
                children: const [
                  _ProfileEmptyState(
                    text:
                        'لا توجد أسئلة بعد',
                  ),
                  _ProfileEmptyState(
                    text:
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

class _Stat
    extends StatelessWidget {
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

class _ProfileEmptyState
    extends StatelessWidget {
  const _ProfileEmptyState({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.x32,
        ),
        child: Text(
          text,
          textAlign:
              TextAlign.center,
          style:
              AppTextStyles.bodyMedium,
        ),
      ),
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
    covariant _ProfileTabsDelegate
        oldDelegate,
  ) {
    return false;
  }
}
