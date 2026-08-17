class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    this.avatarUrl,
    this.followersCount = 0,
    this.followingCount = 0,
    this.questionCount = 0,
    this.isVerified = false,
  });

  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String? avatarUrl;

  final int followersCount;
  final int followingCount;
  final int questionCount;

  final bool isVerified;

  AppUser copyWith({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    int? followersCount,
    int? followingCount,
    int? questionCount,
    bool? isVerified,
  }) {
    return AppUser(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followersCount:
          followersCount ?? this.followersCount,
      followingCount:
          followingCount ?? this.followingCount,
      questionCount:
          questionCount ?? this.questionCount,
      isVerified:
          isVerified ?? this.isVerified,
    );
  }
}
