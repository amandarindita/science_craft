// Model-model ini sekarang ada di file terpisah agar bisa di-import
// oleh DatabaseHelper, MaterialListController, dan MaterialDetailController.

class MaterialItem {
  final int id;
  final String title;
  final String category;
  final double progress;
  final String iconPath;

  MaterialItem({
    required this.id,
    required this.title,
    required this.category,
    required this.progress,
    required this.iconPath,
  });
}

class MaterialContent {
  final String title;
  final String introduction;
  final List<TheorySection> theorySections;
  // final QuizSection quiz; <-- KITA HAPUS KUIS DARI SINI
  final String iconPath;
  final double progress; 

  MaterialContent({
    required this.title,
    required this.introduction,
    required this.theorySections,
    // required this.quiz, <-- KITA HAPUS KUIS DARI SINI
    required this.iconPath,
    required this.progress,
  });
}

class TheorySection {
  final String title;
  final String content;
  final String imagePath;
  final List<String> examples;

  TheorySection({
    required this.title,
    required this.content,
    required this.imagePath,
    required this.examples,
  });
}

// Model Quiz ini bisa tetap di sini,
// agar bisa di-import oleh DatabaseHelper dan QuizController
class QuizSection {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizSection({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

