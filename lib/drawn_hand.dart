import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'hand.dart';

/// A clock hand that is drawn with [CustomPainter]
class DrawnHand extends Hand {
  /// Create a const clock [Hand].
  ///
  /// All of the parameters are required and must not be null.
  const DrawnHand({
    @required Color color,
    @required Color colorFill,
    @required Color colorFillLight,
    @required this.thickness,
    @required double topPosition,
    @required double pointPosition,
    @required this.image,
    @required this.imageTrace,
    @required this.isHit,
  })  : assert(color != null),
        assert(colorFill != null),
        assert(colorFillLight != null),
        assert(topPosition != null),
        assert(pointPosition != null),
        assert(image != null),
        assert(imageTrace != null),
        assert(isHit != null),
        super(
          color: color,
          topPosition: topPosition,
          pointPosition: pointPosition,
          colorFill: colorFill,
          colorFillLight: colorFillLight,
        );

  /// How thick the hand should be drawn, in logical pixels.
  final double thickness;
  final ui.Image image;
  final ui.Image imageTrace;
  final bool isHit;

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
            imageTrace: imageTrace,
            isHit: isHit,
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
    this.imageTrace,
    this.isHit,
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
  ui.Image imageTrace;
  bool isHit;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(0, size.shortestSide * topPosition);
    final position = Offset(size.longestSide, size.shortestSide * topPosition);
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, position, linePaint);

    final positionFill = Offset(
        size.longestSide * pointPosition, size.shortestSide * topPosition);
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

    double pointCenterX = size.longestSide * pointPosition;
    double pointCenterY = size.shortestSide * topPosition;
    final pointCenter = Offset(pointCenterX, pointCenterY);
    final double imageSize = lineWidth * 3.6;
    paintImage(
      canvas: canvas,
      image: image,
      rect: Rect.fromCenter(
        center: pointCenter,
        width: imageSize,
        height: imageSize,
      ),
    );
    Random rand =
        Random(DateTime.now().millisecond + ((pointPosition + topPosition) * 100).floor());
    if (isHit) {
      for (var i = 0; i < 13; i++) {
        // Select random Polar coordinate
        // where theta is a random angle between 0..2*PI
        // and r is a random value between 0..radius
        double theta = rand.nextDouble() * pi * 2;
        double r = rand.nextDouble() * 100;

        // Transform the polar coordinate to cartesian (x,y)
        // and translate the center to the current mouse position
        double xPosition = pointCenterX + cos(theta) * r;
        double yPosition = pointCenterY + sin(theta) * r;
        double halfImageSize = imageSize / 2;
        if (xPosition > 0 &&
            xPosition < pointCenterX - halfImageSize &&
            yPosition > pointCenterY - halfImageSize &&
            yPosition < pointCenterY + halfImageSize) {
          final double imageSize = lineWidth * 2 * rand.nextDouble();
          final pointCenter = Offset(xPosition, yPosition);
          paintImage(
            canvas: canvas,
            image: imageTrace,
            rect: Rect.fromCenter(
              center: pointCenter,
              width: imageSize,
              height: imageSize,
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HandPainter oldDelegate) {
    return oldDelegate.lineWidth != lineWidth ||
        oldDelegate.topPosition != topPosition ||
        oldDelegate.pointPosition != pointPosition ||
        oldDelegate.image != image ||
        oldDelegate.isHit != isHit ||
        oldDelegate.color != color;
  }
}
