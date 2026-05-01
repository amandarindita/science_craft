import 'dart:convert'; 

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

  factory MaterialItem.fromMap(Map<String, dynamic> map) {
    return MaterialItem(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      progress: (map['progress'] ?? 0.0).toDouble(), 
      iconPath: map['iconPath'] ?? 'assets/default.png',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'progress': progress,
      'iconPath': iconPath,
    };
  }
}

class MaterialContent {
  final int? id; 
  final String title;
  final String introduction;
  final List<TheorySection> theorySections;
  final String iconPath;
  final double progress;

  MaterialContent({
    this.id, 
    required this.title,
    required this.introduction,
    required this.theorySections,
    required this.iconPath,
    required this.progress,
  });

  factory MaterialContent.fromMap(Map<String, dynamic> map) {
    return MaterialContent(
      id: map['id'], // Ambil ID
      title: map['title'] ?? '',
      introduction: map['introduction'] ?? '',
      // Parsing JSON String menjadi List<TheorySection>
      theorySections: map['sections'] != null 
          ? List<TheorySection>.from(
              jsonDecode(map['sections']).map((x) => TheorySection.fromMap(x)))
          : [],
      iconPath: map['iconPath'] ?? 'assets/default.png',
      progress: (map['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'introduction': introduction,
      'sections': jsonEncode(theorySections.map((x) => x.toMap()).toList()),
      'iconPath': iconPath,
      'progress': progress,
    };
  }
}

class TheorySection {
  final String title;
  final String content; 
  final String? imagePath;
  final String? examples;

  TheorySection({
    required this.title,
    required this.content,
    this.imagePath,
    this.examples,
  });

  factory TheorySection.fromMap(Map<String, dynamic> map) {
    return TheorySection(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imagePath: map['image_path'], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'image_path': imagePath,
      'examples': examples,
    };
  }
}

class QuizSection {
  final int? id; 
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizSection({
    this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory QuizSection.fromMap(Map<String, dynamic> map) {
    List<String> parsedOptions = [];
    if (map['options'] is String) {
      parsedOptions = List<String>.from(jsonDecode(map['options']));
    } else {
      parsedOptions = List<String>.from(map['options']);
    }

    return QuizSection(
      id: map['id'],
      question: map['question'] ?? '',
      options: parsedOptions,
      correctAnswerIndex: map['correct_answer_index'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': jsonEncode(options), // Simpan List sebagai String JSON
      'correct_answer_index': correctAnswerIndex,
    };
  }
}