import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String category; // 'all', 'general', 'xp', 'lab', 'account'
  final IconData icon;

  FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.icon = Icons.help_outline_rounded,
  });
}

class FaqController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString selectedCategory = 'all'.obs;
  final RxString searchQuery = ''.obs;

  final RxList<FaqItem> _allFaqs = <FaqItem>[
    FaqItem(
      id: '1',
      question: 'Apa itu platform Science Craft?',
      answer:
          'Science Craft adalah platform edukasi sains virtual interaktif untuk jenjang SMA yang menggabungkan simulasi laboratorium, materi ringkas terstruktur, kuis adaptif, dan asisten chatbot AI.',
      category: 'general',
      icon: Icons.science_outlined,
    ),
    FaqItem(
      id: '2',
      question: 'Apa tujuan utama dari Science Craft?',
      answer:
          'Memberikan pengalaman praktikum sains yang aman, mudah diakses, dan menarik kapan saja, mengatasi kendala keterbatasan alat atau bahan kimia di laboratorium fisik sekolah.',
      category: 'general',
      icon: Icons.lightbulb_outline_rounded,
    ),
    FaqItem(
      id: '3',
      question: 'Bagaimana cara kerja sistem XP dan Level Pembelajaran?',
      answer:
          'XP diperoleh setiap kali kamu menyelesaikan materi bacaan, kuis penilaian, atau simulasi lab. Kenaikan level pembelajaran didasarkan pada jumlah modul yang berhasil diselesaikan, bukan hanya dari XP semata.',
      category: 'xp',
      icon: Icons.bolt_rounded,
    ),
    FaqItem(
      id: '4',
      question: 'Bagaimana cara membuka bingkai avatar dan badge prestasi?',
      answer:
          'Kamu dapat mengumpulkan koin milestone dan menyelesaikan tantangan capaian untuk membuka bingkai avatar eksklusif di menu Koleksi Milestone pada halaman profil.',
      category: 'xp',
      icon: Icons.workspace_premium_rounded,
    ),
    FaqItem(
      id: '5',
      question: 'Bagaimana cara menjalankan simulasi di Lab Virtual?',
      answer:
          'Masuk ke menu Lab Sains, pilih topik praktikum (Fisika, Kimia, atau Biologi) yang sudah terbuka, lalu ikuti panduan interaktif pada kanvas eksperimen digital.',
      category: 'lab',
      icon: Icons.biotech_rounded,
    ),
    FaqItem(
      id: '6',
      question: 'Apakah asisten Chatbot AI bisa membantu mengerjakan soal?',
      answer:
          'Asisten AI Science Craft dirancang sebagai tutor belajar pintar untuk menjelaskan konsep teori sains, rumus fisika, reaksi kimia, dan biologi secara bertahap.',
      category: 'general',
      icon: Icons.smart_toy_outlined,
    ),
    FaqItem(
      id: '7',
      question: 'Apakah data belajar dan nilai tersimpan secara otomatis?',
      answer:
          'Ya, seluruh progres modul, riwayat kuis, perolehan XP, dan status streak harian tersinkronisasi otomatis ke akun cloud kamu.',
      category: 'account',
      icon: Icons.cloud_done_outlined,
    ),
    FaqItem(
      id: '8',
      question: 'Bagaimana jika saya lupa kata sandi akun?',
      answer:
          'Kamu dapat menggunakan fitur Lupa Password pada halaman Login untuk menerima kode OTP verifikasi dan membuat kata sandi baru. Bagi akun Google Sign-In, keamanan dikelola langsung oleh akun Google.',
      category: 'account',
      icon: Icons.lock_outline_rounded,
    ),
  ].obs;

  final RxList<FaqItem> filteredFaqs = <FaqItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _applyFilters();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text.trim().toLowerCase();
    _applyFilters();
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchQuery.value;
    final cat = selectedCategory.value;

    List<FaqItem> result = _allFaqs;

    if (cat != 'all') {
      result = result.where((item) => item.category == cat).toList();
    }

    if (query.isNotEmpty) {
      result = result
          .where((item) =>
              item.question.toLowerCase().contains(query) ||
              item.answer.toLowerCase().contains(query))
          .toList();
    }

    filteredFaqs.assignAll(result);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
