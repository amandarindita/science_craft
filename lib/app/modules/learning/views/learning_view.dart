import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import '../../../data/api_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/science_shimmer.dart';
import '../controllers/learning_controller.dart';
import 'checkpoint_view.dart';
import 'quiz_view.dart';
import 'progress_view.dart';

const Color _primary = Color(0xFF2563EB);
const Color _primaryDark = Color(0xFF1E3A8A);
const Color _background = Color(0xFFF5F8FF);
const Color _success = Color(0xFF16A34A);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);

class LearningView extends GetView<LearningController> {
  const LearningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Jalur Belajar'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _text,
        actions: <Widget>[
          IconButton(
            tooltip: 'Progress saya',
            onPressed: () async {
              await controller.loadOverview(
                silent: true,
              );

              await Get.to<void>(
                () => const LearningProgressView(),
              );
            },
            icon: const Icon(
              Icons.insights_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: controller.initialize,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.initialize,
        child: Obx(
          () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              32,
            ),
            children: <Widget>[
              const _LearningHeader(),
              const SizedBox(height: 18),
              _LearningFilters(
                controller: controller,
              ),
              const SizedBox(height: 18),
              _LevelSelector(controller: controller),
              const SizedBox(height: 22),
              _SectionTitle(
                title: controller.activeFilterTitle,
                subtitle:
                    'Cari dan pilih materi sesuai mata pelajaran.',
              ),
              const SizedBox(height: 12),
              if (controller.isLoadingModules.value)
                const LearningModuleListShimmer()
              else if (controller.modules.isEmpty)
                _EmptyCard(
                  message: controller.errorMessage.value.isEmpty
                      ? 'Belum ada modul pada filter ini.'
                      : controller.errorMessage.value,
                )
              else if (controller.filteredModules.isEmpty)
                _EmptyCard(
                  message:
                      'Materi tidak ditemukan. Coba kata kunci atau filter lain.',
                )
              else
                ...controller.filteredModules.map(
                  (module) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: _ModuleCard(
                      module: module,
                      controller: controller,
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

class _LearningHeader extends StatelessWidget {
  const _LearningHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            _primaryDark,
            _primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _primary.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Belajar secara bertahap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selesaikan materi, checkpoint, kuis, dan laboratorium untuk membuka level berikutnya.',
                  style: TextStyle(
                    color: Color(0xFFDCE9FF),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14),
          Icon(
            Icons.science_rounded,
            size: 64,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}


class _LearningFilters extends StatelessWidget {
  const _LearningFilters({
    required this.controller,
  });

  final LearningController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller:
              controller.searchTextController,
          onChanged:
              controller.updateSearchQuery,
          textInputAction:
              TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari materi...',
            prefixIcon: const Icon(
              Icons.search_rounded,
            ),
            suffixIcon:
                controller.searchQuery.value.isEmpty
                    ? null
                    : IconButton(
                        tooltip:
                            'Hapus pencarian',
                        onPressed:
                            controller.clearSearch,
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: _primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Mata Pelajaran',
          style: TextStyle(
            color: _text,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                LearningController.categoryOptions
                    .map((category) {
              final bool selected =
                  controller
                          .selectedCategory
                          .value ==
                      category;

              return Padding(
                padding:
                    const EdgeInsets.only(
                  right: 9,
                ),
                child: ChoiceChip(
                  selected: selected,
                  onSelected: (_) {
                    controller.selectCategory(
                      category,
                    );
                  },
                  avatar: Icon(
                    _categoryIcon(category),
                    size: 18,
                    color: selected
                        ? Colors.white
                        : _categoryColor(
                            category,
                          ),
                  ),
                  label: Text(category),
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : _text,
                    fontWeight:
                        FontWeight.w700,
                  ),
                  selectedColor:
                      _categoryColor(category),
                  backgroundColor:
                      Colors.white,
                  side: BorderSide(
                    color: selected
                        ? _categoryColor(
                            category,
                          )
                        : const Color(
                            0xFFE2E8F0,
                          ),
                  ),
                  showCheckmark: false,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  static IconData _categoryIcon(
    String category,
  ) {
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

  static Color _categoryColor(
    String category,
  ) {
    switch (category) {
      case 'Biologi':
        return const Color(0xFF16A34A);
      case 'Fisika':
        return const Color(0xFFF59E0B);
      case 'Kimia':
        return const Color(0xFF7C3AED);
      default:
        return _primary;
    }
  }
}

class _LevelSelector extends StatelessWidget {
  const _LevelSelector({
    required this.controller,
  });

  final LearningController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingLevels.value &&
        controller.levels.isEmpty) {
      return const LearningLevelSelectorShimmer();
    }

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.levels.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = controller.levels[index];
          final level = LearningController.intValue(
            item['level'],
            fallback: index + 1,
          );
          final unlocked =
              LearningController.boolValue(
            item['is_unlocked'],
          );
          final selected =
              controller.selectedLevel.value == level;
          final progress =
              LearningController.doubleValue(
            item['progress'],
          ).clamp(0.0, 1.0);
          final moduleCount =
              LearningController.intValue(
            item['module_count'],
          );

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => controller.selectLevel(level),
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 220),
              width: 154,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected
                    ? _primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? _primary
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: selected ? 0.12 : 0.04,
                    ),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        unlocked
                            ? Icons.lock_open_rounded
                            : Icons.lock_rounded,
                        size: 18,
                        color: selected
                            ? Colors.white
                            : unlocked
                                ? _success
                                : _muted,
                      ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : _muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'LEVEL $level',
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : _text,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$moduleCount modul',
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFFDCE9FF)
                          : _muted,
                    ),
                  ),
                  const SizedBox(height: 9),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    borderRadius:
                        BorderRadius.circular(20),
                    backgroundColor: selected
                        ? Colors.white.withValues(
                            alpha: 0.25,
                          )
                        : const Color(0xFFE2E8F0),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(
                      selected
                          ? Colors.white
                          : _primary,
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

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.controller,
  });

  final Map<String, dynamic> module;
  final LearningController controller;

  @override
  Widget build(BuildContext context) {
    final int materialId =
        LearningController.intValue(module['id']);
    final bool unlocked =
        LearningController.boolValue(
      module['is_unlocked'],
    );
    final bool legacy =
        LearningController.boolValue(
      module['legacy_mode'],
    );
    final double progress =
        LearningController.doubleValue(
      module['progress'],
    ).clamp(0.0, 1.0);
    final int completed =
        LearningController.intValue(
      module['completed_submaterials'],
    );
    final int total =
        LearningController.intValue(
      module['total_submaterials'],
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: unlocked
            ? () async {
                final opened =
                    await controller.loadModuleDetail(
                  materialId,
                );

                if (opened) {
                  await Get.to<void>(
                    () =>
                        const LearningModuleDetailView(),
                  );
                }
              }
            : () => controller.showError(
                  'Modul ini masih terkunci.',
                ),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              _ModuleImage(
                imageUrl: module['image_url']?.toString(),
                unlocked: unlocked,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            module['title']
                                    ?.toString() ??
                                'Modul',
                            style: const TextStyle(
                              color: _text,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(
                          unlocked
                              ? Icons.chevron_right_rounded
                              : Icons.lock_rounded,
                          color: unlocked
                              ? _primary
                              : _muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      module['short_description']
                                  ?.toString()
                                  .trim()
                                  .isNotEmpty ==
                              true
                          ? module['short_description']
                              .toString()
                          : legacy
                              ? 'Materi lama, belum disusun menjadi submateri.'
                              : '$completed dari $total submateri selesai.',
                      style: const TextStyle(
                        color: _muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                            backgroundColor:
                                const Color(
                              0xFFE2E8F0,
                            ),
                            valueColor:
                                const AlwaysStoppedAnimation<
                                    Color>(
                              _primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            color: _primaryDark,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
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

class LearningModuleDetailView
    extends StatefulWidget {
  const LearningModuleDetailView({
    super.key,
  });

  @override
  State<LearningModuleDetailView>
      createState() =>
          _LearningModuleDetailViewState();
}

class _LearningModuleDetailViewState
    extends State<LearningModuleDetailView> {
  late final LearningController
      controller;

  int? _expandedSubmaterialId;

  @override
  void initState() {
    super.initState();
    controller =
        Get.find<LearningController>();
  }

  void _toggleSubmaterial(
    int submaterialId,
  ) {
    setState(() {
      _expandedSubmaterialId =
          _expandedSubmaterialId ==
                  submaterialId
              ? null
              : submaterialId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Detail Modul'),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller
                .isLoadingModuleDetail
                .value &&
            controller.selectedModule
                    .value ==
                null) {
          return const LearningModuleDetailShimmer();
        }

        final Map<String, dynamic>?
            module =
            controller.selectedModule.value;

        if (module == null) {
          return const Center(
            child: Text(
              'Modul tidak ditemukan.',
            ),
          );
        }

        final List<Map<String, dynamic>>
            submaterials =
            LearningController.mapList(
          module['submaterials'],
        );
        final double progress =
            LearningController.doubleValue(
          module['progress'],
        ).clamp(0.0, 1.0);
        final bool legacy =
            LearningController.boolValue(
          module['legacy_mode'],
        );

        return RefreshIndicator(
          onRefresh:
              controller.refreshSelectedModule,
          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              36,
            ),
            children: <Widget>[
              _ModuleDetailHeader(
                module: module,
                progress: progress,
              ),
              const SizedBox(height: 22),
              const _SectionTitle(
                title: 'Submateri',
                subtitle:
                    'Tekan judul untuk membuka detail. Hanya satu submateri terbuka dalam satu waktu.',
              ),
              const SizedBox(height: 12),
              if (legacy ||
                  submaterials.isEmpty)
                const _EmptyCard(
                  message:
                      'Modul ini masih menggunakan format materi lama. Submateri Baca, Dengarkan, dan Visual akan muncul setelah data disusun ulang.',
                )
              else
                ...submaterials.map(
                  (
                    Map<String, dynamic>
                        submaterial,
                  ) {
                    final int id =
                        LearningController
                            .intValue(
                      submaterial['id'],
                    );

                    return Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 10,
                      ),
                      child:
                          _SubmaterialCard(
                        submaterial:
                            submaterial,
                        controller:
                            controller,
                        expanded:
                            _expandedSubmaterialId ==
                                id,
                        onToggle: () =>
                            _toggleSubmaterial(
                          id,
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 10),
              _RequirementSummary(
                module: module,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ModuleDetailHeader extends StatelessWidget {
  const _ModuleDetailHeader({
    required this.module,
    required this.progress,
  });

  final Map<String, dynamic> module;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              _ModuleImage(
                imageUrl:
                    module['image_url']?.toString(),
                unlocked: true,
                size: 74,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      module['title']?.toString() ??
                          'Modul',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Level ${module['level']} • ${module['category'] ?? 'Sains'}',
                      style: const TextStyle(
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            module['short_description']
                        ?.toString()
                        .trim()
                        .isNotEmpty ==
                    true
                ? module['short_description']
                    .toString()
                : 'Selesaikan aktivitas belajar secara berurutan.',
            style: const TextStyle(
              color: _muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  borderRadius:
                      BorderRadius.circular(20),
                  backgroundColor:
                      const Color(0xFFE2E8F0),
                  valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                    _success,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubmaterialCard
    extends StatelessWidget {
  const _SubmaterialCard({
    required this.submaterial,
    required this.controller,
    required this.expanded,
    required this.onToggle,
  });

  final Map<String, dynamic>
      submaterial;
  final LearningController controller;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> progress =
        LearningController.mapValue(
      submaterial['progress'],
    );
    final bool completed =
        LearningController.boolValue(
      progress['is_completed'],
    );
    final bool modeCompleted =
        LearningController.boolValue(
      progress['mode_completed'],
    );
    final List<Map<String, dynamic>>
        checkpoints =
        LearningController.mapList(
      submaterial['checkpoints'],
    );
    final int checkpointCount =
        checkpoints.length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(19),
        border: Border.all(
          color: expanded
              ? _primary
              : completed
                  ? _success.withValues(
                      alpha: 0.45,
                    )
                  : const Color(
                      0xFFE2E8F0,
                    ),
          width: expanded ? 1.8 : 1,
        ),
        boxShadow: expanded
            ? const <BoxShadow>[
                BoxShadow(
                  color:
                      Color(0x142563EB),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        children: <Widget>[
          Material(
            color: expanded
                ? const Color(
                    0xFFF4F8FF,
                  )
                : Colors.white,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration:
                          BoxDecoration(
                        color: completed
                            ? const Color(
                                0xFFE7F8EE,
                              )
                            : const Color(
                                0xFFEAF1FF,
                              ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Icon(
                        completed
                            ? Icons
                                .check_rounded
                            : Icons
                                .menu_book_rounded,
                        color: completed
                            ? _success
                            : _primary,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Text(
                        submaterial['title']
                                ?.toString() ??
                            'Submateri',
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color: _text,
                          fontSize: 15,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    AnimatedRotation(
                      turns:
                          expanded ? 0.5 : 0,
                      duration:
                          const Duration(
                        milliseconds: 220,
                      ),
                      child: const Icon(
                        Icons
                            .keyboard_arrow_down_rounded,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration:
                const Duration(
              milliseconds: 260,
            ),
            curve: Curves.easeOut,
            child: expanded
                ? Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      16,
                      2,
                      16,
                      17,
                    ),
                    decoration:
                        const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Color(
                            0xFFE2E8F0,
                          ),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: <Widget>[
                        const SizedBox(
                          height: 13,
                        ),
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets
                                  .all(
                            11,
                          ),
                          decoration:
                              BoxDecoration(
                            color: completed
                                ? const Color(
                                    0xFFE7F8EE,
                                  )
                                : modeCompleted
                                    ? const Color(
                                        0xFFFFF7E6,
                                      )
                                    : const Color(
                                        0xFFEAF1FF,
                                      ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              13,
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                completed
                                    ? Icons
                                        .check_circle_rounded
                                    : modeCompleted
                                        ? Icons
                                            .task_alt_rounded
                                        : Icons
                                            .info_rounded,
                                color: completed
                                    ? _success
                                    : modeCompleted
                                        ? const Color(
                                            0xFFF59E0B,
                                          )
                                        : _primary,
                                size: 19,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Text(
                                  completed
                                      ? 'Submateri selesai'
                                      : modeCompleted
                                          ? 'Mode selesai, lanjutkan checkpoint'
                                          : '$checkpointCount checkpoint tersedia',
                                  style:
                                      TextStyle(
                                    color: completed
                                        ? const Color(
                                            0xFF166534,
                                          )
                                        : modeCompleted
                                            ? const Color(
                                                0xFF9A3412,
                                              )
                                            : _primaryDark,
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (
                          submaterial['summary']
                                  ?.toString()
                                  .trim()
                                  .isNotEmpty ==
                              true
                        ) ...<Widget>[
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            submaterial[
                                    'summary']
                                .toString(),
                            style:
                                const TextStyle(
                              color: _muted,
                              height: 1.4,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          'Pilih Mode Belajar',
                          style: TextStyle(
                            color: _text,
                            fontSize: 12,
                            fontWeight:
                                FontWeight
                                    .w900,
                          ),
                        ),
                        const SizedBox(
                          height: 9,
                        ),
                        Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: <Widget>[
                            _ModeButton(
                              label: 'Baca',
                              icon: Icons
                                  .article_rounded,
                              enabled: controller
                                  .isModeAvailable(
                                submaterial,
                                'read',
                              ),
                              onTap: () =>
                                  _openMode(
                                controller,
                                submaterial,
                                'read',
                              ),
                            ),
                            _ModeButton(
                              label:
                                  'Dengarkan',
                              icon: Icons
                                  .headphones_rounded,
                              enabled: controller
                                  .isModeAvailable(
                                submaterial,
                                'listen',
                              ),
                              onTap: () =>
                                  _openMode(
                                controller,
                                submaterial,
                                'listen',
                              ),
                            ),
                            _ModeButton(
                              label: 'Visual',
                              icon: Icons
                                  .auto_awesome_rounded,
                              enabled: controller
                                  .isModeAvailable(
                                submaterial,
                                'visual',
                              ),
                              onTap: () =>
                                  _openMode(
                                controller,
                                submaterial,
                                'visual',
                              ),
                            ),
                          ],
                        ),
                        if (checkpoints
                            .isNotEmpty) ...<Widget>[
                          const SizedBox(
                            height: 17,
                          ),
                          const Divider(
                            height: 1,
                            color: Color(
                              0xFFE2E8F0,
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: <Widget>[
                              const Icon(
                                Icons
                                    .task_alt_rounded,
                                size: 19,
                                color:
                                    _primaryDark,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const Text(
                                'Checkpoint',
                                style:
                                    TextStyle(
                                  color: _text,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$checkpointCount aktivitas',
                                style:
                                    const TextStyle(
                                  color: _muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ...checkpoints.map(
                            (
                              Map<String,
                                      dynamic>
                                  checkpoint,
                            ) =>
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom: 9,
                              ),
                              child:
                                  _CheckpointTile(
                                checkpoint:
                                    checkpoint,
                                modeCompleted:
                                    modeCompleted,
                                controller:
                                    controller,
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
    );
  }

  Future<void> _openMode(
    LearningController controller,
    Map<String, dynamic> submaterial,
    String mode,
  ) async {
    final int submaterialId =
        LearningController.intValue(
      submaterial['id'],
    );

    final bool opened =
        await controller.openMode(
      submaterialId: submaterialId,
      mode: mode,
    );

    if (opened) {
      await Get.to<void>(
        () => LearningModeView(
          submaterialId:
              submaterialId,
          mode: mode,
        ),
      );
    }
  }
}


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
    final bool completed =
        LearningController.boolValue(
      checkpoint['is_completed'],
    );
    final String type =
        checkpoint['checkpoint_type']
            ?.toString() ??
        '';
    final bool canOpen =
        modeCompleted || completed;

    return Material(
      color: completed
          ? const Color(0xFFE7F8EE)
          : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          if (!canOpen) {
            controller.showError(
              'Selesaikan salah satu mode belajar terlebih dahulu.',
            );
            return;
          }

          Get.to<void>(
            () => CheckpointExerciseView(
              checkpoint: checkpoint,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: completed
                  ? const Color(0xFF86EFAC)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: completed
                      ? Colors.white
                      : const Color(0xFFEAF1FF),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  completed
                      ? Icons.check_rounded
                      : _checkpointIconForTile(type),
                  color: completed
                      ? _success
                      : _primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      checkpoint['title']
                              ?.toString() ??
                          _checkpointLabelForTile(
                            type,
                          ),
                      style: const TextStyle(
                        color: _text,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      completed
                          ? 'Selesai'
                          : canOpen
                              ? _checkpointLabelForTile(
                                  type,
                                )
                              : 'Terkunci sampai mode belajar selesai',
                      style: TextStyle(
                        color: completed
                            ? _success
                            : _muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                canOpen
                    ? Icons.chevron_right_rounded
                    : Icons.lock_rounded,
                color: canOpen
                    ? _primary
                    : _muted,
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
      return 'Pilihan';
    case 'true_false':
      return 'Benar/Salah';
    case 'matching':
      return 'Pasangkan';
    case 'ordering':
      return 'Urutkan';
    case 'image_hotspot':
      return 'Tunjuk Bagian';
    case 'data_interpretation':
      return 'Analisis Data';
    default:
      return 'Checkpoint';
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
  State<LearningModeView> createState() =>
      _LearningModeViewState();
}

class _LearningModeViewState
    extends State<LearningModeView> {
  final ScrollController _scrollController =
      ScrollController();

  LearningController get controller =>
      Get.find<LearningController>();

  bool _activityReady = false;
  bool _completedLocally = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(
      _checkScrollRequirement,
    );

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

    final ScrollPosition position =
        _scrollController.position;
    final bool reachedEnd =
        position.maxScrollExtent <= 24 ||
        position.pixels >=
            position.maxScrollExtent - 36;

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
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(_modeLabel(widget.mode)),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
      ),
      body: Obx(() {
        final Map<String, dynamic>? submaterial =
            controller.findSubmaterial(
          widget.submaterialId,
        );

        if (submaterial == null) {
          return const Center(
            child: Text(
              'Submateri tidak ditemukan.',
            ),
          );
        }

        final Map<String, dynamic> progress =
            LearningController.mapValue(
          submaterial['progress'],
        );
        final bool alreadyCompleted =
            _completedLocally ||
            LearningController.boolValue(
              progress['mode_completed'],
            );

        final bool canComplete =
            alreadyCompleted || _activityReady;

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            32,
          ),
          children: <Widget>[
            Text(
              submaterial['title']?.toString() ??
                  'Submateri',
              style: const TextStyle(
                color: _text,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              submaterial['summary']?.toString() ??
                  'Pelajari materi berikut dengan teliti.',
              style: const TextStyle(
                color: _muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            _ModeContent(
              submaterial: submaterial,
              mode: widget.mode,
              onReadyChanged: _handleContentReady,
            ),
            const SizedBox(height: 18),
            _ActivityRequirementCard(
              mode: widget.mode,
              ready: canComplete,
              completed: alreadyCompleted,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: alreadyCompleted ||
                        !_activityReady ||
                        controller
                            .isCompletingMode.value
                    ? null
                    : () async {
                        final bool completed =
                            await controller.completeMode(
                          submaterialId:
                              widget.submaterialId,
                          mode: widget.mode,
                        );

                        if (completed && mounted) {
                          setState(() {
                            _completedLocally = true;
                          });
                        }
                      },
                icon: controller
                        .isCompletingMode.value
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        alreadyCompleted
                            ? Icons
                                .verified_rounded
                            : canComplete
                                ? Icons
                                    .check_circle_rounded
                                : Icons.lock_rounded,
                      ),
                label: Text(
                  alreadyCompleted
                      ? 'Aktivitas Sudah Selesai'
                      : canComplete
                          ? 'Selesaikan Aktivitas'
                          : _lockedButtonLabel(
                              widget.mode,
                            ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: alreadyCompleted
                      ? _success
                      : _primary,
                  disabledBackgroundColor:
                      alreadyCompleted
                          ? _success
                          : const Color(
                              0xFFCBD5E1,
                            ),
                  disabledForegroundColor:
                      alreadyCompleted
                          ? Colors.white
                          : const Color(
                              0xFF64748B,
                            ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            if (alreadyCompleted) ...<Widget>[
              const SizedBox(height: 9),
              TextButton.icon(
                onPressed: () => Get.back<void>(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                ),
                label: const Text(
                  'Kembali ke Submateri',
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              'Setelah aktivitas selesai, kerjakan checkpoint untuk memastikan pemahamanmu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.35,
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

  static String _lockedButtonLabel(String mode) {
    switch (mode) {
      case 'listen':
        return 'Dengarkan Hingga 90%';
      case 'visual':
        return 'Lihat Semua Bagian';
      default:
        return 'Baca Hingga Bagian Akhir';
    }
  }
}

class _ActivityRequirementCard
    extends StatelessWidget {
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
      background = const Color(0xFFE7F8EE);
      border = const Color(0xFF86EFAC);
      foreground = const Color(0xFF166534);
      icon = Icons.verified_rounded;
      title = 'Aktivitas selesai';
      message =
          'Progres pembelajaranmu sudah tersimpan.';
    } else if (ready) {
      background = const Color(0xFFEAF1FF);
      border = const Color(0xFFBFDBFE);
      foreground = _primaryDark;
      icon = Icons.check_circle_outline_rounded;
      title = 'Aktivitas siap diselesaikan';
      message =
          'Tekan tombol di bawah untuk menyimpan progresmu.';
    } else {
      background = const Color(0xFFFFF7E6);
      border = const Color(0xFFFCD34D);
      foreground = const Color(0xFF92400E);
      icon = Icons.info_outline_rounded;
      title = 'Selesaikan aktivitas terlebih dahulu';
      message = _requirementMessage(mode);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
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

  static String _requirementMessage(String mode) {
    switch (mode) {
      case 'listen':
        return 'Putar dan dengarkan minimal 90% isi audio.';
      case 'visual':
        return 'Buka seluruh gambar atau titik penjelasan yang tersedia.';
      default:
        return 'Gulir dan baca materi sampai bagian paling akhir.';
    }
  }
}

class _ModeContent extends StatelessWidget {
  const _ModeContent({
    required this.submaterial,
    required this.mode,
    required this.onReadyChanged,
  });

  final Map<String, dynamic> submaterial;
  final String mode;
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
        return _ReadContent(
          submaterial: submaterial,
        );
    }
  }
}

class _ReadContent extends StatelessWidget {
  const _ReadContent({
    required this.submaterial,
  });

  final Map<String, dynamic> submaterial;

  @override
  Widget build(BuildContext context) {
    return _ContentCard(
      icon: Icons.article_rounded,
      title: 'Materi Bacaan',
      child: SelectableText(
        submaterial['read_content']?.toString() ??
            'Konten bacaan belum tersedia.',
        style: const TextStyle(
          color: _text,
          fontSize: 16,
          height: 1.7,
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
  State<_ListenContent> createState() =>
      _ListenContentState();
}

class _ListenContentState
    extends State<_ListenContent> {
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

  int _listenedMilliseconds = 0;
  Duration _lastTrackedPosition = Duration.zero;
  bool _readyWasReported = false;

  String? get _audioUrl => ApiService.resolveMediaUrl(
        widget.submaterial['audio_url']?.toString(),
      );

  String get _narrationText {
    final String ttsText =
        widget.submaterial['tts_text']?.toString().trim() ??
            '';

    if (ttsText.isNotEmpty) {
      return ttsText;
    }

    return widget.submaterial['read_content']
            ?.toString()
            .trim() ??
        '';
  }

  bool get _usesAudioFile => _audioUrl != null;

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
  }

  void _configureAudioPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _durationSubscription =
        _audioPlayer.onDurationChanged.listen(
      (duration) {
        if (!mounted) {
          return;
        }

        setState(() {
          _duration = duration;
        });
      },
    );

    _positionSubscription =
        _audioPlayer.onPositionChanged.listen(
      (position) {
        if (!mounted) {
          return;
        }

        final int delta = position.inMilliseconds -
            _lastTrackedPosition.inMilliseconds;

        // Perpindahan besar dianggap seek dan tidak dihitung.
        if (_playerState == PlayerState.playing &&
            delta > 0 &&
            delta <= 3000) {
          _listenedMilliseconds += delta;
        }

        _lastTrackedPosition = position;

        setState(() {
          _position = position;
        });

        _reportAudioReadiness();
      },
    );

    _stateSubscription =
        _audioPlayer.onPlayerStateChanged.listen(
      (state) {
        if (!mounted) {
          return;
        }

        setState(() {
          _playerState = state;
        });
      },
    );

    _completeSubscription =
        _audioPlayer.onPlayerComplete.listen(
      (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _position = _duration;
          _playerState = PlayerState.completed;
        });
        _reportAudioReadiness();
      },
    );
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
        _errorMessage =
            'TTS tidak dapat diputar: $message';
      });
    });
  }

  void _reportAudioReadiness({
    bool forceReady = false,
  }) {
    final bool ready;

    if (forceReady) {
      ready = true;
    } else if (_usesAudioFile) {
      final int total = _duration.inMilliseconds;
      ready = total > 0 &&
          (_listenedMilliseconds / total) >= 0.90;
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

    if (_usesAudioFile) {
      await _toggleAudioFile();
    } else {
      await _toggleTts();
    }
  }

  Future<void> _toggleAudioFile() async {
    final String? url = _audioUrl;

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
      } else if (
          _audioPrepared &&
          _playerState == PlayerState.paused
      ) {
        await _audioPlayer.resume();
        await _audioPlayer.setPlaybackRate(_speed);
      } else {
        await _audioPlayer.play(
          UrlSource(url),
        );
        _audioPrepared = true;
        await _audioPlayer.setPlaybackRate(_speed);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Audio tidak dapat diputar: $e';
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
        _errorMessage =
            'Naskah audio belum tersedia.';
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
        await _flutterTts.speak(
          text,
          focus: true,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'TTS tidak dapat diputar: $e';
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

  Future<void> _changeSpeed(
    double speed,
  ) async {
    setState(() {
      _speed = speed;
    });

    try {
      if (_usesAudioFile && _audioPrepared) {
        await _audioPlayer.setPlaybackRate(
          speed,
        );
      } else {
        await _applyTtsSpeed(speed);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Kecepatan audio tidak dapat diubah: $e';
        });
      }
    }
  }

  Future<void> _applyTtsSpeed(
    double displayedSpeed,
  ) async {
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

  Future<void> _seekTo(
    double milliseconds,
  ) async {
    if (!_usesAudioFile) {
      return;
    }

    await _audioPlayer.seek(
      Duration(
        milliseconds: milliseconds.round(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNarration =
        _narrationText.isNotEmpty;
    final bool canPlay =
        _usesAudioFile || hasNarration;

    return _ContentCard(
      icon: Icons.headphones_rounded,
      title: 'Materi Audio',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[
                  Color(0xFF1E3A8A),
                  Color(0xFF2563EB),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.18,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed:
                            canPlay && !_isBusy
                                ? _togglePlayback
                                : null,
                        icon: _isBusy
                            ? const SizedBox(
                                width: 21,
                                height: 21,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _usesAudioFile
                                ? 'Rekaman audio'
                                : 'Text-to-Speech',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _usesAudioFile
                                ? 'Audio dari materi pembelajaran'
                                : 'Narasi otomatis Bahasa Indonesia',
                            style: const TextStyle(
                              color: Color(0xFFDCE9FF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Berhenti',
                      onPressed:
                          canPlay ? _stopPlayback : null,
                      icon: const Icon(
                        Icons.stop_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (_usesAudioFile) ...<Widget>[
                  const SizedBox(height: 14),
                  SliderTheme(
                    data: SliderTheme.of(context)
                        .copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor:
                          Colors.white.withValues(
                        alpha: 0.25,
                      ),
                      thumbColor: Colors.white,
                      overlayColor:
                          Colors.white.withValues(
                        alpha: 0.12,
                      ),
                    ),
                    child: Slider(
                      min: 0,
                      max: _duration.inMilliseconds > 0
                          ? _duration.inMilliseconds
                              .toDouble()
                          : 1,
                      value: _safeSliderValue(),
                      onChanged: _duration.inMilliseconds > 0
                          ? _seekTo
                          : null,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        _formatDuration(_position),
                        style: const TextStyle(
                          color: Color(0xFFDCE9FF),
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(
                          color: Color(0xFFDCE9FF),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kecepatan',
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: <double>[
              0.75,
              1.0,
              1.25,
              1.5,
            ].map((speed) {
              final bool selected =
                  _speed == speed;

              return ChoiceChip(
                label: Text(
                  '${speed.toStringAsFixed(
                    speed == 1.0 ? 0 : 2,
                  )}x',
                ),
                selected: selected,
                onSelected: (_) =>
                    _changeSpeed(speed),
                selectedColor:
                    const Color(0xFFEAF1FF),
                side: BorderSide(
                  color: selected
                      ? _primary
                      : const Color(0xFFE2E8F0),
                ),
                labelStyle: TextStyle(
                  color:
                      selected ? _primary : _muted,
                  fontWeight: FontWeight.w800,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _AudioCompletionProgress(
            progress: _usesAudioFile &&
                    _duration.inMilliseconds > 0
                ? (_listenedMilliseconds /
                        _duration.inMilliseconds)
                    .clamp(0.0, 1.0)
                    .toDouble()
                : (_readyWasReported ? 1.0 : 0.0),
            isTts: !_usesAudioFile,
          ),
          if (_errorMessage != null) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFDBA74),
                ),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFF9A3412),
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding:
                const EdgeInsets.only(bottom: 8),
            title: const Text(
              'Lihat naskah audio',
              style: TextStyle(
                color: _text,
                fontWeight: FontWeight.w900,
              ),
            ),
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(
                  hasNarration
                      ? _narrationText
                      : 'Naskah audio belum tersedia.',
                  style: const TextStyle(
                    color: _text,
                    height: 1.65,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _safeSliderValue() {
    final double maximum =
        _duration.inMilliseconds > 0
            ? _duration.inMilliseconds.toDouble()
            : 1;

    return _position.inMilliseconds
        .toDouble()
        .clamp(0.0, maximum);
  }

  String _formatDuration(Duration duration) {
    final int minutes =
        duration.inMinutes.remainder(60);
    final int seconds =
        duration.inSeconds.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class _AudioCompletionProgress
    extends StatelessWidget {
  const _AudioCompletionProgress({
    required this.progress,
    required this.isTts,
  });

  final double progress;
  final bool isTts;

  @override
  Widget build(BuildContext context) {
    final int percent = (progress * 100).round();
    final bool ready = progress >= 0.90;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: ready
            ? const Color(0xFFE7F8EE)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ready
              ? const Color(0xFF86EFAC)
              : const Color(0xFFE2E8F0),
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
                    : Icons.hearing_rounded,
                color: ready ? _success : _primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ready
                      ? 'Syarat dengarkan terpenuhi'
                      : isTts
                          ? 'Dengarkan narasi sampai selesai'
                          : '$percent% telah didengarkan',
                  style: TextStyle(
                    color: ready ? _success : _text,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (!isTts) ...<Widget>[
            const SizedBox(height: 9),
            LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              borderRadius: BorderRadius.circular(20),
              color: ready ? _success : _primary,
              backgroundColor: const Color(0xFFE2E8F0),
            ),
          ],
        ],
      ),
    );
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
  State<_VisualContent> createState() =>
      _VisualContentState();
}

class _VisualContentState
    extends State<_VisualContent> {
  final PageController _pageController =
      PageController();

  int _currentPage = 0;
  Map<String, dynamic>? _selectedVisualHotspot;
  final Set<int> _visitedImagePages = <int>{0};
  final Set<String> _visitedHotspotIds = <String>{};
  bool _visualReadyReported = false;

  Map<String, dynamic> get _visualData =>
      LearningController.mapValue(
        widget.submaterial['visual_data'],
      );

  String get _visualType =>
      widget.submaterial['visual_type']
          ?.toString()
          .trim()
          .toLowerCase() ??
      'infographic';

  List<Map<String, dynamic>> get _visualItems {
    final dynamic raw =
        _visualData['items'] ??
        _visualData['steps'] ??
        _visualData['points'];

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
    final List<Map<String, dynamic>> result =
        <Map<String, dynamic>>[];

    final String? mainImage =
        ApiService.resolveMediaUrl(
      widget.submaterial['image_url']?.toString(),
    );

    if (mainImage != null) {
      result.add(<String, dynamic>{
        'url': mainImage,
        'caption':
            _visualData['image_caption']
                    ?.toString() ??
                '',
      });
    }

    final dynamic rawImages =
        _visualData['images'];

    if (rawImages is List) {
      for (final dynamic item in rawImages) {
        if (item is Map) {
          final Map<String, dynamic> map =
              Map<String, dynamic>.from(item);

          final String? url =
              ApiService.resolveMediaUrl(
            (map['url'] ??
                    map['image_url'] ??
                    map['path'])
                ?.toString(),
          );

          if (url != null) {
            result.add(<String, dynamic>{
              'url': url,
              'caption': (map['caption'] ??
                      map['title'] ??
                      '')
                  .toString(),
            });
          }
        } else {
          final String? url =
              ApiService.resolveMediaUrl(
            item.toString(),
          );

          if (url != null) {
            result.add(<String, dynamic>{
              'url': url,
              'caption': '',
            });
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
    final List<Map<String, dynamic>> hotspots =
        _visualHotspots;

    final bool ready;

    if (_visualType == 'hotspot' && hotspots.isNotEmpty) {
      ready = _visitedHotspotIds.length >=
          hotspots.length;
    } else if (images.length > 1) {
      ready = _visitedImagePages.length >=
          images.length;
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
    final List<Map<String, dynamic>> images =
        _images;
    final List<Map<String, dynamic>> items =
        _visualItems;

    return _ContentCard(
      icon: Icons.auto_awesome_rounded,
      title: _visualData['title']?.toString() ??
          'Visualisasi Materi',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          if (_visualData['description']
                      ?.toString()
                      .trim()
                      .isNotEmpty ==
                  true) ...<Widget>[
            Text(
              _visualData['description'].toString(),
              style: const TextStyle(
                color: _muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (images.isNotEmpty &&
              _visualType != 'hotspot')
            _buildImageSlider(images),
          if (images.isNotEmpty &&
              _visualType != 'hotspot' &&
              (items.isNotEmpty ||
                  _visualType == 'formula' ||
                  _visualType == 'chart' ||
                  _visualType ==
                      'data_interpretation'))
            const SizedBox(height: 18),
          _buildVisualBody(items),
        ],
      ),
    );
  }

  Widget _buildImageSlider(
    List<Map<String, dynamic>> images,
  ) {
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
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const _ImageError();
                      },
                    ),
                    if (image['caption']
                            .toString()
                            .trim()
                            .isNotEmpty)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding:
                              const EdgeInsets.all(12),
                          color: Colors.black
                              .withValues(alpha: 0.62),
                          child: Text(
                            image['caption']
                                .toString(),
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
            mainAxisAlignment:
                MainAxisAlignment.center,
            children:
                List<Widget>.generate(
              images.length,
              (index) => AnimatedContainer(
                duration:
                    const Duration(milliseconds: 180),
                width:
                    index == _currentPage ? 22 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                decoration: BoxDecoration(
                  color: index == _currentPage
                      ? _primary
                      : const Color(0xFFCBD5E1),
                  borderRadius:
                      BorderRadius.circular(20),
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

  Widget _buildVisualBody(
    List<Map<String, dynamic>> items,
  ) {
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
    final List<Map<String, dynamic>> hotspots =
        _visualHotspots;

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
                style: TextStyle(
                  color: _muted,
                  height: 1.4,
                ),
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
                      errorBuilder: (_, __, ___) =>
                          const _ImageError(),
                    ),
                    ...hotspots.map((hotspot) {
                      final double x =
                          _visualCoordinate(hotspot['x']);
                      final double y =
                          _visualCoordinate(hotspot['y']);
                      final bool selected =
                          _selectedVisualHotspot?['id']
                                  ?.toString() ==
                              hotspot['id']?.toString();

                      final double left =
                          (x * constraints.maxWidth - 18)
                              .clamp(
                        0.0,
                        constraints.maxWidth - 36,
                      )
                              .toDouble();
                      final double top =
                          (y * constraints.maxHeight - 18)
                              .clamp(
                        0.0,
                        constraints.maxHeight - 36,
                      )
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
                            duration:
                                const Duration(milliseconds: 160),
                            width: selected ? 42 : 36,
                            height: selected ? 42 : 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? const Color(0xFF16A34A)
                                  : _primary,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
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
              style: TextStyle(
                color: _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFBFDBFE),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.info_rounded,
                      color: _primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedVisualHotspot!['label']
                                ?.toString() ??
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
                  style: const TextStyle(
                    color: _muted,
                    height: 1.5,
                  ),
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
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  double _visualCoordinate(dynamic raw) {
    final double value =
        double.tryParse(raw?.toString() ?? '') ?? 0.5;
    return (value > 1 ? value / 100 : value)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  Widget _buildInfographic(
    List<Map<String, dynamic>> items,
  ) {
    if (items.isEmpty && _images.isEmpty) {
      return const Text(
        'Konten visual belum tersedia.',
        style: TextStyle(color: _muted),
      );
    }

    return Column(
      children: items.asMap().entries.map((entry) {
        final Map<String, dynamic> item =
            entry.value;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
              Expanded(
                child: _VisualItemText(item: item),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComparison(
    List<Map<String, dynamic>> items,
  ) {
    if (items.isEmpty) {
      return const Text(
        'Data perbandingan belum tersedia.',
        style: TextStyle(color: _muted),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide =
            constraints.maxWidth >= 620;

        final List<Widget> cards = items.map((item) {
          return Container(
            width: wide
                ? (constraints.maxWidth - 12) / 2
                : double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: _VisualItemText(item: item),
          );
        }).toList();

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards,
        );
      },
    );
  }

  Widget _buildSequence(
    List<Map<String, dynamic>> items,
  ) {
    if (items.isEmpty) {
      return const Text(
        'Urutan proses belum tersedia.',
        style: TextStyle(color: _muted),
      );
    }

    return Column(
      children: items.asMap().entries.map((entry) {
        final bool isLast =
            entry.key == items.length - 1;

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
                padding: const EdgeInsets.only(
                  bottom: 15,
                ),
                child: _VisualItemText(
                  item: entry.value,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFormula(
    List<Map<String, dynamic>> items,
  ) {
    final String formula =
        (_visualData['formula'] ??
                _visualData['value'] ??
                '')
            .toString();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        if (formula.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 24,
            ),
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
        if (formula.isNotEmpty &&
            items.isNotEmpty)
          const SizedBox(height: 14),
        _buildInfographic(items),
      ],
    );
  }

  Widget _buildDataTable() {
    final List<String> headers =
        _stringList(_visualData['headers']);
    final dynamic rawRows =
        _visualData['rows'] ??
        _visualData['data'];
    final List<dynamic> rows = rawRows is List
        ? List<dynamic>.from(rawRows)
        : <dynamic>[];

    if (rows.isEmpty) {
      return const Text(
        'Data visual belum tersedia.',
        style: TextStyle(color: _muted),
      );
    }

    final List<String> effectiveHeaders =
        _effectiveHeaders(headers, rows);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor:
            WidgetStateProperty.all(
          const Color(0xFFEAF1FF),
        ),
        columns: effectiveHeaders
            .map(
              (header) => DataColumn(
                label: Text(
                  header,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )
            .toList(),
        rows: rows.map((row) {
          if (row is Map) {
            return DataRow(
              cells: effectiveHeaders.map((header) {
                return DataCell(
                  Text(
                    row[header]?.toString() ??
                        row[header.toLowerCase()]
                            ?.toString() ??
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
                  Text(
                    index < row.length
                        ? row[index].toString()
                        : '-',
                  ),
                ),
              ),
            );
          }

          return DataRow(
            cells: effectiveHeaders
                .map(
                  (_) => DataCell(
                    Text(row.toString()),
                  ),
                )
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

    return raw
        .map((item) => item.toString())
        .toList();
  }

  List<String> _effectiveHeaders(
    List<String> headers,
    List<dynamic> rows,
  ) {
    if (headers.isNotEmpty) {
      return headers;
    }

    if (rows.isNotEmpty && rows.first is Map) {
      return (rows.first as Map)
          .keys
          .map((key) => key.toString())
          .toList();
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
  const _VisualItemText({
    required this.item,
  });

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final String title =
        (item['title'] ??
                item['label'] ??
                item['name'] ??
                '')
            .toString();

    final String description =
        (item['description'] ??
                item['content'] ??
                item['text'] ??
                item['value'] ??
                '')
            .toString();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        if (title.trim().isNotEmpty)
          Text(
            title,
            style: const TextStyle(
              color: _text,
              fontWeight: FontWeight.w900,
            ),
          ),
        if (title.trim().isNotEmpty &&
            description.trim().isNotEmpty)
          const SizedBox(height: 5),
        if (description.trim().isNotEmpty)
          Text(
            description,
            style: const TextStyle(
              color: _muted,
              height: 1.45,
            ),
          ),
      ],
    );
  }
}

class _RequirementSummary extends StatelessWidget {
  const _RequirementSummary({
    required this.module,
  });

  final Map<String, dynamic> module;

  @override
  Widget build(BuildContext context) {
    final int materialId =
        LearningController.intValue(
      module['id'],
    );
    final String moduleTitle =
        module['title']?.toString() ??
        'Modul';

    final bool quizRequired =
        LearningController.boolValue(
      module['quiz_required'],
    );
    final bool quizUnlocked =
        LearningController.boolValue(
      module['quiz_unlocked'],
    );
    final bool quizPassed =
        LearningController.boolValue(
      module['quiz_passed'],
    );
    final int quizScore =
        LearningController.intValue(
      module['quiz_score'],
    );
    final int passingScore =
        LearningController.intValue(
      module['quiz_passing_score'],
      fallback: 75,
    );

    final bool labRequired =
        LearningController.boolValue(
      module['lab_required'],
    );
    final bool labUnlocked =
        LearningController.boolValue(
      module['lab_unlocked'],
    );
    final bool labCompleted =
        LearningController.boolValue(
      module['lab_completed'],
    );

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Tahap berikutnya',
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (quizRequired)
            _QuizActionCard(
              unlocked: quizUnlocked,
              passed: quizPassed,
              score: quizScore,
              passingScore: passingScore,
              onTap: quizUnlocked
                  ? () async {
                      await Get.to<void>(
                        () => LearningQuizView(
                          materialId: materialId,
                          moduleTitle:
                              moduleTitle,
                        ),
                      );
                    }
                  : null,
            )
          else
            const _RequirementRow(
              icon: Icons.quiz_rounded,
              label: 'Kuis',
              status: 'Belum tersedia',
            ),
          const SizedBox(height: 10),
          if (!labRequired)
            const _RequirementRow(
              icon: Icons.science_rounded,
              label: 'Laboratorium',
              status: 'Tidak diperlukan',
            )
          else
            _LabActionCard(
              unlocked: labUnlocked,
              completed: labCompleted,
              onTap:
                  labUnlocked || labCompleted
                      ? () async {
                          await Get.toNamed<void>(
                            Routes.LAB,
                            arguments: <
                                String,
                                dynamic>{
                              'materialId':
                                  materialId,
                              'sceneId':
                                  module[
                                      'unity_scene_id'],
                              'sceneName':
                                  moduleTitle,
                              'learningFlow':
                                  true,
                            },
                          );

                          if (Get.isRegistered<
                              LearningController>()) {
                            final controller =
                                Get.find<
                                    LearningController>();

                            await controller
                                .refreshSelectedModule();
                            await controller
                                .loadModules(
                              controller
                                  .selectedLevel
                                  .value,
                            );
                            await controller
                                .refreshLevelsOnly();
                          }
                        }
                      : () {
                          Get.dialog<void>(
                            AlertDialog(
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),
                              title: const Text(
                                'Laboratorium belum terbuka',
                              ),
                              content: Text(
                                'Selesaikan materi dan raih nilai kuis minimal $passingScore pada modul ini terlebih dahulu.',
                                style: const TextStyle(
                                  height: 1.45,
                                ),
                              ),
                              actions: <Widget>[
                                FilledButton(
                                  onPressed: Get.back,
                                  child: const Text(
                                    'Mengerti',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
            ),
        ],
      ),
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
    final Color accent = passed
        ? _success
        : unlocked
            ? _primary
            : _muted;

    return Material(
      color: passed
          ? const Color(0xFFE7F8EE)
          : unlocked
              ? const Color(0xFFEAF1FF)
              : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: accent.withValues(
                alpha: 0.35,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  passed
                      ? Icons
                          .check_circle_rounded
                      : unlocked
                          ? Icons.quiz_rounded
                          : Icons.lock_rounded,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Kuis Modul',
                      style: TextStyle(
                        color: _text,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      passed
                          ? 'Lulus dengan nilai $score'
                          : unlocked
                              ? 'Terbuka • Nilai minimal $passingScore'
                              : 'Selesaikan semua submateri',
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                onTap != null
                    ? Icons.chevron_right_rounded
                    : Icons.lock_rounded,
                color: accent,
              ),
            ],
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
    required this.onTap,
  });

  final bool unlocked;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = completed
        ? _success
        : unlocked
            ? const Color(0xFF7C3AED)
            : _muted;

    return Material(
      color: completed
          ? const Color(0xFFE7F8EE)
          : unlocked
              ? const Color(0xFFF3E8FF)
              : const Color(0xFFF1F5F9),
      borderRadius:
          BorderRadius.circular(16),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: accent.withValues(
                alpha: 0.35,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  completed
                      ? Icons
                          .check_circle_rounded
                      : unlocked
                          ? Icons.science_rounded
                          : Icons.lock_rounded,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Laboratorium Virtual',
                      style: TextStyle(
                        color: _text,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      completed
                          ? 'Selesai • dapat diulangi'
                          : unlocked
                              ? 'Terbuka • siap praktikum'
                              : 'Selesaikan materi & lulus kuis minimal 75',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                unlocked || completed
                    ? Icons.chevron_right_rounded
                    : Icons.lock_rounded,
                color: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.icon,
    required this.label,
    required this.status,
  });

  final IconData icon;
  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 19,
          color: _primaryDark,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          status,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: _primary,
        disabledForegroundColor:
            _muted.withValues(alpha: 0.55),
        side: BorderSide(
          color: enabled
              ? _primary.withValues(alpha: 0.35)
              : const Color(0xFFE2E8F0),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
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
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
    this.size = 62,
  });

  final String? imageUrl;
  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolved =
        ApiService.resolveMediaUrl(imageUrl);

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFEAF1FF)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(17),
      ),
      child: resolved == null
          ? Icon(
              unlocked
                  ? Icons.science_rounded
                  : Icons.lock_rounded,
              color: unlocked ? _primary : _muted,
              size: size * 0.48,
            )
          : Image.network(
              resolved,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
                return Icon(
                  Icons.science_rounded,
                  color: _primary,
                  size: size * 0.48,
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
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.broken_image_outlined,
            color: _muted,
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            'Gambar tidak dapat dimuat',
            style: TextStyle(color: _muted),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: _text,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: _muted,
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 150,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.inbox_outlined,
            size: 42,
            color: _muted,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
