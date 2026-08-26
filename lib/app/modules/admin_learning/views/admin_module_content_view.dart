import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_learning_controller.dart';
import 'admin_checkpoint_manager_view.dart';
import 'admin_module_preview_view.dart';
import 'admin_quiz_manager_view.dart';
import 'admin_submaterial_form_view.dart';

const Color _primary = Color(0xFF2563EB);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _background = Color(0xFFF5F8FF);
const Color _success = Color(0xFF16A34A);

class AdminModuleContentView
    extends StatefulWidget {
  const AdminModuleContentView({
    super.key,
    required this.module,
  });

  final Map<String, dynamic> module;

  @override
  State<AdminModuleContentView>
      createState() =>
          _AdminModuleContentViewState();
}

class _AdminModuleContentViewState
    extends State<AdminModuleContentView> {
  AdminLearningController get controller =>
      Get.find<AdminLearningController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      controller.openModuleContent(
        widget.module,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final int materialId =
        AdminLearningController.intValue(
      widget.module['id'],
    );

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title:
            const Text('Kelola Submateri'),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () =>
                controller.loadSubmaterials(
              materialId,
            ),
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {
          await Get.to<bool>(
            () =>
                AdminSubmaterialFormView(
              materialId: materialId,
            ),
          );
        },
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Tambah Submateri',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            controller.loadSubmaterials(
          materialId,
        ),
        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: _ModuleHeader(
                module: widget.module,
              ),
            ),
            SliverToBoxAdapter(
              child: _ModeExplanation(),
            ),
            SliverToBoxAdapter(
              child: _ModuleActions(
                module: widget.module,
              ),
            ),
            Obx(() {
              if (controller
                      .isLoadingContent.value &&
                  controller
                      .submaterials.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                );
              }

              if (controller
                  .submaterials.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyContent(),
                );
              }

              return SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  110,
                ),
                sliver: SliverList.separated(
                  itemCount: controller
                      .submaterials.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final submaterial =
                        controller
                            .submaterials[index];

                    return _SubmaterialCard(
                      submaterial:
                          submaterial,
                      onCheckpoint: () async {
                        await Get.to<void>(
                          () =>
                              AdminCheckpointManagerView(
                            submaterial:
                                submaterial,
                          ),
                        );
                      },
                      onEdit: () async {
                        await Get.to<bool>(
                          () =>
                              AdminSubmaterialFormView(
                            materialId:
                                materialId,
                            submaterial:
                                submaterial,
                          ),
                        );
                      },
                      onDelete: () =>
                          controller
                              .deleteSubmaterial(
                        submaterial,
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

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({
    required this.module,
  });

  final Map<String, dynamic> module;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        12,
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
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              _HeaderPill(
                text:
                    'Level ${module['level'] ?? 1}',
              ),
              _HeaderPill(
                text:
                    module['category']
                            ?.toString() ??
                        '-',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            module['title']?.toString() ??
                'Modul',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            module['short_description']
                    ?.toString() ??
                '',
            style: const TextStyle(
              color: Color(0xFFDCE9FF),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.16,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ModeExplanation extends StatelessWidget {
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
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            color: _primary,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Setiap submateri dapat memiliki mode Baca, Dengarkan, dan Visual sekaligus. Siswa cukup menyelesaikan mode yang tersedia.',
              style: TextStyle(
                color: _muted,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ModuleActions extends StatelessWidget {
  const _ModuleActions({
    required this.module,
  });

  final Map<String, dynamic> module;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        14,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.to<void>(
                () => AdminQuizManagerView(
                  module: module,
                ),
              ),
              icon: const Icon(
                Icons.quiz_rounded,
              ),
              label: const Text(
                'Kelola Kuis',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => Get.to<void>(
                () => AdminModulePreviewView(
                  module: module,
                ),
              ),
              icon: const Icon(
                Icons.visibility_rounded,
              ),
              label: const Text('Preview'),
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
              ),
            ),
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
    required this.onCheckpoint,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> submaterial;
  final VoidCallback onCheckpoint;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final String readContent =
        submaterial['read_content']
                ?.toString()
                .trim() ??
            '';

    final String ttsText =
        submaterial['tts_text']
                ?.toString()
                .trim() ??
            '';

    final String audioUrl =
        submaterial['audio_url']
                ?.toString()
                .trim() ??
            '';

    final String imageUrl =
        submaterial['image_url']
                ?.toString()
                .trim() ??
            '';

    final Map<String, dynamic>
        visualData =
        AdminLearningController.mapValue(
      submaterial['visual_data'],
    );

    final bool hasRead =
        readContent.isNotEmpty;

    final bool hasListen =
        ttsText.isNotEmpty ||
            audioUrl.isNotEmpty;

    final bool hasVisual =
        imageUrl.isNotEmpty ||
            visualData.isNotEmpty;

    final bool published =
        AdminLearningController.boolValue(
      submaterial['is_published'],
    );

    final bool required =
        AdminLearningController.boolValue(
      submaterial['is_required'],
    );

    final int checkpointCount =
        AdminLearningController.mapList(
      submaterial['checkpoints'],
    ).length;

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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFEAF1FF,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '${submaterial['order_index'] ?? 1}',
                    style: const TextStyle(
                      color: _primary,
                      fontSize: 17,
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
                      submaterial['title']
                              ?.toString() ??
                          'Submateri',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    if (submaterial['summary']
                            ?.toString()
                            .trim()
                            .isNotEmpty ==
                        true) ...<Widget>[
                      const SizedBox(height: 5),
                      Text(
                        submaterial['summary']
                            .toString(),
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          height: 1.4,
                        ),
                      ),
                    ],
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
                      contentPadding:
                          EdgeInsets.zero,
                      leading: Icon(
                        Icons.edit_rounded,
                      ),
                      title:
                          Text('Edit'),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.zero,
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
              _ModeBadge(
                icon: Icons.menu_book_rounded,
                label: 'Baca',
                active: hasRead,
              ),
              _ModeBadge(
                icon: Icons.headphones_rounded,
                label: 'Dengarkan',
                active: hasListen,
              ),
              _ModeBadge(
                icon:
                    Icons.auto_awesome_rounded,
                label: 'Visual',
                active: hasVisual,
              ),
              _ModeBadge(
                icon: Icons.task_alt_rounded,
                label:
                    '$checkpointCount checkpoint',
                active:
                    checkpointCount > 0,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _StatusPill(
                text: published
                    ? 'Publik'
                    : 'Draft',
                active: published,
              ),
              const SizedBox(width: 7),
              _StatusPill(
                text: required
                    ? 'Wajib'
                    : 'Opsional',
                active: required,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 4,
              children: <Widget>[
                TextButton.icon(
                  onPressed: onCheckpoint,
                  icon: const Icon(
                    Icons.task_alt_rounded,
                  ),
                  label: const Text(
                    'Checkpoint',
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_note_rounded,
                  ),
                  label: const Text(
                    'Edit Isi',
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

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
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
            ? const Color(0xFFEAF1FF)
            : const Color(0xFFF1F5F9),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 14,
            color:
                active ? _primary : _muted,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color:
                  active ? _primary : _muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
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
  });

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFE7F8EE)
            : const Color(0xFFF1F5F9),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              active ? _success : _muted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

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
              Icons.library_add_outlined,
              size: 62,
              color: _muted,
            ),
            const SizedBox(height: 13),
            const Text(
              'Belum ada submateri',
              style: TextStyle(
                color: _text,
                fontSize: 19,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Tambahkan bagian pembelajaran pertama untuk modul ini.',
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
