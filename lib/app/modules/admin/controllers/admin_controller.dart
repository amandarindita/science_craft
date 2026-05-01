import 'dart:convert'; // Untuk encode/decode JSON
import 'dart:io';      // WAJIB ADA: Untuk menangani File gambar
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart'; // Rich Text Editor
import 'package:image_picker/image_picker.dart';   // Ambil gambar dari galeri
import 'package:path_provider/path_provider.dart'; // Cari folder penyimpanan HP
import 'package:path/path.dart' as p;            // Manajemen nama file
import '../../../data/db/database_helper.dart';

class AdminController extends GetxController {
  // --- VARIABLES UI HELPER ---
  var currentTab = 0.obs;
  var searchText = ''.obs; // Keyword pencarian
  var isEditMode = false.obs; // Status lagi edit atau input baru (Materi)
  var editingId = 0.obs; // ID materi yang lagi diedit
  final ScrollController scrollController = ScrollController(); // Buat auto-scroll view

  // --- MATERI ---
  final titleController = TextEditingController();
  final introController = TextEditingController();
  var selectedCategory = 'Biologi'.obs;
  final List<String> categories = ['Biologi', 'Fisika', 'Kimia'];
  
  // List data mentah untuk DB
  // Struktur: {title, content (json), examples, image_path}
  var sections = <Map<String, String>>[].obs; 
  
  // List khusus untuk mengontrol Editor "MS Word"
  var sectionQuillControllers = <QuillController>[].obs;

  var materialsList = <Map<String, dynamic>>[].obs;

  // --- KUIS ---
  var selectedMaterialId = Rxn<int>(); 
  final questionController = TextEditingController();
  final optionAController = TextEditingController();
  final optionBController = TextEditingController();
  final optionCController = TextEditingController();
  final optionDController = TextEditingController();
  var correctAnswer = 'A'.obs;
  var quizzesList = <Map<String, dynamic>>[].obs;
  
  // Variabel Edit Mode Kuis
  var isQuizEditMode = false.obs;
  var editingQuizId = 0.obs;

  // --- FUNFACT ---
  final ffDescController = TextEditingController();
  var funFactsList = <Map<String, dynamic>>[].obs;
  
  // Variabel Edit Mode FunFact
  var isFunFactEditMode = false.obs;
  var editingFunFactId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    addSectionField(); // Default ada 1 sub-bab kosong
    loadData();

