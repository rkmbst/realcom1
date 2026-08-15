import 'package:flutter/animation.dart';

class AppMotion {
  AppMotion._();

  static const Duration micro = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration emphasized = Duration(milliseconds: 320);
  static const Duration bouncy = Duration(milliseconds: 550);

  static const Duration passiveMount =
      Duration(milliseconds: 250);

  static const Duration imageCrossfade =
      Duration(milliseconds: 200);

  static const Duration snapBackCeiling =
      Duration(milliseconds: 600);

  static const Curve microCurve = Curves.easeOut;
  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve emphasizedCurve =
      Curves.easeInOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
}
