import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../controllers/chatbot_controller.dart';

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({super.key});

  static const Color primary = Color(0xFF2563EB);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color bg = Color(0xFFF4F8FF);
  static const Color text = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 30,
                      color: Color(0x16000000),
                      offset: Offset(0, 12),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(child: _chat(context)),
                    _actions(),
                    _input(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          InkWell(
            onTap: Get.back,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [primary, cyan]),
            ),
            // Pakai icon science biar lebih cocok dengan SENA
            child: const Icon(Icons.science_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SENA",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: text)),
                Text("Science Education Navigator",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: text),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget _chat(BuildContext context) {
    return Obx(() {
      if (controller.messages.isEmpty) {
        return _welcome();
      }

      // Tambahkan 1 item ekstra jika isBotTyping true
      final itemCount = controller.messages.length + (controller.isBotTyping.value ? 1 : 0);

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(18),
        itemCount: itemCount,
        itemBuilder: (_, i) {
          // Jika indeks mencapai panjang pesan, berarti ini giliran indikator mengetik
          if (i == controller.messages.length) {
            return _typingIndicator();
          }
          return _bubble(controller.messages[i]);
        },
      );
    });
  }

  Widget _welcome() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [primary, cyan]),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Icon(Icons.science_rounded,
                  color: Colors.white, size: 45),
            ),
            const SizedBox(height: 24),
            const Text(
              "Halo, aku SENA 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Teman sains ceria yang siap\nbantu kamu jelajahi dunia sains!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(ChatMessage msg) {
    final user = msg.isUser;

    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          gradient: user
              ? const LinearGradient(colors: [primary, cyan])
              : null,
          color: user ? null : const Color(0xFFF8FAFC),
          border: user ? null : Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: user ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: user ? const Radius.circular(4) : const Radius.circular(20),
          ),
        ),
        child: MarkdownBody(
          data: msg.text,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: user ? Colors.white : text,
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: const BoxConstraints(maxWidth: 200),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: const Text(
          "SENA sedang memikirkan sains...",
          style: TextStyle(
            color: Colors.grey, 
            fontSize: 13, 
            fontStyle: FontStyle.italic
          ),
        ),
      ),
    );
  }

  Widget _actions() {
    final list = [
      "🔬 Jelaskan konsep",
      "💡 Buat analogi",
      "🧪 Ide eksperimen",
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final e = list[index];
          return ActionChip(
            label: Text(e, style: const TextStyle(fontSize: 13, color: primary, fontWeight: FontWeight.w600)),
            backgroundColor: bg,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              controller.textController.text = e.substring(3); 
              controller.sendMessage();
            },
          );
        },
      ),
    );
  }

  Widget _input() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              decoration: InputDecoration(
                hintText: "Tanyakan sesuatu tentang sains...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: bg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              // Opsional: Tekan enter/done di keyboard langsung ngirim pesan
              onSubmitted: (_) => controller.sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [primary, cyan]),
            ),
            child: IconButton(
              onPressed: controller.sendMessage,
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          )
        ],
      ),
    );
  }
}