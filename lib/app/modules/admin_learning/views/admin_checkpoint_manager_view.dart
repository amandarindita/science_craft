import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/api_service.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/science_shimmer.dart';
import '../controllers/admin_learning_controller.dart';

// =============================================================================
// COLOR PALETTE (MAINTAINING PURPLE ACCENT AS REQUESTED)
// =============================================================================
const Color _primary = Color(0xFF7C3AED); // Main Purple
const Color _primaryDark = Color(0xFF4C1D95); // Deep Indigo/Purple
const Color _primaryLight = Color(0xFFF3E8FF); // Soft Tint Purple
const Color _text = Color(0xFF1E293B); // Slate 800
const Color _muted = Color(0xFF64748B); // Slate 500
const Color _background = Color(0xFFF8FAFC); // Slate 50
const Color _border = Color(0xFFE2E8F0); // Slate 200
const Color _danger = Color(0xFFEF4444); // Red 500
const Color _success = Color(0xFF10B981); // Emerald 500
const Color _amber = Color(0xFFF59E0B); // Amber 500

// =============================================================================
// INPUT DECORATION HELPER
// =============================================================================
InputDecoration _buildInputDecoration({
  String? labelText,
  String? hintText,
  IconData? prefixIcon,
  Widget? suffixIcon,
  String? errorText,
  bool alignLabelWithHint = false,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: GoogleFonts.plusJakartaSans(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: _muted,
    ),
    hintText: hintText,
    hintStyle: GoogleFonts.plusJakartaSans(
      fontSize: 12.5,
      color: _muted.withValues(alpha: 0.6),
    ),
    errorText: errorText,
    prefixIcon:
        prefixIcon != null
            ? Icon(prefixIcon, color: _primary, size: 19)
            : null,
    suffixIcon: suffixIcon,
    alignLabelWithHint: alignLabelWithHint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _danger),
    ),
  );
}

// =============================================================================
// 1. CHECKPOINT MANAGER VIEW (LIST SCREEN)
// =============================================================================
class AdminCheckpointManagerView extends StatefulWidget {
  const AdminCheckpointManagerView({super.key, required this.submaterial});

  final Map<String, dynamic> submaterial;

  @override
  State<AdminCheckpointManagerView> createState() =>
      _AdminCheckpointManagerViewState();
}

class _AdminCheckpointManagerViewState
    extends State<AdminCheckpointManagerView> {
  AdminLearningController get controller => Get.find<AdminLearningController>();

  int get submaterialId =>
      AdminLearningController.intValue(widget.submaterial['id']);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.openCheckpointManager(widget.submaterial),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          'Kelola Checkpoint',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _text,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        centerTitle: false,
        shape: const Border(bottom: BorderSide(color: _border)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Get.to<bool>(
              () => AdminCheckpointFormView(submaterialId: submaterialId),
            ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_task_rounded),
        label: Text(
          'Tambah Checkpoint',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: () => controller.loadCheckpoints(submaterialId),
        child: Obx(() {
          if (controller.isLoadingCheckpoints.value &&
              controller.checkpoints.isEmpty) {
            return const AdminModuleListShimmer(itemCount: 3);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: <Widget>[
              _Header(
                title: widget.submaterial['title']?.toString() ?? 'Submateri',
                checkpointCount: controller.checkpoints.length,
              ),
              const SizedBox(height: 16),
              if (controller.checkpoints.isEmpty)
                _EmptyState(
                  onAdd:
                      () => Get.to<bool>(
                        () => AdminCheckpointFormView(
                          submaterialId: submaterialId,
                        ),
                      ),
                )
              else
                ...controller.checkpoints.asMap().entries.map((entry) {
                  final index = entry.key;
                  final checkpoint = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CheckpointCard(
                      index: index,
                      checkpoint: checkpoint,
                      onEdit:
                          () => Get.to<bool>(
                            () => AdminCheckpointFormView(
                              submaterialId: submaterialId,
                              checkpoint: checkpoint,
                            ),
                          ),
                      onDelete: () => controller.deleteCheckpoint(checkpoint),
                    ),
                  );
                }),
            ],
          );
        }),
      ),
    );
  }
}

// =============================================================================
// 2. CHECKPOINT FORM VIEW (ADD / EDIT SCREEN)
// =============================================================================
class AdminCheckpointFormView extends StatefulWidget {
  const AdminCheckpointFormView({
    super.key,
    required this.submaterialId,
    this.checkpoint,
  });

  final int submaterialId;
  final Map<String, dynamic>? checkpoint;

  bool get isEditing => checkpoint != null;

  @override
  State<AdminCheckpointFormView> createState() =>
      _AdminCheckpointFormViewState();
}

