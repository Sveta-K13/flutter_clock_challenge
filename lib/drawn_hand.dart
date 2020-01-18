// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hand.dart';

/// A clock hand that is drawn with [CustomPainter]
///
/// The hand's length scales based on the clock's size.
/// This hand is used to build the second and minute hands, and demonstrates
/// building a custom hand.
class DrawnHand extends Hand {
  /// Create a const clock [Hand].
  ///
  /// All of the parameters are required and must not be null.
  const DrawnHand({
    @required Color color,
    @required this.thickness,
    @required double size,
    @required double topPosition,
  })  : assert(color != null),
        assert(thickness != null),
        assert(size != null),
        assert(topPosition != null),
        super(
          color: color,
          size: size,
          topPosition: topPosition,
        );

  /// How thick the hand should be drawn, in logical pixels.
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _HandPainter(
            handSize: size,
            lineWidth: thickness,
            topPosition: topPosition,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// [CustomPainter] that draws a clock hand.
class _HandPainter extends CustomPainter {
  _HandPainter({
    @required this.handSize,
    @required this.lineWidth,
    @required this.topPosition,
    @required this.color,
  })  : assert(handSize != null),
        assert(lineWidth != null),
        assert(topPosition != null),
        assert(color != null),
        assert(handSize >= 0.0),
        assert(handSize <= 1.0);

  double handSize;
  double lineWidth;
  double topPosition;
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(0, topPosition); //(Offset.zero & size).center;
    final position = Offset(size.longestSide, topPosition);
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(center, position, linePaint);
  }

  @override
  bool shouldRepaint(_HandPainter oldDelegate) {
    return oldDelegate.handSize != handSize ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.topPosition != topPosition ||
        oldDelegate.color != color;
  }
}
