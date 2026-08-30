import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/about_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);

class AboutAppView extends GetView<AboutAppController> {
  const AboutAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            _buildHeroHeader(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
                children: [
                  _buildFeatureHighlights(),
                  const SizedBox(height: 16),
                  _buildMissionCard(),
                  const SizedBox(height: 16),
                  _buildDeveloperCard(),
                  const SizedBox(height: 16),
                  _buildTechStackCard(),
                  const SizedBox(height: 20),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. HERO HEADER WITH BRAND STAGE
  // ===========================================================================
  Widget _buildHeroHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkNavy, _primaryBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x331E3A8A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Nav Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              Material(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Get.back(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              Text(
                'Tentang Aplikasi',
                style: GoogleFonts.poppins(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 20),

          // App Logo / Emblem Stage
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF93C5FD),
                    width: 2.5,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo_app.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.science_rounded,
                      color: _primaryBlue,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            'Science Craft',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Platform Eksperimen & Pembelajaran Sains SMA',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFFDCE9FF),
            ),
          ),
          const SizedBox(height: 12),

          // Version Chip
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                'Versi ${controller.appVersion.value} • Stable Release',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. FEATURE HIGHLIGHTS
  // ===========================================================================
  Widget _buildFeatureHighlights() {
    return Row(
      children: [
        Expanded(
          child: _HighlightTile(
            icon: Icons.biotech_rounded,
            color: _primaryBlue,
            title: 'Virtual Lab',
            subtitle: 'Praktikum Digital',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _HighlightTile(
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFF8B5CF6),
            title: 'Gamifikasi',
            subtitle: 'XP & Milestone',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _HighlightTile(
            icon: Icons.smart_toy_outlined,
            color: const Color(0xFF10B981),
            title: 'AI Tutor',
            subtitle: 'Tanya Konsep',
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. MISSION CARD
  // ===========================================================================
  Widget _buildMissionCard() {
    return _AboutCard(
      icon: Icons.lightbulb_outline_rounded,
      iconColor: const Color(0xFFF59E0B),
      title: 'Visi & Misi Pembelajaran',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Science Craft dirancang sebagai solusi edukasi sains interaktif yang mengatasi keterbatasan fasilitas laboratorium fisik di sekolah.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: _textDark,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Melalui modul terstruktur, kuis adaptif, dan simulasi eksperimen Fisika, Kimia, dan Biologi, kami bertujuan menumbuhkan minat riset dan literasi sains siswa SMA secara mendalam.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: _textMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. DEVELOPER CARD
  // ===========================================================================
  Widget _buildDeveloperCard() {
    return _AboutCard(
      icon: Icons.school_outlined,
      iconColor: _primaryBlue,
      title: 'Pengembang Aplikasi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: _primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amanda Aulia Ayu Arindita',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'D4 Teknik Informatika',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Universitas Harkat Negeri',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. TECH STACK CARD
  // ===========================================================================
  Widget _buildTechStackCard() {
    return _AboutCard(
      icon: Icons.terminal_rounded,
      iconColor: const Color(0xFF10B981),
      title: 'Arsitektur & Teknologi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aplikasi ini dibangun menggunakan tumpukan teknologi modern untuk memastikan performa responsif dan pengalaman pengguna yang mulus:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: _textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _TechPill(label: 'Flutter & Dart'),
              _TechPill(label: 'GetX Architecture'),
              _TechPill(label: 'Python Flask API'),
              _TechPill(label: 'Virtual Canvas Lab'),
              _TechPill(label: 'Interactive Gamification'),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. FOOTER
  // ===========================================================================
  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Science Craft • Empowering Future Scientists',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2026 Science Craft. Hak Cipta Dilindungi.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: _textMuted,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// HELPER COMPONENTS
// =============================================================================
class _HighlightTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _HighlightTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _AboutCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TechPill extends StatelessWidget {
  final String label;

  const _TechPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
      ),
    );
  }
}
