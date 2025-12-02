// 1. KITA PAKAI ALIAS 'fln' SUPAYA TIDAK BINGUNG
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;

// Import Timezone
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  // Tambahkan 'fln.' di depan tipe data
  final fln.FlutterLocalNotificationsPlugin notificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    // Tambahkan 'fln.'
    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.DarwinInitializationSettings initializationSettingsIOS =
        fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final fln.InitializationSettings initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse response) async {
        print("Notifikasi diklik payload: ${response.payload}");
      },
    );
  }

  // ==========================================================================
  // 1. INSTANT NOTIFICATION
  // ==========================================================================
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const fln.AndroidNotificationDetails androidDetails = fln.AndroidNotificationDetails(
      'channel_science_craft',
      'Notifikasi Umum',
      channelDescription: 'Notifikasi instan aplikasi',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
    );

    const fln.NotificationDetails details = fln.NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  // ==========================================================================
  // 2. SCHEDULED DAILY (VERSI 19.5.0 DENGAN ALIAS)
  // ==========================================================================
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'channel_scheduled',
          'Notifikasi Terjadwal',
          channelDescription: 'Reminder harian dan streak',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
        ),
      ),
      
      // PERHATIKAN: Kita pakai 'fln.' di depannya
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      
      matchDateTimeComponents: fln.DateTimeComponents.time, 
    );
  }

  // ==========================================================================
  // 3. SCHEDULED FUTURE (VERSI 19.5.0 DENGAN ALIAS)
  // ==========================================================================
  Future<void> scheduleFutureNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay, 
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'channel_future',
          'Notifikasi Review',
          channelDescription: 'Notifikasi follow-up belajar',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
        ),
      ),
      
      // Pakai 'fln.' lagi
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // UTILITIES
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
  
  Future<void> cancelAll() async {
    await notificationsPlugin.cancelAll();
  }
}