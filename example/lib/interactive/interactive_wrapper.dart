import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shady/shady.dart';
import 'package:vector_math/vector_math.dart';

class InteractiveWrapper extends StatefulWidget {
  final Shady shady;

  const InteractiveWrapper(this.shady, {super.key});

  @override
  State<InteractiveWrapper> createState() => _InteractiveWrapperState();
}

class _InteractiveWrapperState extends State<InteractiveWrapper>
    with SingleTickerProviderStateMixin {
  late DateTime lastInteraction;
  double rawIntensity = 0;
  bool flipper = false;

  bool isActivated() {
    return DateTime.now().difference(lastInteraction) < const Duration(seconds: 2);
  }

  @override
  void initState() {
    super.initState();
    lastInteraction = DateTime.now().subtract(const Duration(minutes: 1));
  }

  void onLoaded() {
    widget.shady.setTransformer<double>('intensity', (previousValue, delta) {
      rawIntensity = isActivated()
          ? min(rawIntensity + (delta.inMilliseconds / 400), 1)
          : max(rawIntensity - (delta.inMilliseconds / 400), 0);
      return Curves.easeInOutCubic.transform(rawIntensity);
    });
  }

  void onInteraction(Vector2 _) {
    lastInteraction = DateTime.now();
  }

  @override
  void dispose() {
    widget.shady.clearTransformer<double>('intensity');
    widget.shady.setUniform<double>('intensity', 0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadyInteractive(
      widget.shady,
      key: Key(widget.shady.assetName),
      uniformVec2Key: 'inputCoord',
      onInteraction: onInteraction,
      onLoaded: onLoaded,
    );
  }
}
