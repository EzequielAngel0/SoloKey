import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../shared/widgets/vault_app_bar.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _found = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime? _lastErrorTime;

  void _onDetect(BarcodeCapture capture) {
    if (_found) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawValue = barcodes.first.rawValue;
      if (rawValue != null) {
        if (rawValue.toLowerCase().startsWith('otpauth') || rawValue.startsWith('{')) {
          setState(() => _found = true);
          if (mounted) Navigator.of(context).pop(rawValue);
        } else {
          // Evitar spam de Snackbars (debounce de 2 segundos)
          final now = DateTime.now();
          if (_lastErrorTime == null ||
              now.difference(_lastErrorTime!).inSeconds > 2) {
            _lastErrorTime = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR Inválido. Apunta a un código de tipo TOTP.'),
                backgroundColor: Color(0xFFCF6679),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const VaultAppBar(title: 'Escanear QR TOTP'),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Sombra semitransparente estilo marco de cámara
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: const Color(0xFFE91E8C),
                borderRadius: 12,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Apunta al código QR generado por tu cuenta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final cutOutSize = this.cutOutSize < width ? this.cutOutSize : width - borderOffset;
    final borderLength = this.borderLength > cutOutSize / 2 + borderWidth * 2
        ? borderWidthSize / 2
        : this.borderLength;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - cutOutSize / 2 + borderOffset,
      cutOutSize - borderOffset * 2,
      cutOutSize - borderOffset * 2,
    );

    canvas.saveLayer(rect, backgroundPaint);

    canvas.drawRect(rect, backgroundPaint);

    // Draw top right corner
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        cutOutRect.right - borderLength,
        cutOutRect.top,
        cutOutRect.right,
        cutOutRect.top + borderLength,
        topRight: Radius.circular(borderRadius),
      ),
      borderPaint,
    );
    // Draw top left corner
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        cutOutRect.left,
        cutOutRect.top,
        cutOutRect.left + borderLength,
        cutOutRect.top + borderLength,
        topLeft: Radius.circular(borderRadius),
      ),
      borderPaint,
    );
    // Draw bottom right corner
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        cutOutRect.right - borderLength,
        cutOutRect.bottom - borderLength,
        cutOutRect.right,
        cutOutRect.bottom,
        bottomRight: Radius.circular(borderRadius),
      ),
      borderPaint,
    );
    // Draw bottom left corner
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        cutOutRect.left,
        cutOutRect.bottom - borderLength,
        cutOutRect.left + borderLength,
        cutOutRect.bottom,
        bottomLeft: Radius.circular(borderRadius),
      ),
      borderPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      boxPaint,
    );

    canvas.restore();
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
