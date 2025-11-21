import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chatbot_controller.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A90E2), // Latar belakang biru tua
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white, // Background chat putih
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/pattern.png'),
                    repeat: ImageRepeat.repeat,
                    scale: 5.0,
                    opacity: 0.05,
                  ),
                ),
                child: Column(
                  children: [
                    // Daftar Chat
                    Expanded(
                      child: Obx(
                        () => ListView.builder(
                          controller: controller.scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.messages.length + (controller.isBotTyping.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Tampilkan indikator "mengetik"
                            if (index == controller.messages.length) {
                              return _ChatBubble(
                                message: ChatMessage(
                                  text: '...',
                                  isUser: false,
                                  timestamp: DateTime.now(),
                                ),
                              );
                            }
                            final message = controller.messages[index];
                            return _ChatBubble(message: message);
                          },
                        ),
                      ),
                    ),
                    // Input Area
                    _buildChatInput(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const CircleAvatar(
            backgroundImage: AssetImage('assets/logo_robot.png'), // Ganti dengan logo bot
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SciBot',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Online',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.textController,
                onSubmitted: (value) => controller.sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Ketik pesanmu...',
                  filled: true,
                  fillColor: const Color(0xFFF4F6FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF1E3A8A),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: () => controller.sendMessage(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Widget helper untuk gelembung chat
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF1E3A8A) : const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: isUser ? const Radius.circular(5) : const Radius.circular(20),
              bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(5),
            ),
          ),
          // --- PERUBAHAN DI SINI ---
          // Kita ganti Text(...) jadi MarkdownBody(...)
          child: MarkdownBody(
            data: message.text, // Teks dari Gemini
            selectable: true,   // Supaya bisa dicopy
            styleSheet: MarkdownStyleSheet(
              // 'p' = Teks biasa (Paragraph)
              p: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
              // 'strong' = Teks Bold (**teks**)
              strong: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold, // Jadi Tebal!
              ),
            ),
          ),
          // -------------------------
        ),
      ),
    );
  }
}