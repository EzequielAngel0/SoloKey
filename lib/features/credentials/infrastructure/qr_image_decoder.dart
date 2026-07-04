import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// Signature for a function that decodes the first QR code in a static image.
/// Lets callers (e.g. [ScreenQrScanner]) inject a fake in tests.
typedef QrImageDecoder = String? Function(Uint8List bytes);

/// Decodes the first QR code found in a static image (PNG/JPEG bytes) with a
/// pure-Dart pipeline (`image` for pixels, ZXing2 for detection). Returns the
/// decoded payload text, or `null` when no QR is present or the bytes are not a
/// decodable image. Never throws.
///
/// Runs entirely on the Dart VM (no camera, no platform channel), so it works
/// on desktop and is unit-testable. The payload can be a secret (e.g. the TOTP
/// `secret` inside an `otpauth://` URI) — callers must never log the result.
String? decodeQrFromImageBytes(Uint8List bytes) {
  final img.Image? image;
  try {
    image = img.decodeImage(bytes);
  } catch (_) {
    return null;
  }
  if (image == null) return null;

  final pixels = image
      .convert(numChannels: 4)
      .getBytes(order: img.ChannelOrder.abgr)
      .buffer
      .asInt32List();

  final source = RGBLuminanceSource(image.width, image.height, pixels);
  final reader = QRCodeReader();

  // Hybrid binarizer first (robust when the region includes surrounding UI),
  // then the global-histogram one (better on a tightly cropped, high-contrast
  // QR). ZXing throws NotFound/Format/Checksum when it fails — we swallow it
  // and fall through to `null`.
  for (final binarizer in <Binarizer>[
    HybridBinarizer(source),
    GlobalHistogramBinarizer(source),
  ]) {
    try {
      final result = reader.decode(
        BinaryBitmap(binarizer),
        hints: DecodeHints()..put(DecodeHintType.tryHarder),
      );
      if (result.text.isNotEmpty) return result.text;
    } catch (_) {
      // Try the next binarizer.
    }
  }
  return null;
}
