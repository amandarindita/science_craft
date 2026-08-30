import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/admin_learning_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _success = Color(0xFF10B981);
const Color _warning = Color(0xFFF59E0B);

class AdminModulePreviewView extends StatefulWidget {
  const AdminModulePreviewView({
    super.key,
    required this.module,
  });

  final Map<String, dynamic> module;

  @override
  State<AdminModulePreviewView> createState() =>
      _AdminModulePreviewViewState();
}

class _AdminModulePreviewViewState extends State<AdminModulePreviewView> {
  AdminLearningController get controller =>
      Get.find<AdminLearningController>();

  int get materialId =>
      AdminLearningController.intValue(widget.module['id']);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.refreshModuleStructure(materialId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          'Preview Struktur Modul',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 17,
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
            tooltip: 'Muat ulang preview',
            onPressed: () => controller.refreshModuleStructure(materialId),
            icon: const Icon(
              Icons.refresh_rounded,
              color: _textDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if ((controller.isLoadingContent.value ||
                controller.isLoadingQuestions.value) &&
            controller.submaterials.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: _primaryBlue,
            ),
          );
        }

        final module =
            controller.activeModule.value ?? widget.module;
        final submaterials = controller.submaterials;
        final questions = controller.questions;
        final checkpointCount = submaterials.fold<int>(
          0,
          (total, item) =>
              total +
              AdminLearningController.mapList(item['checkpoints']).length,
        );
        final hasLab =
            module['unity_scene_id']?.toString().trim().isNotEmpty == true;
        final warnings = _warnings(module, submaterials, questions);

        return RefreshIndicator(
          color: _primaryBlue,
          backgroundColor: Colors.white,
          onRefresh: () => controller.refreshModuleStructure(materialId),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
            children: <Widget>[
              // 1. Hero Header
              _Header(module: module),
              const SizedBox(height: 16),

              // 2. Readiness Check
              _ReadinessCard(warnings: warnings),
              const SizedBox(height: 16),

              // 3. Stats Grid
              _StatsGrid(
                submaterials: submaterials.length,
                checkpoints: checkpointCount,
                questions: questions.length,
                hasLab: hasLab,
              ),
              const SizedBox(height: 20),

              // 4. Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alur Pembelajaran Siswa',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    '${submaterials.length} Tahapan Bab',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 5. Timeline Submaterials
              if (submaterials.isEmpty)
                const _EmptyState()
              else
                ...submaterials.asMap().entries.map(
                      (entry) => _SubmaterialTimelineCard(
                        number: entry.key + 1,
                        isLast: entry.key == submaterials.length - 1,
                        submaterial: entry.value,
                      ),
                    ),

              const SizedBox(height: 16),

              // 6. Final Stage (Quiz & Lab)
              _FinalStageCard(
                questionCount: questions.length,
                sceneId: module['unity_scene_id']?.toString() ?? '',
              ),
            ],
          ),
        );
      }),
    );
  }

  List<String> _warnings(
    Map<String, dynamic> module,
    List<Map<String, dynamic>> submaterials,
    List<Map<String, dynamic>> questions,
  ) {
    final warnings = <String>[];

    if (module['short_description']?.toString().trim().isEmpty ?? true) {
      warnings.add('Intro singkat modul belum diisi.');
    }

    if (submaterials.isEmpty) {
      warnings.add('Modul belum memiliki submateri pembelajaran.');
    }

    for (final item in submaterials) {
      final hasRead =
          item['read_content']?.toString().trim().isNotEmpty == true;
      final hasListen =
          item['tts_text']?.toString().trim().isNotEmpty == true ||
              item['audio_url']?.toString().trim().isNotEmpty == true;
      final hasVisual =
          item['image_url']?.toString().trim().isNotEmpty == true ||
              AdminLearningController.mapValue(item['visual_data']).isNotEmpty;

      if (!hasRead && !hasListen && !hasVisual) {
        warnings.add(
          'Submateri "${item['title']}" belum memiliki konten belajar (Baca/Dengar/Visual).',
        );
      }

      final checkpointCount =
          AdminLearningController.mapList(item['checkpoints']).length;

      if (AdminLearningController.boolValue(item['is_required']) &&
          checkpointCount == 0) {
        warnings.add(
          'Submateri wajib "${item['title']}" belum memiliki checkpoint evaluasi.',
        );
      }
    }

    if (questions.isEmpty) {
      warnings.add('Bank soal kuis modul belum memiliki pertanyaan.');
    }

    return warnings;
  }
}

// =============================================================================
// 1. HERO HEADER
// =============================================================================
class _Header extends StatelessWidget {
  const _Header({required this.module});