    // Auto load kuis kalau dropdown materi dipilih
    ever(selectedMaterialId, (id) {
      if (id != null) loadQuizzes(id);
    });
  }

  // ==========================================
  // 1. LOGIC UTAMA: CRUD MATERI
  // ==========================================

  // A. Tambah Form Sub-Bab Baru (Kosong)
  void addSectionField() {
    sections.add({
      'title': '', 
      'content': '', 
      'examples': '', 
      'image_path': '' 
    }); 
    sectionQuillControllers.add(QuillController.basic());
  }

  // B. Update Data Lokal (Judul Subbab / Contoh)
  void updateSection(int i, String key, String value) {
    var newMap = Map<String, String>.from(sections[i]);
    newMap[key] = value;
    sections[i] = newMap;
  }

  // C. Ambil Gambar dari Galeri
  Future<void> pickImageForSection(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      String fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String savedPath = p.join(directory.path, fileName);

      // Simpan file ke folder internal aplikasi
      await File(image.path).copy(savedPath);

      // Simpan path ke memory
      updateSection(index, 'image_path', savedPath);
      
      Get.snackbar("Berhasil", "Gambar berhasil ditambahkan!", 
        backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  // D. Hapus Gambar (Path saja)
  void removeImageFromSection(int index) {
    updateSection(index, 'image_path', '');
  }

  // E. Hapus Sub-Bab dari Form
  void removeSection(int i) {
    if (sections.length > 1) {
      sections.removeAt(i);
      sectionQuillControllers[i].dispose(); 
      sectionQuillControllers.removeAt(i);
    } else {
      Get.snackbar("Info", "Minimal harus ada satu sub-bab.");
    }
  }

  // F. SIMPAN DATA (Bisa Insert Baru atau Update)
  Future<void> saveMaterial() async {
    if (titleController.text.isEmpty) {
      Get.snackbar("Error", "Judul materi wajib diisi");
      return;
    }

    // 1. Convert isi Editor Quill ke JSON String sebelum simpan
    for (int i = 0; i < sections.length; i++) {
      var delta = sectionQuillControllers[i].document.toDelta();
      String jsonContent = jsonEncode(delta.toJson());
      updateSection(i, 'content', jsonContent);
    }

    if (isEditMode.value) {
      // --- LOGIC UPDATE ---
      await DatabaseHelper.instance.updateMaterial(
        editingId.value,
        titleController.text,
        introController.text,
        selectedCategory.value,
        sections
      );
      Get.snackbar("Updated", "Materi berhasil diperbarui!", backgroundColor: Colors.orange, colorText: Colors.white);
    } else {
      // --- LOGIC INSERT BARU ---
      await DatabaseHelper.instance.addMaterial(
        titleController.text, 
        introController.text, 
        selectedCategory.value, 
        sections
      );
      Get.snackbar("Sukses", "Materi baru tersimpan!", backgroundColor: Colors.green, colorText: Colors.white);
    }
    
    resetMaterialForm(); // Bersihkan form setelah simpan
    loadData(); // Refresh list di bawah
  }

  // G. EDIT MODE: Load Data dari DB ke Form
  Future<void> editMaterial(Map<String, dynamic> item) async {
    // 1. Set Status Edit
    isEditMode.value = true;
    editingId.value = item['id'];

    // 2. Isi Form Utama
    titleController.text = item['title'];
    introController.text = item['intro'] ?? '';
    selectedCategory.value = item['category'];

    // 3. Ambil Detail Sub-Bab dari DB
    var dbSections = await DatabaseHelper.instance.getSectionsByMaterialId(item['id']);
    
    // 4. Bersihkan Form Lama
    sections.clear();
    sectionQuillControllers.clear();

    // 5. Masukkan Data Lama ke Controller
    if (dbSections.isNotEmpty) {
      for (var s in dbSections) {
        sections.add({
          'title': s['title'] ?? '',
          'content': s['content'] ?? '', 
          'examples': s['examples'] ?? '',
          'image_path': s['image_path'] ?? ''
        });

        try {
          var json = jsonDecode(s['content']);
          sectionQuillControllers.add(
            QuillController(
              document: Document.fromJson(json),
              selection: const TextSelection.collapsed(offset: 0)
            )
          );
        } catch (e) {
          // Fallback kalau JSON rusak/kosong
          sectionQuillControllers.add(QuillController.basic());
        }
      }
    } else {
      // Jaga-jaga kalau materinya gada sub-bab (biar ga error)
      addSectionField();
    }

    // 6. Scroll Layar ke Paling Atas (Biar admin sadar form sudah terisi)
    if (scrollController.hasClients) {
      scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  // H. RESET FORM (Dipakai tombol Batal / Selesai Simpan)
  void resetMaterialForm() {
    isEditMode.value = false;
    editingId.value = 0;
    titleController.clear();
    introController.clear();
    
    // Reset sections ke default 1 kosong
    sections.clear();
    sectionQuillControllers.clear();
    addSectionField(); 
  }

  // I. DELETE
  Future<void> deleteMaterial(int id) async {
    Get.defaultDialog(
      title: "Hapus Materi?",
      middleText: "Materi dan semua sub-bab akan hilang permanen.",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await DatabaseHelper.instance.deleteMaterial(id);
        loadData();
        Get.back(); // Tutup dialog
        Get.snackbar("Dihapus", "Materi telah dihapus.");
      },
      textCancel: "Batal"
    );
  }
  
  // ==========================================
  // 2. DATABASE HELPERS (LOAD DATA)
  // ==========================================
   void loadData() async {
    final db = await DatabaseHelper.instance.database;
    materialsList.value = await db.query('materials', orderBy: 'id DESC');
    funFactsList.value = await db.query('funfacts', orderBy: 'id DESC');
  }

  void loadQuizzes(int materialId) async {
    final data = await DatabaseHelper.instance.getQuizzesByMaterial(materialId);
    quizzesList.assignAll(data);
  }

  // ==========================================
  // 3. LOGIC KUIS
  // ==========================================
  
  // 1. Simpan (Bisa Add atau Update)
  Future<void> saveQuiz() async {
    if (selectedMaterialId.value == null) {
       Get.snackbar("Error", "Pilih materi dulu!"); return;
    }
    if (questionController.text.isEmpty) {
       Get.snackbar("Error", "Pertanyaan wajib diisi!"); return;
    }

    if (isQuizEditMode.value) {
      // MODE UPDATE
      await DatabaseHelper.instance.updateQuiz(
        editingQuizId.value,
        selectedMaterialId.value!,
        questionController.text,
        optionAController.text, optionBController.text, 
        optionCController.text, optionDController.text, 
        correctAnswer.value
      );
      Get.snackbar("Sukses", "Soal berhasil diperbarui!", backgroundColor: Colors.orange, colorText: Colors.white);
    } else {
      // MODE TAMBAH BARU
      await DatabaseHelper.instance.addQuiz(
        selectedMaterialId.value!, questionController.text,
        optionAController.text, optionBController.text, 
        optionCController.text, optionDController.text, correctAnswer.value
      );
      Get.snackbar("Sukses", "Soal ditambahkan!", backgroundColor: Colors.green, colorText: Colors.white);
    }
    
    resetQuizForm();
    loadQuizzes(selectedMaterialId.value!);
  }

  // 2. Fungsi Load Data ke Form (Saat tombol pensil diklik)
  void editQuiz(Map<String, dynamic> item) {
    isQuizEditMode.value = true;
    editingQuizId.value = item['id'];
    
    questionController.text = item['question'];
    optionAController.text = item['option_a'];
    optionBController.text = item['option_b'];
    optionCController.text = item['option_c'];
    optionDController.text = item['option_d'];
    correctAnswer.value = item['correct_answer'];
    
    // Scroll ke form (Optional, pakai scrollController yg udah ada)
    if(scrollController.hasClients) {
      scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // 3. Reset Form Jadi Kosong
  void resetQuizForm() {
    isQuizEditMode.value = false;
    editingQuizId.value = 0;
    questionController.clear(); 
    optionAController.clear();
    optionBController.clear(); 
    optionCController.clear(); 
    optionDController.clear();
    correctAnswer.value = 'A'; // Reset default
  }

  Future<void> deleteQuiz(int id) async {
    await DatabaseHelper.instance.deleteQuiz(id);
    if(selectedMaterialId.value != null) loadQuizzes(selectedMaterialId.value!);
    Get.snackbar("Dihapus", "Soal kuis dihapus.");
  }

  // ==========================================
  // 4. LOGIC FUNFACT (FULL)
  // ==========================================
  
  // 1. Simpan / Update FunFact
  Future<void> saveFunFact() async {
    if (ffDescController.text.isEmpty) {
      Get.snackbar("Error", "Isi fakta unik tidak boleh kosong!");
      return;
    }

    if (isFunFactEditMode.value) {
      // MODE UPDATE
      await DatabaseHelper.instance.updateFunFact(editingFunFactId.value, "Tahukah Kamu?", ffDescController.text);
      Get.snackbar("Sukses", "FunFact berhasil diupdate!", backgroundColor: Colors.orange, colorText: Colors.white);
    } else {
      // MODE SIMPAN BARU
      await DatabaseHelper.instance.addFunFact("Tahukah Kamu?", ffDescController.text);
      Get.snackbar("Sukses", "FunFact tersimpan!", backgroundColor: Colors.green, colorText: Colors.white);
    }

    resetFunFactForm();
    loadData(); // Reload list
  }

  // 2. Edit (Load to Form)
  void editFunFact(Map<String, dynamic> item) {
    isFunFactEditMode.value = true;
    editingFunFactId.value = item['id'];
    ffDescController.text = item['description'];
  }

  // 3. Reset Form
  void resetFunFactForm() {
    isFunFactEditMode.value = false;
    editingFunFactId.value = 0;
    ffDescController.clear();
  }

  // 4. Delete
  Future<void> deleteFunFact(int id) async {
    await DatabaseHelper.instance.deleteFunFact(id);
    loadData();
    Get.snackbar("Dihapus", "FunFact dihapus.");
  }
}