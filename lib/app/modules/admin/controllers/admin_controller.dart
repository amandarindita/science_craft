import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/db/database_helper.dart';

class AdminController extends GetxController {
  var currentTab = 0.obs;

  // --- MATERI ---
  final titleController = TextEditingController();
  final introController = TextEditingController();
  var selectedCategory = 'Biologi'.obs;
  final List<String> categories = ['Biologi', 'Fisika', 'Kimia'];
  var sections = <Map<String, String>>[].obs;
  var materialsList = <Map<String, dynamic>>[].obs;

  // --- KUIS ---
  var selectedMaterialId = Rxn<int>(); 
  final questionController = TextEditingController();
  final optionAController = TextEditingController();
  final optionBController = TextEditingController();
  final optionCController = TextEditingController();
  final optionDController = TextEditingController();
  var correctAnswer = 'A'.obs;
  // List Preview Kuis (Akan berubah sesuai materi yg dipilih)
  var quizzesList = <Map<String, dynamic>>[].obs;

  // --- FUNFACT ---
  final ffDescController = TextEditingController();
  var funFactsList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    addSectionField(); 
    loadData();

    // Listener: Kalau Admin ganti pilihan materi di Tab Kuis,
    // otomatis update list soal di bawahnya
    ever(selectedMaterialId, (id) {
      if (id != null) loadQuizzes(id);
    });
  }

  void loadData() async {
    final db = await DatabaseHelper.instance.database;
    // Load Materi
    materialsList.value = await db.query('materials', orderBy: 'id DESC');
    // Load FunFact
    funFactsList.value = await db.query('funfacts', orderBy: 'id DESC');
  }

  void loadQuizzes(int materialId) async {
    final data = await DatabaseHelper.instance.getQuizzesByMaterial(materialId);
    quizzesList.assignAll(data);
  }

  // --- LOGIC MATERI ---
  void addSectionField() => sections.add({'title': '', 'content': '', 'examples': ''});
  void updateSection(int i, String k, String v) {
    var newMap = Map<String, String>.from(sections[i]);
    newMap[k] = v;
    sections[i] = newMap;
  }
  void removeSection(int i) { if (sections.length > 1) sections.removeAt(i); }

  Future<void> saveMaterial() async {
    if (titleController.text.isEmpty) return;
    await DatabaseHelper.instance.addMaterial(titleController.text, introController.text, selectedCategory.value, sections);
    Get.snackbar("Sukses", "Materi tersimpan!", backgroundColor: Colors.green, colorText: Colors.white);
    titleController.clear(); introController.clear(); sections.clear(); addSectionField();
    loadData();
  }

  Future<void> deleteMaterial(int id) async {
    await DatabaseHelper.instance.deleteMaterial(id);
    loadData();
    Get.snackbar("Dihapus", "Materi dihapus.");
  }

  // --- LOGIC KUIS ---
  Future<void> saveQuiz() async {
    if (selectedMaterialId.value == null) {
      Get.snackbar("Error", "Pilih materi dulu!");
      return;
    }
    await DatabaseHelper.instance.addQuiz(
      selectedMaterialId.value!, questionController.text,
      optionAController.text, optionBController.text, 
      optionCController.text, optionDController.text, correctAnswer.value
    );
    Get.snackbar("Sukses", "Soal tersimpan!", backgroundColor: Colors.green, colorText: Colors.white);
    questionController.clear(); optionAController.clear();
    optionBController.clear(); optionCController.clear(); optionDController.clear();
    
    // Refresh list kuis
    loadQuizzes(selectedMaterialId.value!);
  }

  Future<void> deleteQuiz(int id) async {
    await DatabaseHelper.instance.deleteQuiz(id);
    if(selectedMaterialId.value != null) loadQuizzes(selectedMaterialId.value!);
    Get.snackbar("Dihapus", "Soal kuis dihapus.");
  }

  // --- LOGIC FUNFACT ---
  Future<void> saveFunFact() async {
    if (ffDescController.text.isEmpty) return;
    await DatabaseHelper.instance.addFunFact("Tahukah Kamu?", ffDescController.text);
    Get.snackbar("Sukses", "FunFact tersimpan!", backgroundColor: Colors.green, colorText: Colors.white);
    ffDescController.clear();
    loadData();
  }

  Future<void> deleteFunFact(int id) async {
    await DatabaseHelper.instance.deleteFunFact(id);
    loadData();
    Get.snackbar("Dihapus", "FunFact dihapus.");
  }
}