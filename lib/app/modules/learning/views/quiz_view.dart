import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/science_shimmer.dart';

import '../controllers/learning_controller.dart';

const Color _quizPrimary = Color(0xFF2563EB);
const Color _quizDark = Color(0xFF172033);
const Color _quizMuted = Color(0xFF64748B);
const Color _quizBackground = Color(0xFFF5F8FF);
const Color _quizSuccess = Color(0xFF16A34A);
const Color _quizDanger = Color(0xFFDC2626);

class LearningQuizView extends StatefulWidget {
  const LearningQuizView({
    super.key,
    required this.materialId,
    required this.moduleTitle,
  });

  final int materialId;
  final String moduleTitle;

  @override
  State<LearningQuizView> createState() =>
      _LearningQuizViewState();
}

class _LearningQuizViewState
    extends State<LearningQuizView> {
  final PageController _pageController =
      PageController();

  final Map<int, String> _answers =
      <int, String>{};

  final Set<int> _doubtfulQuestionIds =
      <int>{};

  int _currentIndex = 0;

  LearningController get _controller =>
      Get.find<LearningController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _controller.clearQuizSession();
        await _controller.loadQuiz(
          widget.materialId,
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _quizBackground,
      appBar: AppBar(
        title: const Text('Kuis Modul'),
        backgroundColor: Colors.white,
        foregroundColor: _quizDark,
        elevation: 0,
      ),
      body: Obx(() {
        if (_controller.isLoadingQuiz.value &&
            _controller.activeQuiz.value == null) {
          return const QuizPageShimmer();
        }

        final result =
            _controller.quizResult.value;

        if (result != null) {
          return _QuizResultView(
            result: result,
            quiz: _controller.activeQuiz.value,
            onRetry: _retryQuiz,
            onFinish: () => Get.back<void>(),
          );
        }

        final quiz =
            _controller.activeQuiz.value;

        if (quiz == null) {
          return _QuizEmptyState(
            onRetry: () => _controller.loadQuiz(
              widget.materialId,
            ),
          );
        }

        final questions =
            LearningController.mapList(
          quiz['questions'],
        );

        if (questions.isEmpty) {
          return _QuizEmptyState(
            onRetry: () => _controller.loadQuiz(
              widget.materialId,
            ),
          );
        }

        final double progress =
            (_currentIndex + 1) /
                questions.length;

        return Column(
          children: <Widget>[
            _QuizTopSummary(
              title: quiz['title']?.toString() ??
                  widget.moduleTitle,
              currentQuestion:
                  _currentIndex + 1,
              questionCount:
                  questions.length,
              answeredCount:
                  _answers.length,
              doubtfulCount:
                  _doubtfulQuestionIds.length,
              passingScore:
                  LearningController.intValue(
                quiz['passing_score'],
                fallback: 75,
              ),
              progress: progress,
            ),
            _QuestionNumberPanel(
              questions: questions,
              currentIndex: _currentIndex,
              answers: _answers,
              doubtfulQuestionIds:
                  _doubtfulQuestionIds,
              onSelectQuestion:
                  _goToQuestion,
              onOpenFirstUnanswered: () =>
                  _goToFirstUnanswered(
                questions,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (
                  context,
                  index,
                ) {
                  final question =
                      questions[index];
                  final int questionId =
                      LearningController.intValue(
                    question['id'],
                  );

                  return _QuestionPage(
                    question: question,
                    selectedAnswer:
                        _answers[questionId],
                    isDoubtful:
                        _doubtfulQuestionIds
                            .contains(questionId),
                    onSelect: (answer) {
                      setState(() {
                        _answers[questionId] =
                            answer;
                      });
                    },
                    onToggleDoubtful: () =>
                        _toggleDoubtful(
                      questionId,
                    ),
                  );
                },
              ),
            ),
            _QuizNavigation(
              currentIndex: _currentIndex,
              totalQuestions:
                  questions.length,
              isSubmitting:
                  _controller.isSubmittingQuiz.value,
              onPrevious: _currentIndex > 0
                  ? _previousQuestion
                  : null,
              onNext:
                  _currentIndex <
                          questions.length - 1
                      ? () => _nextQuestion(
                            questions,
                          )
                      : null,
              onSubmit:
                  _currentIndex ==
                          questions.length - 1
                      ? () => _confirmSubmit(
                            questions,
                          )
                      : null,
            ),
          ],
        );
      }),
    );
  }

  Future<void> _nextQuestion(
    List<Map<String, dynamic>> questions,
  ) async {
    if (_currentIndex >=
        questions.length - 1) {
      return;
    }

    await _goToQuestion(
      _currentIndex + 1,
    );
  }

  Future<void> _previousQuestion() async {
    if (_currentIndex <= 0) {
      return;
    }

    await _goToQuestion(
      _currentIndex - 1,
    );
  }

  Future<void> _goToQuestion(
    int index,
  ) async {
    if (index < 0) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    if (_pageController.hasClients) {
      await _pageController.animateToPage(
        index,
        duration:
            const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleDoubtful(
    int questionId,
  ) {
    setState(() {
      if (_doubtfulQuestionIds
          .contains(questionId)) {
        _doubtfulQuestionIds
            .remove(questionId);
      } else {
        _doubtfulQuestionIds
            .add(questionId);
      }
    });
  }

  Future<void> _goToFirstUnanswered(
    List<Map<String, dynamic>> questions,
  ) async {
    final int index =
        questions.indexWhere(
      (Map<String, dynamic> question) {
        final int questionId =
            LearningController.intValue(
          question['id'],
        );

        return !_answers.containsKey(
          questionId,
        );
      },
    );

    if (index < 0) {
      Get.snackbar(
        'Semua soal sudah terisi',
        'Tidak ada soal kosong yang perlu dibuka.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            const Color(0xFFEAF1FF),
        colorText:
            const Color(0xFF1E40AF),
        icon: const Icon(
          Icons.info_rounded,
          color: Color(0xFF1E40AF),
        ),
        margin: const EdgeInsets.all(14),
        borderRadius: 16,
      );
      return;
    }

    await _goToQuestion(index);
  }

  Future<void> _confirmSubmit(
    List<Map<String, dynamic>> questions,
  ) async {
    final List<int> unanswered =
        questions
            .map(
              (question) =>
                  LearningController.intValue(
                question['id'],
              ),
            )
            .where(
              (id) => !_answers.containsKey(id),
            )
            .toList();

    if (unanswered.isNotEmpty) {
      final bool openFirstEmpty =
          await Get.dialog<bool>(
                AlertDialog(
                  icon: const Icon(
                    Icons
                        .assignment_late_outlined,
                    color: Color(0xFFF59E0B),
                    size: 36,
                  ),
                  title: const Text(
                    'Kuis belum lengkap',
                  ),
                  content: Text(
                    'Masih ada ${unanswered.length} soal yang belum dijawab. Buka soal kosong pertama sekarang?',
                    textAlign:
                        TextAlign.center,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () =>
                          Get.back<bool>(
                        result: false,
                      ),
                      child: const Text(
                        'Nanti',
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () =>
                          Get.back<bool>(
                        result: true,
                      ),
                      icon: const Icon(
                        Icons
                            .arrow_forward_rounded,
                      ),
                      label: const Text(
                        'Buka Soal Kosong',
                      ),
                    ),
                  ],
                ),
              ) ??
              false;

      if (openFirstEmpty) {
        await _goToFirstUnanswered(
          questions,
        );
      }

      return;
    }

    final int doubtfulCount =
        _doubtfulQuestionIds.length;

    final bool confirmed =
        await Get.dialog<bool>(
              AlertDialog(
                icon: Icon(
                  doubtfulCount > 0
                      ? Icons
                          .help_outline_rounded
                      : Icons
                          .send_rounded,
                  color: doubtfulCount > 0
                      ? const Color(
                          0xFFF59E0B,
                        )
                      : _quizPrimary,
                  size: 36,
                ),
                title: Text(
                  doubtfulCount > 0
                      ? 'Masih ada jawaban ragu-ragu'
                      : 'Kirim kuis?',
                ),
                content: Text(
                  doubtfulCount > 0
                      ? '$doubtfulCount soal masih ditandai ragu-ragu. Kamu tetap bisa mengirim atau memeriksanya kembali.'
                      : 'Semua ${questions.length} soal sudah dijawab. Jawaban tidak dapat diubah setelah dikirim.',
                  textAlign:
                      TextAlign.center,
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () =>
                        Get.back<bool>(
                      result: false,
                    ),
                    child: Text(
                      doubtfulCount > 0
                          ? 'Periksa Lagi'
                          : 'Periksa lagi',
                    ),
                  ),
                  FilledButton(
                    onPressed: () =>
                        Get.back<bool>(
                      result: true,
                    ),
                    child:
                        const Text('Kirim'),
                  ),
                ],
              ),
            ) ??
            false;

    if (!confirmed &&
        doubtfulCount > 0) {
      final int firstDoubtfulIndex =
          questions.indexWhere(
        (Map<String, dynamic> question) {
          final int questionId =
              LearningController.intValue(
            question['id'],
          );

          return _doubtfulQuestionIds
              .contains(questionId);
        },
      );

      if (firstDoubtfulIndex >= 0) {
        await _goToQuestion(
          firstDoubtfulIndex,
        );
      }
    }

    if (!confirmed) {
      return;
    }

    final answers = questions.map((question) {
      final int questionId =
          LearningController.intValue(
        question['id'],
      );

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

    await _controller.loadQuiz(
      widget.materialId,
    );
  }
}

class _QuizTopSummary extends StatelessWidget {
  const _QuizTopSummary({
    required this.title,
    required this.currentQuestion,
    required this.questionCount,
    required this.answeredCount,
    required this.doubtfulCount,
    required this.passingScore,
    required this.progress,
  });

  final String title;
  final int currentQuestion;
  final int questionCount;
  final int answeredCount;
  final int doubtfulCount;
  final int passingScore;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        17,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _quizDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Text(
                'Soal $currentQuestion dari $questionCount',
                style: const TextStyle(
                  color: _quizMuted,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  doubtfulCount > 0
                      ? '$answeredCount dijawab • $doubtfulCount ragu-ragu'
                      : '$answeredCount dijawab • Lulus ≥ $passingScore',
                  textAlign: TextAlign.right,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _quizMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          LinearProgressIndicator(
            value: progress.clamp(
              0.0,
              1.0,
            ),
            minHeight: 7,
            borderRadius:
                BorderRadius.circular(20),
            backgroundColor:
                const Color(0xFFE2E8F0),
            valueColor:
                const AlwaysStoppedAnimation<
                    Color>(
              _quizPrimary,
            ),
          ),
        ],
      ),
    );
  }
}


class _QuestionNumberPanel extends StatelessWidget {
  const _QuestionNumberPanel({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.doubtfulQuestionIds,
    required this.onSelectQuestion,
    required this.onOpenFirstUnanswered,
  });

  final List<Map<String, dynamic>> questions;
  final int currentIndex;
  final Map<int, String> answers;
  final Set<int> doubtfulQuestionIds;
  final ValueChanged<int> onSelectQuestion;
  final VoidCallback onOpenFirstUnanswered;

  @override
  Widget build(BuildContext context) {
    final int unansweredCount =
        questions.where(
      (Map<String, dynamic> question) {
        final int id =
            LearningController.intValue(
          question['id'],
        );

        return !answers.containsKey(id);
      },
    ).length;

    return Container(
      color: Colors.white,
      padding:
          const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        13,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'Daftar Soal',
                style: TextStyle(
                  color: _quizDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              if (unansweredCount > 0)
                TextButton.icon(
                  onPressed:
                      onOpenFirstUnanswered,
                  icon: const Icon(
                    Icons
                        .assignment_late_outlined,
                    size: 17,
                  ),
                  label: Text(
                    '$unansweredCount kosong',
                  ),
                )
              else
                const Row(
                  children: <Widget>[
                    Icon(
                      Icons
                          .check_circle_rounded,
                      color: _quizSuccess,
                      size: 17,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Semua terisi',
                      style: TextStyle(
                        color: _quizSuccess,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(
            height: 45,
            child: ListView.separated(
              scrollDirection:
                  Axis.horizontal,
              itemCount: questions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (
                BuildContext context,
                int index,
              ) {
                final int questionId =
                    LearningController.intValue(
                  questions[index]['id'],
                );
                final bool answered =
                    answers.containsKey(
                  questionId,
                );
                final bool doubtful =
                    doubtfulQuestionIds
                        .contains(questionId);
                final bool current =
                    index == currentIndex;

                return _QuestionNumberButton(
                  number: index + 1,
                  answered: answered,
                  doubtful: doubtful,
                  current: current,
                  onTap: () =>
                      onSelectQuestion(index),
                );
              },
            ),
          ),
          const SizedBox(height: 9),
          const Wrap(
            spacing: 12,
            runSpacing: 6,
            children: <Widget>[
              _QuestionLegend(
                color: Color(0xFF16A34A),
                label: 'Sudah dijawab',
              ),
              _QuestionLegend(
                color: Color(0xFFF59E0B),
                label: 'Ragu-ragu',
              ),
              _QuestionLegend(
                color: Color(0xFFCBD5E1),
                label: 'Belum dijawab',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionNumberButton
    extends StatelessWidget {
  const _QuestionNumberButton({
    required this.number,
    required this.answered,
    required this.doubtful,
    required this.current,
    required this.onTap,
  });

  final int number;
  final bool answered;
  final bool doubtful;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        doubtful
            ? const Color(0xFFFFF7E6)
            : answered
                ? const Color(0xFFE7F8EE)
                : const Color(0xFFF1F5F9);

    final Color foregroundColor =
        doubtful
            ? const Color(0xFFB45309)
            : answered
                ? const Color(0xFF15803D)
                : _quizMuted;

    final Color borderColor =
        current
            ? _quizPrimary
            : doubtful
                ? const Color(0xFFF59E0B)
                : answered
                    ? const Color(
                        0xFF86EFAC,
                      )
                    : const Color(
                        0xFFCBD5E1,
                      );

    return Material(
      color: backgroundColor,
      borderRadius:
          BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(12),
        child: Container(
          width: 43,
          height: 43,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: current ? 2.5 : 1.3,
            ),
          ),
          child: Text(
            '$number',
            style: TextStyle(
              color: current
                  ? _quizPrimary
                  : foregroundColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionLegend extends StatelessWidget {
  const _QuestionLegend({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: _quizMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.question,
    required this.selectedAnswer,
    required this.isDoubtful,
    required this.onSelect,
    required this.onToggleDoubtful,
  });

  final Map<String, dynamic> question;
  final String? selectedAnswer;
  final bool isDoubtful;
  final ValueChanged<String> onSelect;
  final VoidCallback onToggleDoubtful;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> options =
        LearningController.mapValue(
      question['options'],
    );

    const optionKeys = <String>[
      'A',
      'B',
      'C',
      'D',
    ];

    return ListView(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        22,
      ),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(21),
            border: Border.all(
              color:
                  const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _questionTypeLabel(
                  question['question_type']
                          ?.toString() ??
                      '',
                ),
                style: const TextStyle(
                  color: _quizPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                question['question_text']
                        ?.toString() ??
                    'Pertanyaan kuis',
                style: const TextStyle(
                  color: _quizDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ...optionKeys.map((key) {
          final String text =
              options[key]?.toString() ?? '';

          if (text.trim().isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 11,
            ),
            child: _QuizOption(
              optionKey: key,
              text: text,
              selected:
                  selectedAnswer == key,
              onTap: () => onSelect(key),
            ),
          );
        }),
        const SizedBox(height: 3),
        OutlinedButton.icon(
          onPressed: onToggleDoubtful,
          icon: Icon(
            isDoubtful
                ? Icons
                    .help_rounded
                : Icons
                    .help_outline_rounded,
          ),
          label: Text(
            isDoubtful
                ? 'Ditandai Ragu-ragu'
                : 'Tandai Ragu-ragu',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: isDoubtful
                ? const Color(0xFFB45309)
                : _quizMuted,
            backgroundColor: isDoubtful
                ? const Color(0xFFFFF7E6)
                : Colors.white,
            side: BorderSide(
              color: isDoubtful
                  ? const Color(
                      0xFFF59E0B,
                    )
                  : const Color(
                      0xFFCBD5E1,
                    ),
            ),
            padding:
                const EdgeInsets.symmetric(
              vertical: 13,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isDoubtful
              ? 'Kamu bisa kembali ke soal ini dari daftar nomor.'
              : 'Gunakan tanda ini kalau masih ingin memeriksa jawabannya.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _quizMuted,
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.optionKey,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String optionKey;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFFEAF1FF)
          : Colors.white,
      borderRadius:
          BorderRadius.circular(17),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color: selected
                  ? _quizPrimary
                  : const Color(0xFFE2E8F0),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundColor: selected
                    ? _quizPrimary
                    : const Color(
                        0xFFF1F5F9,
                      ),
                foregroundColor: selected
                    ? Colors.white
                    : _quizMuted,
                child: Text(
                  optionKey,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: _quizDark,
                    fontWeight: selected
                        ? FontWeight.w800
                        : FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons
                        .radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? _quizPrimary
                    : _quizMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizNavigation extends StatelessWidget {
  const _QuizNavigation({
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
    final bool lastQuestion =
        currentIndex == totalQuestions - 1;

    return SafeArea(
      top: false,
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(
          18,
          13,
          18,
          13,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: isSubmitting
                  ? null
                  : onPrevious,
              icon: const Icon(
                Icons.chevron_left_rounded,
              ),
              label: const Text('Sebelumnya'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: isSubmitting
                  ? null
                  : lastQuestion
                      ? onSubmit
                      : onNext,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      lastQuestion
                          ? Icons.send_rounded
                          : Icons
                              .chevron_right_rounded,
                    ),
              label: Text(
                lastQuestion
                    ? 'Kirim Kuis'
                    : 'Berikutnya',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: lastQuestion
                    ? _quizSuccess
                    : _quizPrimary,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
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
    final bool passed =
        LearningController.boolValue(
      result['passed'],
    );
    final int score =
        LearningController.intValue(
      result['score'],
    );
    final int passingScore =
        LearningController.intValue(
      result['passing_score'],
      fallback: 75,
    );
    final int correctCount =
        LearningController.intValue(
      result['correct_count'],
    );
    final int totalQuestions =
        LearningController.intValue(
      result['total_questions'],
    );
    final int xpAdded =
        LearningController.intValue(
      result['total_xp_added'],
    );
    final bool xpAlreadyReceived =
        LearningController.boolValue(
      result['xp_already_received'],
    );

    final answerResults =
        LearningController.mapList(
      result['answers'],
    );
    final questions =
        LearningController.mapList(
      quiz?['questions'],
    );

    return ListView(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        34,
      ),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: passed
                  ? const <Color>[
                      Color(0xFF15803D),
                      Color(0xFF22C55E),
                    ]
                  : const <Color>[
                      Color(0xFF9A3412),
                      Color(0xFFF97316),
                    ],
            ),
            borderRadius:
                BorderRadius.circular(24),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                passed
                    ? Icons
                        .emoji_events_rounded
                    : Icons
                        .restart_alt_rounded,
                color: Colors.white,
                size: 58,
              ),
              const SizedBox(height: 12),
              Text(
                passed
                    ? 'Kuis Lulus!'
                    : 'Belum Lulus',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Nilai $score • Minimal $passingScore',
                style: const TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: <Widget>[
                  _ResultStatistic(
                    label: 'Benar',
                    value:
                        '$correctCount/$totalQuestions',
                  ),
                  const SizedBox(width: 12),
                  _ResultStatistic(
                    label: 'XP Baru',
                    value: '+$xpAdded',
                  ),
                ],
              ),
            ],
          ),
        ),
        if (passed) ...<Widget>[
          const SizedBox(height: 12),
          _QuizRewardCard(
            xpAdded: xpAdded,
            xpAlreadyReceived:
                xpAlreadyReceived,
          ),
        ],
        const SizedBox(height: 20),
        const Text(
          'Pembahasan Jawaban',
          style: TextStyle(
            color: _quizDark,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 11),
        ...answerResults.asMap().entries.map(
          (entry) {
            final answer = entry.value;
            final int questionId =
                LearningController.intValue(
              answer['question_id'],
            );

            final question =
                questions.firstWhereOrNull(
              (item) =>
                  LearningController.intValue(
                    item['id'],
                  ) ==
                  questionId,
            );

            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 11,
              ),
              child: _AnswerReviewCard(
                number: entry.key + 1,
                question: question,
                answer: answer,
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            if (!passed) ...<Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text(
                    'Ulangi Kuis',
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 11),
            ],
            Expanded(
              child: FilledButton.icon(
                onPressed: onFinish,
                icon: const Icon(
                  Icons.check_rounded,
                ),
                label: Text(
                  passed
                      ? 'Selesai'
                      : 'Kembali',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      passed
                          ? _quizSuccess
                          : _quizPrimary,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: earnedNow
            ? const Color(0xFFE7F8EE)
            : const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: earnedNow
              ? const Color(0xFF86EFAC)
              : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: earnedNow
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              earnedNow
                  ? Icons.bolt_rounded
                  : Icons.info_rounded,
              color: earnedNow
                  ? const Color(0xFF047857)
                  : const Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  earnedNow
                      ? '+$xpAdded XP diperoleh'
                      : 'XP sudah pernah diterima',
                  style: TextStyle(
                    color: earnedNow
                        ? const Color(0xFF166534)
                        : const Color(0xFF1E40AF),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  earnedNow
                      ? 'Hadiah kuis berhasil ditambahkan ke total XP.'
                      : xpAlreadyReceived
                          ? 'Mengulang kuis tetap memperbarui nilai terbaik, tetapi tidak memberikan XP kedua kali.'
                          : 'Tidak ada XP tambahan pada percobaan ini.',
                  style: TextStyle(
                    color: earnedNow
                        ? const Color(0xFF166534)
                        : const Color(0xFF1E40AF),
                    fontSize: 11,
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

class _ResultStatistic extends StatelessWidget {
  const _ResultStatistic({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFF1F5F9),
              fontSize: 11,
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
    final bool correct =
        LearningController.boolValue(
      answer['is_correct'],
    );
    final String submitted =
        answer['submitted_answer']
                ?.toString() ??
            '-';
    final String correctAnswer =
        answer['correct_answer']
                ?.toString() ??
            '-';
    final String explanation =
        answer['explanation']
                ?.toString()
                .trim() ??
            '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: correct
              ? const Color(0xFF86EFAC)
              : const Color(0xFFFCA5A5),
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
              CircleAvatar(
                radius: 17,
                backgroundColor: correct
                    ? const Color(0xFFE7F8EE)
                    : const Color(0xFFFFE8E8),
                foregroundColor: correct
                    ? _quizSuccess
                    : _quizDanger,
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  question?['question_text']
                          ?.toString() ??
                      'Soal $number',
                  style: const TextStyle(
                    color: _quizDark,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
              ),
              Icon(
                correct
                    ? Icons
                        .check_circle_rounded
                    : Icons.cancel_rounded,
                color: correct
                    ? _quizSuccess
                    : _quizDanger,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Jawabanmu: $submitted',
            style: TextStyle(
              color: correct
                  ? const Color(0xFF166534)
                  : const Color(0xFF991B1B),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!correct) ...<Widget>[
            const SizedBox(height: 5),
            Text(
              'Jawaban benar: $correctAnswer',
              style: const TextStyle(
                color: _quizSuccess,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (explanation.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF8FAFC,
                ),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Text(
                explanation,
                style: const TextStyle(
                  color: _quizMuted,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuizEmptyState extends StatelessWidget {
  const _QuizEmptyState({
    required this.onRetry,
  });

  final Future<bool> Function() onRetry;

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
              Icons.quiz_outlined,
              size: 58,
              color: _quizMuted,
            ),
            const SizedBox(height: 13),
            const Text(
              'Kuis belum dapat dimuat',
              style: TextStyle(
                color: _quizDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Pastikan seluruh submateri wajib sudah selesai dan soal kuis tersedia.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _quizMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label:
                  const Text('Coba Lagi'),
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
