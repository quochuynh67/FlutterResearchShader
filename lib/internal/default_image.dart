part of '../shady.dart';

@protected
Future<Image> getDefaultImage() async {
  final bytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEA'
    'AAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A'
    '8AAQUBAScY42YAAAAASUVORK5CYII=',
  );
  final decoder = await instantiateImageCodec(bytes);
  final frame = await decoder.getNextFrame();
  return frame.image;
}
