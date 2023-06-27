import 'package:shady/shady.dart';

final galleryShaders = [
  // Test shaders

  Shady(assetName: 'assets/shaders/test.frag',
    uniforms: [
      UniformFloat(
          key: 'transitionValue',
          transformer: (previousValue, deltaDuration) {
            double newVal  = previousValue + (deltaDuration.inMilliseconds / 1000);
            if(newVal > 1.0) {
              newVal = 1.0;
            }
            return newVal;
          }
      ),
      UniformVec3(
        key: 'resolution',
        transformer: UniformVec3.resolution,
      ),
    ],
    samplers: [
      TextureSampler(
        key: 'sampler1',
        asset: 'assets/textures/cat.png',
      ),
      TextureSampler(
        key: 'sampler2',
        asset: 'assets/textures/dash.png',
      ),
    ],
  ),

  // ShaderToy shaders
  Shady(assetName: 'assets/shaders/st3.frag', shaderToy: true),
  Shady(assetName: 'assets/shaders/st0.frag', shaderToy: true),
  Shady(assetName: 'assets/shaders/st2.frag', shaderToy: true),
  Shady(assetName: 'assets/shaders/st4.frag', shaderToy: true),
  Shady(assetName: 'assets/shaders/st6.frag', shaderToy: true),
  Shady(assetName: 'assets/shaders/st7.frag', shaderToy: true),
  Shady(assetName: 'assets/shaders/st8.frag', shaderToy: true),
  Shady(assetName: 'assets/shaders/st9.frag', shaderToy: true),
  Shady(assetName: 'assets/shaders/st5.frag', shaderToy: true),
  Shady(assetName: 'assets/shaders/st1.frag', shaderToy: true),

  // Image shaders
  Shady(
    assetName: 'assets/shaders/img0.frag',
    uniforms: [
      UniformFloat(
        key: 'time',
        transformer: UniformFloat.secondsPassed,
      ),
      UniformVec3(
        key: 'resolution',
        transformer: UniformVec3.resolution,
      ),
    ],
    samplers: [
      TextureSampler(
        key: 'cat',
        asset: 'assets/textures/cat.png',
      ),
    ],
  ),
];