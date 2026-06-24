import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- IMPORT BARU KITA ---
import '../../../data/api_service.dart';
import '../../../data/auth_service.dart'; // Opsional, kalau endpoint chat butuh token login

class ChatMessage {
  final String text;
  final bool isUser; 
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotController extends GetxController {
  final textController = TextEditingController();
  final scrollController = ScrollController(); 
  final messages = <ChatMessage>[].obs;
  final isBotTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    messages.add(
      ChatMessage(
        text: 'Hai! Aku SENA (Science Education Navigator Assistant) 🧪 Si teman sains ceria yang siap bantu kamu jelajahi dunia sains dengan cara seru dan mudah! Mau bahas apa hari ini?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    // 1. Tampilkan pesan user
    messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
    textController.clear();
    _scrollToBottom();

    // 2. Tampilkan indikator "berpikir"
    isBotTyping.value = true;

    // 3. Panggil API backend
    _getBotResponse(text);
  }

  Future<void> _getBotResponse(String userMessage) async {
    String responseText;

    try {
      // Kita pakai ApiService.baseUrl biar dinamis!
      // Pastikan endpoint di Flask kamu namanya '/chat' (atau sesuaikan jika '/chat-gemini')
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/chat'), 
        headers: {
          'Content-Type': 'application/json',
          // Jika backend Flask kamu pasang @jwt_required() di route chat, nyalakan baris di bawah ini:
          // 'Authorization': 'Bearer ${Get.find<AuthService>().token}'
        },
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        responseText = data['reply'] ?? data['response'] ?? 'Maaf, SENA tidak mengerti format balasan ini.'; 
      } else {
        responseText = 'Oops! Server lagi ada gangguan nih. Coba lagi ya. (Error: ${response.statusCode})';
      }
    } catch (e) {
      responseText = 'Gagal terhubung ke server. Cek koneksi internet/WiFi kamu dan pastikan server menyala ya.';
    }

    // 4. Matikan indikator "berpikir" & tampilkan pesan
    isBotTyping.value = false;
    messages.add(ChatMessage(text: responseText, isUser: false, timestamp: DateTime.now()));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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