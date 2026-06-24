import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../notification_helper.dart'; // Pastikan path helper-mu benar
import '../../../data/api_service.dart'; // 🌟 Import ApiService Flask kita cok

class NotificationItem {
  final int id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color iconColor;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}

class NotificationController extends GetxController {
  final NotificationHelper _notifHelper = NotificationHelper();
  final box = GetStorage(); 

  final notifications = <NotificationItem>[].obs; // Mulai dengan list kosong
  final isLoading = false.obs; // 🌟 Indikator loading data dari Flask

  @override
  void onInit() {
    super.onInit();
    _notifHelper.initNotification();
    
    // 1. Jalankan logikasi alarm/push lokal harian bawaanmu
    _checkDailyLogin(); 
    _scheduleWeekendPromo(); 
    
    // 2. 🌟 LANGSUNG TARIK RIWAYAT NOTIFIKASI DARI SERVER FLASK!
    fetchServerNotifications();
  }

  // ========================================================================
  // 🔄 SYNC ENGINE: AMBIL DATA DARI SERVER FLASK
  // ========================================================================
  Future<void> fetchServerNotifications() async {
    try {
      isLoading.value = true;
      
      // Ambil list notifikasi mentah dari Flask
      final List<dynamic>? serverData = await ApiService.getNotifications();
      
      if (serverData != null) {
        // Map data dari Flask JSON ke dalam Model NotificationItem UI lu
        List<NotificationItem> mappedItems = serverData.map((notif) {
          final String title = notif['title'] ?? '';
          
          // 💡 PILIHAN IKON DINAMIS BERDASARKAN JENIS NOTIFIKASI FLASK
          IconData iconData = Icons.notifications_active;
          Color iconColor = Colors.blue;

          if (title.contains("Badge")) {
            iconData = Icons.emoji_events; // Ikon Piala 🏆
            iconColor = Colors.amber;
          } else if (title.contains("Level")) {
            iconData = Icons.rocket_launch; // Ikon Roket 🚀
            iconColor = Colors.purple;
          } else if (title.contains("Streak")) {
            iconData = Icons.local_fire_department_rounded; // Ikon Api 🔥
            iconColor = Colors.orange;
          }

          return NotificationItem(
            id: notif['id'] ?? DateTime.now().millisecondsSinceEpoch,
            title: title,
            body: notif['message'] ?? '',
            time: notif['created_at'] ?? 'Baru saja',
            icon: iconData,
            iconColor: iconColor,
            isRead: notif['is_read'] ?? false,
          );
        }).toList();

        // Masukkan semua data dari server ke list UI
        notifications.assignAll(mappedItems);
      }
    } catch (e) {
      print("[NotificationController] Gagal fetch server: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================================================
  // Biar fungsi instan lokal lu tetep bisa nyelip ke dalam list layar
  // ========================================================================
  void _addToHistory(String title, String body, IconData icon, Color color) {
    notifications.insert(0, NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      time: "Baru Saja", 
      icon: icon,
      iconColor: color,
      isRead: false
    ));
  }

  // ========================================================================
  // KATEGORI A: INSTANT TRIGGERS (Lokal + Tetap Berjalan)
  // ========================================================================

  void triggerTestNotification() {
    _notifHelper.showInstantNotification(
      id: 99, 
      title: "Halo Peneliti Muda! 🧪", 
      body: "Jangan lupa cek materi Biologi hari ini ya!"
    );
    _addToHistory("Halo Peneliti Muda! 🧪", "Jangan lupa cek materi Biologi hari ini ya!", Icons.notifications_active, Colors.green);
  }

  void checkXPMilestone(int currentXP) {
    if (currentXP > 0 && currentXP % 500 == 0) {
      String title = "Level Up! XP Tembus $currentXP! 🚀";
      String body = "Kamu makin jago! Pertahankan semangat belajarmu.";
      
      _notifHelper.showInstantNotification(id: 400, title: title, body: body);
      _addToHistory(title, body, Icons.star_rounded, Colors.purple);
    }
  }

  void unlockBadge(String badgeName) {
    String title = "Lencana Baru: $badgeName! 🏅";
    String body = "Cek koleksi lencana barumu di profil.";

    _notifHelper.showInstantNotification(id: 500, title: title, body: body);
    _addToHistory(title, body, Icons.military_tech, Colors.amber);
  }

  void unlockNewChapter(String chapterName) {
    String title = "Bab Terbuka: $chapterName 🔓";
    String body = "Siap melanjutkan petualangan sains? Yuk mulai!";

    _notifHelper.showInstantNotification(id: 600, title: title, body: body);
    _addToHistory(title, body, Icons.lock_open_rounded, Colors.blueAccent);
  }

  // ========================================================================
  // KATEGORI B: SCHEDULED TRIGGERS (Alarm Lokal Latar Belakang)
  // ========================================================================

  void setDailyReminder(int hour, int minute) {
    _notifHelper.scheduleDailyNotification(
      id: 100,
      title: "Waktunya Belajar! ⏰",
      body: "Luangkan 15 menit hari ini biar makin pintar.",
      hour: hour,
      minute: minute,
    );
    box.write('reminder_hour', hour);
    box.write('reminder_minute', minute);
    Get.snackbar("Pengingat", "Diatur setiap jam $hour:$minute");
  }

  void scheduleReviewReminder(String topicName) {
    _notifHelper.scheduleFutureNotification(
      id: topicName.hashCode, 
      title: "Ingat materi $topicName? 🧠",
      body: "Sudah 24 jam nih. Coba tes ingatanmu yuk!",
      delay: const Duration(hours: 24), 
    );
  }

  void checkQuizResult(int score, String subject) {
    if (score < 60) {
      _notifHelper.scheduleFutureNotification(
        id: 700,
        title: "Jangan Menyerah di $subject! 💪",
        body: "Yuk review materi sebentar dan coba lagi nanti.",
        delay: const Duration(hours: 2), 
      );
    }
  }

  void _checkDailyLogin() {
    box.write('last_login', DateTime.now().toString());
    _notifHelper.cancelNotification(888); 

    _notifHelper.scheduleDailyNotification(
      id: 888,
      title: "Streak-mu dalam bahaya! 🔥",
      body: "Login sekarang untuk menyelamatkan api semangatmu!",
      hour: 20, 
      minute: 0,
    );
  }

  void _scheduleWeekendPromo() {
    int weekday = DateTime.now().weekday;
    if (weekday == 6 || weekday == 7) { 
       _notifHelper.scheduleDailyNotification(
        id: 900,
        title: "Weekend Mode 🍃",
        body: "Santai dulu sejenak sambil baca fakta unik sains.",
        hour: 10,
        minute: 0,
      );
    } else {
      _notifHelper.cancelNotification(900);
    }
  }

  void markAsRead(int id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }

  void clearAll() {
    if(notifications.isEmpty) return;
    Get.defaultDialog(
      title: "Hapus Semua?",
      middleText: "Yakin hapus semua riwayat notifikasi?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        notifications.clear();
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }
}