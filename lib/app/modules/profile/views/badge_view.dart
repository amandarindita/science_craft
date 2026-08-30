import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/profile_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _amber = Color(0xFFF59E0B);
const Color _emerald = Color(0xFF10B981);

class BadgeView extends StatefulWidget {
  const BadgeView({super.key});

  @override
  State<BadgeView> createState() => _BadgeViewState();
}

class _BadgeViewState extends State<BadgeView> {
  final ProfileController controller = Get.find<ProfileController>();
  final RxString selectedFilter = 'all'.obs; // 'all', 'owned', 'locked'

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
            _buildFilterPills(),
            Expanded(
              child: Obx(() {
                final allBadges = controller.badges;
                final filter = selectedFilter.value;

                final displayedBadges = allBadges.where((badge) {
                  if (filter == 'owned') return badge.isOwned;
                  if (filter == 'locked') return !badge.isOwned;
                  return true;
                }).toList();

                if (displayedBadges.isEmpty) {
                  return _buildEmptyState();
                }

                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                  itemCount: displayedBadges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final badge = displayedBadges[index];
                    return _BadgeCard(
                      badge: badge,
                      onTap: () => _showBadgeInfo(context, badge),
                    );
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
  // 1. HERO HEADER WITH PROGRESS STATS
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
                'Koleksi Badge Prestasi',
                style: GoogleFonts.poppins(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Card
          Obx(() {
            final int total = controller.badges.length;
            final int owned =
                controller.badges.where((b) => b.isOwned).length;
            final double progress = total > 0 ? (owned / total) : 0.0;
            final int percent = (progress * 100).round();

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: Color(0xFFFDE047),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$owned dari $total Badge Terkumpul',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$percent%',
                          style: GoogleFonts.poppins(
                            color: _darkNavy,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      color: const Color(0xFF38BDF8),
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. FILTER PILLS
  // ===========================================================================
  Widget _buildFilterPills() {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: Obx(() {
        final current = selectedFilter.value;
        final total = controller.badges.length;
        final owned = controller.badges.where((b) => b.isOwned).length;
        final locked = total - owned;

        return ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          children: [
            _FilterPill(
              label: 'Semua',
              count: total,
              isSelected: current == 'all',
              onTap: () => selectedFilter.value = 'all',
            ),
            const SizedBox(width: 8),
            _FilterPill(
              label: 'Dimiliki',
              count: owned,
              isSelected: current == 'owned',
              onTap: () => selectedFilter.value = 'owned',
            ),
            const SizedBox(width: 8),
            _FilterPill(
              label: 'Terkunci',
              count: locked,
              isSelected: current == 'locked',
              onTap: () => selectedFilter.value = 'locked',
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_outlined,
                size: 36,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Badge',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Selesaikan materi dan modul eksperimen sains untuk membuka badge prestasimu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: _textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. BOTTOM SHEET DETAIL
  // ===========================================================================
  void _showBadgeInfo(BuildContext context, BadgeItem badge) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 22),

            // Large Badge Image
            Stack(
              alignment: Alignment.center,
              children: [
                if (badge.isOwned)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _amber.withValues(alpha: 0.35),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                Container(
                  width: 96,
                  height: 96,
                  padding: const EdgeInsets.all(8),
                  child: badge.isOwned
                      ? Image.asset(badge.imagePath, fit: BoxFit.contain)
                      : ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 0.45, 0,
                          ]),
                          child: Image.asset(badge.imagePath,
                              fit: BoxFit.contain),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Badge Name
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _darkNavy,
              ),
            ),
            const SizedBox(height: 8),

            // Status Chip
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: badge.isOwned
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: badge.isOwned
                      ? const Color(0xFFA7F3D0)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    badge.isOwned
                        ? Icons.check_circle_rounded
                        : Icons.lock_rounded,
                    size: 14,
                    color: badge.isOwned ? _emerald : _textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    badge.isOwned
                        ? 'Lencana Terbuka'
                        : 'Lencana Terkunci',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: badge.isOwned ? _emerald : _textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Requirement / Description Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.military_tech_rounded,
                        size: 17,
                        color: _primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Syarat Memperoleh:',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    badge.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: _textMuted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: badge.isOwned ? _primaryBlue : const Color(0xFF334155),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  badge.isOwned ? 'Tutup' : 'Kembali Belajar',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// =============================================================================
// BADGE CARD WIDGET
// =============================================================================
class _BadgeCard extends StatelessWidget {
  final BadgeItem badge;
  final VoidCallback onTap;

  const _BadgeCard({
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: badge.isOwned
                  ? const Color(0xFFFDE68A)
                  : _border,
              width: badge.isOwned ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: badge.isOwned
                    ? _amber.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge Image with State Effect
              Expanded(
                child: Center(
                  child: badge.isOwned
                      ? Image.asset(
                          badge.imagePath,
                          fit: BoxFit.contain,
                        )
                      : ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 0.4, 0,
                          ]),
                          child: Image.asset(
                            badge.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),

              // Title
              Text(
                badge.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: badge.isOwned ? FontWeight.w700 : FontWeight.w600,
                  color: badge.isOwned ? _textDark : _textMuted,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),

              // Mini status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badge.isOwned
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badge.isOwned
                          ? Icons.check_circle_rounded
                          : Icons.lock_rounded,
                      size: 10,
                      color: badge.isOwned ? _emerald : _textMuted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      badge.isOwned ? 'Terbuka' : 'Terkunci',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: badge.isOwned ? _emerald : _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FILTER PILL WIDGET
// =============================================================================
class _FilterPill extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
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
            borderRadius: BorderRadius.circular(14),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : _textDark,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : _textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}