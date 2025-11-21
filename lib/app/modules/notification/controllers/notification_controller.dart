import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Model sederhana untuk data notifikasi
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
  // Daftar notifikasi (dummy)
  final notifications = <NotificationItem>[
    NotificationItem(
      id: 1,
      title: 'Streak Harian Tercapai!',
      body: 'Kerja bagus! Kamu telah menyelesaikan 3 materi berturut-turut.',
      time: 'Baru saja',
      icon: Icons.local_fire_department_rounded,
      iconColor: Colors.orange,
    ),
    NotificationItem(
      id: 2,
      title: 'Materi Baru Telah Rilis',
      body: 'Yuk, pelajari "Hukum Termodinamika" di modul Fisika!',
      time: '2 jam lalu',
      icon: Icons.science_outlined,
      iconColor: Colors.blue,
      isRead: true,
    ),
    NotificationItem(
      id: 3,
      title: 'Selamat Datang, Amanda!',
      body: 'Selamat bergabung di Science Craft. Ayo mulai petualangan sains pertamamu.',
      time: '1 hari lalu',
      icon: Icons.celebration_rounded,
      iconColor: Colors.purple,
      isRead: true,
    ),
  ].obs;

  // Fungsi untuk menandai notifikasi telah dibaca
  void markAsRead(int id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index].isRead = true;
      // 'refresh()' memberi tahu UI untuk update,
      // karena kita mengubah properti di dalam objek, bukan list-nya
      notifications.refresh();
    }
  }

  // Fungsi untuk menghapus semua notifikasi
  void clearAll() {
    if(notifications.isEmpty) {
      Get.snackbar('Notifikasi', 'Tidak ada notifikasi untuk dihapus.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // Tampilkan dialog konfirmasi
    Get.defaultDialog(
      title: "Hapus Semua?",
      middleText: "Apakah kamu yakin ingin menghapus semua notifikasi?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        notifications.clear();
        Get.back(); // Tutup dialog
      },
      onCancel: () => Get.back(), // Tutup dialog
    );
  }
}

