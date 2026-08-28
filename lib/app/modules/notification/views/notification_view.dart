import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/notification_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

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
              child: RefreshIndicator(
                color: _primaryBlue,
                backgroundColor: Colors.white,
                onRefresh: controller.fetchServerNotifications,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildShimmerLoading();
                  }

                  final list = controller.filteredNotifications;

                  if (list.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _NotificationCard(
                        key: ValueKey(item.id),
                        item: item,
                        onTap: () => controller.markAsRead(item.id),
                        onDismissed: () =>
                            controller.deleteNotification(item.id),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. HERO HEADER
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              Material(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
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

              // Title in center/appbar
              Text(
                'Pusat Notifikasi',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              // Action Buttons
              Row(
                children: [
                  // Test Notification Button
                  Tooltip(
                    message: "Kirim Notif Tes",
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: controller.triggerTestNotification,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.science_rounded,
                            color: Color(0xFFFDE047),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // More Options Menu
                  PopupMenuButton<String>(
                    elevation: 8,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'read_all') {
                        controller.markAllAsRead();
                      } else if (value == 'clear_all') {
                        controller.clearAll();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'read_all',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.done_all_rounded,
                              color: _primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Tandai Semua Dibaca',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(height: 1),
                      PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Hapus Semua',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subtitle & Live Unread Indicator
          Obx(() {
            final unread = controller.unreadCount;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Pembaruan aktivitas & pengingat belajarmu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                if (unread > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$unread Belum Dibaca',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _darkNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. CATEGORY / FILTER PILLS
  // ===========================================================================
  Widget _buildFilterPills() {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      child: Obx(() {
        final current = controller.selectedFilter.value;
        final unreadCount = controller.unreadCount;

        return ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          children: [
            _FilterTab(
              label: 'Semua',
              badge: '${controller.notifications.length}',
              isSelected: current == NotificationCategory.all,
              onTap: () => controller.changeFilter(NotificationCategory.all),
            ),
            const SizedBox(width: 8),
            _FilterTab(
              label: 'Belum Dibaca',
              badge: unreadCount > 0 ? '$unreadCount' : null,
              isHighlightBadge: unreadCount > 0,
              isSelected: current == NotificationCategory.unread,
              onTap: () => controller.changeFilter(NotificationCategory.unread),
            ),
            const SizedBox(width: 8),
            _FilterTab(
              label: 'Prestasi',
              badge: controller.achievementCount > 0
                  ? '${controller.achievementCount}'
                  : null,
              isSelected: current == NotificationCategory.achievement,
              onTap: () =>
                  controller.changeFilter(NotificationCategory.achievement),
            ),
            const SizedBox(width: 8),
            _FilterTab(
              label: 'Pengingat',
              badge: controller.reminderCount > 0
                  ? '${controller.reminderCount}'
                  : null,
              isSelected: current == NotificationCategory.reminder,
              onTap: () =>
                  controller.changeFilter(NotificationCategory.reminder),
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFDBEAFE),
                    const Color(0xFFEFF6FF),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryBlue.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                size: 48,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Semua Notifikasi Terbaca',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu telah membaca semua pengingat dan kabar terbaru. Tetap semangat bereksperimen sains!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: _textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.triggerTestNotification,
              icon: const Icon(Icons.science_rounded, size: 18),
              label: Text(
                'Kirim Notifikasi Uji Coba',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: _primaryBlue.withValues(alpha: 0.4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. SHIMMER LOADING
  // ===========================================================================
  Widget _buildShimmerLoading() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 180,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// FILTER PILL WIDGET
// =============================================================================
class _FilterTab extends StatelessWidget {
  final String label;
  final String? badge;
  final bool isHighlightBadge;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    this.badge,
    this.isHighlightBadge = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [_darkNavy, _primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _primaryBlue : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _primaryBlue.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : _textDark,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : (isHighlightBadge
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isHighlightBadge
                              ? Colors.white
                              : const Color(0xFF475569)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// NOTIFICATION CARD WIDGET
// =============================================================================
class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_rounded,
              color: Color(0xFFEF4444),
              size: 26,
            ),
            SizedBox(width: 6),
            Text(
              'Hapus',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: item.isRead
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF0F7FF),
                        Colors.white,
                      ],
                    ),
              color: item.isRead ? Colors.white : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: item.isRead
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFFBFDBFE),
                width: item.isRead ? 1 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: item.isRead
                      ? Colors.black.withValues(alpha: 0.03)
                      : _primaryBlue.withValues(alpha: 0.08),
                  blurRadius: item.isRead ? 8 : 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        item.iconColor.withValues(alpha: 0.2),
                        item.iconColor.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: item.iconColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Category tag + Time + Unread Dot
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: item.iconColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.categoryName.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: item.iconColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: _textMuted.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: _textMuted,
                              ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _primaryBlue,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _primaryBlue.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight:
                              item.isRead ? FontWeight.w600 : FontWeight.w700,
                          color: _textDark,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Body Message
                      Text(
                        item.body,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: item.isRead
                              ? _textMuted
                              : const Color(0xFF334155),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
