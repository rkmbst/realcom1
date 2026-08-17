class Follow {
  const Follow({
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  final String followerId;
  final String followingId;
  final DateTime createdAt;
}
