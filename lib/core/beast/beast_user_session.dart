// lib/core/beast/beast_user_session.dart

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../auth/auth_session.dart';
import 'beast.dart';

/// يربط هوية المستخدم بدورة حياة Beast.
///
/// BeastUltimate نفسه مسؤول عن lifecycle الخاص بالتطبيق.
/// هذا المدير مسؤول عن:
/// - مراقبة المستخدم الحالي.
/// - تشغيل Beast للمستخدم المسجل.
/// - منع تهيئة مكررة.
/// - إنهاء session عند تسجيل الخروج.
/// - منع خلط هوية المستخدم مع session أخرى.
class BeastUserSession extends ChangeNotifier {
  BeastUserSession._();

  static final BeastUserSession instance =
      BeastUserSession._();

  final AuthSession _auth =
      AuthSession.instance;

  final BeastUltimate _beast =
      BeastUltimate();

  bool _attached = false;
  bool _syncing = false;

  String? _boundUserId;

  bool get attached => _attached;

  String? get boundUserId => _boundUserId;

  BeastUltimate get beast => _beast;

  /// يبدأ مراقبة AuthSession.
  ///
  /// يجب استدعاؤها مرة واحدة أثناء bootstrap.
  void attach() {
    if (_attached) {
      return;
    }

    _attached = true;

    _auth.addListener(
      _onAuthChanged,
    );

    unawaited(
      reconcile(),
    );
  }

  /// يوقف مراقبة AuthSession.
  Future<void> detach() async {
    if (!_attached) {
      return;
    }

    _auth.removeListener(
      _onAuthChanged,
    );

    _attached = false;

    await logout();

    notifyListeners();
  }

  void _onAuthChanged() {
    unawaited(
      reconcile(),
    );
  }

  /// يجعل Beast متوافقًا مع المستخدم الحالي.
  Future<void> reconcile() async {
    if (_syncing) {
      return;
    }

    _syncing = true;

    try {
      if (!_auth.isAuthenticated) {
        await logout();
        return;
      }

      final userId =
          _auth.currentUser.id.trim();

      if (userId.isEmpty) {
        await logout();
        return;
      }

      // نفس المستخدم: لا حاجة لتهيئة جديدة.
      if (_boundUserId == userId &&
          _beast.ready) {
        return;
      }

      // لدينا مستخدم آخر.
      //
      // لا نحاول init() فوق instance جاهزة لأن BeastUltimate
      // يرفض إعادة التهيئة أثناء _ready == true.
      if (_boundUserId != null &&
          _boundUserId != userId) {
        await logout();
      }

      await login(userId);
    } catch (error, stackTrace) {
      debugPrint(
        'BeastUserSession.reconcile failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _syncing = false;
    }
  }

  /// يربط Beast بالمستخدم.
  Future<void> login(
    String userId,
  ) async {
    final normalized =
        userId.trim();

    if (normalized.isEmpty) {
      return;
    }

    if (_boundUserId == normalized &&
        _beast.ready) {
      return;
    }

    if (_beast.ready &&
        _boundUserId == null) {
      debugPrint(
        'Beast is already initialized without a bound user.',
      );
      return;
    }

    try {
      await _beast.init(
        userId: normalized,
      );

      _boundUserId = normalized;

      // التطوير فقط.
      //
      // لاحقًا تُربط هذه القيمة بموافقة المستخدم
      // في شاشة الخصوصية/الإعدادات.
      if (_beast.consent !=
          BeastConsent.granted) {
        await _beast.setConsent(
          BeastConsent.granted,
        );
      }

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint(
        'BeastUserSession.login failed: '
        '$error\n$stackTrace',
      );
    }
  }

  /// تسجيل خروج منطقي من طبقة المستخدم.
  ///
  /// لا يستدعي dispose() هنا، لأن BeastUltimate يحتوي
  /// على موارد طويلة العمر وسياسة lifecycle خاصة به.
  ///
  /// دعم تبديل المستخدم بالكامل سيكون في خطوة لاحقة
  /// بإضافة user-scope/reset آمن داخل النواة نفسها.
  Future<void> logout() async {
    if (_boundUserId == null) {
      return;
    }

    try {
      if (_beast.ready &&
          _beast.consent ==
              BeastConsent.granted) {
        await _beast.onBackground();
      }
    } catch (error, stackTrace) {
      debugPrint(
        'BeastUserSession.logout background failed: '
        '$error\n$stackTrace',
      );
    }

    _boundUserId = null;

    notifyListeners();
  }
}
