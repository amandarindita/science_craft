import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../routes/app_pages.dart';
import '../../../widgets/logout_confirmation_dialog.dart';
import '../../../widgets/science_shimmer.dart';

import '../controllers/admin_learning_controller.dart';
import 'admin_content_import_view.dart';
import 'admin_funfact_view.dart';
import 'admin_module_content_view.dart';
import 'admin_module_form_view.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _success = Color(0xFF10B981);
const Color _amber = Color(0xFFF59E0B);
const Color _danger = Color(0xFFEF4444);

class AdminLearningView extends GetView<AdminLearningController> {
  const AdminLearningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: _primaryBlue,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Panel Guru',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: _textDark,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        actions: <Widget>[
          // Tombol Refresh
          IconButton(
            tooltip: 'Muat ulang data',
            onPressed: controller.loadModules,
            icon: const Icon(Icons.refresh_rounded, color: _textDark, size: 21),
          ),

          // Tombol Logout Rapi
          Padding(
            padding: const EdgeInsets.only(right: 14, left: 2),
            child: Material(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap:
                    () => showLogoutConfirmation(
                      onConfirm: () => Get.offAllNamed(Routes.LOGIN),
                    ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded, color: _danger, size: 17),
                      SizedBox(width: 5),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          color: _danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to<bool>(() => const AdminModuleFormView());
        },
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Buat Modul',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _primaryBlue,
        backgroundColor: Colors.white,
        onRefresh: controller.loadModules,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: <Widget>[
            // 1. Hero Header Stats Card
            SliverToBoxAdapter(child: _AdminHeroHeader(controller: controller)),

            // 2. Quick Management Cards (Import & Fun Fact)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(child: _QuickImportCard()),
                    SizedBox(width: 12),
                    Expanded(child: _QuickFunFactCard()),
                  ],
                ),
              ),
            ),

            // 3. Filter Section (Level & Kategori)
            SliverToBoxAdapter(child: _FilterSection(controller: controller)),

            // 4. Module List Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Modul Pembelajaran',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      Text(
                        '${controller.modules.length} Modul',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 5. Module List Items
            Obx(() {
              if (controller.isLoading.value && controller.modules.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: true,
                  child: AdminModuleListShimmer(),
                );
              }

              if (controller.modules.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyModulesState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                sliver: SliverList.separated(
                  itemCount: controller.modules.length,
                  itemBuilder: (context, index) {
                    final module = controller.modules[index];
                    return _ModuleCard(
                      module: module,
                      index: index + 1,
                      onManage: () async {
                        await Get.to<void>(
                          () => AdminModuleContentView(module: module),
                        );
                      },
                      onEdit: () async {
                        await Get.to<bool>(
                          () => AdminModuleFormView(module: module),
                        );
                      },
                      onDelete: () => controller.deleteModule(module),
                    );
                  },
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 12),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 1. HERO HEADER WITH STATS OVERVIEW
// =============================================================================
class _AdminHeroHeader extends StatelessWidget {
  const _AdminHeroHeader({required this.controller});

  final AdminLearningController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkNavy, _primaryBlue],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
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
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Kurikulum Sains',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pusat Kontrol Pembelajaran & Eksperimen',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFDCE9FF),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0x33FFFFFF)),
          const SizedBox(height: 14),

          // Informative Quick Counters
          Obx(() {
            final totalCount = controller.modules.length;
            final publishedCount =
                controller.modules
                    .where(
                      (m) =>
                          AdminLearningController.boolValue(m['is_published']),
                    )
                    .length;

            final draftCount = totalCount - publishedCount;

            return Row(
              children: [
                _HeaderStatItem(
                  label: 'Total Modul',
                  value: '$totalCount',
                  icon: Icons.menu_book_rounded,
                ),
                Container(
                  height: 28,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                _HeaderStatItem(
                  label: 'Terpublikasi',
                  value: '$publishedCount',
                  icon: Icons.check_circle_rounded,
                ),
                Container(
                  height: 28,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                _HeaderStatItem(
                  label: 'Draft',
                  value: '$draftCount',
                  icon: Icons.edit_note_rounded,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderStatItem extends StatelessWidget {
  const _HeaderStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: const Color(0xFF93C5FD)),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFDCE9FF),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 2. QUICK MANAGEMENT CARDS (IMPORT CSV & FUN FACT)
// =============================================================================
class _QuickImportCard extends StatelessWidget {
  const _QuickImportCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await Get.to<void>(() => const AdminContentImportView());
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.table_view_rounded,
                      color: _primaryBlue,
                      size: 20,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: _textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Import 2 CSV',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Modul & Bank Soal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: _textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickFunFactCard extends StatelessWidget {
  const _QuickFunFactCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await Get.to<void>(() => const AdminFunFactView());
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: _amber,
                      size: 20,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: _textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Fakta Sains',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Kelola Fun Fact',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: _textMuted,
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
// 3. FILTER SECTION (LEVEL & CATEGORY)
// =============================================================================
class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.controller});

  final AdminLearningController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Filters
          Row(
            children: [
              const Icon(Icons.layers_outlined, size: 16, color: _textMuted),
              const SizedBox(width: 6),
              Text(
                'Filter Level',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children:
                    [0, 1, 2, 3].map((level) {
                      final bool isSelected =
                          controller.selectedLevel.value == level;
                      final String label =
                          level == 0 ? 'Semua Level' : 'Level $level';

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterPill(
                          label: label,
                          isSelected: isSelected,
                          onTap: () => controller.changeLevel(level),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Filters
          Row(
            children: [
              const Icon(Icons.category_outlined, size: 16, color: _textMuted),
              const SizedBox(width: 6),
              Text(
                'Bidang Sains',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children:
                    controller.categories.map((category) {
                      final bool isSelected =
                          controller.selectedCategory.value == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterPill(
                          label: category,
                          isSelected: isSelected,
                          onTap: () => controller.changeCategory(category),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

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
            gradient:
                isSelected
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
            boxShadow:
                isSelected
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
// 4. MODULE CARD (CLEAN & INFORMATIVE)
// =============================================================================
class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.index,
    required this.onManage,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> module;
  final int index;
  final VoidCallback onManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool published = AdminLearningController.boolValue(
      module['is_published'],
    );
    final bool required = AdminLearningController.boolValue(
      module['is_required'],
    );
    final int level = AdminLearningController.intValue(
      module['level'],
      fallback: 1,
    );
    final int submaterialCount = AdminLearningController.intValue(
      module['submaterial_count'],
    );
    final String scene = module['unity_scene_id']?.toString().trim() ?? '';
    final String title = module['title']?.toString() ?? 'Tanpa Judul';
    final String description =
        module['short_description']?.toString().trim() ?? '';
    final String category = module['category']?.toString() ?? 'Sains';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Index number, title, popup menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_darkNavy, _primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    index < 10 ? '0$index' : '$index',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                        height: 1.3,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: _textMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: _primaryBlue,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Edit Detail Modul',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: _danger,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Hapus Modul',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: _danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Informative Metadata Tags
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _InfoTag(
                icon: Icons.layers_rounded,
                text: 'Level $level',
                color: _primaryBlue,
                bgColor: const Color(0xFFEFF6FF),
              ),
              _InfoTag(
                icon: Icons.science_outlined,
                text: category,
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFF0F9FF),
              ),
              _InfoTag(
                icon: Icons.menu_book_rounded,
                text: '$submaterialCount Submateri',
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF5F3FF),
              ),
              if (scene.isNotEmpty)
                _InfoTag(
                  icon: Icons.view_in_ar_rounded,
                  text: scene,
                  color: const Color(0xFF0D9488),
                  bgColor: const Color(0xFFF0FDFA),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Status Badges (Published & Required)
          Row(
            children: [
              _StatusBadge(
                label: published ? 'Terpublikasi' : 'Draft',
                isActive: published,
                activeColor: _success,
                activeBg: const Color(0xFFECFDF5),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: required ? 'Wajib' : 'Opsional',
                isActive: required,
                activeColor: const Color(0xFF6366F1),
                activeBg: const Color(0xFFEEF2FF),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons: Edit Modul & Kelola Isi
          Row(
            children: [
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _textDark,
                    side: const BorderSide(color: _border),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  onPressed: onManage,
                  icon: const Icon(Icons.auto_stories_rounded, size: 17),
                  label: Text(
                    'Kelola Isi Modul',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.icon,
    required this.text,
    required this.color,
    required this.bgColor,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeBg,
  });

  final String label;
  final bool isActive;
  final Color activeColor;
  final Color activeBg;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : _textMuted;
    final bg = isActive ? activeBg : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 5. EMPTY STATE
// =============================================================================
class _EmptyModulesState extends StatelessWidget {
  const _EmptyModulesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 34,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Modul',
              style: GoogleFonts.poppins(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Buat modul pembelajaran baru atau ubah filter level dan kategori yang dipilih.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
