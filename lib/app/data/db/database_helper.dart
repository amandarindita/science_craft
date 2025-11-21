import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// --- 1. IMPORT MODEL DARI FILE BARU ---
import '../../models/material_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'science_craft.db');
    
    // --- PENTING UNTUK DEVELOPMENT ---
    // Hapus '//' di baris bawah ini SEKALI SAJA untuk memaksa database
    // dibuat ulang dengan struktur tabel yang baru (TERMASUK AppSettings)
    //
    //await deleteDatabase(path); 
    
    return await openDatabase(
      path,
      version: 1, // Jika kamu ubah struktur tabel, naikkan versi ini jadi 2
      onCreate: _onCreate,
    );
  }

  // --- 2. PERBARUI FUNGSI ONCREATE ---
  Future _onCreate(Database db, int version) async {
    print("[DB Helper] Event _onCreate terpanggil! Membuat tabel...");
    
    // Tabel materials (TETAP SAMA)
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
    
    // Tabel theory_sections (TETAP SAMA)
    await db.execute('''
      CREATE TABLE theory_sections(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material_id INTEGER,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        examples TEXT NOT NULL,
        FOREIGN KEY (material_id) REFERENCES materials (id)
      )
    ''');
    
    // --- 3. TAMBAHAN TABEL AppSettings ---
    // Ini adalah tabel baru untuk menyimpan history "Lanjutkan Belajar"
    await db.execute('''
      CREATE TABLE AppSettings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    print("[DB Helper] Tabel AppSettings berhasil dibuat.");
    
    // ---
    
    await _seedDatabase(db);
    print("[DB Helper] Seeding data selesai.");
  }

  // --- 3. PERBARUI FUNGSI SEEDDATABASE (TETAP SAMA) ---
  Future<void> _seedDatabase(Database db) async {
    // (Isi fungsi ini sama persis seperti kode Anda sebelumnya)
    
    // Materi 1
    int materialId1 = await db.insert('materials', {
      'title': 'Apa itu Reaksi Endoterm dan Eksoterm?',
      'introduction': 'Hai, tahu nggak sih, kenapa petasan bisa meledak...',
      'category': 'Kimia', 'iconPath': 'assets/chemistry.png', 'progress': 0.5
    });
    await db.insert('theory_sections', { 'material_id': materialId1, 'title': '1. Reaksi Endoterm: Yang Bikin Dingin!', 'imagePath': 'assets/ice.png', 'content': 'Kalau Reaksi Endoterm itu kebalikannya...', 'examples': 'Es yang mencair.|Fotosintesis...'});
    await db.insert('theory_sections', { 'material_id': materialId1, 'title': '2. Reaksi Eksoterm: Yang Bikin Panas!', 'imagePath': 'assets/fire.png', 'content': 'Reaksi Eksoterm adalah reaksi kimia...', 'examples': 'Api unggun.|Petasan meledak...'});

    // Materi 2
    int materialId2 = await db.insert('materials', {
      'title': 'Hukum Newton Tentang Gerak',
      'introduction': 'Kenapa kita terdorong ke depan saat mobil direm mendadak?',
      'category': 'Fisika', 'iconPath': 'assets/physics.png', 'progress': 0.8
    });
    // ...

    // Materi 3
    int materialId3 = await db.insert('materials', {
      'title': 'Struktur Sel Tumbuhan dan Hewan',
      'introduction': 'Sel adalah unit terkecil kehidupan...',
      'category': 'Biologi', 'iconPath': 'assets/biology.png', 'progress': 0.2
    });
    // ...

    // ... (Materi 4, 5, 6 tetap sama) ...
    // Materi 4
    await db.insert('materials', {
      'title': 'Dasar-dasar Rangkaian Listrik', 'introduction': 'Lampu di rumahmu bisa menyala...',
      'category': 'Fisika', 'iconPath': 'assets/physics.png', 'progress': 1.0
    });

    // Materi 5
    await db.insert('materials', {
      'title': 'Fotosintesis: Proses dan Faktor', 'introduction': 'Fotosintesis adalah cara tumbuhan "memasak"...',
      'category': 'Biologi', 'iconPath': 'assets/biology.png', 'progress': 0.0
    });

    // Materi 6
    await db.insert('materials', {
      'title': 'Tabel Periodik dan Sifat Unsur', 'introduction': 'Tabel periodik adalah "peta" untuk semua unsur...',
      'category': 'Kimia', 'iconPath': 'assets/chemistry.png', 'progress': 0.7
    });
  }

  // --- 4. FUNGSI BARU UNTUK MENGAMBIL SEMUA MATERI (TETAP SAMA) ---
  Future<List<MaterialItem>> getAllMaterials() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('materials');
    
    return List.generate(maps.length, (i) {
      return MaterialItem(
        id: maps[i]['id'],
        title: maps[i]['title'],
        category: maps[i]['category'],
        progress: (maps[i]['progress'] as num).toDouble(), // Konversi aman
        iconPath: maps[i]['iconPath'],
      );
    });
  }

  // --- 5. FUNGSI BARU UNTUK UPDATE PROGRESS (TETAP SAMA) ---
  Future<void> updateMaterialProgress(int id, double progress) async {
    final db = await instance.database;
    await db.update(
      'materials',
      {'progress': progress},
      where: 'id = ?',
      whereArgs: [id],
    );
    print("[DB Helper] Progress untuk ID $id diupdate ke $progress di database.");
  }

  // --- 6. PERBARUI getMaterialById (TETAP SAMA) ---
  Future<MaterialContent?> getMaterialById(int id) async {
    final db = await instance.database;
    var materialRes = await db.query('materials', where: 'id = ?', whereArgs: [id]);
    
    if (materialRes.isNotEmpty) {
      var materialMap = materialRes.first;
      var theoryRes = await db.query('theory_sections', where: 'material_id = ?', whereArgs: [id]);
      
      List<TheorySection> theories = theoryRes.isNotEmpty ? theoryRes.map((c) => TheorySection(
        title: c['title'] as String,
        content: c['content'] as String,
        imagePath: c['imagePath'] as String,
        examples: (c['examples'] as String).split('|'),
        // ... (data theory)
      )).toList() : [];
      
      return MaterialContent(
        title: materialMap['title'] as String,
        introduction: materialMap['introduction'] as String,
        theorySections: theories,
        progress: (materialMap['progress'] as num).toDouble(),
        // --- 3. TAMBAHKAN BARIS INI ---
        iconPath: materialMap['iconPath'] as String 
      );
    }
    return null;
  }
  // --- 7. DUA FUNGSI BARU UNTUK HISTORY (INI YANG HILANG) ---

  /// Menyimpan atau memperbarui data setting (key-value)
  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'AppSettings', // <-- Nama tabel baru
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace, // <-- Ini penting (INSERT OR REPLACE)
    );
    print("[DB Helper] Setting disimpan: $key = $value");
  }

  /// Mengambil data setting berdasarkan key
  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final maps = await db.query(
      'AppSettings', // <-- Nama tabel baru
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    } else {
      return null;
    }
  }
  Future<void> clearUserData() async {
    final db = await instance.database;
    
    // 1. Hapus setting history (Last Learned)
    await db.delete('AppSettings'); 
    
    // 2. Reset progress materi lokal ke 0
    // (Opsional, karena nanti kita akan timpa dengan data server, tapi bagus untuk kebersihan)
    await db.update('materials', {'progress': 0.0}); 
    
    print("[DB Helper] Data user lokal berhasil dibersihkan.");
  }
}