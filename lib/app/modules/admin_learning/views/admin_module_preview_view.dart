import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_learning_controller.dart';

const Color _primary = Color(0xFF2563EB);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _background = Color(0xFFF5F8FF);
const Color _success = Color(0xFF16A34A);
const Color _warning = Color(0xFFD97706);

class AdminModulePreviewView
    extends StatefulWidget {
  const AdminModulePreviewView({
    super.key,
    required this.module,
  });

  final Map<String, dynamic> module;

  @override
  State<AdminModulePreviewView> createState() =>
      _AdminModulePreviewViewState();
}

class _AdminModulePreviewViewState
    extends State<AdminModulePreviewView> {
  AdminLearningController get controller =>
      Get.find<AdminLearningController>();

  int get materialId =>
      AdminLearningController.intValue(
        widget.module['id'],
      );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.refreshModuleStructure(
        materialId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Preview Struktur'),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
      ),
      body: Obx(() {
        if ((controller.isLoadingContent.value ||
                controller.isLoadingQuestions.value) &&
            controller.submaterials.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final module =
            controller.activeModule.value ??
                widget.module;
        final submaterials =
            controller.submaterials;
        final questions = controller.questions;
        final checkpointCount =
            submaterials.fold<int>(
          0,
          (total, item) =>
              total +
              AdminLearningController.mapList(
                item['checkpoints'],
              ).length,
        );
        final hasLab =
            module['unity_scene_id']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true;
        final warnings = _warnings(
          module,
          submaterials,
          questions,
        );

        return RefreshIndicator(
          onRefresh: () =>
              controller.refreshModuleStructure(
            materialId,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              32,
            ),
            children: <Widget>[
              _Header(module: module),
              const SizedBox(height: 14),
              _Readiness(warnings: warnings),
              const SizedBox(height: 14),
              _Stats(
                submaterials:
                    submaterials.length,
                checkpoints:
                    checkpointCount,
                questions: questions.length,
                hasLab: hasLab,
              ),
              const SizedBox(height: 18),
              const Text(
                'Alur Konten',
                style: TextStyle(
                  color: _text,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 11),
              if (submaterials.isEmpty)
                const _Empty()
              else
                ...submaterials
                    .asMap()
                    .entries
                    .map(
                  (entry) => _SubmaterialPreview(
                    number: entry.key + 1,
                    submaterial: entry.value,
                  ),
                ),
              const SizedBox(height: 14),
              _FinalStage(
                questionCount:
                    questions.length,
                sceneId:
                    module['unity_scene_id']
                            ?.toString() ??
                        '',
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

    if (module['short_description']
            ?.toString()
            .trim()
            .isEmpty ??
        true) {
      warnings.add('Intro modul belum diisi.');
    }

    if (submaterials.isEmpty) {
      warnings.add(
        'Modul belum memiliki submateri.',
      );
    }

    for (final item in submaterials) {
      final hasRead =
          item['read_content']
                  ?.toString()
                  .trim()
                  .isNotEmpty ==
              true;
      final hasListen =
          item['tts_text']
                      ?.toString()
                      .trim()
                      .isNotEmpty ==
                  true ||
              item['audio_url']
                      ?.toString()
                      .trim()
                      .isNotEmpty ==
                  true;
      final hasVisual =
          item['image_url']
                      ?.toString()
                      .trim()
                      .isNotEmpty ==
                  true ||
              AdminLearningController.mapValue(
                item['visual_data'],
              ).isNotEmpty;

      if (!hasRead && !hasListen && !hasVisual) {
        warnings.add(
          'Submateri "${item['title']}" belum memiliki mode belajar.',
        );
      }

      final checkpointCount =
          AdminLearningController.mapList(
        item['checkpoints'],
      ).length;

      if (AdminLearningController.boolValue(
            item['is_required'],
          ) &&
          checkpointCount == 0) {
        warnings.add(
          'Submateri wajib "${item['title']}" belum memiliki checkpoint.',
        );
      }
    }

    if (questions.isEmpty) {
      warnings.add(
        'Kuis modul belum memiliki soal.',
      );
    }

    return warnings;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.module});

  final Map<String, dynamic> module;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF172554),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
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
                    module['category']?.toString() ??
                        '-',
              ),
              _HeaderPill(
                text:
                    AdminLearningController.boolValue(
                  module['is_published'],
                )
                        ? 'Publik'
                        : 'Draft',
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            module['title']?.toString() ??
                'Modul',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
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
  const _HeaderPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(20),
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

class _Readiness extends StatelessWidget {
  const _Readiness({required this.warnings});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    final ready = warnings.isEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ready
            ? const Color(0xFFE7F8EE)
            : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ready
              ? const Color(0xFF86EFAC)
              : const Color(0xFFFDBA74),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                ready
                    ? Icons.verified_rounded
                    : Icons.warning_amber_rounded,
                color:
                    ready ? _success : _warning,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  ready
                      ? 'Struktur siap dipublikasikan'
                      : 'Masih ada yang perlu dilengkapi',
                  style: TextStyle(
                    color:
                        ready ? _success : _warning,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (!ready) ...<Widget>[
            const SizedBox(height: 10),
            ...warnings.map(
              (item) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 5,
                ),
                child: Text(
                  '• $item',
                  style: const TextStyle(
                    color: _text,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({
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
        final width =
            (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _Stat(
              width: width,
              label: 'Submateri',
              value: '$submaterials',
              icon: Icons.menu_book_rounded,
            ),
            _Stat(
              width: width,
              label: 'Checkpoint',
              value: '$checkpoints',
              icon: Icons.task_alt_rounded,
            ),
            _Stat(
              width: width,
              label: 'Soal Kuis',
              value: '$questions',
              icon: Icons.quiz_rounded,
            ),
            _Stat(
              width: width,
              label: 'Laboratorium',
              value: hasLab ? 'Aktif' : 'Tidak',
              icon: Icons.science_rounded,
            ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: _primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                style: const TextStyle(
                  color: _text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubmaterialPreview
    extends StatelessWidget {
  const _SubmaterialPreview({
    required this.number,
    required this.submaterial,
  });

  final int number;
  final Map<String, dynamic> submaterial;

  @override
  Widget build(BuildContext context) {
    final hasRead =
        submaterial['read_content']
                ?.toString()
                .trim()
                .isNotEmpty ==
            true;
    final hasListen =
        submaterial['tts_text']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true ||
            submaterial['audio_url']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true;
    final hasVisual =
        submaterial['image_url']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true ||
            AdminLearningController.mapValue(
              submaterial['visual_data'],
            ).isNotEmpty;
    final checkpoints =
        AdminLearningController.mapList(
      submaterial['checkpoints'],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    const Color(0xFFEAF1FF),
                foregroundColor: _primary,
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  submaterial['title']
                          ?.toString() ??
                      'Submateri',
                  style: const TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              _Mode(
                text: 'Baca',
                active: hasRead,
              ),
              _Mode(
                text: 'Dengarkan',
                active: hasListen,
              ),
              _Mode(
                text: 'Visual',
                active: hasVisual,
              ),
              _Mode(
                text:
                    '${checkpoints.length} checkpoint',
                active: checkpoints.isNotEmpty,
              ),
            ],
          ),
          if (checkpoints.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            ...checkpoints.map(
              (checkpoint) => Container(
                margin: const EdgeInsets.only(
                  bottom: 7,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.task_alt_rounded,
                      size: 18,
                      color: Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        checkpoint['title']
                                ?.toString() ??
                            'Checkpoint',
                        style: const TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      checkpoint['checkpoint_label']
                              ?.toString() ??
                          '',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10,
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

class _Mode extends StatelessWidget {
  const _Mode({
    required this.text,
    required this.active,
  });

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFEAF1FF)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? _primary : _muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FinalStage extends StatelessWidget {
  const _FinalStage({
    required this.questionCount,
    required this.sceneId,
  });

  final int questionCount;
  final String sceneId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Tahap Akhir Modul',
            style: TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Kuis: $questionCount soal • nilai minimal 75',
            style: const TextStyle(
              color: _text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            sceneId.trim().isEmpty
                ? 'Lab: tidak diperlukan'
                : 'Lab: scene $sceneId',
            style: const TextStyle(
              color: _text,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Belum ada submateri.',
        textAlign: TextAlign.center,
        style: TextStyle(color: _muted),
      ),
    );
  }
}
