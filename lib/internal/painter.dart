part of '../shady.dart';

/// A painter that draws a Shady shader.
@protected
class ShadyPainter extends CustomPainter {
  Size _lastSize = Size.zero;
  final Shady _shady;

  ShadyPainter(Shady shady)
      : _shady = shady,
        super(repaint: shady._notifier);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    if (!_shady.ready) {
      canvas.drawRect(rect, Paint());
      return;
    }

    if (size != _lastSize) {
      _lastSize = size;
      for (final uniform in _shady._uniforms.values) {
        if (uniform is UniformVec3Instance && uniform.isResolution) {
          uniform.notifier.value = Vector3(size.width, size.height, 0);
        }
      }
    }

    _shady.update();
    _shady.flush();

    canvas.drawRect(rect, _shady.paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
