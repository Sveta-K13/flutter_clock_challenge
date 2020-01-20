import 'package:flutter/material.dart';

/// A base class for an analog clock hand-drawing widget.
abstract class Hand extends StatelessWidget {
  /// Create a const clock [Hand].
  ///
  /// All of the parameters are required and must not be null.
  const Hand({
    @required this.color,
    @required this.colorFill,
    @required this.colorFillLight,
    @required this.topPosition,
    @required this.pointPosition,
  })  : assert(color != null),
        assert(colorFill != null),
        assert(colorFillLight != null),
        assert(topPosition != null),
        assert(pointPosition != null);

  /// Hand colors
  final Color color;
  final Color colorFill;
  final Color colorFillLight;

  /// Part of canvas for hand line
  final double topPosition;

  /// Part of line for time point
  final double pointPosition;
}
