import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Model sederhana untuk data FAQ
class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class FaqController extends GetxController {
  final searchController = TextEditingController();

  // Daftar semua FAQ (data dummy)
  // Nanti bisa kamu ganti dari database juga kalau mau
  final _allFaqs = <FaqItem>[
    FaqItem(
      question: 'Apa itu Science Craft?',
      answer:
          'Science Craft adalah aplikasi eksperimen sains virtual berbasis gamifikasi yang membantu belajar Fisika, Kimia, dan Biologi dengan cara interaktif.',
    ),
    FaqItem(
      question: 'Apa Tujuan Utama Science Craft',
      answer:
          'Tujuannya untuk memberikan pengalaman belajar praktikum yang mudah, aman, dan menarik, terutama bagi sekolah yang memiliki keterbatasan fasilitas laboratorium.',
    ),
    FaqItem(
      question: 'Bagaimana cara kerja sistem XP (Experience Points)?',
      answer:
          'Kamu akan mendapatkan XP setiap kali berhasil menyelesaikan materi, kuis, atau eksperimen. Semakin tinggi XP, semakin tinggi level akun kamu!',
    ),
    FaqItem(
      question: 'Apakah aplikasi ini gratis?',
      answer:
          'Ya, aplikasi ini gratis untuk diunduh dan digunakan untuk semua materi dasar. Mungkin akan ada beberapa modul eksperimen premium di masa depan.',
    ),
  ].obs;

  // Daftar FAQ yang sudah difilter untuk ditampilkan
  final filteredFaqs = <FaqItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Tampilkan semua FAQ saat pertama kali dibuka
    filteredFaqs.assignAll(_allFaqs);
    // Tambahkan listener untuk memfilter saat user mengetik
    searchController.addListener(_filterFaqs);
  }

  void _filterFaqs() {
    String query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredFaqs.assignAll(_allFaqs);
    } else {
      filteredFaqs.value = _allFaqs
          .where((faq) =>
              faq.question.toLowerCase().contains(query) ||
              faq.answer.toLowerCase().contains(query))
          .toList();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
