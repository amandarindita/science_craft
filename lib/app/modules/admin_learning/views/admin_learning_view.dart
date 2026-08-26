import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../widgets/logout_confirmation_dialog.dart';
import '../../../widgets/science_shimmer.dart';

import '../controllers/admin_learning_controller.dart';
import 'admin_content_import_view.dart';
import 'admin_funfact_view.dart';
import 'admin_module_content_view.dart';
import 'admin_module_form_view.dart';

const Color _primary = Color(0xFF2563EB);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _background = Color(0xFFF5F8FF);
const Color _success = Color(0xFF16A34A);

class AdminLearningView
    extends GetView<AdminLearningController> {
  const AdminLearningView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title:
            const Text('Panel Guru'),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            tooltip: 'Import 2 CSV',
            onPressed: () async {
              await Get.to<void>(
                () =>
                    const AdminContentImportView(),
              );
            },
            icon: const Icon(
              Icons.upload_file_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed:
                controller.loadModules,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Keluar',
            onPressed: () =>
                showLogoutConfirmation(
              onConfirm: () =>
                  Get.offAllNamed(
                Routes.LOGIN,
              ),
            ),
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {
          await Get.to<bool>(
            () =>
                const AdminModuleFormView(),
          );
        },
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Buat Modul',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadModules,
        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: _AdminHeader(
                controller: controller,
              ),
            ),
            SliverToBoxAdapter(
              child: _ImportContentCard(),
            ),
            const SliverToBoxAdapter(
              child: _FunFactContentCard(),
            ),
            SliverToBoxAdapter(
              child: _Filters(
                controller: controller,
              ),
            ),
            Obx(() {
              if (controller.isLoading.value &&
                  controller.modules.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: true,
                  child: AdminModuleListShimmer(),
                );
              }

              if (controller.modules.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyModules(),
                );
              }

              return SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  2,
                  16,
                  110,
                ),
                sliver: SliverList.separated(
                  itemCount:
                      controller.modules.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final module =
                        controller.modules[index];

                    return _ModuleCard(
                      module: module,
                      onManage: () async {
                        await Get.to<void>(
                          () =>
                              AdminModuleContentView(
                            module: module,
                          ),
                        );
                      },
                      onEdit: () async {
                        await Get.to<bool>(
                          () =>
                              AdminModuleFormView(
                            module: module,
                          ),
                        );
                      },
                      onDelete: () =>
                          controller.deleteModule(
                        module,
                      ),
                    );
                  },
                  separatorBuilder:
                      (context, index) =>
                          const SizedBox(
                    height: 12,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({
    required this.controller,
  });

  final AdminLearningController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        13,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF172554),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.17,
              ),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Panel Konten Guru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Kelola modul, submateri, checkpoint, kuis, media, Fun Fact, dan laboratorium dalam satu tempat.',
                  style: TextStyle(
                    color: Color(0xFFDCE9FF),
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
}


