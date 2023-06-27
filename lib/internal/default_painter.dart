part of '../shady.dart';

final _defaultPaint = Paint();

/// A painter that draws a Shady shader.
@protected
class DefaultPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.transparent, BlendMode.srcOver);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
