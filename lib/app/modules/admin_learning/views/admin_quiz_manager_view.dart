import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/app_snackbar.dart';
import '../controllers/admin_learning_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _indigoQuiz = Color(0xFF6366F1);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _success = Color(0xFF10B981);
const Color _danger = Color(0xFFEF4444);

// =============================================================================
// 1. ADMIN QUIZ MANAGER VIEW
// =============================================================================
class AdminQuizManagerView extends StatefulWidget {
  const AdminQuizManagerView({
    super.key,
    required this.module,
  });

  final Map<String, dynamic> module;

  @override
  State<AdminQuizManagerView> createState() => _AdminQuizManagerViewState();
}

class _AdminQuizManagerViewState extends State<AdminQuizManagerView> {
  AdminLearningController get controller =>
      Get.find<AdminLearningController>();

  int get materialId =>
      AdminLearningController.intValue(widget.module['id']);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.loadQuestions(materialId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String moduleTitle =
        widget.module['title']?.toString() ?? 'Modul Pembelajaran';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          'Kelola Bank Soal Kuis',
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
            tooltip: 'Muat ulang data',
            onPressed: () => controller.loadQuestions(materialId),
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
        onPressed: () => Get.to<bool>(
          () => AdminQuestionFormView(materialId: materialId),
        ),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Tambah Soal',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _primaryBlue,
        backgroundColor: Colors.white,
        onRefresh: () => controller.loadQuestions(materialId),
        child: Obx(() {
          if (controller.isLoadingQuestions.value &&
              controller.questions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _primaryBlue,
              ),
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
            children: <Widget>[
              // 1. Hero Header Card
              _QuizHeader(
                title: moduleTitle,
                totalQuestions: controller.questions.length,
              ),
              const SizedBox(height: 16),

              // 2. Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Pertanyaan Kuis',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    '${controller.questions.length} Soal Terdaftar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Question List or Empty State
              if (controller.questions.isEmpty)
                const _EmptyQuiz()
              else
                ...controller.questions.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _QuestionCard(
                          number: entry.key + 1,
                          question: entry.value,
                          onEdit: () => Get.to<bool>(
                            () => AdminQuestionFormView(
                              materialId: materialId,
                              question: entry.value,
                            ),
                          ),
                          onDelete: () =>
                              _confirmDeleteQuestion(entry.value),
                        ),
                      ),
                    ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _confirmDeleteQuestion(Map<String, dynamic> question) async {
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
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: _danger,
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Hapus Soal Kuis?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pertanyaan beserta pilihan jawaban dan pembahasan akan dihapus dari modul ini.',
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
      await controller.deleteQuestion(question, materialId);
    }
  }
}

// =============================================================================
// 2. ADMIN QUESTION FORM VIEW (TAMBAH / EDIT SOAL)
// =============================================================================
class AdminQuestionFormView extends StatefulWidget {
  const AdminQuestionFormView({
    super.key,
    required this.materialId,
    this.question,
  });

  final int materialId;
  final Map<String, dynamic>? question;

  bool get isEditing => question != null;

  @override
  State<AdminQuestionFormView> createState() => _AdminQuestionFormViewState();
}

class _AdminQuestionFormViewState extends State<AdminQuestionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  final List<TextEditingController> _options =
      List<TextEditingController>.generate(
    4,
    (_) => TextEditingController(),
  );

  String _type = 'pemahaman';
  String _answer = 'A';

  AdminLearningController get controller =>
      Get.find<AdminLearningController>();

  @override
  void initState() {
    super.initState();

    final data = widget.question;
    if (data == null) return;

    _questionController.text = data['question_text']?.toString() ?? '';
    _explanationController.text = data['explanation']?.toString() ?? '';
    _type = data['question_type']?.toString() ?? 'pemahaman';
    _answer = data['correct_answer']?.toString() ?? 'A';
    _options[0].text = data['option_a']?.toString() ?? '';
    _options[1].text = data['option_b']?.toString() ?? '';
    _options[2].text = data['option_c']?.toString() ?? '';
    _options[3].text = data['option_d']?.toString() ?? '';
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (final option in _options) {
      option.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Soal Kuis' : 'Tambah Soal Kuis',
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
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
          children: <Widget>[
            // 1. Naskah Pertanyaan & Tipe Soal
            _FormSection(
              title: 'Pertanyaan & Karakteristik Soal',
              subtitle: 'Tentukan tipe kognitif soal dan tuliskan pertanyaan.',
              icon: Icons.quiz_outlined,
              children: <Widget>[
                Text(
                  'Tipe Soal',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                  decoration: _buildInputDecoration(
                    prefixIcon: Icons.category_outlined,
                  ),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'pemahaman',
                      child: Text('Pemahaman Dasar'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'konsep',
                      child: Text('Penguasaan Konsep'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'studi_kasus',
                      child: Text('Studi Kasus & Analisis'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _type = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Teks Pertanyaan',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _questionController,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: _textDark,
                    height: 1.45,
                  ),
                  decoration: _buildInputDecoration(
                    hintText: 'Tuliskan pertanyaan kuis di sini...',
                  ),
                  validator: _required,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2. Pilihan Jawaban (Opsi A - D) & Kunci
            _FormSection(
              title: 'Pilihan Jawaban & Kunci',
              subtitle: 'Masukkan 4 opsi jawaban dan tentukan kunci yang benar.',
              icon: Icons.checklist_rounded,
              children: <Widget>[
                ...List<Widget>.generate(
                  4,
                  (index) {
                    final label = String.fromCharCode(65 + index);
                    final isCorrect = _answer == label;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? _success
                                      : _primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: GoogleFonts.poppins(
                                      color:
                                          isCorrect ? Colors.white : _primaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pilihan $label ${isCorrect ? '(Kunci Jawaban)' : ''}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isCorrect ? _success : _textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _options[index],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: _textDark,
                            ),
                            decoration: _buildInputDecoration(
                              hintText: 'Isi teks untuk pilihan $label...',
                            ),
                            validator: _required,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'Kunci Jawaban yang Benar',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _answer,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _success,
                  ),
                  decoration: _buildInputDecoration(
                    prefixIcon: Icons.check_circle_outline_rounded,
                  ),
                  items: const <String>['A', 'B', 'C', 'D'].map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text('Kunci: Pilihan $item'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _answer = value);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. Pembahasan Jawaban
            _FormSection(
              title: 'Pembahasan & Penjelasan',
              subtitle: 'Jelaskan konsep sains di balik jawaban yang benar.',
              icon: Icons.lightbulb_outline_rounded,
              children: <Widget>[
                Text(
                  'Teks Penjelasan Pembahasan',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _explanationController,
                  minLines: 4,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _textDark,
                    height: 1.45,
                  ),
                  decoration: _buildInputDecoration(
                    hintText:
                        'Tuliskan penjelasan ilmiah mengapa kunci jawaban tersebut benar...',
                  ),
                  validator: _required,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: _border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: controller.isSavingQuestion.value ? null : _save,
                icon: controller.isSavingQuestion.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(
                  controller.isSavingQuestion.value
                      ? 'Menyimpan Soal...'
                      : (widget.isEditing
                          ? 'Simpan Perubahan Soal'
                          : 'Buat Soal Kuis'),
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
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

  InputDecoration _buildInputDecoration({
    String? hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        color: _textMuted.withValues(alpha: 0.7),
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: _primaryBlue, size: 20)
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppSnackbar.warning(
        'Form Belum Lengkap',
        'Mohon periksa dan lengkapi teks pertanyaan serta pilihan opsi.',
      );
      return;
    }

    final success = await controller.saveQuestion(
      questionId: widget.question == null
          ? null
          : AdminLearningController.intValue(widget.question!['id']),
      materialId: widget.materialId,
      data: <String, dynamic>{
        'question_text': _questionController.text.trim(),
        'question_type': _type,
        'option_a': _options[0].text.trim(),
        'option_b': _options[1].text.trim(),
        'option_c': _options[2].text.trim(),
        'option_d': _options[3].text.trim(),
        'correct_answer': _answer,
        'explanation': _explanationController.text.trim(),
      },
    );

    if (success) {
      Get.back<bool>(result: true);
      AppSnackbar.success(
        widget.question != null ? 'Soal Diperbarui' : 'Soal Ditambahkan',
        widget.question != null
            ? 'Perubahan soal kuis berhasil disimpan.'
            : 'Soal kuis baru berhasil ditambahkan.',
      );
    }
  }
}

// =============================================================================
// HERO HEADER QUIZ
// =============================================================================
class _QuizHeader extends StatelessWidget {
  const _QuizHeader({
    required this.title,
    required this.totalQuestions,
  });

  final String title;
  final int totalQuestions;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                    const Icon(Icons.quiz_rounded,
                        size: 13, color: Color(0xFFBFDBFE)),
                    const SizedBox(width: 4),
                    Text(
                      'Evaluasi Akhir Modul',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'Passing Grade: 75',
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
              fontSize: 17.5,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelola bank soal pilihan ganda A–D beserta kunci dan pembahasannya.',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFDCE9FF),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// QUESTION CARD
// =============================================================================
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  final int number;
  final Map<String, dynamic> question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final answer = question['correct_answer']?.toString() ?? '-';
    final questionText = question['question_text']?.toString() ?? '';
    final type = question['question_type']?.toString() ?? '';
    final explanation =
        question['explanation']?.toString().trim() ?? '';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
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
                      fontSize: 13.5,
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
                      questionText,
                      style: GoogleFonts.plusJakartaSans(
                        color: _textDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _BadgeTag(
                          text: _typeLabel(type),
                          color: _indigoQuiz,
                          bgColor: const Color(0xFFEEF2FF),
                        ),
                        _BadgeTag(
                          text: 'Kunci: Pilihan $answer',
                          color: _success,
                          bgColor: const Color(0xFFECFDF5),
                        ),
                      ],
                    ),
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
                  } else {
                    onDelete();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined,
                            size: 18, color: _primaryBlue),
                        const SizedBox(width: 10),
                        Text(
                          'Edit Soal',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded,
                            size: 18, color: _danger),
                        const SizedBox(width: 10),
                        Text(
                          'Hapus Soal',
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
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: _primaryBlue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pembahasan: $explanation',
                      style: GoogleFonts.plusJakartaSans(
                        color: _textMuted,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeTag extends StatelessWidget {
  const _BadgeTag({
    required this.text,
    required this.color,
    required this.bgColor,
  });

  final String text;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// =============================================================================
// FORM SECTION
// =============================================================================
class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
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
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                child: Icon(icon, color: _primaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
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
                      subtitle,
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
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// =============================================================================
// EMPTY QUIZ STATE
// =============================================================================
class _EmptyQuiz extends StatelessWidget {
  const _EmptyQuiz();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
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
                Icons.quiz_outlined,
                size: 34,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Soal Kuis',
              style: GoogleFonts.poppins(
                color: _textDark,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tambahkan soal pilihan ganda A–D beserta kunci dan pembahasan untuk menguji pemahaman siswa.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: _textMuted,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _typeLabel(String type) {
  switch (type) {
    case 'konsep':
      return 'Penguasaan Konsep';
    case 'studi_kasus':
      return 'Studi Kasus';
    default:
      return 'Pemahaman Dasar';
  }
}
