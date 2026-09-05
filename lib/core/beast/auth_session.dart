// lib/core/auth/auth_session.dart
//
// ⚠️ STUB — لم يتم رفع هذا الملف ضمن الملفات المرسلة.
// beast_lifecycle.dart و beast_user_session.dart كلاهما يستوردانه
// ويتوقعان الواجهة أدناه. إن كان لديك تطبيق حقيقي لجلسة المستخدم
// في مكان آخر من المشروع، استبدل هذا الملف به بدلاً من استخدام هذا الـstub.

import 'package:flutter/foundation.dart';

class AuthUser {
  const AuthUser({required this.id});

  final String id;
}

class AuthSession extends ChangeNotifier {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  bool _isAuthenticated = false;
  AuthUser _currentUser = const AuthUser(id: '');

  bool get isAuthenticated => _isAuthenticated;

  AuthUser get currentUser => _currentUser;

  /// استدعها بعد نجاح تسجيل الدخول الفعلي في تطبيقك.
  void signIn(String userId) {
    _currentUser = AuthUser(id: userId);
    _isAuthenticated = true;
    notifyListeners();
  }

  /// استدعها عند تسجيل الخروج.
  void signOut() {
    _currentUser = const AuthUser(id: '');
    _isAuthenticated = false;
    notifyListeners();
  }
}
