import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_learning_controller.dart';

const Color _primary = Color(0xFF2563EB);
const Color _quiz = Color(0xFF7C3AED);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _background = Color(0xFFF5F8FF);
const Color _success = Color(0xFF16A34A);

class AdminContentImportView
    extends StatefulWidget {
  const AdminContentImportView({
    super.key,
  });

  @override
  State<AdminContentImportView>
      createState() =>
          _AdminContentImportViewState();
}

class _AdminContentImportViewState
    extends State<AdminContentImportView> {
  String? _learningFilePath;
  String? _questionFilePath;
  bool _replaceLearningContent = false;

  AdminLearningController get controller =>
      Get.find<AdminLearningController>();

  @override
  void initState() {
    super.initState();
    controller.clearImportResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title:
            const Text('Import Konten CSV'),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
      ),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          17,
          16,
          35,
        ),
        children: <Widget>[
          const _InfoCard(),
          const SizedBox(height: 14),

          // CSV 1: Learning content
          _ImportSection(
            number: '1',
            color: _primary,
            icon:
                Icons.account_tree_rounded,
            title:
                'Konten Pembelajaran',
            description:
                'Modul, submateri, dan checkpoint.',
            fileName:
                _fileName(_learningFilePath),
            expectedName:
                'learning_content.csv',
            isLoading: controller
                .isImportingLearningContent,
            onPick: _pickLearningFile,
            onImport: _learningFilePath == null
                ? null
                : _importLearningContent,
            result: controller
                .lastLearningImportResult,
            importLabel:
                'Import Konten Pembelajaran',
            extra: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Ganti struktur modul yang sama',
                style: TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: const Text(
                'Menghapus submateri dan checkpoint lama pada modul yang sama. Soal kuis tidak ikut terhapus.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              value: _replaceLearningContent,
              onChanged: (value) {
                setState(() {
                  _replaceLearningContent =
                      value;
                });
              },
            ),
          ),

          const SizedBox(height: 14),

          // CSV 2: Questions
          _ImportSection(
            number: '2',
            color: _quiz,
            icon: Icons.quiz_rounded,
            title: 'Soal Kuis',
            description:
                'Soal A–D, kategori soal, kunci, dan pembahasan.',
            fileName:
                _fileName(_questionFilePath),
            expectedName: 'questions.csv',
            isLoading:
                controller.isImportingQuestions,
            onPick: _pickQuestionFile,
            onImport: _questionFilePath == null
                ? null
                : _importQuestions,
            result: controller
                .lastQuestionImportResult,
            importLabel: 'Import Soal Kuis',
          ),

          const SizedBox(height: 14),
          const _OrderCard(),
        ],
      ),
    );
  }

  String _fileName(String? path) {
    if (path == null) {
      return '';
    }

    return File(path)
        .uri
        .pathSegments
        .last;
  }

  Future<String?> _pickCsv() async {
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>[
        'csv',
      ],
      allowMultiple: false,
    );

    return result?.files.single.path;
  }

  Future<void> _pickLearningFile() async {
    final String? path = await _pickCsv();

    if (path == null) {
      return;
    }

    setState(() {
      _learningFilePath = path;
    });

    controller.lastLearningImportResult
        .value = null;
  }

  Future<void> _pickQuestionFile() async {
    final String? path = await _pickCsv();

    if (path == null) {
      return;
    }

    setState(() {
      _questionFilePath = path;
    });

    controller.lastQuestionImportResult
        .value = null;
  }

  Future<void> _importLearningContent()
      async {
    final String? path =
        _learningFilePath;

    if (path == null) {
      return;
    }

    await controller.importLearningContent(
      filePath: path,
      replaceExisting:
          _replaceLearningContent,
    );
  }

  Future<void> _importQuestions() async {
    final String? path =
        _questionFilePath;

    if (path == null) {
      return;
    }

    await controller.importQuestionsCsv(
      filePath: path,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF172554),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius:
            BorderRadius.circular(21),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.file_copy_rounded,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Dua CSV yang lebih rapi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Struktur pembelajaran dan bank soal diimpor terpisah agar kolom lebih mudah dibaca dan diperbaiki.',
                  style: TextStyle(
                    color: Color(0xFFDCE9FF),
                    height: 1.45,
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

class _ImportSection extends StatelessWidget {
  const _ImportSection({
    required this.number,
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
    required this.fileName,
    required this.expectedName,
    required this.isLoading,
    required this.onPick,
    required this.onImport,
    required this.result,
    required this.importLabel,
    this.extra,
  });

  final String number;
  final Color color;
  final IconData icon;
  final String title;
  final String description;
  final String fileName;
  final String expectedName;
  final RxBool isLoading;
  final VoidCallback onPick;
  final VoidCallback? onImport;
  final Rxn<Map<String, dynamic>> result;
  final String importLabel;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final bool hasFile =
        fileName.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(17),
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
            children: <Widget>[
              CircleAvatar(
                backgroundColor:
                    color.withValues(
                  alpha: 0.12,
                ),
                foregroundColor: color,
                child: Text(
                  number,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onPick,
            borderRadius:
                BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF8FAFC,
                ),
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: hasFile
                      ? color
                      : const Color(
                          0xFFCBD5E1,
                        ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    hasFile
                        ? Icons
                            .check_circle_rounded
                        : Icons
                            .upload_file_rounded,
                    color: hasFile
                        ? _success
                        : color,
                    size: 31,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          hasFile
                              ? fileName
                              : expectedName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _text,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasFile
                              ? 'File siap diimpor'
                              : 'Ketuk untuk memilih CSV UTF-8',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons
                        .folder_open_rounded,
                    color: _muted,
                  ),
                ],
              ),
            ),
          ),
          if (extra != null) ...<Widget>[
            const SizedBox(height: 6),
            extra!,
          ],
          const SizedBox(height: 12),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    isLoading.value
                        ? null
                        : onImport,
                icon: isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons
                            .cloud_upload_rounded,
                      ),
                label: Text(
                  isLoading.value
                      ? 'Mengimpor...'
                      : importLabel,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            final Map<String, dynamic>?
                data = result.value;

            if (data == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding:
                  const EdgeInsets.only(
                top: 13,
              ),
              child: _ResultCard(
                result: data,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
  });

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> totals =
        AdminLearningController.mapValue(
      result['totals'],
    );

    final bool isLearningResult =
        totals.isNotEmpty;

    final int imported =
        isLearningResult
            ? AdminLearningController
                .intValue(
                totals['imported'],
              )
            : AdminLearningController
                .intValue(
                result['imported'],
              );

    final int updated =
        isLearningResult
            ? AdminLearningController
                .intValue(
                totals['updated'],
              )
            : AdminLearningController
                .intValue(
                result['updated'],
              );

    final List<Map<String, dynamic>>
        skipped =
        AdminLearningController.mapList(
      result['skipped'],
    );

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F8EE),
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF86EFAC),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(
                Icons.verified_rounded,
                color: _success,
              ),
              SizedBox(width: 8),
              Text(
                'Hasil import',
                style: TextStyle(
                  color: _success,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '$imported data baru • '
            '$updated diperbarui • '
            '${skipped.length} dilewati',
            style: const TextStyle(
              color: _text,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (skipped.isNotEmpty) ...<Widget>[
            const SizedBox(height: 9),
            ...skipped.take(5).map(
              (item) => Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 4,
                ),
                child: Text(
                  'Baris ${item['row'] ?? '-'}: '
                  '${item['reason'] ?? 'Tidak diketahui'}',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            if (skipped.length > 5)
              Text(
                '+${skipped.length - 5} baris lainnya',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDBA74),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFD97706),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Upload learning_content.csv terlebih dahulu. questions.csv mencari modul berdasarkan material_title yang harus sama persis dengan judul modul.',
              style: TextStyle(
                color: _text,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
