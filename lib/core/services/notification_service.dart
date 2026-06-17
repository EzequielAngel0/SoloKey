import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:window_manager/window_manager.dart';

import '../infrastructure/database/app_database.dart';
import 'notification_navigation.dart';

// ── Notification copy & channel constants ─────────────────────────────────────

const String _kChannelId = 'rotation_reminders';
const String _kChannelName = 'Recordatorios de rotacion';
const String _kChannelDesc =
    'Alertas cuando una contrasena debe rotarse por seguridad.';

const String _kRotationTitle = 'Rotacion de Contrasena Requerida';

String _rotationBody(String title) =>
    'Tu contrasena para "$title" ha expirado. Cambiala ahora por seguridad.';

/// Minimum gap between two reminders for the SAME credential, to avoid spamming
/// the user when a background check runs often.
const Duration _kRepromptCooldown = Duration(hours: 24);

bool get _isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

// ── Shared rotation logic (also reused by the background isolate) ─────────────

/// Days threshold for a rotation [interval] string.
/// Returns 0 when the credential should never trigger a reminder.
int rotationDaysForInterval(String interval, int? customDays) => switch (interval) {
      'monthly' => 30,
      'quarterly' => 90,
      'semiAnnually' => 180,
      'custom' => customDays ?? 30,
      _ => 0,
    };

/// A credential whose password is overdue for rotation and not muted by the
/// 24h re-prompt cooldown.
class DueRotation {
  const DueRotation(this.id, this.title, this.daysOverdue);
  final String id;
  final String title;
  final int daysOverdue;
}

/// Scans the local SQLite vault for credentials whose rotation window has
/// elapsed. Reads ONLY plain (non-encrypted) columns, so it works without the
/// master key — safe to call from a background isolate.
Future<List<DueRotation>> findDueRotations(AppDatabase db) async {
  final now = DateTime.now();
  final entries = await db.credentialDao.getAll();
  final due = <DueRotation>[];

  for (final e in entries) {
    if (e.rotationInterval == 'none') continue;

    final days = rotationDaysForInterval(e.rotationInterval, e.customRotationDays);
    if (days <= 0) continue;

    final updatedAt = DateTime.fromMillisecondsSinceEpoch(e.updatedAt);
    final daysSinceUpdate = now.difference(updatedAt).inDays;
    if (daysSinceUpdate < days) continue; // still within rotation window

    // Skip if we already prompted recently (prevents notification fatigue).
    final last = e.lastRotationPromptedAt;
    if (last != null) {
      final lastDt = DateTime.fromMillisecondsSinceEpoch(last);
      if (now.difference(lastDt) < _kRepromptCooldown) continue;
    }

    due.add(DueRotation(e.id, e.title, daysSinceUpdate - days));
  }
  return due;
}

/// Creates/updates the Android channel so [Importance.high] is honoured.
Future<void> _ensureAndroidChannel(FlutterLocalNotificationsPlugin plugin) async {
  final android = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await android?.createNotificationChannel(
    const AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: _kChannelDesc,
      importance: Importance.high,
    ),
  );
}

/// Pushes a single mobile rotation notification. Shared by foreground and the
/// background isolate. Payload carries the credential id for deep-linking.
Future<void> _showMobileRotation(
  FlutterLocalNotificationsPlugin plugin,
  DueRotation item,
) async {
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: _kChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );
  await plugin.show(
    id: item.id.hashCode,
    title: _kRotationTitle,
    body: _rotationBody(item.title),
    notificationDetails: details,
    payload: item.id,
  );
}

/// Top-level routine executed inside the WorkManager background isolate (no
/// GetIt, no master key). Opens its own DB handle, notifies, then closes it.
@pragma('vm:entry-point')
Future<void> runBackgroundRotationCheck() async {
  final db = AppDatabase();
  try {
    final due = await findDueRotations(db);
    if (due.isEmpty) return;

    final plugin = FlutterLocalNotificationsPlugin();
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await plugin.initialize(settings: init);
    await _ensureAndroidChannel(plugin);

    final stampedAt = DateTime.now().millisecondsSinceEpoch;
    for (final item in due) {
      await _showMobileRotation(plugin, item);
      await db.credentialDao.markRotationPrompted(item.id, stampedAt);
    }
  } catch (_) {
    // Background work must never throw — failures stay silent by design.
  } finally {
    await db.close();
  }
}

// ── Foreground service (DI singleton) ─────────────────────────────────────────

/// Coordinates native rotation reminders in the foreground:
/// `local_notifier` banners on desktop, `flutter_local_notifications` on mobile.
/// On desktop it also runs a periodic in-process daemon while the app sits in
/// the system tray.
@lazySingleton
class NotificationService {
  NotificationService(this._db);

  final AppDatabase _db;
  final FlutterLocalNotificationsPlugin _mobilePlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Timer? _desktopTimer;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      if (_isMobile) {
        const init = InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        );
        await _mobilePlugin.initialize(
          settings: init,
          onDidReceiveNotificationResponse: _onMobileTap,
        );
        await _ensureAndroidChannel(_mobilePlugin);

        final android = _mobilePlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await android?.requestNotificationsPermission();

        final ios = _mobilePlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        await ios?.requestPermissions(alert: true, badge: true, sound: true);

        // Handle a cold start triggered by tapping a notification.
        final launch = await _mobilePlugin.getNotificationAppLaunchDetails();
        final payload = launch?.notificationResponse?.payload;
        if ((launch?.didNotificationLaunchApp ?? false) && payload != null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => NotificationNavigation.openCredential(payload),
          );
        }
      }
      // Desktop: `local_notifier` is set up once in main() before runApp.
      _initialized = true;
    } catch (_) {
      // Never let notification setup crash the app.
    }
  }

  /// Scans the vault and fires native reminders for every overdue credential.
  Future<void> checkAndNotify() async {
    await initialize();
    try {
      final due = await findDueRotations(_db);
      if (due.isEmpty) return;

      final stampedAt = DateTime.now().millisecondsSinceEpoch;
      for (final item in due) {
        if (_isDesktop) {
          await _showDesktopRotation(item);
        } else if (_isMobile) {
          await _showMobileRotation(_mobilePlugin, item);
        }
        await _db.credentialDao.markRotationPrompted(item.id, stampedAt);
      }
    } catch (_) {
      // Best-effort.
    }
  }

  /// Starts the desktop tray daemon: an immediate check plus a recurring sweep
  /// every 6 hours while the app stays resident. No-op off desktop.
  void startDesktopDaemon() {
    if (!_isDesktop) return;
    unawaited(checkAndNotify());
    _desktopTimer?.cancel();
    _desktopTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => checkAndNotify(),
    );
  }

  Future<void> _showDesktopRotation(DueRotation item) async {
    final notification = LocalNotification(
      title: _kRotationTitle,
      body: _rotationBody(item.title),
    );
    notification.onClick = () {
      windowManager.show();
      windowManager.focus();
      NotificationNavigation.openCredential(item.id);
    };
    await notification.show();
  }

  void _onMobileTap(NotificationResponse response) {
    final id = response.payload;
    if (id != null) NotificationNavigation.openCredential(id);
  }

  @disposeMethod
  void dispose() {
    _desktopTimer?.cancel();
    _desktopTimer = null;
  }
}
