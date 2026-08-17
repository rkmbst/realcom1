import 'package:flutter/material.dart';

/// Aurora UI v2.1 semantic color tokens.
///
/// IMPORTANT:
/// UI code must consume semantic roles instead of raw hex values.
///
/// v2.1:
/// - Purple primary has been removed.
/// - Dark primary is broken white/silver.
/// - Light primary is graphite-silver.
/// - Dark onPrimary is near-black because primary is now light.
class AppColors {
  AppColors._();

  // ═════════════════════════════════════════════
  // Aurora Dark — default
  // ═════════════════════════════════════════════

  static const Color background =
      Color(0xFF0B0F14);

  static const Color surface =
      Color(0xFF131922);

  static const Color surfaceVariant =
      Color(0xFF1A2230);

  static const Color divider =
      Color(0xFF2A3443);

  // v2.1 — Purple removed.
  static const Color primary =
      Color(0xFFE4E6EB);

  static const Color secondary =
      Color(0xFF4CC9F0);

  static const Color like =
      Color(0xFFFF4D6D);

  static const Color success =
      Color(0xFF2ECC71);

  static const Color warning =
      Color(0xFFF4B400);

  static const Color error =
      Color(0xFFEB4D4B);

  static const Color info =
      Color(0xFF4CC9F0);

  static const Color textPrimary =
      Color(0xFFFFFFFF);

  static const Color textSecondary =
      Color(0xFFAAB2C5);

  static const Color textDisabled =
      Color(0xFF565D6B);

  // Text/icon placed on the light primary.
  static const Color onPrimary =
      Color(0xFF14161B);

  // ═════════════════════════════════════════════
  // WeLibre Titanium / component helpers
  // ═════════════════════════════════════════════

  /// Slightly softer control surface for components
  /// that should be quieter than the semantic primary.
  static const Color titanium =
      Color(0xFFD8DCE1);

  static const Color titaniumHighlight =
      Color(0xFFEEF0F3);

  static const Color titaniumBorder =
      Color(0xFF8F969F);

  static const Color onTitanium =
      Color(0xFF10131A);

  // ═════════════════════════════════════════════
  // Aurora Light
  // ═════════════════════════════════════════════

  static const Color lightBackground =
      Color(0xFFF7F8FA);

  static const Color lightSurface =
      Color(0xFFFFFFFF);

  static const Color lightSurfaceVariant =
      Color(0xFFFFFFFF);

  static const Color lightDivider =
      Color(0xFFE4E7EC);

  // v2.1 — graphite/silver primary.
  static const Color lightPrimary =
      Color(0xFF53565F);

  static const Color lightSecondary =
      Color(0xFF0FA3D9);

  static const Color lightLike =
      Color(0xFFE63950);

  static const Color lightSuccess =
      Color(0xFF1E9A56);

  static const Color lightWarning =
      Color(0xFFC98A00);

  static const Color lightError =
      Color(0xFFD93F3F);

  static const Color lightInfo =
      Color(0xFF0FA3D9);

  static const Color lightTextPrimary =
      Color(0xFF10131A);

  static const Color lightTextSecondary =
      Color(0xFF5C6370);

  static const Color lightTextDisabled =
      Color(0xFFB0B5BF);

  static const Color lightOnPrimary =
      Color(0xFFFFFFFF);

  // ═════════════════════════════════════════════
  // Glass / effects
  // ═════════════════════════════════════════════

  static const Color glassBorder =
      Color(0x2EFFFFFF);

  static const Color glassHighlight =
      Color(0x0DFFFFFF);

  static const Color lightGlassBorder =
      Color(0x1A10131A);

  static const Color lightGlassHighlight =
      Color(0x14FFFFFF);

  // ═════════════════════════════════════════════
  // Utility
  // ═════════════════════════════════════════════

  static const Color transparent =
      Colors.transparent;
}
