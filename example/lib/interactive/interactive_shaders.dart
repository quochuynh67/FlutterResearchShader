import 'package:shady/shady.dart';

final interactiveShaders = [
  Shady(
    assetName: 'assets/shaders/it0.frag',
    uniforms: [
      UniformFloat(key: 'time', transformer: UniformFloat.secondsPassed),
      UniformVec3(key: 'resolution', transformer: UniformVec3.resolution),
      UniformVec2(key: 'inputCoord'),
      UniformFloat(key: 'intensity', initialValue: 0)
    ],
  ),
  Shady(
    assetName: 'assets/shaders/it1.frag',
    uniforms: [
      UniformFloat(key: 'time', transformer: UniformFloat.secondsPassed),
      UniformVec3(key: 'resolution', transformer: UniformVec3.resolution),
      UniformVec2(key: 'inputCoord'),
      UniformFloat(key: 'intensity', initialValue: 0)
    ],
  ),
];
