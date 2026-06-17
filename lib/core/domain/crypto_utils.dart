import 'dart:typed_data';

/// Sobrescribe el búfer de bytes con ceros para reducir el tiempo
/// de exposición de claves sensibles en memoria.
void zeroBuffer(Uint8List buffer) {
  buffer.fillRange(0, buffer.length, 0);
}
