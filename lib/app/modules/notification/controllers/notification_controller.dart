import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Tambahan buat simpan data
import 'dart:math'; // Buat logika random (opsional)

// Import helper yang sudah diedit tadi
import '../notification_helper.dart'; 

// Model tetap sama
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
  final box = GetStorage(); // Database lokal

  // Daftar notifikasi untuk tampilan UI (History)
  final notifications = <NotificationItem>[
    // Data dummy awal (Boleh dihapus kalau mau bersih)
    NotificationItem(
      id: 1,
      title: 'Streak Harian Tercapai!',
      body: 'Kerja bagus! Kamu telah menyelesaikan 3 materi berturut-turut.',
      time: 'Baru saja',
      icon: Icons.local_fire_department_rounded,
      iconColor: Colors.orange,
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _notifHelper.initNotification();
    
    // Cek logika otomatis saat aplikasi dibuka
    _checkDailyLogin(); // (Fitur Streak)
    _scheduleWeekendPromo(); // (Fitur Weekend)
  }

  // ========================================================================
  // FUNGSI BANTUAN (PRIVATE)
  // Biar setiap ada notifikasi, otomatis masuk ke List di layar juga
  // ========================================================================
  void _addToHistory(String title, String body, IconData icon, Color color) {
    notifications.insert(0, NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      time: "Baru Saja", // Bisa dikembangin pake library intl/date format
      icon: icon,
      iconColor: color,
      isRead: false
    ));
  }

  // ========================================================================
  // KATEGORI A: INSTANT TRIGGERS (Langsung Muncul Pop-up + Masuk History)
  // ========================================================================

  // [Test] Fungsi Tes Manual
  void triggerTestNotification() {
    _notifHelper.showInstantNotification(
      id: 99, 
      title: "Halo Peneliti Muda! 🧪", 
      body: "Jangan lupa cek materi Biologi hari ini ya!"
    );
    // Masukkan ke history layar
    _addToHistory("Halo Peneliti Muda!", "Jangan lupa cek materi...", Icons.notifications_active, Colors.green);
  }

  // [4] Milestone XP
  void checkXPMilestone(int currentXP) {
    if (currentXP > 0 && currentXP % 500 == 0) {
      String title = "Level Up! XP Tembus $currentXP! 🚀";
      String body = "Kamu makin jago! Pertahankan semangat belajarmu.";
      
      _notifHelper.showInstantNotification(id: 400, title: title, body: body);
      _addToHistory(title, body, Icons.star_rounded, Colors.purple);
    }
  }

  // [5] Badge Unlocked
  void unlockBadge(String badgeName) {
    String title = "Lencana Baru: $badgeName! 🏅";
    String body = "Cek koleksi lencana barumu di profil.";

    _notifHelper.showInstantNotification(id: 500, title: title, body: body);
    _addToHistory(title, body, Icons.military_tech, Colors.amber);
  }

  // [6] Content Unlocked (Bab Baru)
  void unlockNewChapter(String chapterName) {
    String title = "Bab Terbuka: $chapterName 🔓";
    String body = "Siap melanjutkan petualangan sains? Yuk mulai!";

    _notifHelper.showInstantNotification(id: 600, title: title, body: body);
    _addToHistory(title, body, Icons.lock_open_rounded, Colors.blueAccent);
  }

  // ========================================================================
  // KATEGORI B: SCHEDULED TRIGGERS (Hanya Pop-up Nanti, Tidak masuk History skrg)
  // ========================================================================

  // [1] Daily Reminder (Dari Settings)
  void setDailyReminder(int hour, int minute) {
    _notifHelper.scheduleDailyNotification(
      id: 100,
      title: "Waktunya Belajar! ⏰",
      body: "Luangkan 15 menit hari ini biar makin pintar.",
      hour: hour,
      minute: minute,
    );
    // Simpan preferensi user
    box.write('reminder_hour', hour);
    box.write('reminder_minute', minute);
    
    Get.snackbar("Pengingat", "Diatur setiap jam $hour:$minute");
  }

  // [2] Review Materi (Spaced Repetition)
  void scheduleReviewReminder(String topicName) {
    // Dijadwalkan 24 jam lagi
    _notifHelper.scheduleFutureNotification(
      id: topicName.hashCode, 
      title: "Ingat materi $topicName? 🧠",
      body: "Sudah 24 jam nih. Coba tes ingatanmu yuk!",
      delay: const Duration(hours: 24), 
    );
  }

  // [7] Remedial (Penyemangat saat nilai jelek)
  void checkQuizResult(int score, String subject) {
    if (score < 60) {
      // Jadwalkan 2 jam lagi
      _notifHelper.scheduleFutureNotification(
        id: 700,
        title: "Jangan Menyerah di $subject! 💪",
        body: "Yuk review materi sebentar dan coba lagi nanti.",
        delay: const Duration(hours: 2), 
      );
    }
  }

  // [3] & [8] Streak Rescue (Otomatis jalan di onInit)
  void _checkDailyLogin() {
    // 1. Simpan waktu login sekarang
    box.write('last_login', DateTime.now().toString());

    // 2. Batalkan notifikasi "Streak Warning" yang lama
    _notifHelper.cancelNotification(888); 

    // 3. Buat jadwal baru buat BESOK MALAM jam 20:00
    // Kalau besok user gak buka app, notif ini akan muncul.
    _notifHelper.scheduleDailyNotification(
      id: 888,
      title: "Streak-mu dalam bahaya! 🔥",
      body: "Login sekarang untuk menyelamatkan api semangatmu!",
      hour: 20, 
      minute: 0,
    );
  }

  // [9] Weekend Warrior (Otomatis jalan di onInit)
  void _scheduleWeekendPromo() {
    int weekday = DateTime.now().weekday;
    if (weekday == 6 || weekday == 7) { // Sabtu/Minggu
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

  // ========================================================================
  // FUNGSI BAWAAN LAMA (TIDAK BERUBAH)
  // ========================================================================

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