  final Map<String, dynamic> module;

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
// 2. READINESS CARD
// =============================================================================
class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.warnings});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    final ready = warnings.isEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ready ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ready ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                ready
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: ready ? _success : _warning,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ready
                      ? 'Struktur Modul Lengkap & Siap Rilis'
                      : 'Catatan Kelengkapan Modul (${warnings.length})',
                  style: GoogleFonts.poppins(
                    color: ready ? const Color(0xFF065F46) : const Color(0xFF92400E),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (!ready) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFFDE68A)),
            const SizedBox(height: 10),
            ...warnings.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: Color(0xFF92400E), fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF78350F),
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// 3. STATS GRID
// =============================================================================
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.submaterials,
    required this.checkpoints,
    required this.questions,
    required this.hasLab,
  });

  final int submaterials;
  final int checkpoints;
  final int questions;
  final bool hasLab;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _StatBox(
              width: width,
              label: 'Total Submateri',
              value: '$submaterials Bab',
              icon: Icons.menu_book_rounded,
              color: _primaryBlue,
            ),
            _StatBox(
              width: width,
              label: 'Total Checkpoint',
              value: '$checkpoints Poin',
              icon: Icons.task_alt_rounded,
              color: const Color(0xFF8B5CF6),
            ),
            _StatBox(
              width: width,
              label: 'Bank Soal Kuis',
              value: '$questions Soal',
              icon: Icons.quiz_rounded,
              color: const Color(0xFF6366F1),
            ),
            _StatBox(
              width: width,
              label: 'Virtual Lab 3D',
              value: hasLab ? 'Aktif' : 'Nonaktif',
              icon: Icons.view_in_ar_rounded,
              color: hasLab ? _success : _textMuted,
            ),
          ],
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: _textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: _textMuted,
                    fontSize: 11,
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
// 4. TIMELINE SUBMATERIAL CARD
// =============================================================================
class _SubmaterialTimelineCard extends StatelessWidget {
  const _SubmaterialTimelineCard({
    required this.number,
    required this.isLast,
    required this.submaterial,
  });

  final int number;
  final bool isLast;
  final Map<String, dynamic> submaterial;

  @override
  Widget build(BuildContext context) {
    final hasRead =
        submaterial['read_content']?.toString().trim().isNotEmpty == true;
    final hasListen =
        submaterial['tts_text']?.toString().trim().isNotEmpty == true ||
            submaterial['audio_url']?.toString().trim().isNotEmpty == true;
    final hasVisual =
        submaterial['image_url']?.toString().trim().isNotEmpty == true ||
            AdminLearningController.mapValue(submaterial['visual_data']).isNotEmpty;
    final checkpoints =
        AdminLearningController.mapList(submaterial['checkpoints']);
    final title = submaterial['title']?.toString() ?? 'Submateri';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_darkNavy, _primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    number < 10 ? '0$number' : '$number',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: _textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              _ModeBadge(text: 'Baca', active: hasRead, icon: Icons.menu_book_rounded),
              _ModeBadge(
                  text: 'Dengar', active: hasListen, icon: Icons.headphones_rounded),
              _ModeBadge(
                  text: 'Visual', active: hasVisual, icon: Icons.auto_awesome_rounded),
              _ModeBadge(
                text: '${checkpoints.length} Checkpoint',
                active: checkpoints.isNotEmpty,
                icon: Icons.task_alt_rounded,
                customColor: checkpoints.isNotEmpty
                    ? const Color(0xFF8B5CF6)
                    : _textMuted,
                customBg: checkpoints.isNotEmpty
                    ? const Color(0xFFF5F3FF)
                    : const Color(0xFFF1F5F9),
              ),
            ],
          ),
          if (checkpoints.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...checkpoints.map(
              (checkpoint) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.task_alt_rounded,
                      size: 15,
                      color: Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        checkpoint['title']?.toString() ?? 'Checkpoint',
                        style: GoogleFonts.plusJakartaSans(
                          color: _textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (checkpoint['checkpoint_label']?.toString().isNotEmpty ==
                        true)
                      Text(
                        checkpoint['checkpoint_label'].toString(),
                        style: GoogleFonts.plusJakartaSans(
                          color: _textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({
    required this.text,
    required this.active,
    required this.icon,
    this.customColor,
    this.customBg,
  });

  final String text;
  final bool active;
  final IconData icon;
  final Color? customColor;
  final Color? customBg;

  @override
  Widget build(BuildContext context) {
    final color =
        customColor ?? (active ? _primaryBlue : _textMuted.withValues(alpha: 0.6));
    final bg =
        customBg ?? (active ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
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
// 5. FINAL STAGE CARD (QUIZ & LAB)
// =============================================================================
class _FinalStageCard extends StatelessWidget {
  const _FinalStageCard({
    required this.questionCount,
    required this.sceneId,
  });

  final int questionCount;
  final String sceneId;

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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.military_tech_rounded,
                    color: _primaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Tahap Akhir & Evaluasi Kelulusan',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.quiz_outlined,
                        size: 16, color: _primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Evaluasi Kuis: $questionCount Soal Pilihan Ganda (Passing: 75)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.science_outlined,
                        size: 16, color: Color(0xFF0D9488)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sceneId.trim().isEmpty
                            ? 'Virtual Lab 3D: Tidak ada eksperimen khusus'
                            : 'Virtual Lab 3D: Scene ID "$sceneId"',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
// EMPTY STATE
// =============================================================================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Center(
        child: Text(
          'Belum ada submateri pembelajaran yang ditambahkan.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: _textMuted,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
