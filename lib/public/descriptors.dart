part of '../shady.dart';

/// A description of a `uniform sampler2D` in the shader program.
///
/// The [key] is an arbitrary key for retrieving or setting the texture being sampled.
/// If provided, Shady will load and use the image at [asset].
class TextureSampler {
  final String key;
  final String? asset;

  TextureSampler({
    required this.key,
    this.asset,
  });
}

@protected
abstract class UniformValue<T> {
  final String key;
  final T initialValue;
  final UniformTransformer<T> transformer;

  UniformValue({
    required this.key,
    required this.initialValue,
    UniformTransformer<T>? transformer,
  }) : transformer = transformer ?? ((a, b) => a);
}

/// A description of a `uniform float` in the shader program.
///
/// The [key] is an arbitrary key for retrieving or setting this value.
/// [transformer] is an optional function that takes the previous value and a delta time to return a new value.
class UniformFloat extends UniformValue<double> {
  UniformFloat({
    required super.key,
    super.transformer,
    super.initialValue = 0,
  });

  /// A [UniformTransformer] that will inject the shaders total lifetime in seconds into a float uniform.
  static double secondsPassed(double prev, Duration delta) {
    return prev += (delta.inMilliseconds / 1000);
  }

  /// A [UniformTransformer] that will inject the delta time since last frame into a float uniform.
  static double frameDelta(double prev, Duration delta) {
    return (delta.inMilliseconds / 1000);
  }

  /// A [UniformTransformer] that will inject the current frame rate into a float uniform.
  static double frameRate(double prev, Duration delta) {
    return (delta.inMilliseconds / 1000) / 1;
  }
}

/// A description of a `uniform vec2` in the shader program.
///
/// The [key] is an arbitrary key for retrieving or setting this value.
/// [transformer] is an optional function that takes the previous value and a delta time to return a new value.
class UniformVec2 extends UniformValue<Vector2> {
  UniformVec2({
    required super.key,
    super.transformer,
    Vector2? initialValue,
  }) : super(initialValue: initialValue ?? Vector2.zero());

  static Vector2 resolution(Vector2 prev, Duration delta) => prev;

}

/// A description of a `uniform vec3` in the shader program.
///
/// The [key] is an arbitrary key for retrieving or setting this value.
/// [transformer] is an optional function that takes the previous value and a delta time to return a new value.
class UniformVec3 extends UniformValue<Vector3> {
  UniformVec3({
    required super.key,
    super.transformer,
    Vector3? initialValue,
  }) : super(initialValue: initialValue ?? Vector3.zero());

  /// A [UniformTransformer] that will inject the resolution (size in pixels) of the area drawing the shader.
  ///
  /// Only X and Y of the vector will be set (width and height). Z is always 0.
  static Vector3 resolution(Vector3 prev, Duration delta) => prev;
}

/// A description of a `uniform vec4` in the shader program.
///
/// The [key] is an arbitrary key for retrieving or setting this value.
/// [transformer] is an optional function that takes the previous value and a delta time to return a new value.
class UniformVec4 extends UniformValue<Vector4> {
  UniformVec4({
    required super.key,
    super.transformer,
    Vector4? initialValue,
  }) : super(initialValue: initialValue ?? Vector4.zero());
}
