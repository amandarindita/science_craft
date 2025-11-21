// ----- GANTI SEMUA ISI FILE ChatbotController.dart KAMU DENGAN INI -----

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert'; // <-- TAMBAH: Untuk JSON
import 'package:http/http.dart' as http; // <-- TAMBAH: Untuk HTTP

// Model sederhana untuk satu pesan chat
class ChatMessage {
  final String text;
  final bool isUser; // true jika dari user, false jika dari bot
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotController extends GetxController {
  final textController = TextEditingController();
  final scrollController = ScrollController(); // Untuk auto-scroll

  // Daftar semua pesan
  final messages = <ChatMessage>[].obs;

  // State untuk menandai bot sedang "berpikir"
  final isBotTyping = false.obs;

  // <-- TAMBAH: Alamat IP Backend kamu -->
  // !! GANTI IP INI DENGAN IP DARI TERMINAL FLASK KAMU !!
  final String _baseUrl = 'http://192.168.0.28:5000'; 

  @override
  void onInit() {
    super.onInit();
    // Tambahkan pesan sambutan dari bot saat halaman dibuka
    messages.add(
      ChatMessage(
        text: 'Hai! Aku SENA (Science Education Navigator Assistant) 🧪 Si teman sains ceria yang siap bantu kamu jelajahi dunia sains dengan cara seru dan mudah! Mau bahas apa hari ini?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  // Fungsi untuk mengirim pesan
  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    // 1. Tampilkan pesan user di layar
    messages.add(
      ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    // 2. Kosongkan text field
    textController.clear();
    // 3. Auto-scroll ke pesan terbaru
    _scrollToBottom();

    // 4. Tampilkan indikator "bot sedang mengetik"
    isBotTyping.value = true;

    // 5. Panggil API backend (bukan lagi simulasi delay)
    _getBotResponse(text);
  }

  // <-- UBAH: Logika ini diubah total untuk memanggil API -->
  Future<void> _getBotResponse(String userMessage) async {
    String responseText;

    try {
      // Kirim pesan user ke backend
      final response = await http.post(
        Uri.parse('$_baseUrl/chat-gemini'), // Panggil endpoint /chat-gemini
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': userMessage, // Kirim pesan dalam format JSON
        }),
      );

      // Cek apakah server membalas dengan sukses (status code 200)
      if (response.statusCode == 200) {
        // Ambil balasan 'reply' dari JSON
        final data = jsonDecode(response.body);
        responseText = data['reply'];
      } else {
        // Tampilkan pesan error jika server gagal memproses
        responseText = 'Oops! Server lagi ada gangguan nih. Coba lagi ya. (Error: ${response.statusCode})';
      }
    } catch (e) {
      // Tampilkan pesan error jika HP gagal terhubung ke server
      // (misal: WiFi mati, IP salah, server mati)
      responseText = 'Gagal terhubung ke server. Cek koneksi internet/WiFi kamu dan pastikan IP-nya benar ya. (Error: $e)';
    }

    // 6. Matikan "bot sedang mengetik"
    isBotTyping.value = false;

    // 7. Tampilkan balasan DARI SERVER di layar
    messages.add(
      ChatMessage(
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    // 8. Scroll ke bawah
    _scrollToBottom();
  }

  // Fungsi untuk otomatis scroll ke pesan paling bawah
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}