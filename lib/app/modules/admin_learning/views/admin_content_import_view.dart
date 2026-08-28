import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/admin_learning_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _quizPurple = Color(0xFF6366F1);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _success = Color(0xFF10B981);
const Color _amber = Color(0xFFF59E0B);

class AdminContentImportView extends StatefulWidget {
  const AdminContentImportView({super.key});

  @override
  State<AdminContentImportView> createState() => _AdminContentImportViewState();
}

class _AdminContentImportViewState extends State<AdminContentImportView> {
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
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          'Import Konten CSV',
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
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
        children: <Widget>[
          // 1. Hero Info Card
          const _HeroInfoCard(),
          const SizedBox(height: 16),

          // 2. CSV Step 1: Learning Content
          _ImportSection(
            stepNumber: '1',
            color: _primaryBlue,
            icon: Icons.account_tree_outlined,
            title: 'Struktur Modul & Materi',
            description:
                'File berisi modul, submateri (teks/gambar/audio), dan checkpoint.',
            fileName: _fileName(_learningFilePath),
            expectedName: 'learning_content.csv',
            isLoading: controller.isImportingLearningContent,
            onPick: _pickLearningFile,
            onClear: () => setState(() => _learningFilePath = null),
            onImport: _learningFilePath == null ? null : _importLearningContent,
            result: controller.lastLearningImportResult,
            importLabel: 'Import Konten Modul',
            extraOptions: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeTrackColor: _primaryBlue,
                title: Text(
                  'Ganti struktur modul lama yang sama',
                  style: GoogleFonts.poppins(
                    color: _textDark,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Menimpa submateri lama pada modul bernomor sama. Bank soal kuis tetap aman.',
                  style: GoogleFonts.plusJakartaSans(
                    color: _textMuted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                value: _replaceLearningContent,
                onChanged: (value) {
                  setState(() {
                    _replaceLearningContent = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. CSV Step 2: Quiz Questions
          _ImportSection(
            stepNumber: '2',
            color: _quizPurple,
            icon: Icons.quiz_outlined,
            title: 'Bank Soal Kuis',
            description:
                'File berisi pertanyaan, pilihan A-D, kunci jawaban, dan pembahasan.',
            fileName: _fileName(_questionFilePath),
            expectedName: 'questions.csv',
            isLoading: controller.isImportingQuestions,
            onPick: _pickQuestionFile,
            onClear: () => setState(() => _questionFilePath = null),
            onImport: _questionFilePath == null ? null : _importQuestions,
            result: controller.lastQuestionImportResult,
            importLabel: 'Import Bank Soal Kuis',
          ),

          const SizedBox(height: 16),

          // 4. Workflow Notice Card
          const _WorkflowNoticeCard(),
        ],
      ),
    );
  }

  String _fileName(String? path) {
    if (path == null) {
      return '';
    }
    return File(path).uri.pathSegments.last;
  }

  Future<String?> _pickCsv() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['csv'],
      allowMultiple: false,
    );

    return result?.files.single.path;
  }

  Future<void> _pickLearningFile() async {
    final String? path = await _pickCsv();
    if (path == null) return;

    setState(() {
      _learningFilePath = path;
    });
    controller.lastLearningImportResult.value = null;
  }

  Future<void> _pickQuestionFile() async {
    final String? path = await _pickCsv();
    if (path == null) return;

    setState(() {
      _questionFilePath = path;
    });
    controller.lastQuestionImportResult.value = null;
  }

  Future<void> _importLearningContent() async {
    final String? path = _learningFilePath;
    if (path == null) return;

    await controller.importLearningContent(
      filePath: path,
      replaceExisting: _replaceLearningContent,
    );
  }

  Future<void> _importQuestions() async {
    final String? path = _questionFilePath;
    if (path == null) return;

    await controller.importQuestionsCsv(
      filePath: path,
    );
  }
}

// =============================================================================
// 1. HERO INFO CARD
// =============================================================================
class _HeroInfoCard extends StatelessWidget {
  const _HeroInfoCard();

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.upload_file_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan Import 2 CSV',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Struktur modul dan bank soal dipisahkan ke dalam dua file CSV terpisah untuk memastikan format data lebih rapi, terstruktur, dan mudah diperbaiki.',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFDCE9FF),
                    fontSize: 11.5,
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

// =============================================================================
// 2. IMPORT SECTION CARD
// =============================================================================
class _ImportSection extends StatelessWidget {
  const _ImportSection({
    required this.stepNumber,
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
    required this.fileName,
    required this.expectedName,
    required this.isLoading,
    required this.onPick,
    required this.onClear,
    required this.onImport,
    required this.result,
    required this.importLabel,
    this.extraOptions,
  });

  final String stepNumber;
  final Color color;
  final IconData icon;
  final String title;
  final String description;
  final String fileName;
  final String expectedName;
  final RxBool isLoading;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final VoidCallback? onImport;
  final Rxn<Map<String, dynamic>> result;
  final String importLabel;
  final Widget? extraOptions;

  @override
  Widget build(BuildContext context) {
    final bool hasFile = fileName.isNotEmpty;

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
          // Section Title Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: GoogleFonts.poppins(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: _textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // File Picker Dropzone Container
          Material(
            color: hasFile ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasFile ? _success : const Color(0xFFCBD5E1),
                    width: hasFile ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (hasFile ? _success : color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        hasFile
                            ? Icons.check_circle_rounded
                            : Icons.file_present_rounded,
                        color: hasFile ? _success : color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasFile ? fileName : expectedName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: hasFile ? _textDark : _textMuted,
                              fontSize: 13,
                              fontWeight:
                                  hasFile ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasFile
                                ? 'File CSV siap diimpor'
                                : 'Ketuk untuk memilih file CSV dari penyimpanan',
                            style: GoogleFonts.plusJakartaSans(
                              color: hasFile ? _success : _textMuted,
                              fontSize: 11,
                              fontWeight:
                                  hasFile ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasFile)
                      IconButton(
                        tooltip: 'Ganti file',
                        icon: const Icon(Icons.close_rounded,
                            color: _textMuted, size: 20),
                        onPressed: onClear,
                      )
                    else
                      const Icon(Icons.folder_open_rounded,
                          color: _textMuted, size: 20),
                  ],
                ),
              ),
            ),
          ),

