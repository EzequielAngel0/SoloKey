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
import 'notification_navigation.dart';
import 'rotation_schedule.dart';

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

bool get _isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

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

// Aviso de rotacion agrupado (NUC-2): id fijo; el payload son los ids de las credenciales, separados por coma.
const int _kRotationNotificationId = 990003;

// Login-approval notification (M3): fixed id + payload sentinel.
const int _kApprovalNotificationId = 990001;
const String _kApprovalPayload = '__approve_login__';

// "N changes synced" notification: fixed id + payload sentinel. Tapping it opens
// the Sync screen, whose summary card shows what changed.
const int _kSyncNotificationId = 990002;
const String _kSyncPayload = '__synced__';

// ── Tap routing (pure, shared by foreground tap and cold start) ───────────────

enum NotificationTapKind { none, openSync, snooze, openCredential, openApp }

/// Pure routing decision for a notification tap: sentinel payloads open the
/// Sync screen, the snooze action mutes a rotation reminder, anything else
/// deep-links to the credential in [payload]. Extracted from the plugin
/// callbacks so it is unit-testable (test/core/notification_tap_test.dart).
/// The snooze action only exists on rotation notifications, whose payload is
/// always a credential id — never one of the Sync sentinels.
({NotificationTapKind kind, String? credentialId}) decideNotificationTap({
  String? payload,
  String? actionId,
}) {
  if (payload == null) {
    return (kind: NotificationTapKind.none, credentialId: null);
  }
  if (payload == _kApprovalPayload || payload == _kSyncPayload) {
    return (kind: NotificationTapKind.openSync, credentialId: null);
  }
  if (actionId == _kActionSnooze3d) {
    return (kind: NotificationTapKind.snooze, credentialId: payload);
  }
  // Varias credenciales en un aviso: abrir la app (cuales son se ve dentro, tras desbloquear).
  if (payload.contains(',')) {
    return (kind: NotificationTapKind.openApp, credentialId: null);
  }
  return (kind: NotificationTapKind.openCredential, credentialId: payload);
}

Future<void> _showMobileRotation(
  FlutterLocalNotificationsPlugin plugin,
  List<DueRotation> due,
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
    id: _kRotationNotificationId,
    title: l10n.notifRotationTitle,
    body: l10n.notifRotationBodyCount(due.length),
    notificationDetails: details,
    payload: due.map((d) => d.id).join(','),
  );
}

/// Pospone 3 dias los avisos de las credenciales del [payload].
Future<void> _snooze(String payload) async {
  final until = DateTime.now().add(_kSnoozeDuration).millisecondsSinceEpoch;
  markRotationPrompted(await rotationFile(), payload.split(','), until);
}

/// Handles a notification ACTION tapped while the app is in the background or
/// terminated (runs in its own isolate). Opens a fresh DB handle for the snooze.
/// `change_password` from a closed app launches the app; the cold-start path in
/// [NotificationService.initialize] then deep-links to the credential.
@pragma('vm:entry-point')
Future<void> notificationActionBackground(NotificationResponse response) async {
  if (response.actionId == _kActionSnooze3d && response.payload != null) {
    try {
      await _snooze(response.payload!);
    } catch (_) {
      // Silent — background work must not throw.
    }
  }
}

/// Top-level routine executed inside the WorkManager background isolate (no
/// GetIt, no master key). Opens its own DB handle, notifies, then closes it.
@pragma('vm:entry-point')
Future<void> runBackgroundRotationCheck() async {
  try {
    final file = await rotationFile();
    final due = findDueRotations(file);
    if (due.isEmpty) return;

    final plugin = FlutterLocalNotificationsPlugin();
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await plugin.initialize(settings: init);
    final l10n = await _loadNotifL10n();
    await _ensureAndroidChannel(plugin, l10n);
    await _showMobileRotation(plugin, due, l10n);
    markRotationPrompted(
        file, due.map((d) => d.id), DateTime.now().millisecondsSinceEpoch);
  } catch (_) {
    // Background work must never throw — failures stay silent by design.
  }
}

