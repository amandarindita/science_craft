import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../notification_helper.dart';
import '../../../data/api_service.dart';
import '../../../widgets/app_snackbar.dart';

enum NotificationCategory {
  all,
  unread,
  achievement,
  reminder,
}

class NotificationItem {
  final int id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color iconColor;
  final String categoryName;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.categoryName = 'Info',
    this.isRead = false,
  });
}

class NotificationController extends GetxController {
  final NotificationHelper _notifHelper = NotificationHelper();
  final box = GetStorage();

  final notifications = <NotificationItem>[].obs;
  final isLoading = false.obs;
  final selectedFilter = NotificationCategory.all.obs;

  static const String _readIdsKey = 'notif_read_ids';
  static const String _deletedIdsKey = 'notif_deleted_ids';

  Set<String> _getReadIds() {
    final List<dynamic>? raw = box.read<List<dynamic>>(_readIdsKey);
    return raw?.map((e) => e.toString()).toSet() ?? <String>{};
  }

  void _saveReadIds(Set<String> ids) {
    box.write(_readIdsKey, ids.toList());
  }

  Set<String> _getDeletedIds() {
    final List<dynamic>? raw = box.read<List<dynamic>>(_deletedIdsKey);
    return raw?.map((e) => e.toString()).toSet() ?? <String>{};
  }

  void _saveDeletedIds(Set<String> ids) {
    box.write(_deletedIdsKey, ids.toList());
  }

  int get unreadCount => notifications.where((item) => !item.isRead).length;

  int get achievementCount => notifications
      .where((item) =>
          item.categoryName == 'Prestasi' ||
          item.categoryName == 'Streak' ||
          item.categoryName == 'Level Up')
      .length;

  int get reminderCount => notifications
      .where((item) =>
          item.categoryName == 'Pengingat' ||
          item.categoryName == 'Materi' ||
          item.categoryName == 'Review' ||
          item.categoryName == 'Info')
      .length;

