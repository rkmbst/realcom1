// lib/core/beast/beast_user_scope.dart

/// هوية ونطاق ذاكرة Beast لمستخدم واحد.
///
/// كل ما يُخزن أو يُستعاد من ذاكرة المستخدم يجب أن يكون
/// مرتبطًا بهذا الـscope.
class BeastUserScope {
  const BeastUserScope({
    required this.userId,
  });

  final String userId;

  String get normalizedUserId =>
      userId.trim();

  bool get isValid =>
      normalizedUserId.isNotEmpty;

  /// مفتاح تخزين معزول عن بقية المستخدمين.
  String key(String name) {
    final cleanName = name
        .trim()
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z0-9_]+'),
          '_',
        );

    final cleanUser = normalizedUserId
        .replaceAll(
          RegExp(r'[^a-zA-Z0-9_-]+'),
          '_',
        );

    return 'beast:user:$cleanUser:$cleanName';
  }

  @override
  bool operator ==(
    Object other,
  ) {
    return other is BeastUserScope &&
        other.normalizedUserId ==
            normalizedUserId;
  }

  @override
  int get hashCode =>
      normalizedUserId.hashCode;

  @override
  String toString() =>
      'BeastUserScope($normalizedUserId)';
}
