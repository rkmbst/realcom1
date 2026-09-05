// lib/core/beast/beast_lifecycle.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../auth/auth_session.dart';
import 'beast.dart';

/// مدير دورة حياة 🐺 Beast.
///
/// المسؤوليات:
/// - ربط Beast بالمستخدم الحالي.
/// - تشغيل Beast بعد تسجيل الدخول.
/// - تبديل المستخدم بدون خلط ذاكرة مستخدم بآخر.
/// - تمرير lifecycle events إلى Beast.
/// - إنهاء الجلسة عند logout.
/// - ضمان عدم تشغيل أكثر من تهيئة في الوقت نفسه.
class BeastLifecycle extends ChangeNotifier
    with WidgetsBindingObserver {
  BeastLifecycle._();

  static final BeastLifecycle instance =
      BeastLifecycle._();

  final AuthSession _auth =
      AuthSession.instance;

  final BeastUltimate _beast =
      BeastUltimate();

  bool _started = false;
  bool _initializing = false;
  String? _activeUserId;

  bool get isStarted => _started;

  String? get activeUserId => _activeUserId;

  BeastUltimate get beast => _beast;

  /// ابدأ مراقبة جلسة المستخدم.
  ///
  /// استدعها مرة واحدة من bootstrap/app startup.
  void attach() {
    WidgetsBinding.instance.addObserver(this);

    _auth.addListener(_handleAuthChanged);

    unawaited(
      reconcileUser(),
    );
  }

  /// أوقف مراقبة Auth/Lifecycle.
  ///
  /// لا نستخدم dispose للـBeast نفسه هنا لأن Beast
  /// Singleton ويملك موارد طويلة العمر وسياسة lifecycle خاصة به.
  Future<void> detach() async {
    WidgetsBinding.instance.removeObserver(this);

    _auth.removeListener(_handleAuthChanged);

    if (_started &&
        _beast.ready &&
        _beast.consent == BeastConsent.granted) {
      try {
        await _beast.onBackground();
      } catch (error, stackTrace) {
        debugPrint(
          'BeastLifecycle.detach onBackground failed: '
          '$error\n$stackTrace',
        );
      }
    }

    _started = false;
    _activeUserId = null;

    notifyListeners();
  }

  void _handleAuthChanged() {
    unawaited(
      reconcileUser(),
    );
  }

  /// يجعل Beast متوافقًا مع المستخدم الحالي المسجل دخوله.
  ///
  /// لا يسمح بأكثر من تهيئة متزامنة، ولا يخلط ذاكرة مستخدم
  /// بآخر عند تبديل الحساب.
  Future<void> reconcileUser() async {
    if (_initializing) {
      return;
    }

    _initializing = true;

    try {
      if (!_auth.isAuthenticated) {
        await _stopForNoUser();
        return;
      }

      final userId = _auth.currentUser.id.trim();

      if (userId.isEmpty) {
        await _stopForNoUser();
        return;
      }

      // نفس المستخدم وBeast جاهز بالفعل: لا حاجة لإعادة التهيئة.
      if (_activeUserId == userId && _beast.ready) {
        return;
      }

      // مستخدم مختلف عن الذي كان نشطًا: يجب إغلاق الجلسة القديمة
      // أولاً لمنع خلط الذاكرة بين المستخدمين.
      if (_activeUserId != null && _activeUserId != userId) {
        await _stopForNoUser();
      }

      await _beast.init(
        userId: userId,
      );

      _activeUserId = userId;
      _started = true;

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint(
        'BeastLifecycle.reconcileUser failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _initializing = false;
    }
  }

  Future<void> _stopForNoUser() async {
    if (_activeUserId == null) {
      return;
    }

    try {
      if (_beast.ready &&
          _beast.consent == BeastConsent.granted) {
        await _beast.onBackground();
      }
    } catch (error, stackTrace) {
      debugPrint(
        'BeastLifecycle._stopForNoUser failed: '
        '$error\n$stackTrace',
      );
    }

    _activeUserId = null;
    _started = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_started || !_beast.ready) {
      return;
    }

    if (_beast.consent != BeastConsent.granted) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_beast.onForeground());
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_beast.onBackground());
        break;

      default:
        break;
    }
  }
}
