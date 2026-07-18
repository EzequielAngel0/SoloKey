import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/services/notification_service.dart';

// Pure tap-routing decision (prompt 99). The payload sentinels and the snooze
// action id are part of the notification protocol persisted in shown
// notifications, so the literals are pinned here on purpose: renaming them in
// the service would break taps on already-delivered notifications.
void main() {
  group('decideNotificationTap', () {
    test('null payload does nothing', () {
      final d = decideNotificationTap(payload: null, actionId: null);
      expect(d.kind, NotificationTapKind.none);
      expect(d.credentialId, isNull);
    });

    test('login-approval sentinel opens the Sync screen', () {
      final d = decideNotificationTap(payload: '__approve_login__');
      expect(d.kind, NotificationTapKind.openSync);
      expect(d.credentialId, isNull);
    });

    test('synced sentinel opens the Sync screen', () {
      final d = decideNotificationTap(payload: '__synced__');
      expect(d.kind, NotificationTapKind.openSync);
    });

    test('snooze action mutes the rotation reminder for that credential', () {
      final d =
          decideNotificationTap(payload: 'cred-42', actionId: 'snooze_3d');
      expect(d.kind, NotificationTapKind.snooze);
      expect(d.credentialId, 'cred-42');
    });

    test('plain tap deep-links to the credential in the payload', () {
      final d = decideNotificationTap(payload: 'cred-42');
      expect(d.kind, NotificationTapKind.openCredential);
      expect(d.credentialId, 'cred-42');
    });

    test('change-password action also opens the credential (not snooze)', () {
      final d = decideNotificationTap(
          payload: 'cred-42', actionId: 'change_password');
      expect(d.kind, NotificationTapKind.openCredential);
      expect(d.credentialId, 'cred-42');
    });
  });
}
