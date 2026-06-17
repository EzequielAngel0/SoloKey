import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Flutter side of the Android system-autofill integration.
///
/// Opens the system settings page where the user selects SoloKey as the default
/// autofill provider, and reports whether it is currently active. The actual
/// credential matching/decryption happens in the native [SoloKeyAutofillService]
/// + [AutofillFetchService] (via the `autofillEntrypoint`), not here.
@lazySingleton
class AutofillSettingsService {
  static const _channel = MethodChannel('com.solokey/autofill_settings');

  /// Opens Android system autofill settings where the user can set SoloKey as
  /// the default autofill provider. Returns `true` if the intent launched.
  Future<bool> openAutofillSettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openAutofillSettings');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Returns `true` if SoloKey is the active autofill service on this device.
  Future<bool> isAutofillEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAutofillEnabled');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
