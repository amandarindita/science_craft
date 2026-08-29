import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/science_shimmer.dart';
import '../controllers/learning_controller.dart';

const Color _quizPrimary = Color(0xFF2563EB);
const Color _quizDark = Color(0xFF0F172A);
const Color _quizMuted = Color(0xFF64748B);
const Color _quizBackground = Color(0xFFF8FAFC);
const Color _quizSuccess = Color(0xFF16A34A);
const Color _quizDanger = Color(0xFFDC2626);
const Color _quizBorder = Color(0xFFE2E8F0);

class LearningQuizView extends StatefulWidget {
  const LearningQuizView({
    super.key,
    required this.materialId,
    required this.moduleTitle,
  });

  final int materialId;
  final String moduleTitle;

  @override
  State<LearningQuizView> createState() => _LearningQuizViewState();
}

class _LearningQuizViewState extends State<LearningQuizView> {
  final PageController _pageController = PageController();

  final Map<int, String> _answers = <int, String>{};
  final Set<int> _doubtfulQuestionIds = <int>{};

  int _currentIndex = 0;

  LearningController get _controller => Get.find<LearningController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller.clearQuizSession();
      await _controller.loadQuiz(widget.materialId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoadingQuiz.value &&
          _controller.activeQuiz.value == null) {
        return Scaffold(
          backgroundColor: _quizBackground,
          appBar: AppBar(
            title: Text(
              'Kuis Evaluasi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _quizDark,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            shape: const Border(
              bottom: BorderSide(color: _quizBorder, width: 1),
            ),
          ),
          body: const QuizPageShimmer(),
        );
      }

      final result = _controller.quizResult.value;
      if (result != null) {
        return Scaffold(
          backgroundColor: _quizBackground,
          appBar: AppBar(
            title: Text(
              'Hasil Kuis Evaluasi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _quizDark,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            shape: const Border(
              bottom: BorderSide(color: _quizBorder, width: 1),
            ),
          ),
          body: _QuizResultView(
            result: result,
            quiz: _controller.activeQuiz.value,
            onRetry: _retryQuiz,
            onFinish: () => Get.back<void>(),
          ),
        );
      }

