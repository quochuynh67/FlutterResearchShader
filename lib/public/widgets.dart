part of '../shady.dart';

/// A widget that continuously draws a Shady shader.
///
/// The optional [onLoaded] callback is called when the Shady instance has loaded
/// and is ready to be modified.
///
/// If [assetBundle] is omitted, the current [DefaultAssetBundle] will be used.
class ShadyCanvas extends StatefulWidget {
  final Shady _shady;
  final VoidCallback? onLoaded;
  final AssetBundle? assetBundle;

  const ShadyCanvas(
    shady, {
    Key? key,
    this.onLoaded,
    this.assetBundle,
  })  : _shady = shady,
        super(key: key);

  @override
  State<ShadyCanvas> createState() => _ShadyCanvasState();
}

class _ShadyCanvasState extends State<ShadyCanvas> with SingleTickerProviderStateMixin {
  CustomPainter painter = _defaultPainter;

  @override
  void initState() {
    super.initState();

    if (!widget._shady.ready) {
      widget._shady
          .load(widget.assetBundle ?? DefaultAssetBundle.of(context))
          .then((_) => _startShady());
    } else {
      _startShady();
    }
  }

  void _startShady() {
    setState(() {
      painter = widget._shady.painter;
    });

    if (widget.onLoaded != null) {
      widget.onLoaded!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Animation.fromValueListenable(widget._shady._notifier),
      child: CustomPaint(
        willChange: true,
        painter: widget._shady.painter,
      ),
      builder: (context, child) {
        return child!;
      },
    );
  }
}

/// An interactive version of [ShadyCanvas].
///
/// The [UniformVec2] with key [uniformVec2Key] will be
/// updated with the normalized coordinate of user interactions.
///
/// If the provided [Shady] instance has been flagged as `shaderToy`, the `iMouse`
/// uniform will be populated instead.
///
/// The optional [onInteraction] is called when an interaction happens,
/// with the same normalized coordinates.
///
/// The optional [onLoaded] callback is called when the Shady instance has loaded
/// and is ready to be modified.
///
/// If [assetBundle] is omitted, the current [DefaultAssetBundle] will be used.
class ShadyInteractive extends StatelessWidget {
  final Shady shady;
  final String? uniformVec2Key;
  final void Function(Vector2 offset)? onInteraction;
  final VoidCallback? onLoaded;

  const ShadyInteractive(
    this.shady, {
    Key? key,
    this.uniformVec2Key,
    this.onInteraction,
    this.onLoaded,
  }) : super(key: key);

  void _handleInteraction(
    BoxConstraints constraints,
    Offset position,
  ) {
    if (!shady.ready) {
      return;
    }

    Vector2 vec2 = Vector2(
      position.dx / constraints.maxWidth,
      position.dy / constraints.maxHeight,
    );

    if (shady._shaderToy) {
      shady.setUniform<Vector4>('iMouse', Vector4(vec2.x, vec2.y, 0, 0));
    } else if (uniformVec2Key != null) {
      shady.setUniform<Vector2>(uniformVec2Key!, vec2);
    }

    if (onInteraction != null) {
      onInteraction!(vec2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTertiaryTapDown: (event) => _handleInteraction(constraints, event.localPosition),
        onSecondaryTapDown: (event) => _handleInteraction(constraints, event.localPosition),
        onTapDown: (event) => _handleInteraction(constraints, event.localPosition),
        onPanStart: (event) => _handleInteraction(constraints, event.localPosition),
        onPanUpdate: (event) => _handleInteraction(constraints, event.localPosition),
        child: ShadyCanvas(shady, onLoaded: onLoaded),
      );
    });
  }
}

/// A convenience widget wrapping a [ShadyCanvas] in a [Stack].
///
/// The [child] can be wrapped in a [Positioned] to control layout.
///
/// If supplied, the [topShady] is drawn on top.
///
/// The optional [onLoaded] and [onTopLoaded] callbacks are called when the
/// corresponding Shady instances has loaded and is ready to be modified.
///
/// If [assetBundle] is omitted, the current [DefaultAssetBundle] will be used.
class ShadyStack extends StatelessWidget {
  final Widget? child;
  final Shady shady;
  final Shady? topShady;
  final VoidCallback? onLoaded;
  final VoidCallback? onTopLoaded;
  final AssetBundle? assetBundle;

  const ShadyStack({
    Key? key,
    required this.shady,
    this.topShady,
    this.child,
    this.onLoaded,
    this.onTopLoaded,
    this.assetBundle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ShadyCanvas(shady, onLoaded: onLoaded),
        ),
        if (child != null) child!,
        if (topShady != null)
          Positioned.fill(
            child: ShadyCanvas(topShady, onLoaded: onTopLoaded),
          ),
      ],
    );
  }
}
