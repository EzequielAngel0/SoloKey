import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Global navigator key shared with [GoRouter]. Lets notification taps route
/// without holding a [BuildContext] (taps arrive from native callbacks).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Routing entry points triggered by OS notifications (rotation reminders).
abstract final class NotificationNavigation {
  /// Opens the detail screen for [credentialId]. If the vault is locked the
  /// router guard transparently redirects to the unlock screen first.
  static void openCredential(String credentialId) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null || credentialId.isEmpty) return;
    ctx.go('/credentials/$credentialId');
  }
}
