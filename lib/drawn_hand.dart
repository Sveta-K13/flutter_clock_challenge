// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;
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
    @required Color colorFill,
    @required Color colorFillLight,
    @required this.thickness,
    @required double size,
    @required double topPosition,
    @required double pointPosition,
    this.image,
  })  : assert(color != null),
        assert(thickness != null),
        assert(size != null),
        assert(topPosition != null),
        assert(pointPosition != null),
        super(
          color: color,
          size: size,
          topPosition: topPosition,
          pointPosition: pointPosition,
          colorFill: colorFill,
          colorFillLight: colorFillLight,
        );

  /// How thick the hand should be drawn, in logical pixels.
  final double thickness;
  final ui.Image image;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _HandPainter(
            lineWidth: thickness,
            topPosition: topPosition,
            pointPosition: pointPosition,
            color: color,
            colorFill: colorFill,
            colorFillLight: colorFillLight,
            image: image,
          ),
        ),
      ),
    );
  }
}

/// [CustomPainter] that draws a clock hand.
class _HandPainter extends CustomPainter {
  _HandPainter({
    @required this.lineWidth,
    @required this.topPosition,
    @required this.pointPosition,
    @required this.color,
    @required this.colorFill,
    @required this.colorFillLight,
    this.image,
  })  : assert(lineWidth != null),
        assert(topPosition != null),
        assert(pointPosition != null),
        assert(color != null);

  double lineWidth;
  double topPosition;
  double pointPosition;
  Color color;
  Color colorFill;
  Color colorFillLight;
  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(0, size.shortestSide * topPosition);
    final position = Offset(size.longestSide, size.shortestSide * topPosition);
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, position, linePaint);

    final positionFill = Offset(size.longestSide * pointPosition, size.shortestSide * topPosition);
    final linePaintFill = Paint()
      ..shader = LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[colorFill, colorFillLight],
                  stops: <double>[0.5, 1],
                ).createShader(Rect.fromPoints(Offset.zero, positionFill))
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, positionFill, linePaintFill);

    final pointPaint = Paint()
      ..color = colorFill
      ..style = PaintingStyle.fill;

    final point = Offset(size.longestSide * pointPosition, size.shortestSide * topPosition);
    canvas.drawCircle(point, 30, pointPaint);
    final pointTopLeft = Offset(size.longestSide * pointPosition - 36, size.shortestSide * topPosition - 36);
    canvas.drawImage(image, pointTopLeft, Paint());
  }

  @override
  bool shouldRepaint(_HandPainter oldDelegate) {
    return oldDelegate.lineWidth != lineWidth ||
        oldDelegate.topPosition != topPosition ||
        oldDelegate.pointPosition != pointPosition ||
        oldDelegate.image != image ||
        oldDelegate.color != color;
  }
}