// ── Foreground service (DI singleton) ─────────────────────────────────────────

/// Coordinates native rotation reminders in the foreground:
/// `local_notifier` banners on desktop, `flutter_local_notifications` on mobile.
/// On desktop it also runs a periodic in-process daemon while the app sits in
/// the system tray.
@lazySingleton
class NotificationService {
  NotificationService(this._rotation);

  final RotationSchedule _rotation;
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
          final action = decideNotificationTap(
            payload: payload,
            actionId: resp!.actionId,
          );
          switch (action.kind) {
            case NotificationTapKind.snooze:
              await _snooze(payload);
            case NotificationTapKind.openSync:
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => NotificationNavigation.openSync(),
              );
            case NotificationTapKind.openCredential:
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => NotificationNavigation.openCredential(payload),
              );
            case NotificationTapKind.none:
            case NotificationTapKind.openApp:
              break;
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

  /// Fires a local "N changes synced" banner after a delta lands on THIS device.
  /// [count] is the number of vault items applied locally; no-op when <= 0.
  /// Tapping opens the Sync screen (its summary card shows what changed).
  Future<void> showSyncCompleted(int count) async {
    if (count <= 0) return;
    await initialize();
    final l10n = await _loadNotifL10n();
    if (_isDesktop) {
      final notification = LocalNotification(
        title: l10n.notifSyncTitle,
        body: l10n.notifSyncBody(count),
      );
      notification.onClick = () {
        windowManager.show();
        windowManager.focus();
        NotificationNavigation.openSync();
      };
      await notification.show();
    } else if (_isMobile) {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _kChannelId,
          l10n.notifRotationChannelName,
          channelDescription: l10n.notifRotationChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      );
      await _mobilePlugin.show(
        id: _kSyncNotificationId,
        title: l10n.notifSyncTitle,
        body: l10n.notifSyncBody(count),
        notificationDetails: details,
        payload: _kSyncPayload,
      );
    }
  }

  /// Lee la agenda de rotacion y, si hay vencidas, lanza UN aviso agrupado sin nombres (NUC-2).
  Future<void> checkAndNotify() async {
    await initialize();
    try {
      final due = await _rotation.due();
      if (due.isEmpty) return;

      final l10n = await _loadNotifL10n();
      if (_isDesktop) {
        await _showDesktopRotation(due, l10n);
      } else if (_isMobile) {
        await _showMobileRotation(_mobilePlugin, due, l10n);
      }
      await _rotation.markPrompted(
          due.map((d) => d.id), DateTime.now().millisecondsSinceEpoch);
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
      List<DueRotation> due, AppLocalizations l10n) async {
    final notification = LocalNotification(
      title: l10n.notifRotationTitle,
      body: l10n.notifRotationBodyCount(due.length),
    );
    notification.onClick = () {
      windowManager.show();
      windowManager.focus();
      if (due.length == 1) NotificationNavigation.openCredential(due.single.id);
    };
    await notification.show();
  }

  void _onMobileTap(NotificationResponse response) {
    final action = decideNotificationTap(
      payload: response.payload,
      actionId: response.actionId,
    );
    switch (action.kind) {
      case NotificationTapKind.none:
      case NotificationTapKind.openApp:
        return;
      case NotificationTapKind.openSync:
        // Aprobacion de login (M3) o "N cambios sincronizados".
        NotificationNavigation.openSync();
      case NotificationTapKind.snooze:
        // Posponer 3 dias: empuja el ultimo aviso al futuro en la agenda.
        unawaited(_snooze(action.credentialId!));
        unawaited(_mobilePlugin.cancel(id: _kRotationNotificationId));
      case NotificationTapKind.openCredential:
        // Toque normal o [Cambiar contraseña] → abre el detalle de la credencial.
        NotificationNavigation.openCredential(action.credentialId!);
    }
  }

  @disposeMethod
  void dispose() {
    _desktopTimer?.cancel();
    _desktopTimer = null;
  }
}
