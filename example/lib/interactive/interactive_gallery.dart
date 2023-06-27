import 'package:flutter/material.dart';
import 'package:shady_example/button.dart';
import 'package:shady_example/interactive/interactive_wrapper.dart';

import 'interactive_shaders.dart';

class ShadyInteractives extends StatefulWidget {
  final VoidCallback onBack;
  const ShadyInteractives({required this.onBack, super.key});

  @override
  State<ShadyInteractives> createState() => _ShadyInteractivesState();
}

class _ShadyInteractivesState extends State<ShadyInteractives> {
  var _index = 0;

  void _nextShader() {
    setState(() => _index = (_index + 1) % interactiveShaders.length);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveWrapper(
              interactiveShaders[_index],
              key: Key(interactiveShaders[_index].assetName),
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
