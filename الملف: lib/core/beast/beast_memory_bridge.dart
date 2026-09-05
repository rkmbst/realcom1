// lib/core/beast/beast_memory_bridge.dart

import 'beast_persistence.dart';
import 'beast_user_scope.dart';

class BeastMemoryBridge {
  BeastMemoryBridge({
    required BeastPersistence persistence,
  }) : _persistence = persistence;

  final BeastPersistence _persistence;

  BeastUserScope? _scope;

  BeastUserScope? get scope => _scope;

  bool get hasScope =>
      _scope != null &&
      _scope!.isValid;

  void bindUser(
    String userId,
  ) {
    final scope =
        BeastUserScope(
      userId: userId,
    );

    if (!scope.isValid) {
      _scope = null;
      return;
    }

    _scope = scope;
  }

  void clearUser() {
    _scope = null;
  }

  Future<Map<String, dynamic>?>
      load() async {
    final scope = _scope;

    if (scope == null ||
        !scope.isValid) {
      return null;
    }

    return _persistence.load(
      scope,
    );
  }

  Future<void> deleteCurrentUser() async {
    final scope = _scope;

    if (scope == null ||
        !scope.isValid) {
      return;
    }

    await _persistence.delete(
      scope,
    );
  }
}
