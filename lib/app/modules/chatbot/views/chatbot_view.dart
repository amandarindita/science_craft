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
              child: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [primary, cyan]),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Aira AI",
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: text)),
              Text("Biology Inquiry Assistant",
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.more_vert_rounded)
        ],
      ),
    );
  }

  Widget _chat(BuildContext context) {
    return Obx(() {
      if (controller.messages.isEmpty) {
        return _welcome();
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(18),
        itemCount: controller.messages.length,
        itemBuilder: (_, i) => _bubble(controller.messages[i]),
      );
    });
  }

  Widget _welcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [primary, cyan]),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 45),
          ),
          const SizedBox(height: 20),
          const Text(
            "Halo, saya Aira 👋",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Asisten AI untuk pembelajaran Biologi",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _bubble(ChatMessage msg) {
    final user = msg.isUser;

    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 330),
        decoration: BoxDecoration(
          gradient: user
              ? const LinearGradient(colors: [primary, cyan])
              : null,
          color: user ? null : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: MarkdownBody(
          data: msg.text,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: user ? Colors.white : text,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actions() {
    final list = [
      "Jelaskan konsep",
      "Buat analogi",
      "Buat soal",
    ];

    return SizedBox(
      height: 55,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: list
            .map((e) => Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      controller.textController.text = e;
                      controller.sendMessage();
                    },
                    child: Text(e),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _input() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              decoration: InputDecoration(
                hintText: "Tanyakan sesuatu...",
                filled: true,
                fillColor: bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: primary,
            child: IconButton(
              onPressed: controller.sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