      final quiz = _controller.activeQuiz.value;
      if (quiz == null) {
        return Scaffold(
          backgroundColor: _quizBackground,
          appBar: AppBar(
            title: const Text('Kuis Evaluasi'),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: _QuizEmptyState(
            onRetry: () => _controller.loadQuiz(widget.materialId),
          ),
        );
      }

      final questions = LearningController.mapList(quiz['questions']);
      if (questions.isEmpty) {
        return Scaffold(
          backgroundColor: _quizBackground,
          appBar: AppBar(
            title: const Text('Kuis Evaluasi'),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: _QuizEmptyState(
            onRetry: () => _controller.loadQuiz(widget.materialId),
          ),
        );
      }

      final double progress = (_currentIndex + 1) / questions.length;
      final int answeredCount = _answers.length;

      return Scaffold(
        backgroundColor: _quizBackground,
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: Colors.white,
          foregroundColor: _quizDark,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kuis Evaluasi Modul',
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: _quizDark,
                ),
              ),
              Text(
                widget.moduleTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: _quizMuted,
                ),
              ),
            ],
          ),
          actions: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openQuestionGridSheet(questions),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.grid_view_rounded,
                      size: 16,
                      color: _quizPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$answeredCount/${questions.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _quizPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(_quizPrimary),
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final int questionId = LearningController.intValue(
                    question['id'],
                  );

                  return _QuestionPage(
                    question: question,
                    questionNumber: index + 1,
                    totalQuestions: questions.length,
                    selectedAnswer: _answers[questionId],
                    isDoubtful: _doubtfulQuestionIds.contains(questionId),
                    onSelect: (answer) {
                      setState(() {
                        _answers[questionId] = answer;
                      });
                    },
                    onToggleDoubtful: () => _toggleDoubtful(questionId),
                  );
                },
              ),
            ),
            _QuizBottomBar(
              currentIndex: _currentIndex,
              totalQuestions: questions.length,
              isSubmitting: _controller.isSubmittingQuiz.value,
              onPrevious: _currentIndex > 0 ? _previousQuestion : null,
              onNext:
                  _currentIndex < questions.length - 1
                      ? () => _nextQuestion(questions)
                      : null,
              onSubmit:
                  _currentIndex == questions.length - 1
                      ? () => _confirmSubmit(questions)
                      : null,
            ),
          ],
        ),
      );
    });
  }

  Future<void> _nextQuestion(List<Map<String, dynamic>> questions) async {
    if (_currentIndex >= questions.length - 1) {
      return;
    }
    await _goToQuestion(_currentIndex + 1);
  }

  Future<void> _previousQuestion() async {
    if (_currentIndex <= 0) {
      return;
    }
    await _goToQuestion(_currentIndex - 1);
  }

  Future<void> _goToQuestion(int index) async {
    if (index < 0) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    if (_pageController.hasClients) {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _toggleDoubtful(int questionId) {
    setState(() {
      if (_doubtfulQuestionIds.contains(questionId)) {
        _doubtfulQuestionIds.remove(questionId);
      } else {
        _doubtfulQuestionIds.add(questionId);
      }
    });
  }

  void _openQuestionGridSheet(List<Map<String, dynamic>> questions) {
    Get.bottomSheet<void>(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Daftar Nomor Soal',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _quizDark,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_answers.length}/${questions.length} Terjawab',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _quizMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(questions.length, (index) {
                final int questionId = LearningController.intValue(
                  questions[index]['id'],
                );
                final bool isAnswered = _answers.containsKey(questionId);
                final bool isDoubtful = _doubtfulQuestionIds.contains(
                  questionId,
                );
                final bool isCurrent = index == _currentIndex;

                Color bg = const Color(0xFFF1F5F9);
                Color fg = _quizMuted;
                Color border = const Color(0xFFE2E8F0);

                if (isDoubtful) {
                  bg = const Color(0xFFFEF3C7);
                  fg = const Color(0xFFB45309);
                  border = const Color(0xFFF59E0B);
                } else if (isAnswered) {
                  bg = const Color(0xFFDCFCE7);
                  fg = const Color(0xFF15803D);
                  border = const Color(0xFF86EFAC);
                }

                if (isCurrent) {
                  border = _quizPrimary;
                }

                return Material(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Get.back<void>();
                      _goToQuestion(index);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: border,
                          width: isCurrent ? 2.2 : 1,
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? _quizPrimary : fg,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _LegendItem(color: Color(0xFF16A34A), label: 'Terisi'),
                _LegendItem(color: Color(0xFFD97706), label: 'Ragu-ragu'),
                _LegendItem(color: Color(0xFFCBD5E1), label: 'Belum Terisi'),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _confirmSubmit(List<Map<String, dynamic>> questions) async {
    final List<int> unanswered =
        questions
            .map((question) => LearningController.intValue(question['id']))
            .where((id) => !_answers.containsKey(id))
            .toList();

    if (unanswered.isNotEmpty) {
      final bool openFirstEmpty =
          await Get.dialog<bool>(
            _QuizConfirmationDialog(
              icon: Icons.assignment_late_rounded,
              iconColor: const Color(0xFFD97706),
              iconBgColor: const Color(0xFFFEF3C7),
              title: 'Kuis Belum Lengkap',
              message:
                  'Masih ada ${unanswered.length} butir soal yang belum kamu jawab. Buka soal kosong pertama sekarang?',
              badgeText:
                  '${unanswered.length} dari ${questions.length} soal belum terisi',
              cancelText: 'Nanti',
              confirmText: 'Buka Soal',
              confirmColor: _quizPrimary,
              confirmIcon: Icons.arrow_forward_rounded,
            ),
            barrierDismissible: true,
          ) ??
          false;

      if (openFirstEmpty) {
        final int firstEmptyIndex = questions.indexWhere((q) {
          final id = LearningController.intValue(q['id']);
          return !_answers.containsKey(id);
        });
        if (firstEmptyIndex >= 0) {
          await _goToQuestion(firstEmptyIndex);
        }
      }

      return;
    }

    final int doubtfulCount = _doubtfulQuestionIds.length;

    final bool confirmed =
        await Get.dialog<bool>(
          _QuizConfirmationDialog(
            icon:
                doubtfulCount > 0
                    ? Icons.help_outline_rounded
                    : Icons.check_circle_rounded,
            iconColor:
                doubtfulCount > 0
                    ? const Color(0xFFD97706)
                    : const Color(0xFF16A34A),
            iconBgColor:
                doubtfulCount > 0
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFDCFCE7),
            title:
                doubtfulCount > 0
                    ? 'Masih Ada Ragu-ragu'
                    : 'Kirim Jawaban Kuis?',
            message:
                doubtfulCount > 0
                    ? 'Ada $doubtfulCount soal yang masih kamu tandai ragu-ragu. Yakin ingin mengirim sekarang?'
                    : 'Semua ${questions.length} soal sudah dijawab dengan lengkap. Jawaban tidak dapat diubah setelah dikirim.',
            badgeText:
                doubtfulCount > 0
                    ? '$doubtfulCount Soal Ditandai Ragu-ragu'
                    : '${questions.length} dari ${questions.length} Soal Terisi Lengkap',
            cancelText: doubtfulCount > 0 ? 'Periksa Dulu' : 'Batal',
            confirmText: 'Kirim',
            confirmColor: _quizSuccess,
            confirmIcon: Icons.send_rounded,
          ),
          barrierDismissible: true,
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    final answers =
        questions.map((question) {
          final int questionId = LearningController.intValue(question['id']);

          return <String, dynamic>{
            'question_id': questionId,
            'answer': _answers[questionId],
          };
        }).toList();

    await _controller.submitQuizAnswers(
      materialId: widget.materialId,
      answers: answers,
    );
  }

  Future<void> _retryQuiz() async {
    setState(() {
      _answers.clear();
      _doubtfulQuestionIds.clear();
      _currentIndex = 0;
    });

    _controller.quizResult.value = null;

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }

    await _controller.loadQuiz(widget.materialId);
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: _quizMuted,
          ),
        ),
      ],
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.isDoubtful,
    required this.onSelect,
    required this.onToggleDoubtful,
  });

  final Map<String, dynamic> question;
  final int questionNumber;
  final int totalQuestions;
  final String? selectedAnswer;
  final bool isDoubtful;
  final ValueChanged<String> onSelect;
  final VoidCallback onToggleDoubtful;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> options = LearningController.mapValue(
      question['options'],
    );

    const optionKeys = <String>['A', 'B', 'C', 'D'];
    final String questionType = question['question_type']?.toString() ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: <Widget>[
        // Top Question Pill & Bookmark Toggle
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'SOAL $questionNumber DARI $totalQuestions',
                style: GoogleFonts.poppins(
                  color: _quizPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _questionTypeLabel(questionType),
                style: GoogleFonts.plusJakartaSans(
                  color: _quizMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            Material(
              color: isDoubtful ? const Color(0xFFFEF3C7) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onToggleDoubtful,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isDoubtful
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDoubtful
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 15,
                        color:
                            isDoubtful ? const Color(0xFFB45309) : _quizMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ragu',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color:
                              isDoubtful ? const Color(0xFFB45309) : _quizMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Question Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _quizBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            question['question_text']?.toString() ?? 'Pertanyaan kuis',
            style: GoogleFonts.poppins(
              color: _quizDark,
              fontSize: 16.5,
              fontWeight: FontWeight.w600,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 18),

        Text(
          'PILIHAN JAWABAN',
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: _quizMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        // Options List
        ...optionKeys.map((key) {
          final String text = options[key]?.toString() ?? '';
          if (text.trim().isEmpty) {
            return const SizedBox.shrink();
          }

          final bool isSelected = selectedAnswer == key;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _quizPrimary : _quizBorder,
                      width: isSelected ? 1.8 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isSelected
                                ? _quizPrimary.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.01),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? _quizPrimary
                                  : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          key,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isSelected ? Colors.white : _quizDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          text,
                          style: GoogleFonts.plusJakartaSans(
                            color: _quizDark,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color:
                            isSelected ? _quizPrimary : const Color(0xFFCBD5E1),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _QuizBottomBar extends StatelessWidget {
  const _QuizBottomBar({
    required this.currentIndex,
    required this.totalQuestions,
    required this.isSubmitting,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  final int currentIndex;
  final int totalQuestions;
  final bool isSubmitting;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final bool lastQuestion = currentIndex == totalQuestions - 1;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: _quizBorder, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            if (currentIndex > 0)
              OutlinedButton.icon(
                onPressed: isSubmitting ? null : onPrevious,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(
                  'Sebelumnya',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _quizDark,
                  side: const BorderSide(color: _quizBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed:
                  isSubmitting ? null : (lastQuestion ? onSubmit : onNext),
              icon:
                  isSubmitting
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Icon(
                        lastQuestion
                            ? Icons.check_circle_rounded
                            : Icons.arrow_forward_rounded,
                        size: 17,
                      ),
              label: Text(
                lastQuestion ? 'Selesai & Kirim' : 'Selanjutnya',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: lastQuestion ? _quizSuccess : _quizPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  const _QuizResultView({
    required this.result,
    required this.quiz,
    required this.onRetry,
    required this.onFinish,
  });

  final Map<String, dynamic> result;
  final Map<String, dynamic>? quiz;
  final Future<void> Function() onRetry;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final bool passed = LearningController.boolValue(result['passed']);
    final int score = LearningController.intValue(result['score']);
    final int passingScore = LearningController.intValue(
      result['passing_score'],
      fallback: 75,
    );
    final int correctCount = LearningController.intValue(
      result['correct_count'],
    );
    final int totalQuestions = LearningController.intValue(
      result['total_questions'],
    );
    final int xpAdded = LearningController.intValue(result['total_xp_added']);
    final bool xpAlreadyReceived = LearningController.boolValue(
      result['xp_already_received'],
    );

    final answerResults = LearningController.mapList(result['answers']);
    final questions = LearningController.mapList(quiz?['questions']);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: <Widget>[
        // Hero Score Result Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  passed
                      ? const <Color>[Color(0xFF047857), Color(0xFF10B981)]
                      : const <Color>[Color(0xFFB91C1C), Color(0xFFEA580C)],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: (passed ? _quizSuccess : const Color(0xFFEA580C))
                    .withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                passed ? 'Selamat, Kamu Lulus!' : 'Belum Mencapai Target',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nilai Akhir: $score • Target Minimal: $passingScore',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _ResultStatBox(
                    label: 'Benar',
                    value: '$correctCount/$totalQuestions',
                  ),
                  const SizedBox(width: 12),
                  _ResultStatBox(label: 'Skor', value: '$score'),
                  const SizedBox(width: 12),
                  _ResultStatBox(label: 'XP', value: '+$xpAdded'),
                ],
              ),
            ],
          ),
        ),
        if (passed) ...<Widget>[
          const SizedBox(height: 14),
          _QuizRewardCard(
            xpAdded: xpAdded,
            xpAlreadyReceived: xpAlreadyReceived,
          ),
        ],
        const SizedBox(height: 24),

        Row(
          children: [
            const Icon(Icons.analytics_rounded, size: 19, color: _quizPrimary),
            const SizedBox(width: 8),
            Text(
              'Pembahasan Soal',
              style: GoogleFonts.poppins(
                color: _quizDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...answerResults.asMap().entries.map((entry) {
          final answer = entry.value;
          final int questionId = LearningController.intValue(
            answer['question_id'],
          );

          final question = questions.firstWhereOrNull(
            (item) => LearningController.intValue(item['id']) == questionId,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AnswerReviewCard(
              number: entry.key + 1,
              question: question,
              answer: answer,
            ),
          );
        }),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            if (!passed) ...<Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    'Ulangi Kuis',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _quizDark,
                    side: const BorderSide(color: _quizBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: FilledButton.icon(
                onPressed: onFinish,
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: Text(
                  passed ? 'Selesai' : 'Kembali',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: passed ? _quizSuccess : _quizPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuizRewardCard extends StatelessWidget {
  const _QuizRewardCard({
    required this.xpAdded,
    required this.xpAlreadyReceived,
  });

  final int xpAdded;
  final bool xpAlreadyReceived;

  @override
  Widget build(BuildContext context) {
    final bool earnedNow = xpAdded > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: earnedNow ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: earnedNow ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  earnedNow ? const Color(0xFFDCFCE7) : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              earnedNow ? Icons.bolt_rounded : Icons.info_rounded,
              color:
                  earnedNow ? const Color(0xFF047857) : const Color(0xFF1D4ED8),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  earnedNow
                      ? '+$xpAdded XP Berhasil Diperoleh'
                      : 'XP Sudah Pernah Diterima',
                  style: GoogleFonts.poppins(
                    color:
                        earnedNow
                            ? const Color(0xFF166534)
                            : const Color(0xFF1E40AF),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  earnedNow
                      ? 'Hadiah kuis berhasil ditambahkan ke akun belajarmu.'
                      : xpAlreadyReceived
                      ? 'Mengulang kuis tetap mencatat nilai terbaikmu.'
                      : 'Tidak ada XP tambahan pada percobaan ini.',
                  style: GoogleFonts.plusJakartaSans(
                    color:
                        earnedNow
                            ? const Color(0xFF166534)
                            : const Color(0xFF1E40AF),
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

class _ResultStatBox extends StatelessWidget {
  const _ResultStatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerReviewCard extends StatelessWidget {
  const _AnswerReviewCard({
    required this.number,
    required this.question,
    required this.answer,
  });

  final int number;
  final Map<String, dynamic>? question;
  final Map<String, dynamic> answer;

  @override
  Widget build(BuildContext context) {
    final bool correct = LearningController.boolValue(answer['is_correct']);
    final String submitted = answer['submitted_answer']?.toString() ?? '-';
    final String correctAnswer = answer['correct_answer']?.toString() ?? '-';
    final String explanation = answer['explanation']?.toString().trim() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: correct ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      correct
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: correct ? _quizSuccess : _quizDanger,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question?['question_text']?.toString() ?? 'Soal $number',
                  style: GoogleFonts.poppins(
                    color: _quizDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ),
              Icon(
                correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: correct ? _quizSuccess : _quizDanger,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color:
                  correct ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Jawabanmu: ',
                      style: GoogleFonts.plusJakartaSans(
                        color: _quizDark,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      submitted,
                      style: GoogleFonts.plusJakartaSans(
                        color:
                            correct
                                ? const Color(0xFF166534)
                                : const Color(0xFF991B1B),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (!correct) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Jawaban benar: ',
                        style: GoogleFonts.plusJakartaSans(
                          color: _quizDark,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        correctAnswer,
                        style: GoogleFonts.plusJakartaSans(
                          color: _quizSuccess,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (explanation.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _quizBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: _quizPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      explanation,
                      style: GoogleFonts.plusJakartaSans(
                        color: _quizMuted,
                        fontSize: 12,
                        height: 1.45,
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

class _QuizEmptyState extends StatelessWidget {
  const _QuizEmptyState({required this.onRetry});

  final Future<bool> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.quiz_outlined,
                size: 32,
                color: _quizPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kuis Belum Dapat Dimuat',
              style: GoogleFonts.poppins(
                color: _quizDark,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pastikan seluruh submateri wajib sudah selesai dan soal kuis tersedia di server.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: _quizMuted,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _quizPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _questionTypeLabel(String type) {
  switch (type) {
    case 'konsep':
      return 'KONSEP';
    case 'studi_kasus':
      return 'STUDI KASUS';
    default:
      return 'PEMAHAMAN';
  }
}

class _QuizConfirmationDialog extends StatelessWidget {
  const _QuizConfirmationDialog({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.message,
    this.badgeText,
    required this.cancelText,
    required this.confirmText,
    required this.confirmColor,
    this.confirmIcon,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String message;
  final String? badgeText;
  final String cancelText;
  final String confirmText;
  final Color confirmColor;
  final IconData? confirmIcon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _quizDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _quizMuted,
                height: 1.5,
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  badgeText!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _quizDark,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Get.back<bool>(result: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _quizDark,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: FilledButton.icon(
                      onPressed: () => Get.back<bool>(result: true),
                      icon:
                          confirmIcon != null
                              ? Icon(confirmIcon, size: 17)
                              : const SizedBox.shrink(),
                      label: Text(
                        confirmText,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: confirmColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
