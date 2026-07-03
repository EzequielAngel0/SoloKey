import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:window_manager/window_manager.dart';

import '../../l10n/app_localizations.dart';
import '../infrastructure/database/app_database.dart';
import 'notification_navigation.dart';

// ── Notification copy & channel constants ─────────────────────────────────────

const String _kChannelId = 'rotation_reminders';

/// Loads localized notification strings WITHOUT a BuildContext (works in
/// background isolates) by resolving the system locale to a supported one.
Future<AppLocalizations> _loadNotifL10n() {
  final lang = ui.PlatformDispatcher.instance.locale.languageCode;
  final supported =
      AppLocalizations.supportedLocales.any((l) => l.languageCode == lang);
  return AppLocalizations.delegate.load(Locale(supported ? lang : 'en'));
}

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
/// [now] is injectable so tests can pin the clock deterministically; it
/// defaults to the wall clock in production. No behavioural change.
Future<List<DueRotation>> findDueRotations(AppDatabase db, {DateTime? now}) async {
  final at = now ?? DateTime.now();
  final entries = await db.credentialDao.getAll();
  final due = <DueRotation>[];

  for (final e in entries) {
    if (e.rotationInterval == 'none') continue;

    final days = rotationDaysForInterval(e.rotationInterval, e.customRotationDays);
    if (days <= 0) continue;

    final updatedAt = DateTime.fromMillisecondsSinceEpoch(e.updatedAt);
    final daysSinceUpdate = at.difference(updatedAt).inDays;
    if (daysSinceUpdate < days) continue; // still within rotation window

    // Skip if we already prompted recently (prevents notification fatigue).
    final last = e.lastRotationPromptedAt;
    if (last != null) {
      final lastDt = DateTime.fromMillisecondsSinceEpoch(last);
      if (at.difference(lastDt) < _kRepromptCooldown) continue;
    }

    due.add(DueRotation(e.id, e.title, daysSinceUpdate - days));
  }
  return due;
}

/// Creates/updates the Android channel so [Importance.high] is honoured.
Future<void> _ensureAndroidChannel(
    FlutterLocalNotificationsPlugin plugin, AppLocalizations l10n) async {
  final android = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await android?.createNotificationChannel(
    AndroidNotificationChannel(
      _kChannelId,
      l10n.notifRotationChannelName,
      description: l10n.notifRotationChannelDesc,
      importance: Importance.high,
    ),
  );
}

/// Pushes a single mobile rotation notification. Shared by foreground and the
/// background isolate. Payload carries the credential id for deep-linking.
// Action ids for the rotation notification buttons.
const String _kActionChangePassword = 'change_password';
const String _kActionSnooze3d = 'snooze_3d';
const Duration _kSnoozeDuration = Duration(days: 3);

// Login-approval notification (M3): fixed id + payload sentinel.
const int _kApprovalNotificationId = 990001;
const String _kApprovalPayload = '__approve_login__';

Future<void> _showMobileRotation(
  FlutterLocalNotificationsPlugin plugin,
  DueRotation item,
  AppLocalizations l10n,
) async {
  final details = NotificationDetails(
    android: AndroidNotificationDetails(
      _kChannelId,
      l10n.notifRotationChannelName,
      channelDescription: l10n.notifRotationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          _kActionChangePassword,
          l10n.notifActionChangePassword,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(_kActionSnooze3d, l10n.notifActionSnooze3d),
      ],
    ),
    iOS: const DarwinNotificationDetails(),
  );
  await plugin.show(
    id: item.id.hashCode,
    title: l10n.notifRotationTitle,
    body: l10n.notifRotationBody(item.title),
    notificationDetails: details,
    payload: item.id,
  );
}

