import 'dart:convert'; 

class MaterialItem {
  final int id;
  final String title;
  final String category;
  final double progress;
  final String iconPath;
  final String? unitySceneId;
  final String? instructions;
  final String? imageUrl; // Tambahkan ini

  MaterialItem({
    required this.id,
    required this.title,
    required this.category,
    required this.progress,
    required this.iconPath,
    this.unitySceneId,
    this.instructions,
    this.imageUrl,

  });

  factory MaterialItem.fromMap(Map<String, dynamic> map) {
    return MaterialItem(
      id: map['id'],
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      progress: (map['progress'] ?? 0.0).toDouble(), 
      iconPath: map['iconPath'] ?? 'assets/chemistry.png',
      unitySceneId: map['unity_scene_id'],
      instructions: map['instructions'],
      imageUrl: map['image_url'],
    );
  }
}

class MaterialContent {
  final int? id; 
  final String title;
  final String introduction;
  final List<TheorySection> theorySections;
  final String iconPath;
  final double progress;
  final String? unitySceneId;
  final String? instructions; 
  final String? imageUrl;// Tambahkan ini

  MaterialContent({
    this.id, 
    required this.title,
    required this.introduction,
    required this.theorySections,
    required this.iconPath,
    required this.progress,
    this.unitySceneId,
    this.instructions,
    this.imageUrl,
  });

  factory MaterialContent.fromMap(Map<String, dynamic> map) {
    // --- PROSES UNBOXING: Membongkar JSON dari Flask ---
    Map<String, dynamic> innerData = {};
    if (map['content'] != null) {
      try {
        innerData = jsonDecode(map['content']);
      } catch (e) {
        print("Error decoding content: $e");
      }
    }

    return MaterialContent(
      id: map['id'], 
      title: map['title'] ?? '',
      introduction: innerData['intro'] ?? '', // Ambil dari hasil bongkar
      theorySections: innerData['sections'] != null 
          ? List<TheorySection>.from(
              (innerData['sections'] as List).map((x) => TheorySection.fromMap(x)))
          : [],
      iconPath: map['iconPath'] ?? 'assets/chemistry.png',
      progress: (map['progress'] ?? 0.0).toDouble(),
      unitySceneId: map['unity_scene_id'],
      instructions: map['instructions'],
      imageUrl: map['image_url'],
    );
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
      examples: map['examples'], 
    );
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