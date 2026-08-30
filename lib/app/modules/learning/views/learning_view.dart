import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/api_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/science_shimmer.dart';
import '../controllers/learning_controller.dart';
import 'checkpoint_view.dart';
import 'quiz_view.dart';
import 'progress_view.dart';

const Color _primary = Color(0xFF2563EB);
const Color _primaryDark = Color(0xFF1E3A8A);
const Color _background = Color(0xFFF8FAFC);
const Color _success = Color(0xFF10B981);
const Color _text = Color(0xFF1E293B);
const Color _muted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);

class LearningView extends GetView<LearningController> {
  const LearningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          'Jalur Belajar Sains',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _text,
          ),
        ),
        centerTitle: false,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Obx(
              () => InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await controller.loadOverview(silent: true);
                  await Get.to<void>(() => const LearningProgressView());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 15,
                        color: _primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${controller.totalXp} XP',
                        style: GoogleFonts.poppins(
                          color: _primary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Muat ulang data',
            onPressed: controller.initialize,
            icon: const Icon(Icons.refresh_rounded, size: 22),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: _primary,
        backgroundColor: Colors.white,
        onRefresh: controller.initialize,
        child: Obx(
          () => ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
            children: <Widget>[
              // 1. Fresh Hero Card with Live Status
              _LearningHeader(controller: controller),
              const SizedBox(height: 18),

              // 2. Search & Category Filters
              _LearningFilters(controller: controller),
              const SizedBox(height: 18),

              // 3. Level Stepper & Track
              _LevelSelector(controller: controller),
              const SizedBox(height: 22),

              // 4. Section Title & Live Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.activeFilterTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _border),
                    ),
                    child: Text(
                      '${controller.filteredModules.length} Modul Tersedia',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 5. Module List
              if (controller.isLoadingModules.value)
                const LearningModuleListShimmer()
              else if (controller.modules.isEmpty)
                _EmptyCard(
                  message:
                      controller.errorMessage.value.isEmpty
                          ? 'Belum ada modul pada filter ini.'
                          : controller.errorMessage.value,
                )
              else if (controller.filteredModules.isEmpty)
                const _EmptyCard(
                  message:
                      'Materi tidak ditemukan. Coba gunakan kata kunci atau filter lain.',
                )
              else
                ...controller.filteredModules.map(
                  (module) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ModuleCard(module: module, controller: controller),
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
// 1. FRESH HERO HEADER CARD
// =============================================================================
class _LearningHeader extends StatelessWidget {
  const _LearningHeader({required this.controller});

  final LearningController controller;

  @override
  Widget build(BuildContext context) {
    final int level = controller.selectedLevel.value;
    final int streak = controller.streak;
    final int completedCount = controller.completedModuleCount;
    final int totalCount = controller.progressModules.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[_primaryDark, _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      size: 13,
                      color: Color(0xFFBFDBFE),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Tingkat Level $level',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (streak > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF97316).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 13,
                        color: Color(0xFFFED7AA),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak Hari Belajar',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Kuasai Konsep Sains Terpadu',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Jelajahi submateri interaktif, simulasi lab virtual 3D, dan kuis evaluasi untuk membuka level berikutnya.',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFDCE9FF),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          // Micro Quick Status Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.task_alt_rounded,
                      size: 15,
                      color: Color(0xFF86EFAC),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$completedCount dari $totalCount modul tuntas',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    await controller.loadOverview(silent: true);
                    await Get.to<void>(() => const LearningProgressView());
                  },
                  child: Row(
                    children: [
                      Text(
                        'Lihat Progres',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFBFDBFE),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 15,
                        color: Color(0xFFBFDBFE),
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
}

// =============================================================================
// 2. SEARCH & FRESH CATEGORY PILLS
// =============================================================================
class _LearningFilters extends StatelessWidget {
  const _LearningFilters({required this.controller});

  final LearningController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Search Input Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller.searchTextController,
            onChanged: controller.updateSearchQuery,
            textInputAction: TextInputAction.search,
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: _text),
            decoration: InputDecoration(
              hintText: 'Cari materi, topik, atau konsep...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _muted.withValues(alpha: 0.7),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: _primary,
                size: 21,
              ),
              suffixIcon:
                  controller.searchQuery.value.isEmpty
                      ? null
                      : IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: controller.clearSearch,
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Category Horizontal Capsules
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children:
                LearningController.categoryOptions.map((category) {
                  final bool selected =
                      controller.selectedCategory.value == category;

                  final Color activeColor = _categoryColor(category);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => controller.selectCategory(category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? activeColor : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? activeColor : _border,
                            width: selected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            if (selected)
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            else
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _categoryIcon(category),
                              size: 15,
                              color: selected ? Colors.white : activeColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category,
                              style: GoogleFonts.plusJakartaSans(
                                color: selected ? Colors.white : _text,
                                fontSize: 12.5,
                                fontWeight:
                                    selected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  static IconData _categoryIcon(String category) {
    switch (category) {
      case 'Biologi':
        return Icons.eco_rounded;
      case 'Fisika':
        return Icons.bolt_rounded;
      case 'Kimia':
        return Icons.science_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'Biologi':
        return const Color(0xFF10B981);
      case 'Fisika':
        return const Color(0xFFF59E0B);
      case 'Kimia':
        return const Color(0xFF8B5CF6);
      default:
        return _primary;
    }
  }
}

// =============================================================================
// 3. LEVEL STEPPER TRACK
// =============================================================================
class _LevelSelector extends StatelessWidget {
  const _LevelSelector({required this.controller});

  final LearningController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingLevels.value && controller.levels.isEmpty) {
      return const LearningLevelSelectorShimmer();
    }

    return SizedBox(
      height: 114,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.levels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = controller.levels[index];
          final level = LearningController.intValue(
            item['level'],
            fallback: index + 1,
          );
          final unlocked = LearningController.boolValue(item['is_unlocked']);
          final selected = controller.selectedLevel.value == level;
          final progress = LearningController.doubleValue(
            item['progress'],
          ).clamp(0.0, 1.0);
          final moduleCount = LearningController.intValue(item['module_count']);

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => controller.selectLevel(level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 152,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                gradient:
                    selected
                        ? const LinearGradient(
                          colors: [_primaryDark, _primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
                color: selected ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? _primary : _border,
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: selected ? 0.14 : 0.02,
                    ),
                    blurRadius: selected ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color:
                              selected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : (unlocked
                                      ? _success.withValues(alpha: 0.12)
                                      : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          unlocked
                              ? Icons.lock_open_rounded
                              : Icons.lock_rounded,
                          size: 13,
                          color:
                              selected
                                  ? Colors.white
                                  : unlocked
                                  ? _success
                                  : _muted,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).round()}%',
                        style: GoogleFonts.plusJakartaSans(
                          color: selected ? Colors.white : _text,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Level $level',
                    style: GoogleFonts.poppins(
                      color: selected ? Colors.white : _text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                  Text(
                    '$moduleCount Modul Aktif',
                    style: GoogleFonts.plusJakartaSans(
                      color: selected ? const Color(0xFFDCE9FF) : _muted,
                      fontSize: 10.5,
                    ),
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor:
                          selected
                              ? Colors.white.withValues(alpha: 0.25)
                              : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        selected ? Colors.white : _primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// 4. FRESH MODULAR COURSE CARD
// =============================================================================
class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.controller});

  final Map<String, dynamic> module;
  final LearningController controller;

  @override
  Widget build(BuildContext context) {
    final int materialId = LearningController.intValue(module['id']);
    final bool unlocked = LearningController.boolValue(module['is_unlocked']);
    final bool legacy = LearningController.boolValue(module['legacy_mode']);
    final double progress = LearningController.doubleValue(
      module['progress'],
    ).clamp(0.0, 1.0);
    final int completed = LearningController.intValue(
      module['completed_submaterials'],
    );
    final int total = LearningController.intValue(module['total_submaterials']);

    final String category = module['category']?.toString() ?? 'Sains';
    final int level = LearningController.intValue(module['level'], fallback: 1);
    final bool hasLab =
        module['unity_scene_id']?.toString().trim().isNotEmpty == true;

    final Color categoryColor = _categoryTagColor(category);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap:
            unlocked
                ? () async {
                  final opened = await controller.loadModuleDetail(materialId);
                  if (opened) {
                    await Get.to<void>(() => const LearningModuleDetailView());
                  }
                }
                : () => controller.showError('Modul ini masih terkunci.'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ModuleImage(
                    imageUrl: module['image_url']?.toString(),
                    unlocked: unlocked,
                    size: 70,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Level $level • $category',
                                style: GoogleFonts.plusJakartaSans(
                                  color: categoryColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color:
                                    unlocked
                                        ? _primary.withValues(alpha: 0.1)
                                        : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                unlocked
                                    ? Icons.chevron_right_rounded
                                    : Icons.lock_rounded,
                                color: unlocked ? _primary : _muted,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          module['title']?.toString() ?? 'Modul Pembelajaran',
                          style: GoogleFonts.poppins(
                            color: _text,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                module['short_description']?.toString().trim().isNotEmpty ==
                        true
                    ? module['short_description'].toString()
                    : legacy
                    ? 'Materi pembelajaran sains komprehensif.'
                    : '$completed dari $total submateri selesai.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: _muted,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              // Feature micro tags
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _FeaturePill(
                    icon: Icons.menu_book_rounded,
                    label: '$total Submateri',
                  ),
                  if (hasLab)
                    const _FeaturePill(
                      icon: Icons.science_outlined,
                      label: 'Lab 3D',
                      color: Color(0xFF0D9488),
                      bgColor: Color(0xFFCCFBF1),
                    ),
                  const _FeaturePill(
                    icon: Icons.quiz_outlined,
                    label: 'Kuis Evaluasi',
                    color: Color(0xFF6366F1),
                    bgColor: Color(0xFFEEF2FF),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? _success : _primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(progress * 100).round()}%',
                    style: GoogleFonts.poppins(
                      color: progress >= 1.0 ? _success : _primaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _categoryTagColor(String category) {
    switch (category) {
      case 'Biologi':
        return const Color(0xFF10B981);
      case 'Fisika':
        return const Color(0xFFF59E0B);
      case 'Kimia':
        return const Color(0xFF8B5CF6);
      default:
        return _primary;
    }
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.label,
    this.color,
    this.bgColor,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? _muted;
    final effectiveBg = bgColor ?? const Color(0xFFF8FAFC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: (color ?? _border).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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

class LearningModuleDetailView extends StatefulWidget {
  const LearningModuleDetailView({super.key});

  @override
  State<LearningModuleDetailView> createState() =>
      _LearningModuleDetailViewState();
}

class _LearningModuleDetailViewState extends State<LearningModuleDetailView> {
  late final LearningController controller;

  int? _expandedSubmaterialId;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LearningController>();
  }

  void _toggleSubmaterial(int submaterialId) {
    setState(() {
      _expandedSubmaterialId =
          _expandedSubmaterialId == submaterialId ? null : submaterialId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          'Detail Modul',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            color: _text,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: controller.refreshSelectedModule,
            icon: const Icon(Icons.refresh_rounded, size: 22),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingModuleDetail.value &&
            controller.selectedModule.value == null) {
          return const LearningModuleDetailShimmer();
        }

        final Map<String, dynamic>? module = controller.selectedModule.value;

        if (module == null) {
          return Center(
            child: Text(
              'Modul tidak ditemukan.',
              style: GoogleFonts.plusJakartaSans(color: _muted),
            ),
          );
        }

        final List<Map<String, dynamic>> submaterials =
            LearningController.mapList(module['submaterials']);
        final double progress = LearningController.doubleValue(
          module['progress'],
        ).clamp(0.0, 1.0);
        final bool legacy = LearningController.boolValue(module['legacy_mode']);

        return RefreshIndicator(
          color: _primary,
          backgroundColor: Colors.white,
          onRefresh: controller.refreshSelectedModule,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
            children: <Widget>[
              _ModuleDetailHeader(
                module: module,
                progress: progress,
                submaterialCount: submaterials.length,
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kurikulum Submateri',
                          style: GoogleFonts.poppins(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pelajari topik dan selesaikan latihan checkpoint.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: _muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      '${submaterials.length} Topik',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (legacy || submaterials.isEmpty)
                const _EmptyCard(
                  message:
                      'Modul ini masih menggunakan format materi lama. Submateri Baca, Dengarkan, dan Visual akan muncul setelah data disusun ulang.',
                )
              else
                ...submaterials.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final Map<String, dynamic> submaterial = entry.value;
                  final int id = LearningController.intValue(submaterial['id']);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SubmaterialCard(
                      index: index + 1,
                      submaterial: submaterial,
                      controller: controller,
                      expanded: _expandedSubmaterialId == id,
                      onToggle: () => _toggleSubmaterial(id),
                    ),
                  );
                }),
              const SizedBox(height: 18),
              _RequirementSummary(module: module),
            ],
          ),
        );
      }),
    );
  }
}

// =============================================================================
// MODULE DETAIL HEADER HERO CARD
// =============================================================================
class _ModuleDetailHeader extends StatelessWidget {
  const _ModuleDetailHeader({
    required this.module,
    required this.progress,
    required this.submaterialCount,
  });

  final Map<String, dynamic> module;
  final double progress;
  final int submaterialCount;

  @override
  Widget build(BuildContext context) {
    final String category = module['category']?.toString() ?? 'Sains';
    final int level = LearningController.intValue(module['level'], fallback: 1);
    final Color categoryColor = _ModuleCard._categoryTagColor(category);

    final bool labRequired = LearningController.boolValue(
      module['lab_required'],
    );
    final int passingScore = LearningController.intValue(
      module['quiz_passing_score'],
      fallback: 75,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ModuleImage(
                imageUrl: module['image_url']?.toString(),
                unlocked: true,
                size: 78,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.plusJakartaSans(
                              color: categoryColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Level $level',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF475569),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      module['title']?.toString() ?? 'Modul Pembelajaran',
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (module['short_description']?.toString().trim().isNotEmpty ==
              true) ...[
            const SizedBox(height: 12),
            Text(
              module['short_description'].toString(),
              style: GoogleFonts.plusJakartaSans(
                color: _muted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _FeaturePill(
                icon: Icons.auto_stories_outlined,
                label: '$submaterialCount Submateri',
                color: _primary,
                bgColor: const Color(0xFFEFF6FF),
              ),
              if (labRequired)
                const _FeaturePill(
                  icon: Icons.science_outlined,
                  label: 'Lab 3D',
                  color: Color(0xFF0D9488),
                  bgColor: Color(0xFFCCFBF1),
                ),
              _FeaturePill(
                icon: Icons.quiz_outlined,
                label: 'Kuis Min. $passingScore',
                color: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.5,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? _success : _primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).round()}% Selesai',
                style: GoogleFonts.poppins(
                  color: progress >= 1.0 ? _success : _primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBMATERIAL CARD ACCORDION
// =============================================================================
class _SubmaterialCard extends StatelessWidget {
  const _SubmaterialCard({
    required this.index,
    required this.submaterial,
    required this.controller,
    required this.expanded,
    required this.onToggle,
  });

  final int index;
  final Map<String, dynamic> submaterial;
  final LearningController controller;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> progress = LearningController.mapValue(
      submaterial['progress'],
    );
    final bool completed = LearningController.boolValue(
      progress['is_completed'],
    );
    final bool modeCompleted = LearningController.boolValue(
      progress['mode_completed'],
    );
    final List<Map<String, dynamic>> checkpoints = LearningController.mapList(
      submaterial['checkpoints'],
    );
    final int checkpointCount = checkpoints.length;

    final String numberStr = index < 10 ? '0$index' : '$index';

    final Color borderColor =
        expanded
            ? _primary
            : completed
            ? _success.withValues(alpha: 0.5)
            : _border;
    final double borderWidth = expanded ? 1.8 : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color:
                expanded
                    ? _primary.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
            blurRadius: expanded ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          children: <Widget>[
            Material(
              color: expanded ? const Color(0xFFF8FAFC) : Colors.white,
              child: InkWell(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color:
                              completed
                                  ? const Color(0xFFECFDF5)
                                  : (expanded
                                      ? const Color(0xFFEFF6FF)
                                      : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child:
                              completed
                                  ? const Icon(
                                    Icons.check_rounded,
                                    color: _success,
                                    size: 20,
                                  )
                                  : Text(
                                    numberStr,
                                    style: GoogleFonts.poppins(
                                      color: expanded ? _primary : _muted,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
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
                              submaterial['title']?.toString() ?? 'Submateri',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: _text,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              completed
                                  ? 'Submateri tuntas diselesaikan'
                                  : modeCompleted
                                  ? 'Aktivitas tuntas, selesaikan checkpoint'
                                  : '$checkpointCount checkpoint latihan',
                              style: GoogleFonts.plusJakartaSans(
                                color:
                                    completed
                                        ? _success
                                        : (modeCompleted
                                            ? const Color(0xFFD97706)
                                            : _muted),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                expanded
                                    ? _primary.withValues(alpha: 0.1)
                                    : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: expanded ? _primary : _muted,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              child:
                  expanded
                      ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Color(0xFFF1F5F9)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (submaterial['summary']
                                    ?.toString()
                                    .trim()
                                    .isNotEmpty ==
                                true) ...<Widget>[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      size: 16,
                                      color: _primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        submaterial['summary'].toString(),
                                        style: GoogleFonts.plusJakartaSans(
                                          color: _muted,
                                          height: 1.45,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            Text(
                              'Pilih Mode Pembelajaran',
                              style: GoogleFonts.poppins(
                                color: _text,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _ModeSelectionCard(
                                    icon: Icons.menu_book_rounded,
                                    label: 'Baca',
                                    subtitle: 'Materi Teks',
                                    tintColor: _primary,
                                    enabled: controller.isModeAvailable(
                                      submaterial,
                                      'read',
                                    ),
                                    onTap:
                                        () => _openMode(
                                          controller,
                                          submaterial,
                                          'read',
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ModeSelectionCard(
                                    icon: Icons.headphones_rounded,
                                    label: 'Dengar',
                                    subtitle: 'Audio / TTS',
                                    tintColor: const Color(0xFF8B5CF6),
                                    enabled: controller.isModeAvailable(
                                      submaterial,
                                      'listen',
                                    ),
                                    onTap:
                                        () => _openMode(
                                          controller,
                                          submaterial,
                                          'listen',
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ModeSelectionCard(
                                    icon: Icons.auto_awesome_rounded,
                                    label: 'Visual',
                                    subtitle: 'Simulasi',
                                    tintColor: const Color(0xFFF59E0B),
                                    enabled: controller.isModeAvailable(
                                      submaterial,
                                      'visual',
                                    ),
                                    onTap:
                                        () => _openMode(
                                          controller,
                                          submaterial,
                                          'visual',
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            if (checkpoints.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 16),
                              const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.task_alt_rounded,
                                    size: 16,
                                    color: _primaryDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Latihan Checkpoint',
                                    style: GoogleFonts.poppins(
                                      color: _text,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '$checkpointCount aktivitas',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: _muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...checkpoints.map(
                                (Map<String, dynamic> checkpoint) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _CheckpointTile(
                                    checkpoint: checkpoint,
                                    modeCompleted: modeCompleted,
                                    controller: controller,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMode(
    LearningController controller,
    Map<String, dynamic> submaterial,
    String mode,
  ) async {
    final int submaterialId = LearningController.intValue(submaterial['id']);

    final bool opened = await controller.openMode(
      submaterialId: submaterialId,
      mode: mode,
    );

    if (opened) {
      await Get.to<void>(
        () => LearningModeView(submaterialId: submaterialId, mode: mode),
      );
    }
  }
}

// =============================================================================
// MODE SELECTION MICRO-CARD
// =============================================================================
class _ModeSelectionCard extends StatelessWidget {
  const _ModeSelectionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.tintColor,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color tintColor;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          enabled ? tintColor.withValues(alpha: 0.07) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  enabled
                      ? tintColor.withValues(alpha: 0.3)
                      : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color:
                      enabled
                          ? tintColor.withValues(alpha: 0.14)
                          : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: enabled ? tintColor : _muted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: enabled ? _text : _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  color: enabled ? tintColor : _muted.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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
// CHECKPOINT TILE
// =============================================================================
class _CheckpointTile extends StatelessWidget {
  const _CheckpointTile({
    required this.checkpoint,
    required this.modeCompleted,
    required this.controller,
  });

  final Map<String, dynamic> checkpoint;
  final bool modeCompleted;
  final LearningController controller;

  @override
  Widget build(BuildContext context) {
    final bool completed = LearningController.boolValue(
      checkpoint['is_completed'],
    );
    final String type = checkpoint['checkpoint_type']?.toString() ?? '';
    final bool canOpen = modeCompleted || completed;

    return Material(
      color:
          completed
              ? const Color(0xFFF0FDF4)
              : (canOpen ? Colors.white : const Color(0xFFF8FAFC)),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (!canOpen) {
            controller.showError(
              'Selesaikan salah satu mode belajar terlebih dahulu.',
            );
            return;
          }

          Get.to<void>(() => CheckpointExerciseView(checkpoint: checkpoint));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  completed
                      ? const Color(0xFFA7F3D0)
                      : (canOpen ? const Color(0xFFDBEAFE) : _border),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color:
                      completed
                          ? const Color(0xFFDCFCE7)
                          : (canOpen
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  completed
                      ? Icons.check_rounded
                      : _checkpointIconForTile(type),
                  color: completed ? _success : (canOpen ? _primary : _muted),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      checkpoint['title']?.toString() ??
                          _checkpointLabelForTile(type),
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      completed
                          ? 'Selesai'
                          : canOpen
                          ? _checkpointLabelForTile(type)
                          : 'Terkunci sampai mode belajar selesai',
                      style: GoogleFonts.plusJakartaSans(
                        color:
                            completed
                                ? _success
                                : (canOpen ? _primary : _muted),
                        fontSize: 11,
                        fontWeight:
                            canOpen ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                completed
                    ? Icons.verified_rounded
                    : (canOpen
                        ? Icons.chevron_right_rounded
                        : Icons.lock_outline_rounded),
                color: completed ? _success : (canOpen ? _primary : _muted),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _checkpointLabelForTile(String type) {
  switch (type) {
    case 'multiple_choice':
      return 'Pilihan Ganda';
    case 'true_false':
      return 'Benar / Salah';
    case 'matching':
      return 'Pasangkan';
    case 'ordering':
      return 'Urutkan';
    case 'image_hotspot':
      return 'Tunjuk Bagian';
    case 'data_interpretation':
      return 'Analisis Data';
    default:
      return 'Latihan Soal';
  }
}

IconData _checkpointIconForTile(String type) {
  switch (type) {
    case 'multiple_choice':
      return Icons.list_alt_rounded;
    case 'true_false':
      return Icons.rule_rounded;
    case 'matching':
      return Icons.compare_arrows_rounded;
    case 'ordering':
      return Icons.reorder_rounded;
    case 'image_hotspot':
      return Icons.touch_app_rounded;
    case 'data_interpretation':
      return Icons.analytics_rounded;
    default:
      return Icons.task_alt_rounded;
  }
}

class LearningModeView extends StatefulWidget {
  const LearningModeView({
    super.key,
    required this.submaterialId,
    required this.mode,
  });

  final int submaterialId;
  final String mode;

  @override
  State<LearningModeView> createState() => _LearningModeViewState();
}

class _LearningModeViewState extends State<LearningModeView> {
  final ScrollController _scrollController = ScrollController();

  LearningController get controller => Get.find<LearningController>();

  bool _activityReady = false;
  bool _completedLocally = false;
  double _fontSize = 15.5; // Adjustable reading font size

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollRequirement);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkScrollRequirement(),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_checkScrollRequirement)
      ..dispose();
    super.dispose();
  }

  void _checkScrollRequirement() {
    if (!mounted || widget.mode != 'read') {
      return;
    }

    if (!_scrollController.hasClients) {
      return;
    }

    final ScrollPosition position = _scrollController.position;
    final bool reachedEnd =
        position.maxScrollExtent <= 24 ||
        position.pixels >= position.maxScrollExtent - 36;

    if (reachedEnd != _activityReady) {
      setState(() {
        _activityReady = reachedEnd;
      });
    }
  }

  void _handleContentReady(bool ready) {
    if (!mounted || widget.mode == 'read') {
      return;
    }

    if (_activityReady != ready) {
      setState(() {
        _activityReady = ready;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String modeTitle = _modeLabel(widget.mode);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          modeTitle,
          style: GoogleFonts.poppins(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: _text,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        centerTitle: false,
        shape: const Border(bottom: BorderSide(color: _border, width: 1)),
        actions: [
          if (widget.mode == 'read') ...[
            IconButton(
              tooltip: 'Kecilkan Teks',
              icon: const Icon(Icons.text_decrease_rounded, size: 20),
              onPressed:
                  _fontSize > 13.5
                      ? () => setState(() => _fontSize -= 1.5)
                      : null,
            ),
            IconButton(
              tooltip: 'Besarkan Teks',
              icon: const Icon(Icons.text_increase_rounded, size: 20),
              onPressed:
                  _fontSize < 20.0
                      ? () => setState(() => _fontSize += 1.5)
                      : null,
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: Obx(() {
        final Map<String, dynamic>? submaterial = controller.findSubmaterial(
          widget.submaterialId,
        );

        if (submaterial == null) {
          return Center(
            child: Text(
              'Submateri tidak ditemukan.',
              style: GoogleFonts.plusJakartaSans(color: _muted),
            ),
          );
        }

        final Map<String, dynamic> progress = LearningController.mapValue(
          submaterial['progress'],
        );
        final bool alreadyCompleted =
            _completedLocally ||
            LearningController.boolValue(progress['mode_completed']);

        final bool canComplete = alreadyCompleted || _activityReady;
        final String title = submaterial['title']?.toString() ?? 'Submateri';
        final String summary = submaterial['summary']?.toString() ?? '';
        final String readText = submaterial['read_content']?.toString() ?? '';
        final int wordCount =
            readText.trim().isEmpty
                ? 0
                : readText.trim().split(RegExp(r'\s+')).length;
        final int estMinutes = (wordCount / 160).ceil().clamp(1, 30);

        return ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: <Widget>[
            // Hero Title Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _modeBadgeBg(widget.mode),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _modeIcon(widget.mode),
                              size: 14,
                              color: _modeBadgeColor(widget.mode),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              modeTitle,
                              style: GoogleFonts.plusJakartaSans(
                                color: _modeBadgeColor(widget.mode),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.mode == 'read' && wordCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '±$estMinutes Menit Baca',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF475569),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: _text,
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  if (summary.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: _primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              summary,
                              style: GoogleFonts.plusJakartaSans(
                                color: _muted,
                                height: 1.45,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ModeContent(
              submaterial: submaterial,
              mode: widget.mode,
              fontSize: _fontSize,
              onReadyChanged: _handleContentReady,
            ),
            const SizedBox(height: 18),
            _ActivityRequirementCard(
              mode: widget.mode,
              ready: canComplete,
              completed: alreadyCompleted,
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed:
                    alreadyCompleted ||
                            !_activityReady ||
                            controller.isCompletingMode.value
                        ? null
                        : () async {
                          final bool completed = await controller.completeMode(
                            submaterialId: widget.submaterialId,
                            mode: widget.mode,
                          );

                          if (completed && mounted) {
                            setState(() {
                              _completedLocally = true;
                            });
                          }
                        },
                icon:
                    controller.isCompletingMode.value
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Icon(
                          alreadyCompleted
                              ? Icons.verified_rounded
                              : canComplete
                              ? Icons.check_circle_rounded
                              : Icons.lock_outline_rounded,
                          size: 20,
                        ),
                label: Text(
                  alreadyCompleted
                      ? 'Aktivitas Sudah Selesai'
                      : canComplete
                      ? 'Selesaikan Mode Baca'
                      : _lockedButtonLabel(widget.mode),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: alreadyCompleted ? _success : _primary,
                  disabledBackgroundColor:
                      alreadyCompleted ? _success : const Color(0xFFE2E8F0),
                  disabledForegroundColor:
                      alreadyCompleted ? Colors.white : const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: canComplete && !alreadyCompleted ? 2 : 0,
                ),
              ),
            ),
            if (alreadyCompleted) ...<Widget>[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Get.back<void>(),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  'Kembali ke Daftar Submateri',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: BorderSide(color: _primary.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Setelah aktivitas selesai, kerjakan checkpoint untuk memastikan pemahaman materi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: _muted,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ],
        );
      }),
    );
  }

  static String _modeLabel(String mode) {
    switch (mode) {
      case 'listen':
        return 'Mode Dengarkan';
      case 'visual':
        return 'Mode Visual';
      default:
        return 'Mode Baca';
    }
  }

  static IconData _modeIcon(String mode) {
    switch (mode) {
      case 'listen':
        return Icons.headphones_rounded;
      case 'visual':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  static Color _modeBadgeColor(String mode) {
    switch (mode) {
      case 'listen':
        return const Color(0xFF8B5CF6);
      case 'visual':
        return const Color(0xFFF59E0B);
      default:
        return _primary;
    }
  }

  static Color _modeBadgeBg(String mode) {
    switch (mode) {
      case 'listen':
        return const Color(0xFFF3E8FF);
      case 'visual':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  static String _lockedButtonLabel(String mode) {
    switch (mode) {
      case 'listen':
        return 'Dengarkan Hingga 90%';
      case 'visual':
        return 'Lihat Semua Bagian Visual';
      default:
        return 'Gulir & Baca Sampai Akhir';
    }
  }
}

class _ActivityRequirementCard extends StatelessWidget {
  const _ActivityRequirementCard({
    required this.mode,
    required this.ready,
    required this.completed,
  });

  final String mode;
  final bool ready;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color border;
    final Color foreground;
    final IconData icon;
    final String title;
    final String message;

    if (completed) {
      background = const Color(0xFFF0FDF4);
      border = const Color(0xFFA7F3D0);
      foreground = const Color(0xFF166534);
      icon = Icons.verified_rounded;
      title = 'Aktivitas Telah Selesai';
      message = 'Progres pembelajaranmu sudah berhasil tersimpan.';
    } else if (ready) {
      background = const Color(0xFFEFF6FF);
      border = const Color(0xFFBFDBFE);
      foreground = _primaryDark;
      icon = Icons.task_alt_rounded;
      title = 'Aktivitas Siap Diselesaikan';
      message = 'Tekan tombol di bawah untuk menyimpan progres belajarmu.';
    } else {
      background = const Color(0xFFFFFBEB);
      border = const Color(0xFFFDE68A);
      foreground = const Color(0xFF92400E);
      icon = Icons.info_outline_rounded;
      title = 'Lanjutkan Membaca';
      message = _requirementMessage(mode);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: foreground, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: GoogleFonts.plusJakartaSans(
                        color: foreground.withValues(alpha: 0.9),
                        fontSize: 12,
                        height: 1.4,
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

  static String _requirementMessage(String mode) {
    switch (mode) {
      case 'listen':
        return 'Putar dan dengarkan minimal 90% isi audio narasi.';
      case 'visual':
        return 'Buka seluruh gambar atau titik penjelasan yang tersedia.';
      default:
        return 'Gulir dan baca materi hingga bagian paling akhir untuk membuka tombol.';
    }
  }
}

class _ModeContent extends StatelessWidget {
  const _ModeContent({
    required this.submaterial,
    required this.mode,
    this.fontSize = 15.5,
    required this.onReadyChanged,
  });

  final Map<String, dynamic> submaterial;
  final String mode;
  final double fontSize;
  final ValueChanged<bool> onReadyChanged;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case 'listen':
        return _ListenContent(
          submaterial: submaterial,
          onReadyChanged: onReadyChanged,
        );
      case 'visual':
        return _VisualContent(
          submaterial: submaterial,
          onReadyChanged: onReadyChanged,
        );
      default:
        return _ReadContent(submaterial: submaterial, fontSize: fontSize);
    }
  }
}

class _ReadContent extends StatelessWidget {
  const _ReadContent({required this.submaterial, this.fontSize = 15.5});

  final Map<String, dynamic> submaterial;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final String content = submaterial['read_content']?.toString().trim() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.article_outlined,
                      color: _primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Naskah Materi Pembelajaran',
                    style: GoogleFonts.poppins(
                      color: _text,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),
              if (content.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Konten materi bacaan belum tersedia.',
                      style: GoogleFonts.plusJakartaSans(
                        color: _muted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              else
                SelectableText(
                  content,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF1E293B),
                    fontSize: fontSize,
                    height: 1.8,
                    letterSpacing: 0.15,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListenContent extends StatefulWidget {
  const _ListenContent({
    required this.submaterial,
    required this.onReadyChanged,
  });

  final Map<String, dynamic> submaterial;
  final ValueChanged<bool> onReadyChanged;

  @override
  State<_ListenContent> createState() => _ListenContentState();
}

class _ListenContentState extends State<_ListenContent> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<void>? _completeSubscription;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;

  double _speed = 1.0;
  bool _audioPrepared = false;
  bool _isBusy = false;
  bool _ttsSpeaking = false;
  bool _ttsPaused = false;
  String? _errorMessage;

  String? _neuralTtsAudioUrl;
  bool _isLoadingNeural = false;

  int _listenedMilliseconds = 0;
  Duration _lastTrackedPosition = Duration.zero;
  bool _readyWasReported = false;

  String? get _directAudioUrl =>
      ApiService.resolveMediaUrl(widget.submaterial['audio_url']?.toString());

  String? get _effectiveAudioUrl => _directAudioUrl ?? _neuralTtsAudioUrl;

  bool get _usesAudioFile => _effectiveAudioUrl != null;

  String get _narrationText {
    final String ttsText =
        widget.submaterial['tts_text']?.toString().trim() ?? '';

    if (ttsText.isNotEmpty) {
      return ttsText;
    }

    return widget.submaterial['read_content']?.toString().trim() ?? '';
  }

  bool get _isPlaying {
    if (_usesAudioFile) {
      return _playerState == PlayerState.playing;
    }

    return _ttsSpeaking && !_ttsPaused;
  }

  @override
  void initState() {
    super.initState();
    _configureAudioPlayer();
    _configureTts();

    if (_directAudioUrl == null) {
      _loadNeuralTtsAudio();
    }
  }

  Future<void> _loadNeuralTtsAudio() async {
    final int submaterialId =
        LearningController.intValue(widget.submaterial['id']);
    if (submaterialId <= 0) {
      return;
    }

    setState(() {
      _isLoadingNeural = true;
    });

    try {
      final res = await ApiService.getSubmaterialTtsAudio(submaterialId);
      if (res != null && res['success'] == true && res['audio_url'] != null) {
        final String? resolved =
            ApiService.resolveMediaUrl(res['audio_url'].toString());
        if (mounted && resolved != null && resolved.isNotEmpty) {
          setState(() {
            _neuralTtsAudioUrl = resolved;
            _isLoadingNeural = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('[Audio] Gagal memuat audio narasi: $e');
    }

    if (mounted) {
      setState(() {
        _isLoadingNeural = false;
      });
    }
  }

  void _configureAudioPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) {
        return;
      }

      setState(() {
        _duration = duration;
      });
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) {
        return;
      }

      final int delta =
          position.inMilliseconds - _lastTrackedPosition.inMilliseconds;

      // Perpindahan besar dianggap seek dan tidak dihitung.
      if (_playerState == PlayerState.playing && delta > 0 && delta <= 3000) {
        _listenedMilliseconds += delta;
      }

      _lastTrackedPosition = position;

      setState(() {
        _position = position;
      });

      _reportAudioReadiness();
    });

    _stateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) {
        return;
      }

      setState(() {
        _playerState = state;
      });
    });

    _completeSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _position = _duration;
        _playerState = PlayerState.completed;
      });
      _reportAudioReadiness();
    });
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('id-ID');
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _applyTtsSpeed(_speed);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      if (!mounted) {
        return;
      }

      setState(() {
        _ttsSpeaking = true;
        _ttsPaused = false;
        _errorMessage = null;
      });
    });

    _flutterTts.setPauseHandler(() {
      if (!mounted) {
        return;
      }

      setState(() {
        _ttsSpeaking = true;
        _ttsPaused = true;
      });
    });

    _flutterTts.setContinueHandler(() {
      if (!mounted) {
        return;
      }

      setState(() {
        _ttsSpeaking = true;
        _ttsPaused = false;
      });
    });

    _flutterTts.setCompletionHandler(() {
      if (!mounted) {
        return;
      }

      setState(() {
        _ttsSpeaking = false;
        _ttsPaused = false;
      });
      _reportAudioReadiness(forceReady: true);
    });

    _flutterTts.setCancelHandler(() {
      if (!mounted) {
        return;
      }

      setState(() {
        _ttsSpeaking = false;
        _ttsPaused = false;
      });
    });

    _flutterTts.setErrorHandler((message) {
      if (!mounted) {
        return;
      }

      setState(() {
        _ttsSpeaking = false;
        _ttsPaused = false;
        _errorMessage = 'TTS tidak dapat diputar: $message';
      });
    });
  }

  void _reportAudioReadiness({bool forceReady = false}) {
    final bool ready;

    if (forceReady) {
      ready = true;
    } else if (_usesAudioFile) {
      final int total = _duration.inMilliseconds;
      ready = total > 0 && (_listenedMilliseconds / total) >= 0.90;
    } else {
      ready = false;
    }

    if (ready && !_readyWasReported) {
      _readyWasReported = true;
      widget.onReadyChanged(true);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _completeSubscription?.cancel();

    _audioPlayer.dispose();
    _flutterTts.stop();

    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isBusy) {
      return;
    }

    if (_directAudioUrl == null &&
        _neuralTtsAudioUrl == null &&
        _isLoadingNeural) {
      setState(() {
        _isBusy = true;
      });
      await _loadNeuralTtsAudio();
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }

    if (_usesAudioFile) {
      await _toggleAudioFile();
    } else {
      await _toggleTts();
    }
  }

  Future<void> _toggleAudioFile() async {
    final String? url = _effectiveAudioUrl;

    if (url == null) {
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      if (_playerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else if (_audioPrepared && _playerState == PlayerState.paused) {
        await _audioPlayer.resume();
        await _audioPlayer.setPlaybackRate(_speed);
      } else {
        await _audioPlayer.play(UrlSource(url));
        _audioPrepared = true;
        await _audioPlayer.setPlaybackRate(_speed);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Audio tidak dapat diputar: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _toggleTts() async {
    final String text = _narrationText;

    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Naskah audio belum tersedia.';
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      if (_ttsSpeaking && !_ttsPaused) {
        await _flutterTts.pause();
      } else {
        await _applyTtsSpeed(_speed);
        await _flutterTts.speak(text, focus: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'TTS tidak dapat diputar: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _stopPlayback() async {
    if (_usesAudioFile) {
      await _audioPlayer.stop();

      if (mounted) {
        setState(() {
          _position = Duration.zero;
        });
      }

      return;
    }

    await _flutterTts.stop();
  }

  Future<void> _changeSpeed(double speed) async {
    setState(() {
      _speed = speed;
    });

    try {
      if (_usesAudioFile && _audioPrepared) {
        await _audioPlayer.setPlaybackRate(speed);
      } else {
        await _applyTtsSpeed(speed);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Kecepatan audio tidak dapat diubah: $e';
        });
      }
    }
  }

  Future<void> _applyTtsSpeed(double displayedSpeed) async {
    final double ttsRate;

    if (displayedSpeed <= 0.75) {
      ttsRate = 0.35;
    } else if (displayedSpeed <= 1.0) {
      ttsRate = 0.45;
    } else if (displayedSpeed <= 1.25) {
      ttsRate = 0.55;
    } else {
      ttsRate = 0.65;
    }

    await _flutterTts.setSpeechRate(ttsRate);
  }

  Future<void> _seekTo(double milliseconds) async {
    if (!_usesAudioFile) {
      return;
    }

    await _audioPlayer.seek(Duration(milliseconds: milliseconds.round()));
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNarration = _narrationText.isNotEmpty;
    final bool canPlay = _usesAudioFile || hasNarration;

    return _ContentCard(
      icon: Icons.headphones_rounded,
      title: 'Materi Audio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ==========================================
          // VIBRANT ROYAL BLUE GRADIENT PLAYER CARD
          // ==========================================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF1E3A8A), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Translucent Circular Play Button
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        onPressed: canPlay && !_isBusy ? _togglePlayback : null,
                        icon: _isBusy || _isLoadingNeural
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Track Title & Clean Status Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Audio Pembelajaran',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _isPlaying
                                ? 'Sedang memutar audio materi...'
                                : (_position > Duration.zero
                                    ? 'Audio sedang dijeda'
                                    : 'Dengarkan penjelasan materi'),
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFDCE9FF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stop Button
                    IconButton(
                      tooltip: 'Berhenti',
                      onPressed: canPlay ? _stopPlayback : null,
                      icon: const Icon(
                        Icons.stop_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                if (_usesAudioFile) ...<Widget>[
                  const SizedBox(height: 14),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withValues(alpha: 0.15),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      min: 0,
                      max: _duration.inMilliseconds > 0
                          ? _duration.inMilliseconds.toDouble()
                          : 1,
                      value: _safeSliderValue(),
                      onChanged: _duration.inMilliseconds > 0 ? _seekTo : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _formatDuration(_position),
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFDCE9FF),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFDCE9FF),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Speed Section
          Text(
            'Kecepatan Suara',
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: <double>[0.75, 1.0, 1.25, 1.5].map((speed) {
              final bool selected = _speed == speed;

              return ChoiceChip(
                label: Text(
                  '${speed.toStringAsFixed(speed == 1.0 ? 0 : 2)}x',
                ),
                selected: selected,
                onSelected: (_) => _changeSpeed(speed),
                selectedColor: const Color(0xFFEFF6FF),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(
                  color: selected ? _primary : const Color(0xFFE2E8F0),
                  width: selected ? 1.5 : 1,
                ),
                labelStyle: GoogleFonts.plusJakartaSans(
                  color: selected ? _primary : _muted,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12.5,
                ),
              );
            }).toList(),
          ),

          if (_errorMessage != null) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDBA74)),
              ),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF9A3412),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _safeSliderValue() {
    final double maximum =
        _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1;

    return _position.inMilliseconds.toDouble().clamp(0.0, maximum);
  }

  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class _VisualContent extends StatefulWidget {
  const _VisualContent({
    required this.submaterial,
    required this.onReadyChanged,
  });

  final Map<String, dynamic> submaterial;
  final ValueChanged<bool> onReadyChanged;

  @override
  State<_VisualContent> createState() => _VisualContentState();
}

class _VisualContentState extends State<_VisualContent> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  Map<String, dynamic>? _selectedVisualHotspot;
  final Set<int> _visitedImagePages = <int>{0};
  final Set<String> _visitedHotspotIds = <String>{};
  bool _visualReadyReported = false;

  Map<String, dynamic> get _visualData =>
      LearningController.mapValue(widget.submaterial['visual_data']);

  String get _visualType =>
      widget.submaterial['visual_type']?.toString().trim().toLowerCase() ??
      'infographic';

  List<Map<String, dynamic>> get _visualItems {
    final dynamic raw =
        _visualData['items'] ?? _visualData['steps'] ?? _visualData['points'];

    if (raw is Map) {
      return raw.entries.map((entry) {
        return <String, dynamic>{
          'title': entry.key.toString(),
          'description': entry.value.toString(),
        };
      }).toList();
    }

    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw.asMap().entries.map((entry) {
      final dynamic item = entry.value;

      if (item is Map) {
        return Map<String, dynamic>.from(item);
      }

      return <String, dynamic>{
        'title': 'Poin ${entry.key + 1}',
        'description': item.toString(),
      };
    }).toList();
  }

  List<Map<String, dynamic>> get _images {
    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];

    final String? mainImage = ApiService.resolveMediaUrl(
      widget.submaterial['image_url']?.toString(),
    );

    if (mainImage != null) {
      result.add(<String, dynamic>{
        'url': mainImage,
        'caption': _visualData['image_caption']?.toString() ?? '',
      });
    }

    final dynamic rawImages = _visualData['images'];

    if (rawImages is List) {
      for (final dynamic item in rawImages) {
        if (item is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(item);

          final String? url = ApiService.resolveMediaUrl(
            (map['url'] ?? map['image_url'] ?? map['path'])?.toString(),
          );

          if (url != null) {
            result.add(<String, dynamic>{
              'url': url,
              'caption': (map['caption'] ?? map['title'] ?? '').toString(),
            });
          }
        } else {
          final String? url = ApiService.resolveMediaUrl(item.toString());

          if (url != null) {
            result.add(<String, dynamic>{'url': url, 'caption': ''});
          }
        }
      }
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _reportVisualReadiness(),
    );
  }

  void _reportVisualReadiness() {
    if (!mounted || _visualReadyReported) {
      return;
    }

    final List<Map<String, dynamic>> images = _images;
    final List<Map<String, dynamic>> hotspots = _visualHotspots;

    final bool ready;

    if (_visualType == 'hotspot' && hotspots.isNotEmpty) {
      ready = _visitedHotspotIds.length >= hotspots.length;
    } else if (images.length > 1) {
      ready = _visitedImagePages.length >= images.length;
    } else {
      // Visual statis dianggap telah dilihat ketika tampil.
      ready = true;
    }

    if (ready) {
      _visualReadyReported = true;
      widget.onReadyChanged(true);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> images = _images;
    final List<Map<String, dynamic>> items = _visualItems;

    return _ContentCard(
      icon: Icons.auto_awesome_rounded,
      title: _visualData['title']?.toString() ?? 'Visualisasi Materi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_visualData['description']?.toString().trim().isNotEmpty ==
              true) ...<Widget>[
            Text(
              _visualData['description'].toString(),
              style: const TextStyle(color: _muted, height: 1.45),
            ),
            const SizedBox(height: 16),
          ],
          if (images.isNotEmpty && _visualType != 'hotspot')
            _buildImageSlider(images),
          if (images.isNotEmpty &&
              _visualType != 'hotspot' &&
              (items.isNotEmpty ||
                  _visualType == 'formula' ||
                  _visualType == 'chart' ||
                  _visualType == 'data_interpretation'))
            const SizedBox(height: 18),
          _buildVisualBody(items),
        ],
      ),
    );
  }

  Widget _buildImageSlider(List<Map<String, dynamic>> images) {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _visitedImagePages.add(index);
              });
              _reportVisualReadiness();
            },
            itemBuilder: (context, index) {
              final image = images[index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.network(
                      image['url'].toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const _ImageError();
                      },
                    ),
                    if (image['caption'].toString().trim().isNotEmpty)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.black.withValues(alpha: 0.62),
                          child: Text(
                            image['caption'].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        if (images.length > 1) ...<Widget>[
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: index == _currentPage ? 22 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color:
                      index == _currentPage
                          ? _primary
                          : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
        if (images.length > 1) ...<Widget>[
          const SizedBox(height: 7),
          Text(
            '${_visitedImagePages.length}/${images.length} gambar telah dilihat',
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVisualBody(List<Map<String, dynamic>> items) {
    switch (_visualType) {
      case 'comparison':
        return _buildComparison(items);
      case 'flow':
      case 'sequence':
        return _buildSequence(items);
      case 'formula':
        return _buildFormula(items);
      case 'hotspot':
        return _buildHotspotVisual();
      case 'chart':
      case 'data':
      case 'data_interpretation':
        return _buildDataTable();
      default:
        return _buildInfographic(items);
    }
  }

  Widget _buildHotspotVisual() {
    final List<Map<String, dynamic>> images = _images;
    final List<Map<String, dynamic>> hotspots = _visualHotspots;

    if (images.isEmpty) {
      return const Text(
        'Gambar visual belum tersedia.',
        style: TextStyle(color: _muted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Ketuk seluruh titik pada gambar untuk membaca penjelasannya.',
                style: TextStyle(color: _muted, height: 1.4),
              ),
            ),
            if (hotspots.isNotEmpty)
              Text(
                '${_visitedHotspotIds.length}/${hotspots.length}',
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.network(
                      images.first['url'].toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ImageError(),
                    ),
                    ...hotspots.map((hotspot) {
                      final double x = _visualCoordinate(hotspot['x']);
                      final double y = _visualCoordinate(hotspot['y']);
                      final bool selected =
                          _selectedVisualHotspot?['id']?.toString() ==
                          hotspot['id']?.toString();

                      final double left =
                          (x * constraints.maxWidth - 18)
                              .clamp(0.0, constraints.maxWidth - 36)
                              .toDouble();
                      final double top =
                          (y * constraints.maxHeight - 18)
                              .clamp(0.0, constraints.maxHeight - 36)
                              .toDouble();

                      return Positioned(
                        left: left,
                        top: top,
                        child: GestureDetector(
                          onTap: () {
                            final String hotspotId =
                                hotspot['id']?.toString() ??
                                hotspot['label']?.toString() ??
                                hotspots.indexOf(hotspot).toString();

                            setState(() {
                              _selectedVisualHotspot = hotspot;
                              _visitedHotspotIds.add(hotspotId);
                            });
                            _reportVisualReadiness();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: selected ? 42 : 36,
                            height: selected ? 42 : 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  selected ? const Color(0xFF16A34A) : _primary,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.touch_app_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (hotspots.isEmpty)
          const Text(
            'Belum ada titik penjelasan pada gambar ini.',
            style: TextStyle(color: _muted),
          )
        else if (_selectedVisualHotspot == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Pilih salah satu titik pada gambar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.info_rounded, color: _primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedVisualHotspot!['label']?.toString() ??
                            'Penjelasan',
                        style: const TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  (_selectedVisualHotspot!['explanation'] ??
                          _selectedVisualHotspot!['description'] ??
                          'Belum ada penjelasan.')
                      .toString(),
                  style: const TextStyle(color: _muted, height: 1.5),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Map<String, dynamic>> get _visualHotspots {
    final dynamic raw = _visualData['hotspots'];
    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  double _visualCoordinate(dynamic raw) {
    final double value = double.tryParse(raw?.toString() ?? '') ?? 0.5;
    return (value > 1 ? value / 100 : value).clamp(0.0, 1.0).toDouble();
  }

  Widget _buildInfographic(List<Map<String, dynamic>> items) {
    if (items.isEmpty && _images.isEmpty) {
      return const Text(
        'Konten visual belum tersedia.',
        style: TextStyle(color: _muted),
      );
    }

    return Column(
      children:
          items.asMap().entries.map((entry) {
            final Map<String, dynamic> item = entry.value;

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _VisualItemText(item: item)),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildComparison(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Text(
        'Data perbandingan belum tersedia.',
        style: TextStyle(color: _muted),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 620;

        final List<Widget> cards =
            items.map((item) {
              return Container(
                width: wide ? (constraints.maxWidth - 12) / 2 : double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: _VisualItemText(item: item),
              );
            }).toList();

        return Wrap(spacing: 12, runSpacing: 12, children: cards);
      },
    );
  }

  Widget _buildSequence(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Text(
        'Urutan proses belum tersedia.',
        style: TextStyle(color: _muted),
      );
    }

    return Column(
      children:
          items.asMap().entries.map((entry) {
            final bool isLast = entry.key == items.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 3,
                        height: 54,
                        color: const Color(0xFFBFDBFE),
                      ),
                  ],
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: _VisualItemText(item: entry.value),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildFormula(List<Map<String, dynamic>> items) {
    final String formula =
        (_visualData['formula'] ?? _visualData['value'] ?? '').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (formula.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF172554),
              borderRadius: BorderRadius.circular(18),
            ),
            child: SelectableText(
              formula,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.4,
              ),
            ),
          ),
        if (formula.isNotEmpty && items.isNotEmpty) const SizedBox(height: 14),
        _buildInfographic(items),
      ],
    );
  }

  Widget _buildDataTable() {
    final List<String> headers = _stringList(_visualData['headers']);
    final dynamic rawRows = _visualData['rows'] ?? _visualData['data'];
    final List<dynamic> rows =
        rawRows is List ? List<dynamic>.from(rawRows) : <dynamic>[];

    if (rows.isEmpty) {
      return const Text(
        'Data visual belum tersedia.',
        style: TextStyle(color: _muted),
      );
    }

    final List<String> effectiveHeaders = _effectiveHeaders(headers, rows);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEAF1FF)),
        columns:
            effectiveHeaders
                .map(
                  (header) => DataColumn(
                    label: Text(
                      header,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                )
                .toList(),
        rows:
            rows.map((row) {
              if (row is Map) {
                return DataRow(
                  cells:
                      effectiveHeaders.map((header) {
                        return DataCell(
                          Text(
                            row[header]?.toString() ??
                                row[header.toLowerCase()]?.toString() ??
                                '-',
                          ),
                        );
                      }).toList(),
                );
              }

              if (row is List) {
                return DataRow(
                  cells: List<DataCell>.generate(
                    effectiveHeaders.length,
                    (index) => DataCell(
                      Text(index < row.length ? row[index].toString() : '-'),
                    ),
                  ),
                );
              }

              return DataRow(
                cells:
                    effectiveHeaders
                        .map((_) => DataCell(Text(row.toString())))
                        .toList(),
              );
            }).toList(),
      ),
    );
  }

  List<String> _stringList(dynamic raw) {
    if (raw is! List) {
      return <String>[];
    }

    return raw.map((item) => item.toString()).toList();
  }

  List<String> _effectiveHeaders(List<String> headers, List<dynamic> rows) {
    if (headers.isNotEmpty) {
      return headers;
    }

    if (rows.isNotEmpty && rows.first is Map) {
      return (rows.first as Map).keys.map((key) => key.toString()).toList();
    }

    if (rows.isNotEmpty && rows.first is List) {
      return List<String>.generate(
        (rows.first as List).length,
        (index) => 'Kolom ${index + 1}',
      );
    }

    return const <String>['Data'];
  }
}

class _VisualItemText extends StatelessWidget {
  const _VisualItemText({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final String title =
        (item['title'] ?? item['label'] ?? item['name'] ?? '').toString();

    final String description =
        (item['description'] ??
                item['content'] ??
                item['text'] ??
                item['value'] ??
                '')
            .toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title.trim().isNotEmpty)
          Text(
            title,
            style: const TextStyle(color: _text, fontWeight: FontWeight.w900),
          ),
        if (title.trim().isNotEmpty && description.trim().isNotEmpty)
          const SizedBox(height: 5),
        if (description.trim().isNotEmpty)
          Text(
            description,
            style: const TextStyle(color: _muted, height: 1.45),
          ),
      ],
    );
  }
}

// =============================================================================
// REQUIREMENT SUMMARY & EVALUATION ACTION CARDS
// =============================================================================
class _RequirementSummary extends StatelessWidget {
  const _RequirementSummary({required this.module});

  final Map<String, dynamic> module;

  @override
  Widget build(BuildContext context) {
    final int materialId = LearningController.intValue(module['id']);
    final String moduleTitle = module['title']?.toString() ?? 'Modul';

    final bool quizRequired = LearningController.boolValue(
      module['quiz_required'],
    );
    final bool quizUnlocked = LearningController.boolValue(
      module['quiz_unlocked'],
    );
    final bool quizPassed = LearningController.boolValue(module['quiz_passed']);
    final int quizScore = LearningController.intValue(module['quiz_score']);
    final int passingScore = LearningController.intValue(
      module['quiz_passing_score'],
      fallback: 75,
    );

    final bool labRequired = LearningController.boolValue(
      module['lab_required'],
    );
    final bool labUnlocked = LearningController.boolValue(
      module['lab_unlocked'],
    );
    final bool labCompleted = LearningController.boolValue(
      module['lab_completed'],
    );

    int totalStages = 0;
    int completedStages = 0;
    if (quizRequired) {
      totalStages++;
      if (quizPassed) completedStages++;
    }
    if (labRequired) {
      totalStages++;
      if (labCompleted) completedStages++;
    }

    final String sectionTitle =
        labRequired ? 'Tahap Evaluasi & Praktikum' : 'Tahap Evaluasi Kelulusan';
    final String sectionSubtitle =
        labRequired
            ? 'Selesaikan kuis dan simulasi untuk menuntaskan modul.'
            : 'Selesaikan kuis untuk menuntaskan modul ini.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sectionTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sectionSubtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            if (totalStages > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      completedStages == totalStages
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        completedStages == totalStages
                            ? const Color(0xFFA7F3D0)
                            : _primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '$completedStages/$totalStages Selesai',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: completedStages == totalStages ? _success : _primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (quizRequired)
          _QuizActionCard(
            unlocked: quizUnlocked,
            passed: quizPassed,
            score: quizScore,
            passingScore: passingScore,
            onTap:
                quizUnlocked
                    ? () async {
                      await Get.to<void>(
                        () => LearningQuizView(
                          materialId: materialId,
                          moduleTitle: moduleTitle,
                        ),
                      );
                    }
                    : null,
          )
        else
          const _InactiveActionCard(
            icon: Icons.quiz_outlined,
            title: 'Kuis Evaluasi Modul',
            subtitle: 'Belum tersedia untuk modul ini',
            badgeText: 'Nonaktif',
          ),
        const SizedBox(height: 10),
        if (!labRequired)
          const _InactiveActionCard(
            icon: Icons.science_outlined,
            title: 'Laboratorium Virtual 3D',
            subtitle: 'Tidak diperlukan pada modul ini',
            badgeText: 'Tidak Wajib',
          )
        else
          _LabActionCard(
            unlocked: labUnlocked,
            completed: labCompleted,
            passingScore: passingScore,
            onTap:
                labUnlocked || labCompleted
                    ? () async {
                      await Get.toNamed<void>(
                        Routes.LAB,
                        arguments: <String, dynamic>{
                          'materialId': materialId,
                          'sceneId': module['unity_scene_id'],
                          'sceneName': moduleTitle,
                          'learningFlow': true,
                        },
                      );

                      if (Get.isRegistered<LearningController>()) {
                        final controller = Get.find<LearningController>();
                        await controller.refreshSelectedModule();
                        await controller.loadModules(
                          controller.selectedLevel.value,
                        );
                        await controller.refreshLevelsOnly();
                      }
                    }
                    : () {
                      Get.dialog<void>(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            'Laboratorium Belum Terbuka',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          content: Text(
                            'Selesaikan seluruh submateri dan raih nilai kuis minimal $passingScore pada modul ini terlebih dahulu.',
                            style: GoogleFonts.plusJakartaSans(
                              height: 1.45,
                              fontSize: 13,
                            ),
                          ),
                          actions: <Widget>[
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: _primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: Get.back,
                              child: Text(
                                'Mengerti',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
          ),
      ],
    );
  }
}

class _QuizActionCard extends StatelessWidget {
  const _QuizActionCard({
    required this.unlocked,
    required this.passed,
    required this.score,
    required this.passingScore,
    required this.onTap,
  });

  final bool unlocked;
  final bool passed;
  final int score;
  final int passingScore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color cardBorderColor =
        passed
            ? const Color(0xFFA7F3D0)
            : unlocked
            ? _primary.withValues(alpha: 0.3)
            : _border;

    final Color iconBgColor =
        passed
            ? const Color(0xFFDCFCE7)
            : unlocked
            ? const Color(0xFFDBEAFE)
            : const Color(0xFFF1F5F9);

    final Color iconColor =
        passed
            ? _success
            : unlocked
            ? _primary
            : _muted;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cardBorderColor,
          width: unlocked || passed ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color:
                passed
                    ? _success.withValues(alpha: 0.04)
                    : unlocked
                    ? _primary.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      passed
                          ? Icons.check_circle_rounded
                          : unlocked
                          ? Icons.quiz_rounded
                          : Icons.lock_outline_rounded,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Text(
                              'Kuis Evaluasi Modul',
                              style: GoogleFonts.poppins(
                                color: _text,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            if (passed) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'LULUS',
                                  style: GoogleFonts.poppins(
                                    color: _success,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          passed
                              ? 'Lulus dengan nilai $score (Dapat diulang)'
                              : unlocked
                              ? 'Terbuka • Target Kelulusan Min. $passingScore'
                              : 'Selesaikan seluruh submateri di atas',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color:
                                passed
                                    ? _success
                                    : unlocked
                                    ? _primary
                                    : _muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (unlocked || passed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            passed
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              passed
                                  ? const Color(0xFFA7F3D0)
                                  : _primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            passed ? 'Ulangi' : 'Mulai',
                            style: GoogleFonts.plusJakartaSans(
                              color: passed ? _success : _primary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: passed ? _success : _primary,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: _muted,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabActionCard extends StatelessWidget {
  const _LabActionCard({
    required this.unlocked,
    required this.completed,
    required this.passingScore,
    required this.onTap,
  });

  final bool unlocked;
  final bool completed;
  final int passingScore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const Color labColor = Color(0xFF0D9488);

    final Color cardBorderColor =
        completed
            ? const Color(0xFFA7F3D0)
            : unlocked
            ? labColor.withValues(alpha: 0.3)
            : _border;

    final Color iconBgColor =
        completed
            ? const Color(0xFFDCFCE7)
            : unlocked
            ? const Color(0xFFCCFBF1)
            : const Color(0xFFF1F5F9);

    final Color iconColor =
        completed
            ? _success
            : unlocked
            ? labColor
            : _muted;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cardBorderColor,
          width: unlocked || completed ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color:
                completed
                    ? _success.withValues(alpha: 0.04)
                    : unlocked
                    ? labColor.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : unlocked
                          ? Icons.view_in_ar_rounded
                          : Icons.lock_outline_rounded,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Text(
                              'Laboratorium Virtual 3D',
                              style: GoogleFonts.poppins(
                                color: _text,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            if (completed) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'TUNTAS',
                                  style: GoogleFonts.poppins(
                                    color: _success,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          completed
                              ? 'Praktikum Selesai • Dapat diulang'
                              : unlocked
                              ? 'Siap Praktikum Eksperimen Interaktif'
                              : 'Buka setelah lulus kuis min. $passingScore',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color:
                                completed
                                    ? _success
                                    : unlocked
                                    ? labColor
                                    : _muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (unlocked || completed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            completed
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              completed
                                  ? const Color(0xFFA7F3D0)
                                  : labColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            completed ? 'Ulangi' : 'Masuk',
                            style: GoogleFonts.plusJakartaSans(
                              color: completed ? _success : labColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: completed ? _success : labColor,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: _muted,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InactiveActionCard extends StatelessWidget {
  const _InactiveActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(icon, color: _muted, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: _muted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    color: _muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
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

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: _primary),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ModuleImage extends StatelessWidget {
  const _ModuleImage({
    required this.imageUrl,
    required this.unlocked,
    this.size = 64,
  });

  final String? imageUrl;
  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolved = ApiService.resolveMediaUrl(imageUrl);

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? _primary.withValues(alpha: 0.15) : _border,
        ),
      ),
      child:
          resolved == null
              ? Icon(
                unlocked ? Icons.science_outlined : Icons.lock_rounded,
                color: unlocked ? _primary : _muted,
                size: size * 0.44,
              )
              : Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.science_outlined,
                    color: _primary,
                    size: size * 0.44,
                  );
                },
              ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.broken_image_outlined, color: _muted, size: 36),
          const SizedBox(height: 8),
          Text(
            'Gambar tidak dapat dimuat',
            style: GoogleFonts.plusJakartaSans(color: _muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_outlined, size: 32, color: _muted),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: _muted,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
