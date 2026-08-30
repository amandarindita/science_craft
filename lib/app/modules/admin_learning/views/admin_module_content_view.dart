import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/admin_learning_controller.dart';
import 'admin_checkpoint_manager_view.dart';
import 'admin_module_preview_view.dart';
import 'admin_quiz_manager_view.dart';
import 'admin_submaterial_form_view.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _success = Color(0xFF10B981);
const Color _danger = Color(0xFFEF4444);

class AdminModuleContentView extends StatefulWidget {
  const AdminModuleContentView({
    super.key,
    required this.module,
  });

  final Map<String, dynamic> module;

  @override
  State<AdminModuleContentView> createState() =>
      _AdminModuleContentViewState();
}

class _AdminModuleContentViewState extends State<AdminModuleContentView> {
  AdminLearningController get controller =>
      Get.find<AdminLearningController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.openModuleContent(widget.module);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int materialId =
        AdminLearningController.intValue(widget.module['id']);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          'Kelola Submateri',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 17.5,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang data',
            onPressed: () => controller.loadSubmaterials(materialId),
            icon: const Icon(
              Icons.refresh_rounded,
              color: _textDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to<bool>(
            () => AdminSubmaterialFormView(materialId: materialId),
          );
        },
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Tambah Submateri',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _primaryBlue,
        backgroundColor: Colors.white,
        onRefresh: () => controller.loadSubmaterials(materialId),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: <Widget>[
            // 1. Hero Module Info Header
            SliverToBoxAdapter(
              child: _ModuleHeader(
                module: widget.module,
                controller: controller,
              ),
            ),

            // 2. Quick Action Bar (Kelola Kuis & Preview Siswa)
            SliverToBoxAdapter(
              child: _ModuleActions(module: widget.module),
            ),

            // 3. Multi-mode Learning Guidance Card
            const SliverToBoxAdapter(
              child: _ModeExplanation(),
            ),

            // 4. Submaterial Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Submateri & Bab',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      Text(
                        '${controller.submaterials.length} Submateri',
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

            // 5. Submaterial List Items
            Obx(() {
              if (controller.isLoadingContent.value &&
                  controller.submaterials.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _primaryBlue,
                    ),
                  ),
                );
              }

              if (controller.submaterials.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyContent(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                sliver: SliverList.separated(
                  itemCount: controller.submaterials.length,
                  itemBuilder: (context, index) {
                    final submaterial = controller.submaterials[index];
                    return _SubmaterialCard(
                      submaterial: submaterial,
                      index: index + 1,
                      onCheckpoint: () async {
                        await Get.to<void>(
                          () => AdminCheckpointManagerView(
                            submaterial: submaterial,
                          ),
                        );
                      },
                      onEdit: () async {
                        await Get.to<bool>(
                          () => AdminSubmaterialFormView(
                            materialId: materialId,
                            submaterial: submaterial,
                          ),
                        );
                      },
                      onDelete: () => _confirmDeleteSubmaterial(submaterial),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteSubmaterial(Map<String, dynamic> submaterial) async {
    final String title = submaterial['title']?.toString() ?? 'Submateri';
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFEE2E8)),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: _danger,
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Hapus Submateri?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Submateri "$title" beserta seluruh checkpoint di dalamnya akan dihapus secara permanen.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: _textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textDark,
                        side: const BorderSide(color: _border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Ya, Hapus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await controller.deleteSubmaterial(submaterial);
    }
  }
}

// =============================================================================
// 1. HERO MODULE HEADER
// =============================================================================
class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({
    required this.module,
    required this.controller,
  });

  final Map<String, dynamic> module;
  final AdminLearningController controller;

  @override
  Widget build(BuildContext context) {
    final int level =
        AdminLearningController.intValue(module['level'], fallback: 1);
    final String category =
        module['category']?.toString() ?? 'Sains';
    final String title =
        module['title']?.toString() ?? 'Modul Pembelajaran';
    final String description =
        module['short_description']?.toString().trim() ?? '';
    final bool isPublished =
        AdminLearningController.boolValue(module['is_published']);

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 12),
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
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  _HeaderPill(text: 'Level $level', icon: Icons.layers_rounded),
                  _HeaderPill(text: category, icon: Icons.science_outlined),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPublished
                      ? _success.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPublished
                        ? _success.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  isPublished ? 'Terpublikasi' : 'Draft',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFDCE9FF),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFBFDBFE)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 2. QUICK ACTION BAR (KELOLA KUIS & PREVIEW SISWA)
// =============================================================================
class _ModuleActions extends StatelessWidget {
  const _ModuleActions({required this.module});

