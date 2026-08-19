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

class VerticalFeedPhysics extends PageScrollPhysics {
  const VerticalFeedPhysics({
    super.parent,
  });

  @override
  VerticalFeedPhysics applyTo(
    ScrollPhysics? ancestor,
  ) {
    return VerticalFeedPhysics(
      parent: buildParent(ancestor),
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (position.outOfRange) {
      return super.createBallisticSimulation(
        position,
        velocity,
      );
    }

    final viewport =
        position.viewportDimension;

    if (viewport <= 0) {
      return null;
    }

    final currentPage =
        position.pixels / viewport;

    int targetPage;

    if (velocity > 300) {
      targetPage = currentPage.ceil();
    } else if (velocity < -300) {
      targetPage = currentPage.floor();
    } else {
      targetPage = currentPage.round();
    }

    final maxPage =
        (position.maxScrollExtent / viewport)
            .round();

    targetPage =
        targetPage.clamp(0, maxPage);

    final targetPixels =
        targetPage * viewport;

    if ((targetPixels - position.pixels)
            .abs() <
        toleranceFor(position).distance &&
        velocity.abs() <
            toleranceFor(position).velocity) {
      return null;
    }

    return ScrollSpringSimulation(
      AppPhysics.videoSpring,
      position.pixels,
      targetPixels,
      velocity,
      tolerance: toleranceFor(position),
    );
  }
}
