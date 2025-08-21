// Utility functions for image compression
import 'dart:typed_data';
import 'dart:ui' as ui;

class ImageCompressor {
  static Future<Uint8List> compressImage(
    Uint8List imageBytes, {
    int maxWidth = 300,
    int maxHeight = 300,
    int quality = 80,
  }) async {
    // Decode the image
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: maxWidth,
      targetHeight: maxHeight,
    );

    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return data!.buffer.asUint8List();
  }
}
