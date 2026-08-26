import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_learning_controller.dart';

const Color _primary = Color(0xFF2563EB);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _background = Color(0xFFF5F8FF);

class AdminQuizManagerView extends StatefulWidget {
  const AdminQuizManagerView({
    super.key,
    required this.module,
  });

  final Map<String, dynamic> module;

  @override
  State<AdminQuizManagerView> createState() =>
      _AdminQuizManagerViewState();
}

class _AdminQuizManagerViewState
    extends State<AdminQuizManagerView> {
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
      (_) => controller.loadQuestions(materialId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Kelola Kuis'),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () => Get.to<bool>(
          () => AdminQuestionFormView(
            materialId: materialId,
          ),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Soal',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            controller.loadQuestions(materialId),
        child: Obx(() {
          if (controller.isLoadingQuestions.value &&
              controller.questions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              110,
            ),
            children: <Widget>[
              _QuizHeader(
                title:
                    widget.module['title']?.toString() ??
                        'Modul',
              ),
              const SizedBox(height: 14),
              if (controller.questions.isEmpty)
                const _EmptyQuiz()
              else
                ...controller.questions
                    .asMap()
                    .entries
                    .map(
                  (entry) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12),
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
                          controller.deleteQuestion(
                        entry.value,
                        materialId,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

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
  State<AdminQuestionFormView> createState() =>
      _AdminQuestionFormViewState();
}

class _AdminQuestionFormViewState
    extends State<AdminQuestionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _questionController =
      TextEditingController();
  final _explanationController =
      TextEditingController();
  final List<TextEditingController>
      _options =
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

    _questionController.text =
        data['question_text']?.toString() ?? '';
    _explanationController.text =
        data['explanation']?.toString() ?? '';
    _type =
        data['question_type']?.toString() ??
            'pemahaman';
    _answer =
        data['correct_answer']?.toString() ?? 'A';
    _options[0].text =
        data['option_a']?.toString() ?? '';
    _options[1].text =
        data['option_b']?.toString() ?? '';
    _options[2].text =
        data['option_c']?.toString() ?? '';
    _options[3].text =
        data['option_d']?.toString() ?? '';
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
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit Soal'
              : 'Tambah Soal',
        ),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            110,
          ),
          children: <Widget>[
            _Section(
              title: 'Pertanyaan',
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Tipe soal',
                  ),
                  items: const <
                      DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'pemahaman',
                      child: Text('Pemahaman'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'konsep',
                      child: Text('Konsep'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'studi_kasus',
                      child: Text('Studi Kasus'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _type = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _questionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Pertanyaan',
                    alignLabelWithHint: true,
                  ),
                  validator: _required,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'Pilihan Jawaban',
              children: <Widget>[
                ...List<Widget>.generate(
                  4,
                  (index) {
                    final label =
                        String.fromCharCode(
                      65 + index,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: TextFormField(
                        controller: _options[index],
                        decoration: InputDecoration(
                          labelText: 'Opsi $label',
                        ),
                        validator: _required,
                      ),
                    );
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _answer,
                  decoration: const InputDecoration(
                    labelText: 'Jawaban benar',
                  ),
                  items: const <String>[
                    'A',
                    'B',
                    'C',
                    'D',
                  ].map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text('Opsi $item'),
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
            const SizedBox(height: 14),
            _Section(
              title: 'Pembahasan',
              children: <Widget>[
                TextFormField(
                  controller:
                      _explanationController,
                  minLines: 5,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText:
                        'Penjelasan jawaban',
                    hintText:
                        'Jelaskan mengapa jawaban ini benar.',
                    alignLabelWithHint: true,
                  ),
                  validator: _required,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Obx(
            () => FilledButton.icon(
              onPressed:
                  controller.isSavingQuestion.value
                      ? null
                      : _save,
              icon: controller
                      .isSavingQuestion.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                widget.isEditing
                    ? 'Simpan Perubahan'
                    : 'Buat Soal',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi.';
    }

    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ??
        false)) {
      return;
    }

    final success =
        await controller.saveQuestion(
      questionId: widget.question == null
          ? null
          : AdminLearningController.intValue(
              widget.question!['id'],
            ),
      materialId: widget.materialId,
      data: <String, dynamic>{
        'question_text':
            _questionController.text.trim(),
        'question_type': _type,
        'option_a': _options[0].text.trim(),
        'option_b': _options[1].text.trim(),
        'option_c': _options[2].text.trim(),
        'option_d': _options[3].text.trim(),
        'correct_answer': _answer,
        'explanation':
            _explanationController.text.trim(),
      },
    );

    if (success) {
      Get.back<bool>(result: true);
    }
  }
}

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'KUIS MODUL',
            style: TextStyle(
              color: Color(0xFFBFDBFE),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Nilai minimal kelulusan tetap 75.',
            style: TextStyle(
              color: Color(0xFFDBEAFE),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final answer =
        question['correct_answer']?.toString() ??
            '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  question['question_text']
                          ?.toString() ??
                      '',
                  style: const TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w900,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_typeLabel(question['question_type']?.toString() ?? '')} • Kunci $answer',
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (question['explanation']
                        ?.toString()
                        .trim()
                        .isNotEmpty ==
                    true) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    question['explanation']
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
              } else {
                onDelete();
              }
            },
            itemBuilder: (_) =>
                const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Hapus'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }
}

class _EmptyQuiz extends StatelessWidget {
  const _EmptyQuiz();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(35),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.quiz_outlined,
            size: 60,
            color: _muted,
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada soal kuis',
            style: TextStyle(
              color: _text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

String _typeLabel(String type) {
  switch (type) {
    case 'konsep':
      return 'Konsep';
    case 'studi_kasus':
      return 'Studi Kasus';
    default:
      return 'Pemahaman';
  }
}
