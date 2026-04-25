import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _nudgeId = 42;
  static bool _initialized = false;

  static const _nudges = [
    ('Parts to log?', 'Keep your WreckLog inventory up to date before you forget.'),
    ('Your parts are waiting', 'Check what\'s ready to sell in WreckLog.'),
    ('Still dismantling?', 'Log your parts in WreckLog before you forget where they are.'),
    ('Ready to sell?', 'Open WreckLog and check your unlisted parts.'),
    ('Stay on top of your stock', 'A quick check in WreckLog keeps your inventory accurate.'),
  ];

  static Future<void> init() async {
    if (kIsWeb || _initialized) return;
    _initialized = true;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> requestPermission() async {
    if (kIsWeb || !_initialized) return;
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Cancels any pending nudge and schedules a new one 3 days from now.
  /// Call on every app open so the timer resets when users return.
  static Future<void> scheduleRetentionNudge() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(_nudgeId);
    final (title, body) = _nudges[Random().nextInt(_nudges.length)];
    final when = tz.TZDateTime.now(tz.local).add(const Duration(days: 3));
    await _plugin.zonedSchedule(
      _nudgeId,
      title,
      body,
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'wrecklog_retention',
          'Reminders',
          channelDescription: 'Reminders to keep your inventory up to date',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