  List<NotificationItem> get filteredNotifications {
    switch (selectedFilter.value) {
      case NotificationCategory.unread:
        return notifications.where((item) => !item.isRead).toList();
      case NotificationCategory.achievement:
        return notifications
            .where((item) =>
                item.categoryName == 'Prestasi' ||
                item.categoryName == 'Streak' ||
                item.categoryName == 'Level Up')
            .toList();
      case NotificationCategory.reminder:
        return notifications
            .where((item) =>
                item.categoryName == 'Pengingat' ||
                item.categoryName == 'Materi' ||
                item.categoryName == 'Review' ||
                item.categoryName == 'Info')
            .toList();
      case NotificationCategory.all:
      default:
        return notifications;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _notifHelper.initNotification();

    // Jalankan alarm/push lokal terjadwal
    _checkDailyLogin();
    _scheduleWeekendPromo();

    // Ambil data notifikasi dari server Flask
    fetchServerNotifications();
  }

  void changeFilter(NotificationCategory category) {
    selectedFilter.value = category;
  }

  // ========================================================================
  // 🔄 SYNC ENGINE: AMBIL DATA DARI SERVER FLASK + LOCAL CACHE
  // ========================================================================
  Future<void> fetchServerNotifications() async {
    try {
      isLoading.value = true;

      final List<dynamic>? serverData = await ApiService.getNotifications();
      final localReadIds = _getReadIds();
      final localDeletedIds = _getDeletedIds();

      if (serverData != null) {
        List<NotificationItem> mappedItems = [];

        for (final notif in serverData) {
          final int notifId = notif['id'] is int
              ? notif['id']
              : int.tryParse(notif['id']?.toString() ?? '') ??
                  DateTime.now().millisecondsSinceEpoch;

          final strId = notifId.toString();

          // Skip if user has deleted this notification locally
          if (localDeletedIds.contains(strId)) {
            continue;
          }

          final String title = notif['title'] ?? '';
          final String body = notif['message'] ?? '';
          final String textLower = ('$title $body').toLowerCase();

          IconData iconData = Icons.notifications_active_rounded;
          Color iconColor = const Color(0xFF3B82F6);
          String categoryName = 'Info';

          if (textLower.contains('badge') ||
              textLower.contains('lencana') ||
              textLower.contains('piala') ||
              textLower.contains('prestasi')) {
            iconData = Icons.emoji_events_rounded;
            iconColor = const Color(0xFFF59E0B);
            categoryName = 'Prestasi';
          } else if (textLower.contains('level') ||
              textLower.contains(' xp') ||
              textLower.contains('+xp') ||
              textLower.contains('naik level')) {
            iconData = Icons.rocket_launch_rounded;
            iconColor = const Color(0xFF8B5CF6);
            categoryName = 'Level Up';
          } else if (textLower.contains('streak') ||
              textLower.contains('api') ||
              textLower.contains('semangat')) {
            iconData = Icons.local_fire_department_rounded;
            iconColor = const Color(0xFFEF4444);
            categoryName = 'Streak';
          } else if (textLower.contains('bab') ||
              textLower.contains('materi') ||
              textLower.contains('eksperimen') ||
              textLower.contains('lab') ||
              textLower.contains('terbuka')) {
            iconData = Icons.menu_book_rounded;
            iconColor = const Color(0xFF06B6D4);
            categoryName = 'Materi';
          } else if (textLower.contains('belajar') ||
              textLower.contains('pengingat') ||
              textLower.contains('waktunya') ||
              textLower.contains('alarm') ||
              textLower.contains('review') ||
              textLower.contains('ingat') ||
              textLower.contains('⏰')) {
            iconData = Icons.alarm_rounded;
            iconColor = const Color(0xFF10B981);
            categoryName = 'Pengingat';
          }

          final bool isItemRead =
              notif['is_read'] == true || localReadIds.contains(strId);

          mappedItems.add(
            NotificationItem(
              id: notifId,
              title: title,
              body: body,
              time: _formatTimestamp(notif['created_at']?.toString()),
              icon: iconData,
              iconColor: iconColor,
              categoryName: categoryName,
              isRead: isItemRead,
            ),
          );
        }

        notifications.assignAll(mappedItems);
      }
    } catch (e) {
      debugPrint("[NotificationController] Gagal fetch server: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _formatTimestamp(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Baru Saja';
    try {
      final dt = DateTime.tryParse(raw);
      if (dt == null) return raw;
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Baru Saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  void _addToHistory(
    String title,
    String body,
    IconData icon,
    Color color,
    String category,
  ) {
    notifications.insert(
      0,
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        body: body,
        time: "Baru Saja",
        icon: icon,
        iconColor: color,
        categoryName: category,
        isRead: false,
      ),
    );
  }

  // ========================================================================
  // KATEGORI A: INSTANT TRIGGERS (Lokal + Feedback Nyata)
  // ========================================================================

  void triggerTestNotification() {
    const String title = "Materi Baru Tersedia: Reaksi Kimia! 🧪";
    const String body =
        "Modul eksperimen baru dan quest harian sudah siap untuk kamu jelajahi!";

    _notifHelper.showInstantNotification(
      id: 99,
      title: title,
      body: body,
    );
    _addToHistory(
      title,
      body,
      Icons.menu_book_rounded,
      const Color(0xFF06B6D4),
      "Materi",
    );

    AppSnackbar.success(
      'Notifikasi Dikirim 🔔',
      'Notifikasi uji coba info materi berhasil dimunculkan!',
    );
  }

  void checkXPMilestone(int currentXP) {
    if (currentXP > 0 && currentXP % 500 == 0) {
      String title = "Level Up! XP Tembus $currentXP! 🚀";
      String body = "Kamu makin jago! Pertahankan semangat belajarmu.";

      _notifHelper.showInstantNotification(id: 400, title: title, body: body);
      _addToHistory(
        title,
        body,
        Icons.rocket_launch_rounded,
        const Color(0xFF8B5CF6),
        "Level Up",
      );
    }
  }

  void unlockBadge(String badgeName) {
    String title = "Lencana Baru: $badgeName! 🏅";
    String body = "Cek koleksi lencana barumu di profil.";

    _notifHelper.showInstantNotification(id: 500, title: title, body: body);
    _addToHistory(
      title,
      body,
      Icons.military_tech_rounded,
      const Color(0xFFF59E0B),
      "Prestasi",
    );
  }

  void unlockNewChapter(String chapterName) {
    String title = "Bab Terbuka: $chapterName 🔓";
    String body = "Siap melanjutkan petualangan sains? Yuk mulai!";

    _notifHelper.showInstantNotification(id: 600, title: title, body: body);
    _addToHistory(
      title,
      body,
      Icons.menu_book_rounded,
      const Color(0xFF06B6D4),
      "Materi",
    );
  }

  // ========================================================================
  // KATEGORI B: SCHEDULED TRIGGERS
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
    AppSnackbar.success(
      "Pengingat Aktif ⏰",
      "Pengingat belajar dijadwalkan setiap jam ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}",
    );
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

  // ========================================================================
  // KONTROL STATUS ITEM & PERSISTENCE
  // ========================================================================

  void markAsRead(int id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index].isRead = true;
      notifications.refresh();

      // Persist locally
      final readIds = _getReadIds();
      readIds.add(id.toString());
      _saveReadIds(readIds);

      // Sync with backend API
      ApiService.markNotificationAsRead(id);
    }
  }

  void markAllAsRead() {
    if (notifications.isEmpty) return;
    bool hasUnread = false;
    final readIds = _getReadIds();

    for (var item in notifications) {
      if (!item.isRead) {
        item.isRead = true;
        hasUnread = true;
        readIds.add(item.id.toString());
      }
    }

    if (hasUnread) {
      notifications.refresh();
      _saveReadIds(readIds);

      // Sync with backend API
      ApiService.markAllNotificationsAsRead();

      AppSnackbar.success(
        'Selesai 🎉',
        'Semua notifikasi telah ditandai sudah dibaca.',
      );
    }
  }

  void deleteNotification(int id) {
    notifications.removeWhere((item) => item.id == id);

    // Persist deleted state locally
    final deletedIds = _getDeletedIds();
    deletedIds.add(id.toString());
    _saveDeletedIds(deletedIds);

    // Sync with backend API
    ApiService.deleteNotification(id);
  }

  void clearAll() {
    if (notifications.isEmpty) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Color(0xFFEF4444),
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Hapus Semua Notifikasi?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Semua riwayat notifikasi akan dibersihkan. Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Mark all current IDs as deleted locally
                        final deletedIds = _getDeletedIds();
                        for (final item in notifications) {
                          deletedIds.add(item.id.toString());
                        }
                        _saveDeletedIds(deletedIds);

                        notifications.clear();
                        Get.back();

                        // Sync with backend API
                        ApiService.clearAllNotifications();

                        AppSnackbar.success(
                          'Riwayat Dibersihkan',
                          'Semua notifikasi berhasil dihapus.',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Ya, Hapus',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}