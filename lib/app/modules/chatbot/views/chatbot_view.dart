import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/chatbot_controller.dart';

// Palet Warna Bersih & Modern
const Color _bg = Color(0xFFF8FAFC);
const Color _primary = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF0F172A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _textLight = Color(0xFF94A3B8);
const Color _border = Color(0xFFE2E8F0);
const Color _borderLight = Color(0xFFF1F5F9);
const Color _onlineGreen = Color(0xFF10B981);

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildCleanAppBar(context),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Area Obrolan Utama
            Expanded(child: _buildChatList(context)),

            // Area Input Bersih & Modern
            _buildCleanInputArea(),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. CLEAN APP BAR
  // ===========================================================================
  PreferredSizeWidget _buildCleanAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      shape: const Border(bottom: BorderSide(color: _borderLight, width: 1)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 18, color: _darkNavy),
        onPressed: () => Get.back(),
        tooltip: 'Kembali',
      ),
      title: Row(
        children: [
          // Avatar SENA
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: const Center(
              child: Icon(Icons.smart_toy_rounded, size: 20, color: _primary),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SENA AI',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _darkNavy,
                  letterSpacing: -0.2,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _onlineGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Online • Asisten Sains',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _onlineGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 22, color: _textMuted),
          tooltip: 'Mulai Ulang Percakapan',
          onPressed: () => _confirmClearChat(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ===========================================================================
  // 2. CHAT STREAM / LIST
  // ===========================================================================
  Widget _buildChatList(BuildContext context) {
    return Obx(() {
      final messages = controller.messages;
      final isTyping = controller.isBotTyping.value;

      // Jika hanya ada pesan sambutan pertama, tampilkan saran pertanyaan bersih
      final showSamplePrompts = messages.length <= 1;

      return ListView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          // Render setiap balon pesan
          ...messages.map(
            (msg) => _CleanMessageBubble(msg: msg, controller: controller),
          ),

          // Indikator saat AI sedang berpikir/mengetik
          if (isTyping) const _CleanTypingIndicator(),

          // Kartu Saran Pertanyaan Bersih (hanya di awal)
          if (showSamplePrompts && !isTyping) _buildSamplePromptsSection(),
        ],
      );
    });
  }

  // ===========================================================================
  // 3. SARAN PERTANYAAN AWAL (BERSIH & INFORMATIF)
  // ===========================================================================
  Widget _buildSamplePromptsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Contoh pertanyaan yang bisa kamu tanyakan:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
          ),
          ...controller.samplePrompts.map((prompt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.usePrompt(prompt),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF0F172A,
                          ).withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            prompt,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: _textDark,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: _primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. CLEAN INPUT BAR
  // ===========================================================================
  Widget _buildCleanInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _borderLight, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Input Box
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.textController,
                      focusNode: controller.inputFocusNode,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.plusJakartaSans(
                        color: _textDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tanyakan materi atau rumus sains...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: _textLight,
                          fontSize: 13.5,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 11,
                        ),
                      ),
                      onSubmitted: (_) => controller.sendMessage(),
                    ),
                  ),
                  Obx(() {
                    if (controller.hasUserTyped.value) {
                      return InkWell(
                        onTap: () => controller.textController.clear(),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.clear_rounded,
                            size: 16,
                            color: _textLight,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Tombol Kirim
          Obx(() {
            final canSend =
                controller.hasUserTyped.value && !controller.isBotTyping.value;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: canSend ? controller.sendMessage : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: canSend ? _primary : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        controller.isBotTyping.value
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Icon(
                              Icons.arrow_upward_rounded,
                              color:
                                  canSend
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. MODAL KONFIRMASI BERSIH
  // ===========================================================================
  void _confirmClearChat(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              'Mulai Ulang Percakapan?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _darkNavy,
              ),
            ),
            content: Text(
              'Semua pesan obrolan dengan SENA akan dihapus dan dimulai kembali.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _textMuted,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Batal',
                  style: GoogleFonts.plusJakartaSans(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  controller.clearMessages();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Mulai Ulang',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

// =============================================================================
// 💬 CLEAN MESSAGE BUBBLE (USER & BOT)
// =============================================================================
class _CleanMessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final ChatbotController controller;

  const _CleanMessageBubble({required this.msg, required this.controller});

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: isUser ? _buildUserBubble(context) : _buildBotBubble(context),
    );
  }

  // Balon Pesan User (Biru, Rapi, Sisi Kanan)
  Widget _buildUserBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              decoration: const BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _formatTime(msg.timestamp),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: _textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Balon Pesan Bot AI (Putih, Bersih, Format Markdown Informatif)
  Widget _buildBotBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teks Format Markdown Informatif
                  MarkdownBody(
                    data: msg.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.plusJakartaSans(
                        color: _textDark,
                        fontSize: 13.5,
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                      ),
                      strong: GoogleFonts.plusJakartaSans(
                        color: _darkNavy,
                        fontWeight: FontWeight.w700,
                      ),
                      em: GoogleFonts.plusJakartaSans(
                        fontStyle: FontStyle.italic,
                        color: _textDark,
                      ),
                      h1: GoogleFonts.poppins(
                        color: _darkNavy,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                      h2: GoogleFonts.poppins(
                        color: _darkNavy,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                      h3: GoogleFonts.poppins(
                        color: _darkNavy,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                      blockquote: GoogleFonts.plusJakartaSans(
                        color: _primary,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          left: BorderSide(color: _primary, width: 3),
                        ),
                      ),
                      code: const TextStyle(
                        fontFamily: 'monospace',
                        backgroundColor: Color(0xFFF1F5F9),
                        color: _primary,
                        fontSize: 12,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      listBullet: GoogleFonts.plusJakartaSans(
                        color: _primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Divider(color: _borderLight, height: 1),
                  const SizedBox(height: 4),

                  // Toolbar Aksi Sederhana & Bersih
                  _buildCleanToolbar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanToolbar() {
    return Row(
      children: [
        // Tombol Text-to-Speech
        Obx(() {
          final isSpeaking = controller.currentlySpeakingId.value == msg.id;
          return InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => controller.toggleSpeak(msg),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSpeaking
                        ? Icons.stop_circle_outlined
                        : Icons.volume_up_outlined,
                    size: 15,
                    color: isSpeaking ? _primary : _textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSpeaking ? 'Berhenti' : 'Dengarkan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight:
                          isSpeaking ? FontWeight.w700 : FontWeight.w500,
                      color: isSpeaking ? _primary : _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(width: 4),

        // Tombol Salin Teks
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => controller.copyMessage(msg.text),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.copy_rounded, size: 13, color: _textMuted),
                const SizedBox(width: 4),
                Text(
                  'Salin',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Waktu
        Text(
          _formatTime(msg.timestamp),
          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _textLight),
        ),
      ],
    );
  }
}

// =============================================================================
// 🧠 CLEAN TYPING INDICATOR
// =============================================================================
class _CleanTypingIndicator extends StatelessWidget {
  const _CleanTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SENA sedang mengetik...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _textMuted,
              ),
            ),
            const SizedBox(width: 8),
            const _BouncingDots(),
          ],
        ),
      ),
    );
  }
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
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
              offset: Offset(0, -y * 3.5),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 4.5,
                height: 4.5,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.4 + (y * 0.6)),
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