class _ImportContentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        14,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(
                0xFFEAF1FF,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.table_view_rounded,
              color: _primary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Import 2 CSV',
                  style: TextStyle(
                    color: _text,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Masukkan struktur pembelajaran dan kuis melalui dua CSV terpisah.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () async {
              await Get.to<void>(
                () =>
                    const AdminContentImportView(),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}


class _FunFactContentCard
    extends StatelessWidget {
  const _FunFactContentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        14,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(
                0xFFFFF4D8,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Fun Fact',
                  style: TextStyle(
                    color: _text,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Lihat data lama, tambah, edit, cari, atau hapus fakta sains.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _openFunFacts,
            style: FilledButton.styleFrom(
              backgroundColor:
                  const Color(0xFFF59E0B),
              foregroundColor:
                  Colors.white,
            ),
            child: const Text('Kelola'),
          ),
        ],
      ),
    );
  }

  static Future<void> _openFunFacts()
      async {
    await Get.to<void>(
      () => const AdminFunFactView(),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.controller,
  });

  final AdminLearningController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        15,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Filter level',
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <int>[
                0,
                1,
                2,
                3,
              ].map((level) {
                final bool selected =
                    controller
                            .selectedLevel
                            .value ==
                        level;

                return ChoiceChip(
                  label: Text(
                    level == 0
                        ? 'Semua'
                        : 'Level $level',
                  ),
                  selected: selected,
                  onSelected: (_) =>
                      controller.changeLevel(
                    level,
                  ),
                  selectedColor:
                      const Color(0xFFEAF1FF),
                  side: BorderSide(
                    color: selected
                        ? _primary
                        : const Color(
                            0xFFE2E8F0,
                          ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Mata pelajaran',
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  controller.categories.map(
                (category) {
                  final bool selected =
                      controller
                              .selectedCategory
                              .value ==
                          category;

                  return FilterChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (_) =>
                        controller
                            .changeCategory(
                      category,
                    ),
                    selectedColor:
                        const Color(
                      0xFFEAF1FF,
                    ),
                    side: BorderSide(
                      color: selected
                          ? _primary
                          : const Color(
                              0xFFE2E8F0,
                            ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.onManage,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> module;
  final VoidCallback onManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool published =
        AdminLearningController.boolValue(
      module['is_published'],
    );

    final bool required =
        AdminLearningController.boolValue(
      module['is_required'],
    );

    final int level =
        AdminLearningController.intValue(
      module['level'],
      fallback: 1,
    );

    final int order =
        AdminLearningController.intValue(
      module['module_order'],
    );

    final int submaterialCount =
        AdminLearningController.intValue(
      module['submaterial_count'],
    );

    final String scene =
        module['unity_scene_id']
                ?.toString()
                .trim() ??
            '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFEAF1FF,
                  ),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    '$order',
                    style: const TextStyle(
                      color: _primary,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      module['title']
                              ?.toString() ??
                          'Tanpa Judul',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      module[
                                  'short_description']
                              ?.toString()
                              .trim()
                              .isNotEmpty ==
                          true
                          ? module[
                                  'short_description']
                              .toString()
                          : 'Intro belum diisi.',
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (
                      value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) =>
                    const <
                        PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(
                        Icons.edit_rounded,
                      ),
                      title: Text('Edit'),
                      contentPadding:
                          EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_rounded,
                        color: Color(
                          0xFFDC2626,
                        ),
                      ),
                      title: Text(
                        'Hapus',
                        style: TextStyle(
                          color: Color(
                            0xFFDC2626,
                          ),
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              _InfoPill(
                icon: Icons.layers_rounded,
                text: 'Level $level',
              ),
              _InfoPill(
                icon:
                    Icons.category_rounded,
                text: module['category']
                        ?.toString() ??
                    '-',
              ),
              _InfoPill(
                icon:
                    Icons.menu_book_rounded,
                text:
                    '$submaterialCount submateri',
              ),
              if (scene.isNotEmpty)
                _InfoPill(
                  icon:
                      Icons.science_rounded,
                  text: scene,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _StatusBadge(
                text: published
                    ? 'Dipublikasikan'
                    : 'Draft',
                active: published,
              ),
              _StatusBadge(
                text: required
                    ? 'Wajib'
                    : 'Opsional',
                active: required,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Edit Modul',
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onManage,
                  icon: const Icon(
                    Icons.library_books_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Kelola Isi',
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 14,
            color: _muted,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.text,
    required this.active,
  });

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFE7F8EE)
            : const Color(0xFFF1F5F9),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            active
                ? Icons
                    .check_circle_rounded
                : Icons
                    .radio_button_unchecked,
            size: 14,
            color:
                active ? _success : _muted,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color:
                  active ? _success : _muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyModules extends StatelessWidget {
  const _EmptyModules();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons
                  .menu_book_outlined,
              size: 62,
              color: _muted,
            ),
            const SizedBox(height: 13),
            const Text(
              'Belum ada modul',
              style: TextStyle(
                color: _text,
                fontSize: 19,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Buat modul pertama atau ubah filter yang sedang dipakai.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
