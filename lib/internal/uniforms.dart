part of '../shady.dart';

@protected
class TextureInstance {
  late final String key;
  late final ValueNotifier<Image?> _notifier;
  late final AssetBundle _bundle;
  ValueNotifier<Image?> get notifier => _notifier;

  TextureInstance(AssetBundle bundle, TextureSampler description, Image defaultImage)
      : _bundle = bundle {
    key = description.key;
    _notifier = ValueNotifier(defaultImage);
    if (description.asset != null) {
      load(description.asset!);
    }
  }

  int apply(FragmentShader shader, int index) {
    if (_notifier.value != null) shader.setImageSampler(index, _notifier.value!);
    return index + 1;
  }

  Future<void> load(String assetKey) async {
    final buffer = await _bundle.loadBuffer(assetKey);
    final codec = await instantiateImageCodecFromBuffer(buffer);
    final frame = await codec.getNextFrame();
    _notifier.value = frame.image;
  }
}

@protected
abstract class UniformInstance<T> {
  late final String key;
  late final ValueNotifier<T> notifier;
  UniformTransformer<T> transformer = (a, b) => a;

  Duration? _lastTs;

  UniformInstance(UniformValue<T> description)
      : key = description.key,
        notifier = ValueNotifier<T>(description.initialValue),
        transformer = description.transformer;

  void update(Duration ts) {
    T newValue = transformer(notifier.value, ts - (_lastTs ?? ts));
    _lastTs = ts;
    notifier.value = newValue;
  }

  void set(T value) {
    notifier.value = value;
  }

  void setTransformer(UniformTransformer<T> transformer) {
    this.transformer = transformer;
  }

  int apply(FragmentShader shader, int index);
}

@protected
class UniformFloatInstance extends UniformInstance<double> {
  UniformFloatInstance(UniformValue<double> description) : super(description);

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value);
    return index + 1;
  }
}

@protected
class UniformVec2Instance extends UniformInstance<Vector2> {
  UniformVec2Instance(UniformValue<Vector2> description) : super(description);

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value.x);
    shader.setFloat(index + 1, notifier.value.y);
    return index + 2;
  }
}

@protected
class UniformVec3Instance extends UniformInstance<Vector3> {
  final bool isResolution;
  UniformVec3Instance(UniformValue<Vector3> description)
      : isResolution = description.transformer == UniformVec3.resolution,
        super(description);

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value.x);
    shader.setFloat(index + 1, notifier.value.y);
    shader.setFloat(index + 2, notifier.value.z);
    return index + 3;
  }
}

@protected
class UniformVec4Instance extends UniformInstance<Vector4> {
  UniformVec4Instance(UniformValue<Vector4> description) : super(description);

  @override
  int apply(FragmentShader shader, int index) {
    shader.setFloat(index, notifier.value.x);
    shader.setFloat(index + 1, notifier.value.y);
    shader.setFloat(index + 2, notifier.value.z);
    shader.setFloat(index + 3, notifier.value.w);
    return index + 4;
  }
}
