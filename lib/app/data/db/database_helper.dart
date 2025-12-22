import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/material_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    // Kita pakai v2 biar fresh dan tabel baru (quizzes/funfacts) terbuat otomatis
    String path = join(await getDatabasesPath(), 'science_craft_v2.db'); 
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    
    // 1. Tabel Materials (Header Materi)
    await db.execute('''
      CREATE TABLE materials(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        introduction TEXT NOT NULL,
        category TEXT NOT NULL, 
        iconPath TEXT NOT NULL,
        progress REAL NOT NULL DEFAULT 0.0 
      )
    ''');
    
    // 2. Tabel Theory Sections (Isi Sub-bab)
    await db.execute('''
      CREATE TABLE theory_sections(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material_id INTEGER,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        examples TEXT NOT NULL,
        FOREIGN KEY (material_id) REFERENCES materials (id) ON DELETE CASCADE
      )
    ''');
    
    // 3. Tabel AppSettings (History User)
    await db.execute('''
      CREATE TABLE AppSettings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // 4. TABEL BARU: QUIZZES (Soal-soal)
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

    // 5. TABEL BARU: FUNFACTS (Fakta Unik Dashboard)
    await db.execute('''
      CREATE TABLE funfacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    // Kita biarkan kosong agar kamu bisa isi lewat Admin Panel
    // Kalau mau isi dummy, bisa panggil _seedDatabase(db) di sini.
  }

  // --- BAGIAN 1: CRUD ADMIN (INPUT DATA) ---

  // Tambah Materi Baru (Header + Sub-bab)
  Future<int> addMaterial(String title, String intro, String category, List<Map<String, String>> sections) async {
    final db = await instance.database;
    // 1. Insert Header
    int id = await db.insert('materials', {
      'title': title, 
      'introduction': intro, 
      'category': category, 
      'iconPath': 'assets/chemistry.png', // Default icon sementara
      'progress': 0.0
    });

    // 2. Insert Sub-bab
    for (var section in sections) {
      await db.insert('theory_sections', {
        'material_id': id, 
        'title': section['title'], 
        'content': section['content'],
        'imagePath': 'assets/chemistry.png', 
        'examples': section['examples'] ?? '-'
      });
    }
    return id;
  }

  // Hapus Materi (Otomatis hapus sub-bab & kuis terkait)
  Future<int> deleteMaterial(int id) async {
    final db = await instance.database;
    await db.delete('theory_sections', where: 'material_id = ?', whereArgs: [id]);
    await db.delete('quizzes', where: 'material_id = ?', whereArgs: [id]);
    return await db.delete('materials', where: 'id = ?', whereArgs: [id]);
  }

  // Tambah Kuis
  Future<int> addQuiz(int materialId, String q, String a, String b, String c, String d, String correct) async {
    final db = await instance.database;
    return await db.insert('quizzes', {
      'material_id': materialId, 'question': q,
      'option_a': a, 'option_b': b, 'option_c': c, 'option_d': d,
      'correct_answer': correct
    });
  }

  // Ambil Kuis berdasarkan ID Materi
  Future<List<Map<String, dynamic>>> getQuizzesByMaterial(int materialId) async {
    final db = await instance.database;
    return await db.query('quizzes', where: 'material_id = ?', whereArgs: [materialId]);
  }

  // Hapus Kuis
  Future<int> deleteQuiz(int id) async {
    final db = await instance.database;
    return await db.delete('quizzes', where: 'id = ?', whereArgs: [id]);
  }

  // Tambah FunFact
  Future<int> addFunFact(String title, String desc) async {
    final db = await instance.database;
    return await db.insert('funfacts', {'title': title, 'description': desc});
  }

  // Ambil Semua FunFact
  Future<List<Map<String, dynamic>>> getAllFunFacts() async {
     final db = await instance.database;
     return await db.query('funfacts');
  }

  // Hapus FunFact
  Future<int> deleteFunFact(int id) async {
    final db = await instance.database;
    return await db.delete('funfacts', where: 'id = ?', whereArgs: [id]);
  }

  // --- BAGIAN 2: FITUR USER (READ & PROGRESS) ---

  // Ambil List Semua Materi (Untuk Halaman List Materi)
  Future<List<MaterialItem>> getAllMaterials() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('materials');
    
    return List.generate(maps.length, (i) {
      return MaterialItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        category: maps[i]['category'],
        progress: (maps[i]['progress'] as num).toDouble(),
        iconPath: maps[i]['iconPath'],
      );
    });
  }

  // --- BAGIAN 3: DETAIL MATERI (YANG DIPERBAIKI) ---
  // Fungsi ini menggabungkan Header Materi dengan Isi Sub-babnya
  
  Future<MaterialContent?> getMaterialById(int id) async {
    final db = await instance.database;
    
    // 1. Ambil Header
    final materialRes = await db.query('materials', where: 'id = ?', whereArgs: [id]);

    if (materialRes.isNotEmpty) {
      final materialMap = materialRes.first;

      // 2. Ambil Sub-bab
      final sectionsRes = await db.query('theory_sections', where: 'material_id = ?', whereArgs: [id]);

      // 3. Rakit Data
      List<TheorySection> sections = sectionsRes.map((s) {
        return TheorySection(
          title: s['title'] as String,
          content: s['content'] as String,
          imagePath: (s['imagePath'] as String).isNotEmpty 
              ? s['imagePath'] as String 
              : 'assets/chemistry.png', 
          // Perbaikan: Split pakai Enter (\n) karena inputan Admin pakai Enter
          examples: (s['examples'] as String).isNotEmpty 
              ? (s['examples'] as String).split('\n') 
              : [],
        );
      }).toList();

      return MaterialContent(
        title: materialMap['title'] as String,
        introduction: materialMap['introduction'] as String,
        iconPath: materialMap['iconPath'] as String,
        progress: (materialMap['progress'] as num).toDouble(),
        theorySections: sections,
      );
    }
    return null;
  }

  // --- BAGIAN 4: FUNGSI LAMA (DIPERTAHANKAN BIAR GAK ERROR) ---

  // Update Progress Belajar User
  Future<void> updateMaterialProgress(int id, double progress) async {
    final db = await instance.database;
    await db.update(
      'materials',
      {'progress': progress},
      where: 'id = ?',
      whereArgs: [id],
    );
    print("[DB Helper] Progress ID $id updated: $progress");
  }

  // Simpan History (Last Learned)
  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'AppSettings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Ambil History
  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final maps = await db.query(
      'AppSettings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) return maps.first['value'] as String?;
    return null;
  }

  // Reset Data User
  Future<void> clearUserData() async {
    final db = await instance.database;
    await db.delete('AppSettings'); 
    await db.update('materials', {'progress': 0.0}); 
    print("[DB Helper] User data cleared.");
  }
}