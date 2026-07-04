import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Installs an in-memory handler for the `flutter_secure_storage` platform
/// channel so real [FlutterSecureStorage] instances work headlessly in unit
/// tests — no Keystore (Android) / DPAPI (Windows) involved. Returns the
/// backing map so a test can seed state and assert on it.
///
/// The channel name/method contract mirrors
/// `flutter_secure_storage_platform_interface` (read/write/delete/deleteAll/
/// readAll/containsKey with a `{key, value, options}` argument map).
///
/// Registers an `addTearDown` that removes the mock handler, so callers just
/// call this in `setUp` and forget about cleanup.
Map<String, String> installInMemorySecureStorage() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final store = <String, String>{};
  const channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(channel, (call) async {
    final args = (call.arguments as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    switch (call.method) {
      case 'write':
        final key = args['key'] as String;
        final value = args['value'] as String?;
        if (value == null) {
          store.remove(key);
        } else {
          store[key] = value;
        }
        return null;
      case 'read':
        return store[args['key'] as String];
      case 'delete':
        store.remove(args['key'] as String);
        return null;
      case 'deleteAll':
        store.clear();
        return null;
      case 'readAll':
        return Map<String, String>.from(store);
      case 'containsKey':
        return store.containsKey(args['key'] as String);
      default:
        return null;
    }
  });

  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  return store;
}
