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
    //rawait deleteDatabase(path); 
    
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
  // --- FUNGSI SEEDING DATA (VERSI ULTRA PANJANG - SCROLLABLE) ---
  // --- FUNGSI SEEDING DATA (VERSI SPESIFIK & BANYAK) ---
  Future<void> _seedDatabase(Database db) async {
    print("Memulai seeding materi SPESIFIK (10 ITEM)...");

    // ==========================================
    // 1. KIMIA: Reaksi Termokimia (Fokus Panas)
    // ==========================================
    int mat1 = await db.insert('materials', {
      'title': 'Reaksi Endoterm & Eksoterm', // Judul Spesifik
      'introduction': 'Kenapa api terasa panas dan es terasa dingin? Fokus pelajari perpindahan kalor di sini.',
      'category': 'Kimia', 
      'iconPath': 'assets/chemistry.png', 
      'progress': 0.0
    });

    await db.insert('theory_sections', { 
      'material_id': mat1, 
      'title': 'Pengertian Sistem & Lingkungan', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Sistem adalah zat yang bereaksi (pusat perhatian), Lingkungan adalah segala sesuatu di sekitarnya.\nContoh: Air panas dalam gelas (Sistem), Gelas dan Udara (Lingkungan).', 
      'examples': 'Air Kopi (Sistem)|Dinding Gelas (Lingkungan)'
    });

    await db.insert('theory_sections', { 
      'material_id': mat1, 
      'title': 'Bedanya Eksoterm & Endoterm', 
      'imagePath': 'assets/chemistry.png', 
      'content': '• EKSOTERM (Keluar): Sistem melepas panas. Suhu lingkungan NAIK (jadi panas).\n• ENDOTERM (Masuk): Sistem menyerap panas. Suhu lingkungan TURUN (jadi dingin).', 
      'examples': 'Api Unggun (Eksoterm)|Es Mencair (Endoterm)'
    });


    // ==========================================
    // 2. FISIKA: Hukum Newton (Fokus Gerak)
    // ==========================================
    int mat2 = await db.insert('materials', {
      'title': 'Hukum Newton I, II, dan III', // Judul Spesifik
      'introduction': 'Kenapa kita terdorong ke depan saat direm? Pelajari 3 aturan dasar gerak di alam semesta.',
      'category': 'Fisika', 
      'iconPath': 'assets/physics.png', 
      'progress': 0.0
    });

    await db.insert('theory_sections', { 
      'material_id': mat2, 
      'title': 'Hukum I: Kelembaman', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Benda yang diam ingin tetap diam. Benda bergerak ingin terus bergerak. Ini alasan kenapa kita butuh sabuk pengaman.', 
      'examples': 'Terdorong saat direm|Menarik taplak meja tanpa menjatuhkan gelas'
    });
    
    await db.insert('theory_sections', { 
      'material_id': mat2, 
      'title': 'Hukum III: Aksi-Reaksi', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Setiap Aksi ada Reaksi yang sama besar tapi berlawanan arah. Kalau kamu pukul tembok, tembok pukul balik tanganmu.', 
      'examples': 'Mendayung perahu|Roket meluncur'
    });


    // ==========================================
    // 3. BIOLOGI: Organel Sel (Fokus Bagian Sel)
    // ==========================================
    int mat3 = await db.insert('materials', {
      'title': 'Mengenal Organel Sel', // Judul Spesifik
      'introduction': 'Apa saja isi di dalam sel? Kenalan sama Nukleus, Mitokondria, dan Ribosom.',
      'category': 'Biologi', 
      'iconPath': 'assets/biology.png', 
      'progress': 0.0
    });

    await db.insert('theory_sections', { 
      'material_id': mat3, 
      'title': 'Nukleus (Inti Sel)', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Bos dari segala aktivitas sel. Di dalamnya ada DNA (buku resep genetik) kita.', 
      'examples': 'DNA|Kromosom'
    });

    await db.insert('theory_sections', { 
      'material_id': mat3, 
      'title': 'Mitokondria (Pabrik Energi)', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Tempat pembakaran sari makanan menjadi energi (ATP). Semakin aktif kamu, semakin banyak mitokondrianya.', 
      'examples': 'Respirasi Sel|Otot punya banyak mitokondria'
    });


    // ==========================================
    // 4. BIOLOGI: Hewan vs Tumbuhan (Fokus Perbedaan)
    // ==========================================
    int mat4 = await db.insert('materials', {
      'title': 'Sel Hewan vs Sel Tumbuhan', // Judul BEDA dari yg atas
      'introduction': 'Kenapa pohon kaku tapi kucing lentur? Cari tahu perbedaan struktur sel mereka di sini.',
      'category': 'Biologi', 
      'iconPath': 'assets/biology.png', 
      'progress': 0.0
    });

    await db.insert('theory_sections', { 
      'material_id': mat4, 
      'title': 'Dinding Sel', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Hanya tumbuhan yang punya Dinding Sel dari selulosa. Ini yang bikin batang pohon keras. Hewan gak punya, makanya kulit kita lembek.', 
      'examples': 'Kayu (Keras)|Kulit (Lentur)'
    });

    await db.insert('theory_sections', { 
      'material_id': mat4, 
      'title': 'Kloroplas', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Hanya tumbuhan yang punya Kloroplas (zat hijau daun) buat memasak makanan sendiri (Fotosintesis).', 
      'examples': 'Daun Hijau|Fotosintesis'
    });


    // ==========================================
    // 5. FISIKA: Rangkaian Listrik (Fokus Circuit)
    // ==========================================
    int mat5 = await db.insert('materials', {
      'title': 'Rangkaian Seri & Paralel',
      'introduction': 'Cara menyusun kabel itu ada seninya. Salah pasang, satu lampu mati, serumah gelap!',
      'category': 'Fisika', 
      'iconPath': 'assets/physics.png', 
      'progress': 0.0
    });

    await db.insert('theory_sections', { 
      'material_id': mat5, 
      'title': 'Rangkaian Seri', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Disusun sejajar. Hemat kabel, tapi kalau satu putus, semua mati. Lampunya juga lebih redup.', 
      'examples': 'Lampu hias murah|Senter lama'
    });

    await db.insert('theory_sections', { 
      'material_id': mat5, 
      'title': 'Rangkaian Paralel', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Disusun bercabang. Boros kabel, tapi kalau satu putus, yang lain tetap nyala. Ini standar rumah PLN.', 
      'examples': 'Listrik Rumah|Lampu Merah'
    });


    // ==========================================
    // 6. KIMIA: Atom (Fokus Struktur)
    // ==========================================
    int mat6 = await db.insert('materials', {
      'title': 'Struktur Atom (Proton, Elektron)',
      'introduction': 'Bedah isi benda terkecil di dunia. Apa itu Proton, Neutron, dan Elektron?',
      'category': 'Kimia', 
      'iconPath': 'assets/chemistry.png', 
      'progress': 0.0
    });

    await db.insert('theory_sections', { 
      'material_id': mat6, 
      'title': 'Isi Dalam Atom', 
      'imagePath': 'assets/chemistry.png', 
      'content': '• PROTON (+): Di tengah (inti).\n• NEUTRON (0): Di tengah (inti).\n• ELEKTRON (-): Muter-muter di luar (kulit).', 
      'examples': 'Inti Atom|Kulit Atom'
    });


    // ==========================================
    // 7. KIMIA: Tabel Periodik (Fokus Unsur)
    // ==========================================
    int mat7 = await db.insert('materials', {
      'title': 'Membaca Tabel Periodik', // Judul Baru
      'introduction': 'Cara baca peta unsur kimia. Mana Logam, mana Gas Mulia, mana yang meledak kena air.',
      'category': 'Kimia', 
      'iconPath': 'assets/chemistry.png', 
      'progress': 0.0
    });

    await db.insert('theory_sections', { 
      'material_id': mat7, 
      'title': 'Golongan Gas Mulia', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Unsur paling sombong (Stabil). Gak mau bereaksi sama yang lain. Contoh: Helium buat balon.', 
      'examples': 'Helium|Neon|Argon'
    });


    // ==========================================
    // 8. BIOLOGI: Enzim (Fokus Kimia Tubuh)
    // ==========================================
    int mat8 = await db.insert('materials', {
      'title': 'Cara Kerja Enzim',
      'introduction': 'Mandor dalam tubuh kita. Tanpa dia, pencernaan butuh waktu 50 tahun!',
      'category': 'Biologi', 
      'iconPath': 'assets/biology.png', 
      'progress': 0.0
    });

    await db.insert('theory_sections', { 
      'material_id': mat8, 
      'title': 'Lock and Key', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Enzim itu spesifik kayak Kunci dan Gembok. Enzim lemak cuma mau mecah lemak, gak mau mecah protein.', 
      'examples': 'Lipase (Lemak)|Amilase (Gula)'
    });


    // ==========================================
    // 9. FISIKA: Besaran & Satuan (Dasar)
    // ==========================================
    int mat9 = await db.insert('materials', {
      'title': 'Besaran Pokok & Turunan', // Materi Baru
      'introduction': 'Jangan salah sebut Berat dengan Massa! Pelajari satuan fisika yang benar di sini.',
      'category': 'Fisika', 
      'iconPath': 'assets/physics.png', 
      'progress': 0.0
    });

    await db.insert('theory_sections', { 
      'material_id': mat9, 
      'title': 'Massa vs Berat', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Massa (Kg) itu tetap dimana-mana. Berat (Newton) itu tergantung gravitasi. Di bulan, beratmu turun, massamu tetap.', 
      'examples': 'Timbangan Badan|Astronot'
    });


    // ==========================================
    // 10. BIOLOGI: Virus (Kesehatan)
    // ==========================================
    int mat10 = await db.insert('materials', {
      'title': 'Virus dan Bakteri', // Materi Baru
      'introduction': 'Apa bedanya Flu sama Infeksi Luka? Kenalan sama makhluk mikroskopis ini.',
      'category': 'Biologi', 
      'iconPath': 'assets/biology.png', 
      'progress': 0.0
    });

    await db.insert('theory_sections', { 
      'material_id': mat10, 
      'title': 'Virus itu Unik', 
      'imagePath': 'assets/chemistry.png', 
      'content': 'Virus bukan makhluk hidup seutuhnya. Dia butuh inang (tubuh kita) buat hidup. Antibiotik gak mempan buat virus!', 
      'examples': 'Influenza|Covid-19'
    });

    print("Seeding selesai! Total 10 Materi.");
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