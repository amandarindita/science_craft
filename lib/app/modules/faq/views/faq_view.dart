import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/faq_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);

class FaqView extends GetView<FaqController> {
  const FaqView({super.key});

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
            _buildCategoryFilter(),
            Expanded(
              child: Obx(() {
                final faqs = controller.filteredFaqs;

                if (faqs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                  itemCount: faqs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == faqs.length) {
                      return _buildContactHelpCard();
                    }
                    final item = faqs[index];
                    return _FaqCard(item: item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. HERO HEADER WITH INTEGRATED SEARCH
  // ===========================================================================
  Widget _buildHeroHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                'Pusat Bantuan & FAQ',
                style: GoogleFonts.poppins(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              // Placeholder for balance
              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            'Temukan jawaban cepat seputar pembelajaran & fitur Science Craft.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFFDCE9FF),
            ),
          ),
          const SizedBox(height: 14),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller.searchController,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: _textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan atau topik sains...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: _textMuted.withValues(alpha: 0.7),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _primaryBlue,
                  size: 20,
                ),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: _textMuted,
                      size: 18,
                    ),
                    onPressed: controller.clearSearch,
                  );
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. CATEGORY FILTER PILLS
  // ===========================================================================
  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: Obx(() {
        final current = controller.selectedCategory.value;

        return ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          children: [
            _FilterTab(
              label: 'Semua',
              isSelected: current == 'all',
              onTap: () => controller.changeCategory('all'),
            ),
            const SizedBox(width: 8),
            _FilterTab(
              label: 'Umum & Fitur',
              isSelected: current == 'general',
              onTap: () => controller.changeCategory('general'),
            ),
            const SizedBox(width: 8),
            _FilterTab(
              label: 'XP & Milestone',
              isSelected: current == 'xp',
              onTap: () => controller.changeCategory('xp'),
            ),
            const SizedBox(width: 8),
            _FilterTab(
              label: 'Lab Sains',
              isSelected: current == 'lab',
              onTap: () => controller.changeCategory('lab'),
            ),
            const SizedBox(width: 8),
            _FilterTab(
              label: 'Akun & Keamanan',
              isSelected: current == 'account',
              onTap: () => controller.changeCategory('account'),
            ),
          ],
        );
      }),
    );
  }

  // ===========================================================================
  // 3. EMPTY STATE
  // ===========================================================================
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 38,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Pertanyaan Tidak Ditemukan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba gunakan kata kunci lain atau pilih kategori yang berbeda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: controller.clearSearch,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset Pencarian'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryBlue,
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. CONTACT HELP CARD
  // ===========================================================================
  Widget _buildContactHelpCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEFF6FF),
            Color(0xFFF8FAFC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: _primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masih Butuh Bantuan?',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _darkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jika kendala atau pertanyaanmu belum terjawab, silakan berkonsultasi melalui asisten AI di menu Chatbot.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: _textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FILTER PILL TAB WIDGET
// =============================================================================
class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [_darkNavy, _primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _primaryBlue : _border,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : _textDark,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FAQ ACCORDION CARD WIDGET
// =============================================================================
class _FaqCard extends StatefulWidget {
  final FaqItem item;

  const _FaqCard({required this.item});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isExpanded ? const Color(0xFFBFDBFE) : _border,
          width: _isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isExpanded
                ? _primaryBlue.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: _isExpanded ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _isExpanded
                  ? _primaryBlue.withValues(alpha: 0.12)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              widget.item.icon,
              color: _isExpanded ? _primaryBlue : _textMuted,
              size: 20,
            ),
          ),
          title: Text(
            widget.item.question,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: _isExpanded ? FontWeight.w700 : FontWeight.w600,
              color: _isExpanded ? _darkNavy : _textDark,
              height: 1.35,
            ),
          ),
          trailing: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _isExpanded ? 0.5 : 0,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _isExpanded ? _primaryBlue : _textMuted,
              size: 22,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.answer,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: _textMuted,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
