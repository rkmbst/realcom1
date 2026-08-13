import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Controls the ambient background color across the app.
class AmbientColorController extends ChangeNotifier {
  Color _primaryOrbColor = AppColors.primary;
  Color _secondaryOrbColor = AppColors.secondary;

  Color get primaryOrbColor => _primaryOrbColor;
  Color get secondaryOrbColor => _secondaryOrbColor;

  /// Set a specific ambient color (e.g., from a selected question category).
  void setColor(Color color) {
    _primaryOrbColor = color;
    _secondaryOrbColor = color.withOpacity(0.6);
    notifyListeners();
  }

  /// Reset to the default Aurora colors.
  void reset() {
    _primaryOrbColor = AppColors.primary;
    _secondaryOrbColor = AppColors.secondary;
    notifyListeners();
  }
}
