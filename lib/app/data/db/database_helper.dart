import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/material_model.dart'; 

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'science_app_v5_final.db'); 
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE materials(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        intro TEXT NOT NULL, 
        category TEXT NOT NULL, 
        iconPath TEXT, 
        progress REAL NOT NULL DEFAULT 0.0 
      )
    ''');
    
    await db.execute('''
      CREATE TABLE sections(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material_id INTEGER,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        image_path TEXT, 
        examples TEXT,
        FOREIGN KEY (material_id) REFERENCES materials (id) ON DELETE CASCADE
      )
    ''');
    
  
    await db.execute('''
      CREATE TABLE quizzes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material_id INTEGER,
        question TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        FOREIGN KEY (material_id) REFERENCES materials (id) ON DELETE CASCADE
      )
    ''');


    await db.execute('''
      CREATE TABLE funfacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE AppSettings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> addMaterial(String title, String intro, String category, List<Map<String, String>> sections) async {
    final db = await instance.database;
    
    // 1. Insert Header
    int id = await db.insert('materials', {
      'title': title, 
      'intro': intro, 
      'category': category, 
      'iconPath': 'assets/chemistry.png', 
      'progress': 0.0
    });


    for (var section in sections) {
      await db.insert('sections', {
        'material_id': id, 
        'title': section['title'], 
        'content': section['content'], 
        'image_path': section['image_path'] ?? '', 
        'examples': section['examples']
      });
    }
  }

  Future<int> deleteMaterial(int id) async {
    final db = await instance.database;
    await db.delete('sections', where: 'material_id = ?', whereArgs: [id]);
    await db.delete('quizzes', where: 'material_id = ?', whereArgs: [id]);
    return await db.delete('materials', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> addQuiz(int materialId, String q, String a, String b, String c, String d, String correct) async {
    final db = await instance.database;
    return await db.insert('quizzes', {
      'material_id': materialId, 'question': q,
      'option_a': a, 'option_b': b, 'option_c': c, 'option_d': d,
      'correct_answer': correct
    });
  }

  Future<int> updateQuiz(int id, int materialId, String q, String a, String b, String c, String d, String correct) async {
    final db = await instance.database;
    return await db.update('quizzes', {
      'material_id': materialId,
      'question': q,
      'option_a': a,
      'option_b': b,
      'option_c': c,
      'option_d': d,
      'correct_answer': correct
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getQuizzesByMaterial(int materialId) async {
    final db = await instance.database;
    return await db.query('quizzes', where: 'material_id = ?', whereArgs: [materialId]);
  }

  Future<int> deleteQuiz(int id) async {
    final db = await instance.database;
    return await db.delete('quizzes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> addFunFact(String title, String desc) async {
    final db = await instance.database;
    return await db.insert('funfacts', {'title': title, 'description': desc});
  }

  Future<List<Map<String, dynamic>>> getAllFunFacts() async {
     final db = await instance.database;
     return await db.query('funfacts');
  }

  Future<int> updateFunFact(int id, String title, String desc) async {
    final db = await instance.database;
    return await db.update('funfacts', {
      'title': title, 
      'description': desc
    }, where: 'id = ?', whereArgs: [id]);
  }
  Future<int> deleteFunFact(int id) async {
    final db = await instance.database;
    return await db.delete('funfacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MaterialItem>> getAllMaterials() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('materials');
    
    return List.generate(maps.length, (i) {
      return MaterialItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        category: maps[i]['category'],
        progress: (maps[i]['progress'] as num).toDouble(),
        iconPath: maps[i]['iconPath'] ?? 'assets/chemistry.png',
      );
    });
  }

  Future<MaterialContent?> getMaterialById(int id) async {
    final db = await instance.database;
    
    final materialRes = await db.query('materials', where: 'id = ?', whereArgs: [id]);

    if (materialRes.isNotEmpty) {
      final materialMap = materialRes.first;

      final sectionsRes = await db.query('sections', where: 'material_id = ?', whereArgs: [id]);

      List<TheorySection> sections = sectionsRes.map((s) {
        return TheorySection(
          title: s['title'] as String,
          content: s['content'] as String,
          imagePath: s['image_path'] as String?, 
          examples: s['examples'] as String?,
        );
      }).toList();

      return MaterialContent(
        title: materialMap['title'] as String,
        introduction: materialMap['intro'] as String, 
        iconPath: materialMap['iconPath'] as String? ?? 'assets/chemistry.png',
        progress: (materialMap['progress'] as num).toDouble(),
        theorySections: sections,
      );
    }
    return null;
  }

  // Update Progress
  Future<void> updateMaterialProgress(int id, double progress) async {
    final db = await instance.database;
    await db.update('materials', {'progress': progress}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert('AppSettings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final maps = await db.query('AppSettings', columns: ['value'], where: 'key = ?', whereArgs: [key]);
    if (maps.isNotEmpty) return maps.first['value'] as String?;
    return null;
  }
 
  Future<int> updateMaterial(int id, String title, String intro, String category, List<Map<String, String>> sections) async {
    final db = await instance.database;
    
    // A. Update tabel induk (materials)
    int res = await db.update('materials', {
      'title': title,
      'intro': intro,
      'category': category
    }, where: 'id = ?', whereArgs: [id]);
    await db.delete('sections', where: 'material_id = ?', whereArgs: [id]);

  
    for (var section in sections) {
      await db.insert('sections', {
        'material_id': id,
        'title': section['title'],
        'content': section['content'], 
        'image_path': section['image_path'] ?? '',
        'examples': section['examples']
      });
    }
    return res;
  }

  Future<List<Map<String, dynamic>>> getSectionsByMaterialId(int materialId) async {
    final db = await instance.database;
    return await db.query('sections', where: 'material_id = ?', whereArgs: [materialId]);
  }
  Future<void> clearUserData() async {
    final db = await instance.database;
    try {
      await db.delete('AppSettings'); 
      // Reset progress materi
      await db.update('materials', {'progress': 0.0}); 
    } catch (e) {
      print("Error clearing data: $e");
    }
  }
}