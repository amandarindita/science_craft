import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/chatbot_controller.dart';

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({super.key});

  static const Color primary = Color(0xFF2563EB);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color text = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Color(0x0A000000),
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(child: _chat(context)),
                    _actions(),
                    const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          InkWell(
            onTap: Get.back,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: text),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [primary, cyan]),
              boxShadow: [
                BoxShadow(color: Color(0x332563EB), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Aira AI",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
                ),
                Text(
                  "Asisten Belajar Biologi",
                  style: GoogleFonts.inter(
                    color: muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chat(BuildContext context) {
    return Obx(() {
      if (controller.messages.isEmpty && !controller.isBotTyping.value) {
        return _welcome();
      }

      final itemCount = controller.messages.length + (controller.isBotTyping.value ? 1 : 0);

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: itemCount,
        itemBuilder: (_, i) {
          if (i == controller.messages.length) {
            return const _TypingIndicatorBubble();
          }
          return _AnimatedBubble(msg: controller.messages[i]);
        },
      );
    });
  }

  Widget _welcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [primary, cyan]),
                boxShadow: [
                  BoxShadow(color: Color(0x332563EB), blurRadius: 20, offset: Offset(0, 10)),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              "Halo, saya Aira 👋",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: text,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Asisten AI cerdas untuk menemani perjalanan belajar Biologimu. Tanyakan apa saja!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: muted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions() {
    final list = [
      "Jelaskan sel",
      "Analogi DNA",
      "Soal ekosistem",
    ];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: list.map((e) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: ActionChip(
              onPressed: () {
                controller.textController.text = e;
                controller.sendMessage();
              },
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              label: Text(
                e,
                style: GoogleFonts.inter(color: primary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _input() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: controller.textController,
                style: GoogleFonts.inter(color: text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Ketik pesan di sini...",
                  hintStyle: GoogleFonts.inter(color: muted, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: controller.sendMessage,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [primary, cyan]),
                boxShadow: [
                  BoxShadow(color: Color(0x332563EB), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          )
        ],
      ),
    );
  }
}

class _AnimatedBubble extends StatefulWidget {
  final ChatMessage msg;
  const _AnimatedBubble({required this.msg});

  @override
  State<_AnimatedBubble> createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<_AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.msg.isUser;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: user ? Alignment.bottomRight : Alignment.bottomLeft,
        child: Align(
          alignment: user ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              gradient: user
                  ? const LinearGradient(
                      colors: [ChatbotView.primary, ChatbotView.cyan],
                    )
                  : null,
              color: user ? null : Colors.white,
              boxShadow: user
                  ? [const BoxShadow(color: Color(0x332563EB), blurRadius: 8, offset: Offset(0, 3))]
                  : [const BoxShadow(color: Color(0x0A0F172A), blurRadius: 10, offset: Offset(0, 4))],
              border: user ? null : Border.all(color: const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: Radius.circular(user ? 24 : 6),
                bottomRight: Radius.circular(user ? 6 : 24),
              ),
            ),
            child: MarkdownBody(
              data: widget.msg.text,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.inter(
                  color: user ? Colors.white : ChatbotView.text,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                strong: GoogleFonts.inter(
                  color: user ? Colors.white : ChatbotView.text,
                  fontWeight: FontWeight.w800,
                ),
                code: TextStyle(
                  fontFamily: 'monospace',
                  backgroundColor: user ? Colors.black12 : const Color(0xFFF1F5F9),
                  color: user ? Colors.white : ChatbotView.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingIndicatorBubble extends StatelessWidget {
  const _TypingIndicatorBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 10, offset: Offset(0, 4))],
          border: Border.all(color: const Color(0xFFF1F5F9)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: const _BouncingDots(),
      ),
    );
  }
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();
  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double offset = (index * 0.2);
            double t = (_controller.value - offset);
            if (t < 0) t += 1.0;
            
            final double y = (t < 0.5) ? (t * 2) : ((1 - t) * 2);
            
            return Transform.translate(
              offset: Offset(0, -y * 5),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: ChatbotView.muted.withValues(alpha: 0.3 + (y * 0.7)),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

