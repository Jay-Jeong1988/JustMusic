import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class CustomPageScrollPhysics extends ScrollPhysics {

  const CustomPageScrollPhysics({ScrollPhysics parent});

  @override
  CustomPageScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomPageScrollPhysics(parent: buildParent(ancestor));
  }
//  @override
//  double get minFlingVelocity => 0.0;

//  double get dragStartDistanceMotionThreshold => 800;

//  @override
//  bool shouldAcceptUserOffset(ScrollMetrics position) => false;
//
//  @override
//  bool get allowImplicitScrolling => false;

}

class CustomSimulation extends Simulation {
  final double initialPosition;
  final double velocity;

  CustomSimulation({this.initialPosition, this.velocity});

  @override
  double x(double time) {
    return null;
  }

  @override
  double dx(double time) {
    return velocity;
  }

  @override
  bool isDone(double time) {
    return false;
  }
}


class CustomScrollPhysics extends ScrollPhysics {

  const CustomScrollPhysics({ScrollPhysics parent});

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }
//  @override
//  double get minFlingVelocity => 0.0;

  double get dragStartDistanceMotionThreshold => 800;

//  @override
//  bool shouldAcceptUserOffset(ScrollMetrics position) => false;
//
//  @override
//  bool get allowImplicitScrolling => false;

}