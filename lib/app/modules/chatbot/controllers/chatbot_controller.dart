import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/api_client.dart';
import '../../profile/controllers/profile_controller.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Rx<String?> feedback;

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    String? feedback,
  })  : id = id ??
            '${DateTime.now().millisecondsSinceEpoch}_${isUser ? 'u' : 'b'}',
        timestamp = timestamp ?? DateTime.now(),
        feedback = Rx<String?>(feedback);
}

class ChatbotController extends GetxController {
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final inputFocusNode = FocusNode();

  final messages = <ChatMessage>[].obs;
  final isBotTyping = false.obs;
  final hasUserTyped = false.obs;

  // Audio / TTS state
  late final FlutterTts flutterTts;
  final currentlySpeakingId = ''.obs;
  final isTtsAvailable = true.obs;

  final samplePrompts = const [
    '🌱 Jelaskan bagaimana proses fotosintesis menghasilkan oksigen',
    '⚡ Bagaimana hukum aksi-reaksi Newton bekerja pada roket?',
    '🧪 Mengapa minyak dan air tidak bisa menyatu secara alami?',
    '🌌 Apa yang terjadi di dalam lubang hitam (Black Hole)?',
  ];

  @override
  void onInit() {
    super.onInit();
    _initTts();

    textController.addListener(() {
      final hasText = textController.text.trim().isNotEmpty;
      if (hasUserTyped.value != hasText) {
        hasUserTyped.value = hasText;
      }
    });

    _sendWelcomeMessage();
  }

  Future<void> _initTts() async {
    try {
      flutterTts = FlutterTts();
      await flutterTts.setLanguage('id-ID');
      await flutterTts.setSpeechRate(0.52);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      flutterTts.setCompletionHandler(() {
        currentlySpeakingId.value = '';
      });

      flutterTts.setCancelHandler(() {
        currentlySpeakingId.value = '';
      });

      flutterTts.setErrorHandler((_) {
        currentlySpeakingId.value = '';
      });
    } catch (_) {
      isTtsAvailable.value = false;
    }
  }

  String getUserName() {
    try {
      if (Get.isRegistered<ProfileController>()) {
        final name = Get.find<ProfileController>().userName.value;
        if (name.isNotEmpty && name != 'Loading...') return name;
      }
    } catch (_) {}

    final box = GetStorage();
    final storedName = box.read('userName') ?? box.read('user_name');
    if (storedName != null && storedName.toString().trim().isNotEmpty) {
      return storedName.toString().trim();
    }
    return 'Sobat Sains';
  }

  void _sendWelcomeMessage() {
    final name = getUserName();
    messages.add(
      ChatMessage(
        text:
            'Hai **$name**! 👋 Aku **SENA**, asisten belajar sainsmu. Tanyakan konsep biologi, fisika, kimia, atau materi sains apa pun yang ingin kamu pahami hari ini.',
        isUser: false,
      ),
    );
  }

  void usePrompt(String promptText) {
    // Bersihkan emoji awal jika ada
    final cleaned = promptText.replaceAll(RegExp(r'^[^\w\s]+\s*'), '').trim();
    textController.text = cleaned.isNotEmpty ? cleaned : promptText;
    sendMessage();
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty || isBotTyping.value) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
    );

    messages.add(userMessage);
    textController.clear();
    _scrollToBottom();

    HapticFeedback.lightImpact();

    // Dapatkan balasan dari API
    _getBotResponse(text);
  }

  Future<void> _getBotResponse(String userMessage) async {
    isBotTyping.value = true;
    _scrollToBottom();

    String responseText;

    try {
      final response = await ApiClient.post(
        Uri.parse('${ApiClient.baseUrl}/chat'),
        body: jsonEncode({
          'message': userMessage,
        }),
      );

      if (response.statusCode == 200) {
        final data = ApiClient.decodeMap(response.body);
        responseText = data['reply']?.toString() ??
            data['response']?.toString() ??
            data['message']?.toString() ??
            'SENA telah menerima pertanyaanmu, namun format balasan tidak terdeteksi.';
      } else {
        responseText =
            'Oops! Terjadi kendala saat menghubungkan ke server (Kode ${response.statusCode}). Silakan coba sesaat lagi ya.';
      }
    } catch (e) {
      responseText =
          'Gagal terhubung ke server SENA. Pastikan koneksi internet aktif dan server menyala.';
    }

    isBotTyping.value = false;
    final botMsg = ChatMessage(
      text: responseText,
      isUser: false,
    );

    messages.add(botMsg);
    _scrollToBottom();
  }

  Future<void> toggleSpeak(ChatMessage msg) async {
    if (!isTtsAvailable.value) {
      Get.rawSnackbar(
        message: 'Text-to-Speech tidak didukung pada perangkat ini.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (currentlySpeakingId.value == msg.id) {
      await flutterTts.stop();
      currentlySpeakingId.value = '';
    } else {
      await flutterTts.stop();
      currentlySpeakingId.value = msg.id;
      final cleanText = _stripMarkdown(msg.text);
      await flutterTts.speak(cleanText);
    }
  }

  String _stripMarkdown(String markdown) {
    return markdown
        .replaceAll(RegExp(r'\*\*|\*|__|_|`|#'), '')
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1')
        .replaceAll(RegExp(r'^[>\-\*\+]\s+', multiLine: true), '')
        .trim();
  }

  void setFeedback(ChatMessage msg, String type) {
    if (msg.feedback.value == type) {
      msg.feedback.value = null;
    } else {
      msg.feedback.value = type;
      HapticFeedback.selectionClick();
    }
  }

  void copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.selectionClick();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'Teks disalin ke clipboard',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.95),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void clearMessages() {
    flutterTts.stop();
    currentlySpeakingId.value = '';
    messages.clear();
    _sendWelcomeMessage();
    HapticFeedback.mediumImpact();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void onClose() {
    try {
      flutterTts.stop();
    } catch (_) {}
    textController.dispose();
    scrollController.dispose();
    inputFocusNode.dispose();
    super.onClose();
  }
}