          if (extraOptions != null) extraOptions!,

          const SizedBox(height: 12),

          // Import Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: isLoading.value ? null : onImport,
                icon: isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded, size: 19),
                label: Text(
                  isLoading.value ? 'Mengimpor Data...' : importLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          // Result Card
          Obx(() {
            final Map<String, dynamic>? data = result.value;
            if (data == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _ResultFeedbackCard(result: data),
            );
          }),
        ],
      ),
    );
  }
}

// =============================================================================
// 3. RESULT FEEDBACK CARD
// =============================================================================
class _ResultFeedbackCard extends StatelessWidget {
  const _ResultFeedbackCard({required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> totals =
        AdminLearningController.mapValue(result['totals']);

    final bool isLearningResult = totals.isNotEmpty;

    final int imported = isLearningResult
        ? AdminLearningController.intValue(totals['imported'])
        : AdminLearningController.intValue(result['imported']);

    final int updated = isLearningResult
        ? AdminLearningController.intValue(totals['updated'])
        : AdminLearningController.intValue(result['updated']);

    final List<Map<String, dynamic>> skipped =
        AdminLearningController.mapList(result['skipped']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: _success, size: 18),
              const SizedBox(width: 8),
              Text(
                'Laporan Hasil Import',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF065F46),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$imported data baru berhasil dimasukkan • $updated diperbarui • ${skipped.length} dilewati',
            style: GoogleFonts.plusJakartaSans(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (skipped.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFA7F3D0)),
            const SizedBox(height: 8),
            Text(
              'Catatan Baris yang Dilewati:',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
            const SizedBox(height: 4),
            ...skipped.take(4).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      '• Baris ${item['row'] ?? '-'}: ${item['reason'] ?? 'Format tidak sesuai'}',
                      style: GoogleFonts.plusJakartaSans(
                        color: _textMuted,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
            if (skipped.length > 4)
              Text(
                '+ ${skipped.length - 4} baris lainnya dilewati.',
                style: GoogleFonts.plusJakartaSans(
                  color: _textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// 4. WORKFLOW NOTICE CARD
// =============================================================================
class _WorkflowNoticeCard extends StatelessWidget {
  const _WorkflowNoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: _amber,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Urutan Import yang Disarankan',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Unggah learning_content.csv terlebih dahulu agar struktur modul terdaftar di sistem. Setelah itu, unggah questions.csv yang mencocokkan kolom material_title sama persis dengan judul modul.',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF78350F),
                    fontSize: 11.5,
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
