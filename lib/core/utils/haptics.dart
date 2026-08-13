import 'package:flutter/services.dart';

/// Safe haptic feedback helper.
class Haptics {
  static void light() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static void medium() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static void heavy() {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
