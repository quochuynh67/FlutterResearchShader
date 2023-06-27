library shady;

import 'dart:async';
import 'dart:convert';
import 'dart:ui' hide Color;
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

part 'public/descriptors.dart';
part 'public/widgets.dart';
part 'internal/default_image.dart';
part 'internal/uniforms.dart';
part 'internal/painter.dart';
part 'internal/default_painter.dart';

final _shaderCache = <String, FragmentShader>{};
Image? _defaultImage;
CustomPainter _defaultPainter = DefaultPainter();

final _shaderToyUniforms = [
  UniformVec3(key: 'iResolution', transformer: UniformVec3.resolution),
  UniformFloat(key: 'iTime', transformer: UniformFloat.secondsPassed),
  UniformFloat(key: 'iTimeDelta', transformer: UniformFloat.frameDelta),
  UniformFloat(key: 'iFrameRate', transformer: UniformFloat.frameRate),
  UniformVec4(key: 'iMouse'),
];

final _shaderToySamplers = [
  TextureSampler(key: 'iChannel0'),
  TextureSampler(key: 'iChannel1'),
  TextureSampler(key: 'iChannel2')
];

/// Transformer function that generates a new value
/// based on the [previousValue] one and a [delta] duration.
typedef UniformTransformer<T> = T Function(T previousValue, Duration delta);

/// A mapping of user-created shaders and ways to manipulate them.
class Shady {
  final String _assetName;
  String get assetName => _assetName;

  BlendMode _blendMode = BlendMode.srcOver;
  final _uniformDescriptions = <UniformValue>[];
  final _samplerDescriptions = <TextureSampler>[];
  final _uniforms = <String, UniformInstance>{};
  final _samplers = <String, TextureInstance>{};
  final _notifier = ValueNotifier(false);

  FragmentShader? _shader;

  Paint _paint = Paint();
  Paint get paint => _paint;

  CustomPainter _painter = _defaultPainter;
  CustomPainter get painter => _painter;

  var _updateQueued = false;
  var _readying = false;

  final bool _shaderToy;

  var _ready = false;
  bool get ready => _ready;

  /// Creates a new [Shady] instance.
  ///
  /// [Shady] facilitates interaction with the provided shader
  /// program at [assetName], according to the provided
  /// [samplers] and [uniforms].
  ///
  /// If you are painting the shader without using the widgets
  /// provided by the shady library, you must call [load]
  /// before use.
  ///
  /// Once loaded, a [Shady] instance can be reused (although
  /// the uniform values will be shared).
  ///
  /// To get a fresh copy with its own uniform values, you can call the
  /// [copy] method of an existing instance.
  Shady({
    required String assetName,
    List<TextureSampler>? samplers,
    List<UniformValue>? uniforms,
    BlendMode? blendMode,
    bool? shaderToy,
  })  : _assetName = assetName,
        _shaderToy = shaderToy ?? false,
        _blendMode = blendMode ?? BlendMode.srcOver {
    _samplerDescriptions.addAll(samplers ?? <TextureSampler>[]);
    _uniformDescriptions.addAll(uniforms ?? <UniformValue>[]);
  }

  /// Parses the previously provided descriptions and initializes the
  /// [FragmentProgram].
  ///
  /// This is handled automatically by the widgets provided by the shady library.
  /// Calling it is only required if you are using this [Shady] for painting manually.
  ///
  /// Providing an [assetBundle] is optional. If omitted, [rootBundle] will be used.
  Future<void> load([AssetBundle? assetBundle]) async {
    if (_ready || _readying) return;
    _readying = true;

    final actualAssetBundle = assetBundle ?? rootBundle;

    _defaultImage ??= await getDefaultImage();
    if (!_shaderCache.containsKey(_assetName)) {
      final program = await FragmentProgram.fromAsset(_assetName);
      _shaderCache[_assetName] = program.fragmentShader();
    }

    _shader = _shaderCache[_assetName];

    _initializeUniforms();
    _initializeSamplers(actualAssetBundle);

    _readying = false;
    _ready = true;

    flush();

    _paint = Paint()
      ..shader = _shader!
      ..blendMode = _blendMode;

    _painter = ShadyPainter(this);
  }

  /// Constructs a copy of this [Shady] instance.
  Shady copy() {
    return Shady(
      assetName: _assetName,
      samplers: _samplerDescriptions,
      shaderToy: _shaderToy,
      uniforms: _uniformDescriptions,
      blendMode: _blendMode,
    );
  }

