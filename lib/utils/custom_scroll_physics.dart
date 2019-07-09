import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class CustomScrollPhysics extends ScrollPhysics {

  CustomScrollPhysics({ScrollPhysics parent}){}

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    if (parent == null)
      print("hello");
      return false;
  }

  @override
  bool get allowImplicitScrolling => false;
}