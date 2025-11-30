import 'package:flutter/material.dart';

class PagingScrollPhysics extends ScrollPhysics {
  final double itemHeight;

  const PagingScrollPhysics({required this.itemHeight, super.parent});

  @override
  PagingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PagingScrollPhysics(
      itemHeight: itemHeight,
      parent: buildParent(ancestor),
    );
  }

  double _getPage(ScrollMetrics position) {
    if (itemHeight <= 0) return 0;
    return position.pixels / itemHeight;
  }

  double _getPixels(ScrollMetrics position, double page) {
    return page * itemHeight;
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // If we're out of range and not ended back in range yet, we should just
    // defer to the parent physics.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);

    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