  final Map<String, dynamic> module;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: <Widget>[
          // Kelola Bank Soal Kuis
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Get.to<void>(
                  () => AdminQuizManagerView(module: module),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.quiz_outlined,
                          color: Color(0xFF6366F1),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kelola Kuis',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                            Text(
                              'Bank Soal Modul',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 13, color: _textMuted),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Preview Modul Siswa
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Get.to<void>(
                  () => AdminModulePreviewView(module: module),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.visibility_outlined,
                          color: _primaryBlue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview Siswa',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                            Text(
                              'Simulasi Modul',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 13, color: _textMuted),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 3. MODE EXPLANATION CARD
// =============================================================================
class _ModeExplanation extends StatelessWidget {
  const _ModeExplanation();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.info_outline_rounded,
            color: _primaryBlue,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Setiap submateri mendukung 3 format sekaligus: Baca, Dengarkan (TTS/Audio), dan Visual Interaktif. Siswa dapat menuntaskan submateri melalui mode yang tersedia.',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF1E40AF),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 4. SUBMATERIAL CARD
// =============================================================================
class _SubmaterialCard extends StatelessWidget {
  const _SubmaterialCard({
    required this.submaterial,
    required this.index,
    required this.onCheckpoint,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> submaterial;
  final int index;
  final VoidCallback onCheckpoint;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final String readContent =
        submaterial['read_content']?.toString().trim() ?? '';
    final String ttsText = submaterial['tts_text']?.toString().trim() ?? '';
    final String audioUrl = submaterial['audio_url']?.toString().trim() ?? '';
    final String imageUrl = submaterial['image_url']?.toString().trim() ?? '';
    final Map<String, dynamic> visualData =
        AdminLearningController.mapValue(submaterial['visual_data']);

    final bool hasRead = readContent.isNotEmpty;
    final bool hasListen = ttsText.isNotEmpty || audioUrl.isNotEmpty;
    final bool hasVisual = imageUrl.isNotEmpty || visualData.isNotEmpty;
    final bool published =
        AdminLearningController.boolValue(submaterial['is_published']);
    final bool required =
        AdminLearningController.boolValue(submaterial['is_required']);

    final int checkpointCount =
        AdminLearningController.mapList(submaterial['checkpoints']).length;

    final String title = submaterial['title']?.toString() ?? 'Submateri';
    final String summary = submaterial['summary']?.toString().trim() ?? '';

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
        children: <Widget>[
          // Header Row: Order badge, title, popup menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_darkNavy, _primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    index < 10 ? '0$index' : '$index',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                        height: 1.3,
                      ),
                    ),
                    if (summary.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: _textMuted,
                          height: 1.35,
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
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined,
                            size: 18, color: _primaryBlue),
                        const SizedBox(width: 10),
                        Text(
                          'Edit Submateri',
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
                        const Icon(Icons.delete_outline_rounded,
                            size: 18, color: _danger),
                        const SizedBox(width: 10),
                        Text(
                          'Hapus Submateri',
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

          // Multi-mode Indicators & Checkpoint Badge
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              _ModeBadge(
                icon: Icons.menu_book_rounded,
                label: 'Baca',
                active: hasRead,
              ),
              _ModeBadge(
                icon: Icons.headphones_rounded,
                label: 'Dengar',
                active: hasListen,
              ),
              _ModeBadge(
                icon: Icons.auto_awesome_rounded,
                label: 'Visual',
                active: hasVisual,
              ),
              _ModeBadge(
                icon: Icons.task_alt_rounded,
                label: '$checkpointCount Checkpoint',
                active: checkpointCount > 0,
                color: checkpointCount > 0
                    ? const Color(0xFF8B5CF6)
                    : _textMuted,
                bgColor: checkpointCount > 0
                    ? const Color(0xFFF5F3FF)
                    : const Color(0xFFF1F5F9),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Status Pills
          Row(
            children: <Widget>[
              _StatusPill(
                text: published ? 'Terpublikasi' : 'Draft',
                active: published,
                activeColor: _success,
                activeBg: const Color(0xFFECFDF5),
              ),
              const SizedBox(width: 8),
              _StatusPill(
                text: required ? 'Wajib' : 'Opsional',
                active: required,
                activeColor: const Color(0xFF6366F1),
                activeBg: const Color(0xFFEEF2FF),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons: Kelola Checkpoint & Edit Isi
          Row(
            children: [
              Expanded(
                flex: 5,
                child: OutlinedButton.icon(
                  onPressed: onCheckpoint,
                  icon: const Icon(Icons.task_alt_rounded, size: 16),
                  label: Text(
                    'Checkpoint',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _textDark,
                    side: const BorderSide(color: _border),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_note_rounded, size: 17),
                  label: Text(
                    'Edit Isi Materi',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 9),
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

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({
    required this.icon,
    required this.label,
    required this.active,
    this.color,
    this.bgColor,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color? color;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? (active ? _primaryBlue : _textMuted.withValues(alpha: 0.6));
    final effectiveBg =
        bgColor ?? (active ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: effectiveColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: effectiveColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.active,
    required this.activeColor,
    required this.activeBg,
  });

  final String text;
  final bool active;
  final Color activeColor;
  final Color activeBg;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : _textMuted;
    final bg = active ? activeBg : const Color(0xFFF1F5F9);

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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
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
// 5. EMPTY CONTENT STATE
// =============================================================================
class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 34,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Submateri',
              style: GoogleFonts.poppins(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Mulai buat submateri pertama untuk menyusun bab pembelajaran modul ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: _textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
