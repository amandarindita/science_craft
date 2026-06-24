import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final fln.FlutterLocalNotificationsPlugin notificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  // INIT
  Future<void> initNotification() async {
    tz.initializeTimeZones();

    // Set timezone manual (AMAN, tanpa plugin yg rusak)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    // Minta izin notifikasi buat Android 13+ biar pop-up nya beneran keluar
final fln.AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    notificationsPlugin.resolvePlatformSpecificImplementation<
        fln.AndroidFlutterLocalNotificationsPlugin>();
await androidImplementation?.requestNotificationsPermission();

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.DarwinInitializationSettings initializationSettingsIOS =
        fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final fln.InitializationSettings initializationSettings =
        fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (fln.NotificationResponse response) async {
        print("Notifikasi diklik payload: ${response.payload}");
      },
    );
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const fln.AndroidNotificationDetails androidDetails =
        fln.AndroidNotificationDetails(
      'channel_science_craft',
      'Notifikasi Umum',
      channelDescription: 'Notifikasi instan aplikasi',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
    );

    const fln.NotificationDetails details =
        fln.NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(id, title, body, details,
        payload: payload);
  }

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
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: fln.DateTimeComponents.time,
    );
  }

  Future<void> scheduleFutureNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.now(tz.local).add(delay);

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
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

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
