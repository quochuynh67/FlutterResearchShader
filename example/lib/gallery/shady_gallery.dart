import 'package:flutter/material.dart';
import 'package:shady/shady.dart';
import 'package:shady_example/gallery/gallery_shaders.dart';

import '../button.dart';

class ShadyGallery extends StatefulWidget {
  final VoidCallback onBack;

  const ShadyGallery({
    super.key,
    required this.onBack,
  });

  @override
  State<ShadyGallery> createState() => _ShadyGalleryState();
}

class _ShadyGalleryState extends State<ShadyGallery> {
  var _zoomOut = 0;
  var _index = 0;

  void _nextShader() {
    setState(() => _index = (_index + 1) % galleryShaders.length);
  }

  @override
  Widget build(BuildContext context) {
    Widget canvas = ShadyCanvas(
      galleryShaders[_index],
      key: Key(galleryShaders[_index].assetName),
    );

    if (_zoomOut == 1) {
      canvas = Center(child: SizedBox(height: 460, width: 340, child: canvas));
    } else if (_zoomOut == 2) {
      canvas = Center(child: SizedBox(height: 160, width: 240, child: canvas));
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              child: canvas,
              onTap: () => setState(() => _zoomOut = ((_zoomOut < 2) ? _zoomOut + 1 : 0)),
            ),
          ),
          Positioned(
            top: 40,
            left: 40,
            child: ShadyButton(
              onTap: widget.onBack,
              text: 'BACK',
              icon: Icons.close_rounded,
            ),
          ),
          Positioned(
            bottom: 40,
            right: 40,
            child: ShadyButton(
              onTap: _nextShader,
              text: 'NEXT',
            ),
          ),
        ],
      ),
    );
  }
}
