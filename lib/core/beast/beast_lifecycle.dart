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
  /// Singleton ويملك موارد
