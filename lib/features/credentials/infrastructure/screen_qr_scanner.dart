import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

import 'qr_image_decoder.dart';

/// Outcome of a desktop screen-region QR scan.
enum ScreenQrStatus {
  /// A QR code was found and decoded; [ScreenQrResult.payload] is set.
  ok,

  /// The user dismissed the region selector without capturing.
  cancelled,

  /// A screenshot was taken but it contained no decodable QR code.
  noQr,

  /// Screen capture is not available on this platform (mobile).
  unsupported,

  /// The capture failed unexpectedly (permission denied, tool missing…).
  error,
}

/// Result of [ScreenQrScanner.captureAndDecode].
class ScreenQrResult {
  const ScreenQrResult(this.status, [this.payload]);

  final ScreenQrStatus status;

  /// Decoded QR payload when [status] is [ScreenQrStatus.ok]. May be a secret
  /// (e.g. an `otpauth://` URI) — never log it.
  final String? payload;
}

/// Signature for a function that captures a user-selected screen region and
/// returns its raw image bytes (PNG), or `null` when the user cancelled.
typedef ScreenRegionCapturer = Future<Uint8List?> Function();

/// Captures a user-selected region of the desktop screen and decodes any QR
/// code inside it — the Windows/desktop counterpart to the mobile camera
/// scanner. The screenshot is transient: it is written to a temp file only long
/// enough to read its bytes, then deleted; nothing is persisted or logged.
///
/// Both the capture step and the decode step are injectable so the pure-Dart
/// decode pipeline can be unit-tested without a real screen or platform channel.
class ScreenQrScanner {
  ScreenQrScanner({ScreenRegionCapturer? capture, QrImageDecoder? decode})
    : _capture = capture,
      _decode = decode ?? decodeQrFromImageBytes;

  final ScreenRegionCapturer? _capture;
  final QrImageDecoder _decode;

  /// Only desktop platforms have a practical "screen capture" affordance.
  static bool get isSupported =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// Prompts the user to select a screen region, then decodes a QR from it.
  Future<ScreenQrResult> captureAndDecode() async {
    if (!isSupported) return const ScreenQrResult(ScreenQrStatus.unsupported);

    final Uint8List? bytes;
    try {
      bytes = await (_capture ?? _captureRegion)();
    } catch (_) {
      return const ScreenQrResult(ScreenQrStatus.error);
    }
    if (bytes == null || bytes.isEmpty) {
      return const ScreenQrResult(ScreenQrStatus.cancelled);
    }

    final payload = _decode(bytes);
    if (payload == null || payload.isEmpty) {
      return const ScreenQrResult(ScreenQrStatus.noQr);
    }
    return ScreenQrResult(ScreenQrStatus.ok, payload);
  }

  /// Default capture via `screen_capturer`: region mode, no clipboard copy (the
  /// screenshot may embed a secret), reading bytes from a temp PNG we delete
  /// immediately afterwards.
  Future<Uint8List?> _captureRegion() async {
    final dir = await getTemporaryDirectory();
    final file = File(
      p.join(dir.path, 'solokey_qr_${DateTime.now().microsecondsSinceEpoch}.png'),
    );
    try {
      final data = await screenCapturer.capture(
        mode: CaptureMode.region,
        imagePath: file.path,
        copyToClipboard: false,
        silent: true,
      );
      if (data == null) return null; // cancelled
      if (data.imageBytes != null && data.imageBytes!.isNotEmpty) {
        return data.imageBytes;
      }
      if (file.existsSync()) return file.readAsBytesSync();
      return null;
    } finally {
      try {
        if (file.existsSync()) file.deleteSync();
      } catch (_) {
        // Best-effort cleanup; ignore.
      }
    }
  }
}