  void _initializeUniforms() {
    final expandedUniformDescriptions = [
      ...(_shaderToy ? _shaderToyUniforms : []),
      ..._uniformDescriptions,
    ];

    for (final uniformDescription in (expandedUniformDescriptions)) {
      if (uniformDescription is UniformValue<double>) {
        _uniforms[uniformDescription.key] = UniformFloatInstance(uniformDescription);
      } else if (uniformDescription is UniformValue<Vector2>) {
        _uniforms[uniformDescription.key] = UniformVec2Instance(uniformDescription);
      } else if (uniformDescription is UniformValue<Vector3>) {
        _uniforms[uniformDescription.key] = UniformVec3Instance(uniformDescription);
      } else if (uniformDescription is UniformValue<Vector4>) {
        _uniforms[uniformDescription.key] = UniformVec4Instance(uniformDescription);
      } else {
        throw Exception(
          'Unable to load: unsupported uniform type: '
          '${uniformDescription.runtimeType}',
        );
      }

      var instance = _uniforms[uniformDescription.key]!;
      instance.notifier.addListener(update);
    }
  }

  void _initializeSamplers(AssetBundle assetBundle) {
    final expandedSamplerDescriptions = <TextureSampler>[
      ...(_shaderToy ? _shaderToySamplers : []),
      ..._samplerDescriptions,
    ];

    for (final textureDescription in expandedSamplerDescriptions) {
      final instance = TextureInstance(assetBundle, textureDescription, _defaultImage!);
      _samplers[instance.key] = instance;
      instance.notifier.addListener(update);
    }
  }

  /// Sets the [asset] image to be used by the texture sampler with key [samplerKey].
  void setTexture(String samplerKey, String assetKey) {
    assert(_ready, 'setTexture was called before Shady instance was loaded');

    try {
      final sampler = _samplers[samplerKey];
      sampler!.load(assetKey);
    } catch (e) {
      throw Exception('Texture sampler with key "$samplerKey" not found.');
    }
  }

  /// Sets the [blendMode] used for painting this shader.
  void setBlendMode(BlendMode blendMode) {
    assert(_ready, 'setBlendMode was called before Shady instance was loaded');

    _blendMode = blendMode;
    _paint.blendMode = blendMode;
  }

  /// Retrieve the image used by the sampler with key [samplerKey].
  Image? getImage(String samplerKey) {
    assert(_ready, 'getImage was called before Shady instance was loaded');

    try {
      final texture = _samplers[samplerKey];
      return texture!.notifier.value;
    } catch (e) {
      throw Exception('Sampler with key "$samplerKey" not found.');
    }
  }

  /// Immediately set the uniform value of the uniform with key [uniformKey].
  void setUniform<T>(String uniformKey, T value) {
    assert(_ready, 'setUniform was called before Shady instance was loaded');

    try {
      final uniform = _uniforms[uniformKey] as UniformInstance<T>;
      uniform.notifier.value = value;
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }

  /// Sets the [transformer] to be used by the uniform with key [uniformKey].
  void setTransformer<T>(String uniformKey, UniformTransformer<T> transformer) {
    assert(_ready, 'setTransformer was called before Shady instance was loaded');

    try {
      final uniform = _uniforms[uniformKey] as UniformInstance<T>;
      uniform.setTransformer(transformer);
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }

  /// Clears the [transformer] for [uniformKey].
  void clearTransformer<T>(String uniformKey) {
    assert(_ready, 'clearTransformer was called before Shady instace was loaded');

    try {
      final uniform = (_uniforms[uniformKey] as UniformInstance<T>);
      uniform.setTransformer((x, y) => x);
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" not found.');
    }
  }

  /// Retrieve the uniform value of the uniform with key [uniformKey].
  T getUniform<T>(String uniformKey) {
    assert(_ready, 'getUniform was called before Shady instance was loaded');
    try {
      final uniform = _uniforms[uniformKey] as UniformInstance<T>;
      return uniform.notifier.value;
    } catch (e) {
      throw Exception('Uniform with key "$uniformKey" and type "$T" not found.');
    }
  }

  /// Schedules an update of the uniform values and a repaint.
  ///
  /// While the internal [_refs] are over 0, this
  /// starts a loop that will repeat indefinitely once every frame.
  ///
  /// This call is idempotent, and will not trigger extraneous
  /// updates, loop triggers or repaints.
  void update() {
    assert(_ready, 'update was called before Shady instance was loaded');

    if (_updateQueued) return;
    SchedulerBinding.instance.addPostFrameCallback(_internalUpdate);
    _updateQueued = true;
  }

  /// Flushes this instances values to the (possibly shared) shader program.
  /// Primarily called by the [ShadyPainter] before drawing.
  ///
  /// Do not use unless you know what you are doing.
  void flush() {
    assert(_ready, 'flush was called before Shady instance was loaded');

    var i = 0;
    for (final uniform in _uniforms.values) {
      i = uniform.apply(_shader!, i);
    }

    i = 0;
    for (final sampler in _samplers.values) {
      i = sampler.apply(_shader!, i);
    }
  }

  void _internalUpdate(Duration ts) {
    assert(_ready, '_internalUpdate was called before Shady instane was loaded');

    for (var x in _uniforms.values) {
      x.update(ts);
    }

    _updateQueued = false;
    _notifier.value = !_notifier.value;
  }
}