/// Handles a notification ACTION tapped while the app is in the background or
/// terminated (runs in its own isolate). Opens a fresh DB handle for the snooze.
/// `change_password` from a closed app launches the app; the cold-start path in
/// [NotificationService.initialize] then deep-links to the credential.
@pragma('vm:entry-point')
Future<void> notificationActionBackground(NotificationResponse response) async {
  if (response.actionId == _kActionSnooze3d && response.payload != null) {
    final db = AppDatabase();
    try {
      final until = DateTime.now().add(_kSnoozeDuration).millisecondsSinceEpoch;
      await db.credentialDao.markRotationPrompted(response.payload!, until);
    } catch (_) {
      // Silent — background work must not throw.
    } finally {
      await db.close();
    }
  }
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
    final l10n = await _loadNotifL10n();
    await _ensureAndroidChannel(plugin, l10n);

    final stampedAt = DateTime.now().millisecondsSinceEpoch;
    for (final item in due) {
      await _showMobileRotation(plugin, item, l10n);
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
          onDidReceiveBackgroundNotificationResponse:
              notificationActionBackground,
        );
        await _ensureAndroidChannel(_mobilePlugin, await _loadNotifL10n());

        final android = _mobilePlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await android?.requestNotificationsPermission();

        final ios = _mobilePlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        await ios?.requestPermissions(alert: true, badge: true, sound: true);

        // Handle a cold start triggered by tapping a notification (or action).
        final launch = await _mobilePlugin.getNotificationAppLaunchDetails();
        final resp = launch?.notificationResponse;
        final payload = resp?.payload;
        if ((launch?.didNotificationLaunchApp ?? false) && payload != null) {
          if (resp!.actionId == _kActionSnooze3d) {
            final until =
                DateTime.now().add(_kSnoozeDuration).millisecondsSinceEpoch;
            await _db.credentialDao.markRotationPrompted(payload, until);
          } else if (payload == _kApprovalPayload) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => NotificationNavigation.openSync(),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => NotificationNavigation.openCredential(payload),
            );
          }
        }
      }
      // Desktop: `local_notifier` is set up once in main() before runApp.
      _initialized = true;
    } catch (_) {
      // Never let notification setup crash the app.
    }
  }

  /// Shows a local notification asking the user to approve a desktop login (M3).
  /// No FCM: only delivered while the phone app is running/connected. Tapping it
  /// opens the Sync screen where the user approves (biometric + DUK send).
  Future<void> showLoginApprovalRequest({String desktopName = ''}) async {
    await initialize();
    if (!_isMobile) return;
    final l10n = await _loadNotifL10n();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannelId,
        l10n.notifRotationChannelName,
        channelDescription: l10n.notifRotationChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _mobilePlugin.show(
      id: _kApprovalNotificationId,
      title: l10n.notifApprovalTitle,
      body: desktopName.isEmpty
          ? l10n.notifApprovalBody
          : l10n.notifApprovalBodyNamed(desktopName),
      notificationDetails: details,
      payload: _kApprovalPayload,
    );
  }

  /// Scans the vault and fires native reminders for every overdue credential.
  Future<void> checkAndNotify() async {
    await initialize();
    try {
      final due = await findDueRotations(_db);
      if (due.isEmpty) return;

      final l10n = await _loadNotifL10n();
      final stampedAt = DateTime.now().millisecondsSinceEpoch;
      for (final item in due) {
        if (_isDesktop) {
          await _showDesktopRotation(item, l10n);
        } else if (_isMobile) {
          await _showMobileRotation(_mobilePlugin, item, l10n);
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

  Future<void> _showDesktopRotation(
      DueRotation item, AppLocalizations l10n) async {
    final notification = LocalNotification(
      title: l10n.notifRotationTitle,
      body: l10n.notifRotationBody(item.title),
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
    if (id == null) return;
    if (id == _kApprovalPayload) {
      // M3: abrir la pantalla de Sincronizar para aprobar el desbloqueo.
      NotificationNavigation.openSync();
      return;
    }
    if (response.actionId == _kActionSnooze3d) {
      // Posponer 3 dias: empuja lastRotationPromptedAt al futuro para silenciar.
      final until = DateTime.now().add(_kSnoozeDuration).millisecondsSinceEpoch;
      unawaited(_db.credentialDao.markRotationPrompted(id, until));
      unawaited(_mobilePlugin.cancel(id: id.hashCode));
      return;
    }
    // Toque normal o [Cambiar contraseña] → abre el detalle de la credencial.
    NotificationNavigation.openCredential(id);
  }

  @disposeMethod
  void dispose() {
    _desktopTimer?.cancel();
    _desktopTimer = null;
  }
}
