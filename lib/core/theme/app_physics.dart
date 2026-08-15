import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

class AppPhysics {
  AppPhysics._();

  static const Duration hardCeiling =
      Duration(milliseconds: 600);

  static const SpringDescription snapBackSpring =
      SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 20,
  );

  static const SpringDescription videoSpring =
      SpringDescription(
    mass: 1,
    stiffness: 180,
    damping: 22,
  );

  static const SpringDescription lightSpring =
      SpringDescription(
    mass: 1,
    stiffness: 220,
    damping: 22,
  );

  static const ScrollPhysics storyPhysics =
      BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );
}