class _AdminCheckpointFormViewState extends State<AdminCheckpointFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController(
    text: 'Cek Pemahaman',
  );
  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _orderController = TextEditingController(
    text: '1',
  );
  final TextEditingController _correctFeedbackController =
      TextEditingController(text: 'Mantap, jawabanmu benar!');
  final TextEditingController _wrongFeedbackController = TextEditingController(
    text: 'Belum tepat. Pelajari kembali bagian ini lalu coba lagi.',
  );

  final List<TextEditingController> _choiceControllers =
      List<TextEditingController>.generate(4, (_) => TextEditingController());

  String _correctChoice = 'A';
  bool _trueFalseAnswer = true;

  final List<_MatchingDraft> _matchingItems = <_MatchingDraft>[];
  final List<TextEditingController> _orderingItems = <TextEditingController>[];

  final TextEditingController _dataTitleController = TextEditingController(
    text: 'Data Pengamatan',
  );
  final TextEditingController _dataDescriptionController =
      TextEditingController();
  final TextEditingController _headerOneController = TextEditingController(
    text: 'Objek / Sampel',
  );
  final TextEditingController _headerTwoController = TextEditingController(
    text: 'Hasil Pengamatan',
  );
  final List<_TableRowDraft> _tableRows = <_TableRowDraft>[];
  final List<TextEditingController> _analysisOptionControllers =
      List<TextEditingController>.generate(4, (_) => TextEditingController());
  String _analysisCorrectChoice = 'A';

  final List<_HotspotDraft> _hotspots = <_HotspotDraft>[];

  String _type = 'multiple_choice';
  bool _isRequired = true;
  String? _imagePath;
  String _existingImageUrl = '';
  bool _removeImage = false;

  AdminLearningController get controller => Get.find<AdminLearningController>();

  @override
  void initState() {
    super.initState();

    _setDefaultTypeValues();

    final Map<String, dynamic>? data = widget.checkpoint;
    if (data == null) {
      return;
    }

    _type = data['checkpoint_type']?.toString() ?? 'multiple_choice';
    _titleController.text = data['title']?.toString() ?? 'Cek Pemahaman';
    _instructionController.text = data['instruction']?.toString() ?? '';
    _questionController.text = data['question_text']?.toString() ?? '';
    _orderController.text =
        AdminLearningController.intValue(
          data['order_index'],
          fallback: 1,
        ).toString();
    _correctFeedbackController.text =
        data['correct_feedback']?.toString() ?? '';
    _wrongFeedbackController.text = data['wrong_feedback']?.toString() ?? '';
    _isRequired = AdminLearningController.boolValue(
      data['is_required'],
      fallback: true,
    );
    _existingImageUrl = data['image_url']?.toString().trim() ?? '';

    _loadTypeValues(
      AdminLearningController.mapValue(data['content']),
      AdminLearningController.mapValue(data['answer']),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionController.dispose();
    _questionController.dispose();
    _orderController.dispose();
    _correctFeedbackController.dispose();
    _wrongFeedbackController.dispose();

    for (final TextEditingController item in _choiceControllers) {
      item.dispose();
    }
    for (final _MatchingDraft item in _matchingItems) {
      item.dispose();
    }
    for (final TextEditingController item in _orderingItems) {
      item.dispose();
    }

    _dataTitleController.dispose();
    _dataDescriptionController.dispose();
    _headerOneController.dispose();
    _headerTwoController.dispose();

    for (final _TableRowDraft row in _tableRows) {
      row.dispose();
    }
    for (final TextEditingController item in _analysisOptionControllers) {
      item.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? resolvedImage =
        _existingImageUrl.isEmpty || _removeImage
            ? null
            : ApiService.resolveMediaUrl(_existingImageUrl);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Checkpoint' : 'Tambah Checkpoint',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _text,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: _border)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: <Widget>[
            // 1. Selector Tipe Checkpoint Interaktif
            _Section(
              title: 'Model Checkpoint',
              subtitle: 'Pilih model interaktif untuk menguji pemahaman siswa.',
              icon: Icons.category_rounded,
              children: [
                _buildTypeSelectorChips(),
                const SizedBox(height: 12),
                _InfoBanner(type: _type),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Informasi Dasar & Pertanyaan
            _Section(
              title: 'Informasi Pertanyaan',
              subtitle: 'Judul, instruksi, dan narasi soal checkpoint.',
              icon: Icons.quiz_rounded,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _text,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Judul Checkpoint',
                    hintText: 'Contoh: Cek Konsep Fotosintesis',
                    prefixIcon: Icons.title_rounded,
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _instructionController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _text,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Instruksi Pengerjaan (Opsional)',
                    hintText: 'Contoh: Pilih satu jawaban yang paling tepat.',
                    prefixIcon: Icons.help_outline_rounded,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _questionController,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: _text,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Teks Pertanyaan Utama *',
                    hintText: 'Tuliskan pertanyaan checkpoint di sini...',
                    alignLabelWithHint: true,
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _orderController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _text,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Urutan Posisi Checkpoint *',
                    hintText: '1, 2, 3...',
                    prefixIcon: Icons.format_list_numbered_rounded,
                  ),
                  validator: (String? value) {
                    final int? number = int.tryParse(value?.trim() ?? '');
                    if (number == null || number < 1) {
                      return 'Urutan minimal 1.';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Editor Khusus Tipe Jawaban
            _buildAnswerEditor(resolvedImage),
            const SizedBox(height: 16),

            // 4. Gambar Pendukung Opsional (Bila bukan tipe hotspot)
            if (_type != 'image_hotspot') ...[
              _buildOptionalImage(resolvedImage),
              const SizedBox(height: 16),
            ],

            // 5. Feedback dan Status Checkpoint
            _Section(
              title: 'Umpan Balik & Ketuntasan',
              subtitle: 'Respon otomatis ketika siswa menjawab soal.',
              icon: Icons.feedback_outlined,
              children: <Widget>[
                TextFormField(
                  controller: _correctFeedbackController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _text,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Umpan Balik Jawaban Benar',
                    hintText: 'Contoh: Hebat, pemahamanmu tepat!',
                    prefixIcon: Icons.check_circle_outline_rounded,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _wrongFeedbackController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _text,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Umpan Balik Jawaban Salah',
                    hintText: 'Contoh: Masih kurang tepat, coba pelajari lagi.',
                    prefixIcon: Icons.highlight_off_rounded,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: _primary,
                    title: Text(
                      'Checkpoint Wajib Diselesaikan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _text,
                      ),
                    ),
                    subtitle: Text(
                      'Siswa harus menjawab benar sebelum menandai materi selesai.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: _muted,
                      ),
                    ),
                    value: _isRequired,
                    onChanged: (bool value) {
                      setState(() {
                        _isRequired = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _border)),
          ),
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: controller.isSavingCheckpoint.value ? null : _save,
                icon:
                    controller.isSavingCheckpoint.value
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save_rounded, size: 19),
                label: Text(
                  widget.isEditing
                      ? 'Simpan Perubahan Checkpoint'
                      : 'Buat Checkpoint Baru',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TYPE SELECTOR CHIPS
  // ===========================================================================
  Widget _buildTypeSelectorChips() {
    final List<Map<String, dynamic>> types =
        controller.checkpointTypes.isEmpty
            ? _fallbackTypes
            : controller.checkpointTypes;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children:
            types.map((item) {
              final val = item['value'].toString();
              final isSelected = _type == val;
              final meta = _typeMeta[val] ?? _defaultMeta;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: isSelected ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      if (_type == val) return;
                      setState(() {
                        _type = val;
                        _setDefaultTypeValues();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? _primary : _border,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: _primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                                : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            meta.icon,
                            size: 16,
                            color: isSelected ? Colors.white : _primary,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            item['label']?.toString() ?? meta.label,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              color: isSelected ? Colors.white : _text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // ===========================================================================
  // ANSWER EDITORS
  // ===========================================================================
  Widget _buildAnswerEditor(String? resolvedImage) {
    switch (_type) {
      case 'true_false':
        return _buildTrueFalseEditor();
      case 'matching':
        return _buildMatchingEditor();
      case 'ordering':
        return _buildOrderingEditor();
      case 'image_hotspot':
        return _buildHotspotEditor(resolvedImage);
      case 'data_interpretation':
        return _buildDataEditor();
      case 'multiple_choice':
      default:
        return _buildChoiceEditor();
    }
  }

  Widget _buildChoiceEditor() {
    return _Section(
      title: 'Pilihan Jawaban & Kunci',
      subtitle:
          'Isi 4 pilihan jawaban dan pilih radio button untuk kunci jawaban.',
      icon: Icons.checklist_rounded,
      children: <Widget>[
        ...List<Widget>.generate(4, (int index) {
          final String letter = String.fromCharCode(65 + index);
          final bool isSelected = _correctChoice == letter;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? _primaryLight.withValues(alpha: 0.5)
                      : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? _primary : _border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      _correctChoice = letter;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? _primary : Colors.white,
                      border: Border.all(
                        color: isSelected ? _primary : _muted,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : _text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _choiceControllers[index],
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: _text,
                    ),
                    decoration: _buildInputDecoration(
                      hintText: 'Tulis pilihan jawaban $letter',
                    ),
                    validator: _required,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Kunci',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _success,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrueFalseEditor() {
    return _Section(
      title: 'Kunci Jawaban Benar / Salah',
      subtitle: 'Tentukan apakah premis soal bernilai Benar atau Salah.',
      icon: Icons.rule_rounded,
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _trueFalseAnswer = true),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color:
                        _trueFalseAnswer
                            ? _success.withValues(alpha: 0.12)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _trueFalseAnswer ? _success : _border,
                      width: _trueFalseAnswer ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: _trueFalseAnswer ? _success : _muted,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'BENAR',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _trueFalseAnswer ? _success : _text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _trueFalseAnswer = false),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color:
                        !_trueFalseAnswer
                            ? _danger.withValues(alpha: 0.12)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: !_trueFalseAnswer ? _danger : _border,
                      width: !_trueFalseAnswer ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cancel_rounded,
                        color: !_trueFalseAnswer ? _danger : _muted,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'SALAH',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: !_trueFalseAnswer ? _danger : _text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchingEditor() {
    return _Section(
      title: 'Pasangan Jawaban (Matching)',
      subtitle:
          'Setiap baris adalah satu pasangan yang valid. Sistem akan mengacak urutan sisi kanan bagi siswa.',
      icon: Icons.join_inner_rounded,
      children: <Widget>[
        ..._matchingItems.asMap().entries.map((entry) {
          final int index = entry.key;
          final _MatchingDraft item = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primaryDark, _primary],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pasangan ${index + 1}',
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    const Spacer(),
                    if (_matchingItems.length > 2)
                      IconButton(
                        tooltip: 'Hapus pasangan',
                        onPressed: () {
                          setState(() {
                            final removed = _matchingItems.removeAt(index);
                            removed.dispose();
                          });
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: _danger,
                          size: 19,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: item.leftController,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _text,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Kolom Kiri (Pertanyaan/Konsep)',
                    hintText: 'Contoh: Kloroplas',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: item.rightController,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _text,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Kolom Kanan (Pasangan Jawaban Benar)',
                    hintText: 'Contoh: Tempat fotosintesis',
                  ),
                  validator: _required,
                ),
              ],
            ),
          );
        }),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _matchingItems.add(_MatchingDraft());
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              side: const BorderSide(color: _primary, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 19),
            label: Text(
              'Tambah Pasangan Jawaban',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderingEditor() {
    return _Section(
      title: 'Urutan Langkah yang Benar',
      subtitle:
          'Isi urutan kronologis yang benar. Tekan dan geser handle untuk mengubah posisi urutan.',
      icon: Icons.format_list_numbered_rounded,
      children: <Widget>[
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _orderingItems.length,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final TextEditingController item = _orderingItems.removeAt(
                oldIndex,
              );
              _orderingItems.insert(newIndex, item);
            });
          },
          itemBuilder: (BuildContext context, int index) {
            return Container(
              key: ObjectKey(_orderingItems[index]),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _primaryLight,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _orderingItems[index],
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: _text,
                      ),
                      decoration: _buildInputDecoration(
                        hintText: 'Langkah ${index + 1}',
                      ),
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.drag_handle_rounded, color: _muted),
                    ),
                  ),
                  if (_orderingItems.length > 2)
                    IconButton(
                      tooltip: 'Hapus langkah',
                      onPressed: () {
                        setState(() {
                          final removed = _orderingItems.removeAt(index);
                          removed.dispose();
                        });
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: _danger,
                        size: 19,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _orderingItems.add(TextEditingController());
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              side: const BorderSide(color: _primary, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 19),
            label: Text(
              'Tambah Langkah Urutan',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotspotEditor(String? resolvedImage) {
    final bool hasImage = _imagePath != null || resolvedImage != null;

    return Column(
      children: <Widget>[
        _Section(
          title: 'Ilustrasi & Penanda Titik Hotspot',
          subtitle:
              'Unggah gambar, lalu ketuk area gambar untuk menempatkan pin interaktif.',
          icon: Icons.touch_app_rounded,
          children: <Widget>[
            if (!hasImage)
              _ImagePickerPlaceholder(
                label: 'Pilih gambar untuk membuat titik hotspot',
                onTap: _pickImage,
              )
            else ...<Widget>[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        _createHotspot(
                          details.localPosition,
                          Size(constraints.maxWidth, constraints.maxHeight),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            if (_imagePath != null)
                              Image.file(File(_imagePath!), fit: BoxFit.cover)
                            else
                              Image.network(
                                resolvedImage!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const _ImageError(),
                              ),
                            ..._hotspots.map((_HotspotDraft hotspot) {
                              final double left =
                                  (hotspot.x * constraints.maxWidth - 20)
                                      .clamp(0.0, constraints.maxWidth - 40)
                                      .toDouble();
                              final double top =
                                  (hotspot.y * constraints.maxHeight - 20)
                                      .clamp(0.0, constraints.maxHeight - 40)
                                      .toDouble();

                              return Positioned(
                                left: left,
                                top: top,
                                child: GestureDetector(
                                  onTap: () => _editHotspot(hotspot),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors:
                                            hotspot.isCorrect
                                                ? [
                                                  const Color(0xFF059669),
                                                  _success,
                                                ]
                                                : [_primaryDark, _primary],
                                      ),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                      boxShadow: const <BoxShadow>[
                                        BoxShadow(
                                          color: Color(0x44000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${_hotspots.indexOf(hotspot) + 1}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.image_search_rounded, size: 18),
                      label: Text(
                        'Ganti Gambar',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _imagePath = null;
                          _removeImage = true;
                          _hotspots.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _danger,
                        side: const BorderSide(color: Color(0xFFFEE2E2)),
                        backgroundColor: const Color(0xFFFEF2F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: Text(
                        'Hapus Gambar',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Daftar Titik Penjelasan',
          subtitle:
              'Kelola nama bagian dan tentukan satu titik sebagai kunci jawaban benar.',
          icon: Icons.pin_drop_rounded,
          children: <Widget>[
            if (_hotspots.isEmpty)
              const _InlineEmpty(
                text:
                    'Belum ada titik. Ketuk bagian gambar di atas untuk menambahkan hotspot.',
              )
            else
              ..._hotspots.asMap().entries.map((entry) {
                final int index = entry.key;
                final _HotspotDraft item = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        item.isCorrect
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          item.isCorrect
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.isCorrect ? _success : _primary,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                Text(
                                  item.label,
                                  style: GoogleFonts.poppins(
                                    color: _text,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                if (item.isCorrect) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _success.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Kunci Jawaban',
                                      style: GoogleFonts.poppins(
                                        color: _success,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.explanation.isEmpty
                                  ? 'Belum ada penjelasan'
                                  : item.explanation,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                color: _muted,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit titik',
                        onPressed: () => _editHotspot(item),
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: _primary,
                          size: 19,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Hapus titik',
                        onPressed: () {
                          setState(() {
                            _hotspots.removeAt(index);
                          });
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: _danger,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ],
    );
  }

  Widget _buildDataEditor() {
    return _Section(
      title: 'Tabel Data & Pilihan Kesimpulan',
      subtitle:
          'Isi data tabel pengamatan sains dan buat pilihan kesimpulan analisa.',
      icon: Icons.analytics_rounded,
      children: <Widget>[
        TextFormField(
          controller: _dataTitleController,
          textCapitalization: TextCapitalization.sentences,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _text,
          ),
          decoration: _buildInputDecoration(
            labelText: 'Judul Data Pengamatan',
            hintText: 'Contoh: Hasil Uji Laju Reaksi',
          ),
          validator: _required,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _dataDescriptionController,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: _text),
          decoration: _buildInputDecoration(
            labelText: 'Keterangan Data (Opsional)',
            hintText: 'Pengantar atau parameter percobaan...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 14),

        // Headers Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Judul Kolom Tabel',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _headerOneController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _text,
                      ),
                      decoration: _buildInputDecoration(
                        labelText: 'Judul Kolom 1 (Kiri)',
                        hintText: 'Contoh: Suhu (°C)',
                      ),
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _headerTwoController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _text,
                      ),
                      decoration: _buildInputDecoration(
                        labelText: 'Judul Kolom 2 (Kanan)',
                        hintText: 'Contoh: Waktu (detik)',
                      ),
                      validator: _required,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Rows
        ..._tableRows.asMap().entries.map((entry) {
          final int index = entry.key;
          final _TableRowDraft row = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: row.firstController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: _text,
                    ),
                    decoration: _buildInputDecoration(
                      hintText: 'Nilai kolom 1',
                    ),
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: row.secondController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: _text,
                    ),
                    decoration: _buildInputDecoration(
                      hintText: 'Nilai kolom 2',
                    ),
                    validator: _required,
                  ),
                ),
                if (_tableRows.length > 2)
                  IconButton(
                    tooltip: 'Hapus baris',
                    onPressed: () {
                      setState(() {
                        final removed = _tableRows.removeAt(index);
                        removed.dispose();
                      });
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: _danger,
                      size: 20,
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _tableRows.add(_TableRowDraft());
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              side: const BorderSide(color: _primary, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 19),
            label: Text(
              'Tambah Baris Data',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Divider(height: 1, color: _border),
        const SizedBox(height: 16),

        Text(
          'Pilihan Kesimpulan Analisa',
          style: GoogleFonts.poppins(
            color: _text,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 10),
        ...List<Widget>.generate(4, (int index) {
          final String letter = String.fromCharCode(65 + index);
          final bool isSelected = _analysisCorrectChoice == letter;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? _primaryLight.withValues(alpha: 0.5)
                      : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? _primary : _border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      _analysisCorrectChoice = letter;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? _primary : Colors.white,
                      border: Border.all(
                        color: isSelected ? _primary : _muted,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : _text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _analysisOptionControllers[index],
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: _text,
                    ),
                    decoration: _buildInputDecoration(
                      hintText: 'Kesimpulan analisa $letter',
                    ),
                    validator: _required,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Kunci',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _success,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOptionalImage(String? resolvedImage) {
    final bool hasImage = _imagePath != null || resolvedImage != null;

    return _Section(
      title: 'Gambar Ilustrasi Soal (Opsional)',
      subtitle: 'Tambahkan gambar bantuan untuk memperjelas narasi soal.',
      icon: Icons.image_rounded,
      children: <Widget>[
        if (hasImage)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child:
                      _imagePath != null
                          ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                          : Image.network(
                            resolvedImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const _ImageError(),
                          ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    _CircleAction(
                      icon: Icons.edit_rounded,
                      onTap: _pickImage,
                    ),
                    const SizedBox(width: 6),
                    _CircleAction(
                      icon: Icons.delete_rounded,
                      onTap: () {
                        setState(() {
                          _imagePath = null;
                          _removeImage = true;
                        });
                      },
                      danger: true,
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          _ImagePickerPlaceholder(
            label: 'Pilih Gambar Ilustrasi Soal',
            onTap: _pickImage,
          ),
      ],
    );
  }

  void _setDefaultTypeValues() {
    if (_choiceControllers.every(
      (TextEditingController item) => item.text.trim().isEmpty,
    )) {
      _choiceControllers[0].text = 'Pilihan A';
      _choiceControllers[1].text = 'Pilihan B';
      _choiceControllers[2].text = 'Pilihan C';
      _choiceControllers[3].text = 'Pilihan D';
    }

    if (_matchingItems.isEmpty) {
      _matchingItems.addAll(<_MatchingDraft>[
        _MatchingDraft(),
        _MatchingDraft(),
      ]);
    }

    if (_orderingItems.isEmpty) {
      _orderingItems.addAll(<TextEditingController>[
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    }

    if (_tableRows.isEmpty) {
      _tableRows.addAll(<_TableRowDraft>[_TableRowDraft(), _TableRowDraft()]);
    }

    if (_analysisOptionControllers.every(
      (TextEditingController item) => item.text.trim().isEmpty,
    )) {
      _analysisOptionControllers[0].text = 'Kesimpulan A';
      _analysisOptionControllers[1].text = 'Kesimpulan B';
      _analysisOptionControllers[2].text = 'Kesimpulan C';
      _analysisOptionControllers[3].text = 'Kesimpulan D';
    }
  }

  void _loadTypeValues(
    Map<String, dynamic> content,
    Map<String, dynamic> answer,
  ) {
    switch (_type) {
      case 'true_false':
        _trueFalseAnswer = AdminLearningController.boolValue(
          answer['correct'],
          fallback: true,
        );
        break;

      case 'matching':
        for (final _MatchingDraft item in _matchingItems) {
          item.dispose();
        }
        _matchingItems.clear();

        final List<Map<String, dynamic>> left = _mapList(content['left']);
        final List<Map<String, dynamic>> right = _mapList(content['right']);
        final List<Map<String, dynamic>> pairs = _mapList(answer['pairs']);

        final Map<String, String> rightTextById = <String, String>{
          for (final Map<String, dynamic> item in right)
            item['id'].toString(): item['text']?.toString() ?? '',
        };

        final Map<String, String> rightIdByLeft = <String, String>{
          for (final Map<String, dynamic> pair in pairs)
            pair['left_id'].toString(): pair['right_id'].toString(),
        };

        for (final Map<String, dynamic> item in left) {
          final String leftId = item['id'].toString();
          final String rightId = rightIdByLeft[leftId] ?? '';

          _matchingItems.add(
            _MatchingDraft(
              left: item['text']?.toString() ?? '',
              right: rightTextById[rightId] ?? '',
            ),
          );
        }

        if (_matchingItems.length < 2) {
          _matchingItems.addAll(
            List<_MatchingDraft>.generate(
              2 - _matchingItems.length,
              (_) => _MatchingDraft(),
            ),
          );
        }
        break;

      case 'ordering':
        for (final TextEditingController item in _orderingItems) {
          item.dispose();
        }
        _orderingItems.clear();

        final List<Map<String, dynamic>> items = _mapList(content['items']);
        final List<dynamic> order =
            answer['order'] is List ? answer['order'] as List : <dynamic>[];

        final Map<String, String> textById = <String, String>{
          for (final Map<String, dynamic> item in items)
            item['id'].toString(): item['text']?.toString() ?? '',
        };

        final Iterable<String> ids =
            order.isNotEmpty
                ? order.map((dynamic item) => item.toString())
                : items.map(
                  (Map<String, dynamic> item) => item['id'].toString(),
                );

        for (final String id in ids) {
          _orderingItems.add(TextEditingController(text: textById[id] ?? ''));
        }

        while (_orderingItems.length < 2) {
          _orderingItems.add(TextEditingController());
        }
        break;

      case 'image_hotspot':
        _hotspots.clear();
        final String correctId = answer['hotspot_id']?.toString() ?? '';

        for (final Map<String, dynamic> item in _mapList(content['hotspots'])) {
          final String id =
              item['id']?.toString() ?? 'hotspot_${_hotspots.length + 1}';

          _hotspots.add(
            _HotspotDraft(
              id: id,
              label: item['label']?.toString() ?? 'Titik',
              explanation:
                  item['explanation']?.toString() ??
                  item['description']?.toString() ??
                  '',
              x: _coordinate(item['x']),
              y: _coordinate(item['y']),
              isCorrect: id == correctId,
            ),
          );
        }
        break;

      case 'data_interpretation':
        _dataTitleController.text =
            content['title']?.toString() ?? 'Data Pengamatan';
        _dataDescriptionController.text =
            content['description']?.toString() ?? '';

        final List<dynamic> headers =
            content['headers'] is List
                ? content['headers'] as List
                : <dynamic>[];

        if (headers.isNotEmpty) {
          _headerOneController.text = headers.first.toString();
        }
        if (headers.length > 1) {
          _headerTwoController.text = headers[1].toString();
        }

        for (final _TableRowDraft row in _tableRows) {
          row.dispose();
        }
        _tableRows.clear();

        final List<dynamic> rows =
            content['rows'] is List ? content['rows'] as List : <dynamic>[];

        for (final dynamic rawRow in rows) {
          if (rawRow is List) {
            _tableRows.add(
              _TableRowDraft(
                first: rawRow.isNotEmpty ? rawRow[0].toString() : '',
                second: rawRow.length > 1 ? rawRow[1].toString() : '',
              ),
            );
          }
        }

        while (_tableRows.length < 2) {
          _tableRows.add(_TableRowDraft());
        }

        final List<Map<String, dynamic>> analysisOptions = _mapList(
          content['options'],
        );

        for (int index = 0; index < 4; index++) {
          _analysisOptionControllers[index].text =
              index < analysisOptions.length
                  ? analysisOptions[index]['text']?.toString() ?? ''
                  : '';
        }

        _analysisCorrectChoice = answer['correct']?.toString() ?? 'A';
        break;

      case 'multiple_choice':
      default:
        final List<Map<String, dynamic>> options = _mapList(content['options']);

        for (int index = 0; index < 4; index++) {
          _choiceControllers[index].text =
              index < options.length
                  ? options[index]['text']?.toString() ?? ''
                  : '';
        }

        _correctChoice = answer['correct']?.toString() ?? 'A';
    }

    _setDefaultTypeValues();
  }

  Future<void> _pickImage() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    final String? path = result?.files.single.path;
    if (path == null) {
      return;
    }

    setState(() {
      _imagePath = path;
      _removeImage = false;

      if (_type == 'image_hotspot') {
        _hotspots.clear();
      }
    });
  }

  Future<void> _createHotspot(Offset position, Size size) async {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final _HotspotDraft draft = _HotspotDraft(
      id: 'hotspot_${DateTime.now().microsecondsSinceEpoch}',
      label: 'Titik ${_hotspots.length + 1}',
      explanation: '',
      x: (position.dx / size.width).clamp(0.0, 1.0),
      y: (position.dy / size.height).clamp(0.0, 1.0),
      isCorrect: _hotspots.isEmpty,
    );

    final bool saved = await _showHotspotDialog(draft);
    if (!saved || !mounted) {
      return;
    }

    setState(() {
      if (draft.isCorrect) {
        for (final _HotspotDraft item in _hotspots) {
          item.isCorrect = false;
        }
      }
      _hotspots.add(draft);
    });
  }

  Future<void> _editHotspot(_HotspotDraft hotspot) async {
    final _HotspotDraft edited = hotspot.copy();
    final bool saved = await _showHotspotDialog(edited);

    if (!saved || !mounted) {
      return;
    }

    setState(() {
      if (edited.isCorrect) {
        for (final _HotspotDraft item in _hotspots) {
          item.isCorrect = false;
        }
      }

      final int index = _hotspots.indexOf(hotspot);
      if (index >= 0) {
        _hotspots[index] = edited;
      }
    });
  }

  Future<bool> _showHotspotDialog(_HotspotDraft hotspot) async {
    final TextEditingController labelController = TextEditingController(
      text: hotspot.label,
    );
    final TextEditingController explanationController = TextEditingController(
      text: hotspot.explanation,
    );

    bool correct = hotspot.isCorrect;
    String? validation;

    final bool result =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext sheetContext) {
            return StatefulBuilder(
              builder: (
                BuildContext context,
                void Function(void Function()) setSheetState,
              ) {
                return AnimatedPadding(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Container(
                              width: 40,
                              height: 4.5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBD5E1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: _primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.touch_app_rounded,
                                  color: _primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Atur Titik Hotspot',
                                style: GoogleFonts.poppins(
                                  color: _text,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tentukan nama bagian dan apakah titik ini merupakan kunci jawaban.',
                            style: GoogleFonts.plusJakartaSans(
                              color: _muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: labelController,
                            autofocus: true,
                            textCapitalization: TextCapitalization.sentences,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _text,
                            ),
                            decoration: _buildInputDecoration(
                              labelText: 'Nama Bagian / Komponen',
                              hintText: 'Contoh: Mitokondria',
                              prefixIcon: Icons.label_important_outline_rounded,
                              errorText: validation,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: explanationController,
                            minLines: 2,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: _text,
                            ),
                            decoration: _buildInputDecoration(
                              labelText: 'Penjelasan saat Titik Dipilih',
                              hintText:
                                  'Jelaskan fungsi atau fakta bagian ini...',
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  correct
                                      ? _success.withValues(alpha: 0.08)
                                      : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: correct ? _success : _border,
                              ),
                            ),
                            child: SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              activeTrackColor: _success,
                              title: Text(
                                'Jadikan Kunci Jawaban Benar',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: correct ? _success : _text,
                                ),
                              ),
                              subtitle: Text(
                                'Siswa harus menunjuk titik ini untuk mendapatkan skor.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: _muted,
                                ),
                              ),
                              value: correct,
                              onChanged: (bool value) {
                                setSheetState(() {
                                  correct = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _text,
                                    side: const BorderSide(color: _border),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Batal',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final String label =
                                        labelController.text.trim();
                                    if (label.isEmpty) {
                                      setSheetState(() {
                                        validation =
                                            'Nama bagian wajib diisi.';
                                      });
                                      return;
                                    }

                                    hotspot.label = label;
                                    hotspot.explanation =
                                        explanationController.text.trim();
                                    hotspot.isCorrect = correct;

                                    Navigator.of(context).pop(true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check_rounded, size: 18),
                                  label: Text(
                                    'Simpan Titik',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ) ??
        false;

    labelController.dispose();
    explanationController.dispose();
    return result;
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi.';
    }
    return null;
  }

  String? _validateTypeSpecific() {
    if (_type == 'image_hotspot') {
      final bool hasImage =
          _imagePath != null || (_existingImageUrl.isNotEmpty && !_removeImage);

      if (!hasImage) {
        return 'Pilih gambar untuk checkpoint hotspot.';
      }
      if (_hotspots.length < 2) {
        return 'Tambahkan minimal dua titik pada gambar.';
      }
      if (!_hotspots.any((_HotspotDraft item) => item.isCorrect)) {
        return 'Tentukan satu titik sebagai jawaban benar.';
      }
    }
    return null;
  }

  Map<String, dynamic> _buildContent() {
    switch (_type) {
      case 'true_false':
        return <String, dynamic>{};

      case 'matching':
        return <String, dynamic>{
          'left':
              _matchingItems
                  .asMap()
                  .entries
                  .map(
                    (entry) => <String, dynamic>{
                      'id': 'left_${entry.key + 1}',
                      'text': entry.value.leftController.text.trim(),
                    },
                  )
                  .toList(),
          'right':
              _matchingItems
                  .asMap()
                  .entries
                  .map(
                    (entry) => <String, dynamic>{
                      'id': 'right_${entry.key + 1}',
                      'text': entry.value.rightController.text.trim(),
                    },
                  )
                  .toList(),
        };

      case 'ordering':
        return <String, dynamic>{
          'items':
              _orderingItems
                  .asMap()
                  .entries
                  .map(
                    (entry) => <String, dynamic>{
                      'id': 'item_${entry.key + 1}',
                      'text': entry.value.text.trim(),
                    },
                  )
                  .toList(),
        };

      case 'image_hotspot':
        return <String, dynamic>{
          'hotspots':
              _hotspots
                  .map(
                    (_HotspotDraft item) => <String, dynamic>{
                      'id': item.id,
                      'label': item.label,
                      'explanation': item.explanation,
                      'x': item.x,
                      'y': item.y,
                    },
                  )
                  .toList(),
        };

      case 'data_interpretation':
        return <String, dynamic>{
          'title': _dataTitleController.text.trim(),
          'description': _dataDescriptionController.text.trim(),
          'headers': <String>[
            _headerOneController.text.trim(),
            _headerTwoController.text.trim(),
          ],
          'rows':
              _tableRows
                  .map(
                    (_TableRowDraft row) => <String>[
                      row.firstController.text.trim(),
                      row.secondController.text.trim(),
                    ],
                  )
                  .toList(),
          'options': List<Map<String, dynamic>>.generate(
            4,
            (int index) => <String, dynamic>{
              'id': String.fromCharCode(65 + index),
              'text': _analysisOptionControllers[index].text.trim(),
            },
          ),
        };

      case 'multiple_choice':
      default:
        return <String, dynamic>{
          'options': List<Map<String, dynamic>>.generate(
            4,
            (int index) => <String, dynamic>{
              'id': String.fromCharCode(65 + index),
              'text': _choiceControllers[index].text.trim(),
            },
          ),
        };
    }
  }

  Map<String, dynamic> _buildAnswer() {
    switch (_type) {
      case 'true_false':
        return <String, dynamic>{'correct': _trueFalseAnswer};

      case 'matching':
        return <String, dynamic>{
          'pairs': List<Map<String, dynamic>>.generate(
            _matchingItems.length,
            (int index) => <String, dynamic>{
              'left_id': 'left_${index + 1}',
              'right_id': 'right_${index + 1}',
            },
          ),
        };

      case 'ordering':
        return <String, dynamic>{
          'order': List<String>.generate(
            _orderingItems.length,
            (int index) => 'item_${index + 1}',
          ),
        };

      case 'image_hotspot':
        final _HotspotDraft correct = _hotspots.firstWhere(
          (_HotspotDraft item) => item.isCorrect,
        );
        return <String, dynamic>{'hotspot_id': correct.id};

      case 'data_interpretation':
        return <String, dynamic>{'correct': _analysisCorrectChoice};

      case 'multiple_choice':
      default:
        return <String, dynamic>{'correct': _correctChoice};
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppSnackbar.warning(
        'Form Belum Lengkap',
        'Mohon periksa dan lengkapi data wajib checkpoint.',
      );
      return;
    }

    final String? typeError = _validateTypeSpecific();
    if (typeError != null) {
      AppSnackbar.warning('Format Tipe Belum Valid', typeError);
      return;
    }

    final bool success = await controller.saveCheckpoint(
      checkpointId:
          widget.checkpoint == null
              ? null
              : AdminLearningController.intValue(widget.checkpoint!['id']),
      submaterialId: widget.submaterialId,
      imagePath: _imagePath,
      data: <String, dynamic>{
        'checkpoint_type': _type,
        'title': _titleController.text.trim(),
        'instruction': _instructionController.text.trim(),
        'question_text': _questionController.text.trim(),
        'content': _buildContent(),
        'answer': _buildAnswer(),
        'correct_feedback': _correctFeedbackController.text.trim(),
        'wrong_feedback': _wrongFeedbackController.text.trim(),
        'order_index': int.parse(_orderController.text),
        'is_required': _isRequired,
        if (_removeImage && _imagePath == null) 'image_url': '',
      },
    );

    if (success) {
      Get.back<bool>(result: true);
      AppSnackbar.success(
        widget.checkpoint != null
            ? 'Checkpoint Diperbarui'
            : 'Checkpoint Ditambahkan',
        widget.checkpoint != null
            ? 'Perubahan data checkpoint berhasil disimpan.'
            : 'Checkpoint interaktif baru berhasil ditambahkan.',
      );
    }
  }

  static List<Map<String, dynamic>> _mapList(dynamic raw) {
    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }
    return raw
        .whereType<Map>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static double _coordinate(dynamic raw) {
    final double value = double.tryParse(raw?.toString() ?? '') ?? 0.5;
    return (value > 1 ? value / 100 : value).clamp(0.0, 1.0);
  }
}

// =============================================================================
// DRAFT MODELS
// =============================================================================
class _MatchingDraft {
  _MatchingDraft({String left = '', String right = ''})
    : leftController = TextEditingController(text: left),
      rightController = TextEditingController(text: right);

  final TextEditingController leftController;
  final TextEditingController rightController;

  void dispose() {
    leftController.dispose();
    rightController.dispose();
  }
}

class _TableRowDraft {
  _TableRowDraft({String first = '', String second = ''})
    : firstController = TextEditingController(text: first),
      secondController = TextEditingController(text: second);

  final TextEditingController firstController;
  final TextEditingController secondController;

  void dispose() {
    firstController.dispose();
    secondController.dispose();
  }
}

class _HotspotDraft {
  _HotspotDraft({
    required this.id,
    required this.label,
    required this.explanation,
    required this.x,
    required this.y,
    required this.isCorrect,
  });

  String id;
  String label;
  String explanation;
  double x;
  double y;
  bool isCorrect;

  _HotspotDraft copy() {
    return _HotspotDraft(
      id: id,
      label: label,
      explanation: explanation,
      x: x,
      y: y,
      isCorrect: isCorrect,
    );
  }
}

// =============================================================================
// HELPER METADATA & BANNERS
// =============================================================================
class _TypeMeta {
  const _TypeMeta({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

const _TypeMeta _defaultMeta = _TypeMeta(
  icon: Icons.checklist_rounded,
  label: 'Pilihan Ganda',
);

const Map<String, _TypeMeta> _typeMeta = {
  'multiple_choice': _TypeMeta(
    icon: Icons.checklist_rounded,
    label: 'Pilihan Ganda',
  ),
  'true_false': _TypeMeta(icon: Icons.rule_rounded, label: 'Benar / Salah'),
  'matching': _TypeMeta(icon: Icons.join_inner_rounded, label: 'Pasangkan'),
  'ordering': _TypeMeta(
    icon: Icons.format_list_numbered_rounded,
    label: 'Urutkan',
  ),
  'image_hotspot': _TypeMeta(
    icon: Icons.touch_app_rounded,
    label: 'Tunjuk Bagian',
  ),
  'data_interpretation': _TypeMeta(
    icon: Icons.analytics_rounded,
    label: 'Analisis Data',
  ),
};

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: _primaryLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.auto_awesome_rounded, color: _primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _typeHelp(type),
              style: GoogleFonts.plusJakartaSans(
                color: _text,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _typeHelp(String type) {
  switch (type) {
    case 'true_false':
      return 'Guru menulis pernyataan dan memilih kunci Benar atau Salah.';
    case 'matching':
      return 'Tulis pasangan konsep yang benar. Sistem akan mengacak sisi kanan untuk siswa.';
    case 'ordering':
      return 'Tulis langkah dalam urutan yang benar. Sistem akan mengacaknya saat tes.';
    case 'image_hotspot':
      return 'Unggah ilustrasi, ketuk titik penting, lalu tandai satu titik sebagai jawaban benar.';
    case 'data_interpretation':
      return 'Isi tabel data pengamatan dan sediakan pilihan kesimpulan analisa yang benar.';
    default:
      return 'Isi empat opsi pilihan dan tandai satu kunci jawaban yang benar.';
  }
}

// =============================================================================
// HEADER & LIST CARDS
// =============================================================================
class _Header extends StatelessWidget {
  const _Header({required this.title, required this.checkpointCount});

  final String title;
  final int checkpointCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[_primaryDark, _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'CHECKPOINT INTERAKTIF',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$checkpointCount Soal',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _primaryDark,
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
          const SizedBox(height: 4),
          Text(
            'Uji pemahaman langsung siswa sebelum melanjutkan ke materi berikutnya.',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFE9D5FF),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckpointCard extends StatelessWidget {
  const _CheckpointCard({
    required this.index,
    required this.checkpoint,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final Map<String, dynamic> checkpoint;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final type = checkpoint['checkpoint_type']?.toString() ?? 'multiple_choice';
    final meta = _typeMeta[type] ?? _defaultMeta;
    final isReq = AdminLearningController.boolValue(
      checkpoint['is_required'],
      fallback: true,
    );

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
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primaryDark, _primary],
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${checkpoint['order_index'] ?? index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(meta.icon, size: 13, color: _primary),
                    const SizedBox(width: 4),
                    Text(
                      meta.label,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isReq) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Wajib',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _amber,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: _muted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (String value) {
                  if (value == 'edit') {
                    onEdit();
                  } else {
                    onDelete();
                  }
                },
                itemBuilder:
                    (_) => [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: _primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Edit',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: _danger,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hapus',
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
          const SizedBox(height: 10),
          Text(
            checkpoint['title']?.toString() ?? 'Checkpoint',
            style: GoogleFonts.poppins(
              color: _text,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            checkpoint['question_text']?.toString() ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: _muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION CARD WRAPPER
// =============================================================================
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    this.subtitle,
    this.icon,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _primary, size: 18),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.plusJakartaSans(
                          color: _muted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// =============================================================================
// HELPER PLACEHOLDERS & ACTIONS
// =============================================================================
class _ImagePickerPlaceholder extends StatelessWidget {
  const _ImagePickerPlaceholder({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 32,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: _text,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Klik untuk mengunggah gambar dari perangkat',
                style: GoogleFonts.plusJakartaSans(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image_rounded, color: _muted, size: 28),
          const SizedBox(height: 6),
          Text(
            'Gambar tidak dapat dimuat',
            style: GoogleFonts.plusJakartaSans(color: _muted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: danger ? _danger : Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: danger ? Colors.white : _text),
        ),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          color: _muted,
          fontSize: 12,
          height: 1.45,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_outlined,
              size: 48,
              color: _primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Checkpoint',
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tambahkan soal checkpoint pertama untuk menguji pemahaman konsep siswa pada submateri ini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: _muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_task_rounded, size: 18),
            label: Text(
              'Tambah Checkpoint Baru',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<Map<String, dynamic>> _fallbackTypes = <Map<String, dynamic>>[
  {'value': 'multiple_choice', 'label': 'Pilihan Ganda'},
  {'value': 'true_false', 'label': 'Benar / Salah'},
  {'value': 'matching', 'label': 'Pasangkan'},
  {'value': 'ordering', 'label': 'Urutkan'},
  {'value': 'image_hotspot', 'label': 'Tunjuk Bagian'},
  {'value': 'data_interpretation', 'label': 'Analisis Data'},
];
