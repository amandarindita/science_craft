import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../controllers/admin_controller.dart';
import '../../../routes/app_pages.dart';

class AdminView extends GetView<AdminController> {
  // Helper warna & Style
  final Color primaryColor = Colors.indigo;
  final Color bgColor = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller ter-inject
    Get.put(AdminController());

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Admin Panel", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Keluar",
            onPressed: () {
              Get.defaultDialog(
                title: "Keluar Admin?",
                middleText: "Sesi kamu akan berakhir.",
                textConfirm: "Ya, Keluar",
                textCancel: "Batal",
                confirmTextColor: Colors.white,
                buttonColor: Colors.redAccent,
                onConfirm: () => Get.offAllNamed(Routes.LOGIN),
              );
            },
          )
        ],
      ),
      // Gunakan scrollController dari controller agar bisa auto-scroll saat edit
      body: SingleChildScrollView(
        controller: controller.scrollController, 
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- TAB SELECTOR (Navigasi Atas) ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  _customTabBtn(0, "Materi", Icons.book),
                  _customTabBtn(1, "FunFact", Icons.lightbulb),
                  _customTabBtn(2, "Kuis", Icons.quiz),
                ],
              ),
            ),
            
            const SizedBox(height: 25),

            // --- CONTENT AREA (Ganti-ganti isi sesuai Tab) ---
            Obx(() {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentForm(),
              );
            }),
            
            const SizedBox(height: 50), // Jarak bawah biar scroll enak
          ],
        ),
      ),
    );
  }

  // Logic Switch Form
  Widget _buildCurrentForm() {
    if (controller.currentTab.value == 0) return _formMateri();
    if (controller.currentTab.value == 1) return _formFunFact();
    return _formKuis();
  }

  // Widget Tombol Tab Custom
  Widget _customTabBtn(int index, String title, IconData icon) {
    return Expanded(
      child: Obx(() {
        bool isActive = controller.currentTab.value == index;
        return GestureDetector(
          onTap: () {
             controller.currentTab.value = index;
             // Reset form kalau pindah tab, biar bersih
             if (index == 0) controller.resetMaterialForm(); 
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: isActive ? Colors.white : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Helper Input Decoration biar rapi
  InputDecoration _inputDecor(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // ==========================================
  // 1. FORM MATERI (LENGKAP: Input + List + Search)
  // ==========================================
  Widget _formMateri() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- A. BANNER MODE EDIT (Muncul cuma pas edit) ---
        Obx(() {
          if (controller.isEditMode.value) {
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.orange),
                  const SizedBox(width: 10),
                  const Expanded(child: Text("Mode Edit Aktif: Mengubah data lama", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold))),
                  TextButton(
                    onPressed: controller.resetMaterialForm,
                    child: const Text("Batal", style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // --- B. FORM INPUT UTAMA ---
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(controller: controller.titleController, decoration: _inputDecor("Judul Materi")),
                const SizedBox(height: 15),
                InputDecorator(
                  decoration: _inputDecor("Kategori"),
                  child: DropdownButtonHideUnderline(
                    child: Obx(() => DropdownButton<String>(
                      isDense: true,
                      value: controller.selectedCategory.value,
                      items: controller.categories.map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (val) => controller.selectedCategory.value = val!,
                    )),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(controller: controller.introController, decoration: _inputDecor("Intro Singkat"), maxLines: 2),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // --- C. DYNAMIC SECTIONS (SUB-BAB Loop) ---
        Obx(() => Column(
          children: List.generate(controller.sections.length, (i) {
            if (i >= controller.sectionQuillControllers.length) return Container();
            
            return Container(
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Sub-bab
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Text("Sub-Bab #${i + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => controller.removeSection(i),
                          )
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          // Trick agar cursor ga lompat saat ngetik di list dynamic
                          controller: TextEditingController(text: controller.sections[i]['title'])
                            ..selection = TextSelection.fromPosition(TextPosition(offset: controller.sections[i]['title']?.length ?? 0)),
                          decoration: _inputDecor("Judul Sub-Bab"),
                          onChanged: (v) => controller.updateSection(i, 'title', v),
                        ),
                        const SizedBox(height: 15),

                        // --- UPLOAD GAMBAR SUB-BAB ---
                        Obx(() {
                          String? imagePath = controller.sections[i]['image_path'];
                          bool hasImage = imagePath != null && imagePath.isNotEmpty;
                          bool isUrl = hasImage && (imagePath.startsWith('http') || imagePath.contains('assets'));
                          File? imageFile = (hasImage && !isUrl) ? File(imagePath) : null;

                          return Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: hasImage
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: isUrl 
                                        ? Image.asset("assets/placeholder.png", width: double.infinity, height: double.infinity, fit: BoxFit.cover) // Ganti placeholder kalau URL
                                        : Image.file(imageFile!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      top: 8, right: 8,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 18,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                          onPressed: () => controller.removeImageFromSection(i),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : InkWell(
                                  onTap: () => controller.pickImageForSection(i),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      Text("Tambah Gambar", style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                          );
                        }),
                        const SizedBox(height: 15),

                        // --- TEXT EDITOR (Quill) ---
                        const Align(alignment: Alignment.centerLeft, child: Text("Isi Materi:", style: TextStyle(fontWeight: FontWeight.bold))),
                        const SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              QuillSimpleToolbar(
                                controller: controller.sectionQuillControllers[i],
                                configurations: const QuillSimpleToolbarConfigurations(
                                  showFontFamily: false, showFontSize: false, showSearchButton: false, 
                                  showInlineCode: false, showCodeBlock: false, multiRowsDisplay: false,
                                ),
                              ),
                              const Divider(height: 1),
                              SizedBox(
                                height: 200,
                                child: QuillEditor.basic(
                                  controller: controller.sectionQuillControllers[i],
                                  configurations: const QuillEditorConfigurations(padding: EdgeInsets.all(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          decoration: _inputDecor("Contoh (Opsional)"),
                          onChanged: (v) => controller.updateSection(i, 'examples', v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        )),

        // Tombol Tambah Sub-Bab
        OutlinedButton.icon(
          onPressed: controller.addSectionField,
          icon: const Icon(Icons.add),
          label: const Text("Tambah Sub-Bab Lagi"),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
        ),
        const SizedBox(height: 15),
        
        // Tombol SIMPAN / UPDATE (Dynamic Text & Color)
        Obx(() => ElevatedButton(
          onPressed: controller.saveMaterial,
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isEditMode.value ? Colors.orange : Colors.indigo,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          child: Text(
            controller.isEditMode.value ? "UPDATE MATERI" : "SIMPAN MATERI BARU",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
          ),
        )),

        const SizedBox(height: 40),
        const Divider(thickness: 2),
        const SizedBox(height: 10),

        // ==========================================
        // D. LIST MATERI & PENCARIAN (New Feature)
        // ==========================================
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Daftar Materi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            Obx(() => Text("${controller.materialsList.length} Total", style: TextStyle(color: Colors.grey[600]))),
          ],
        ),
        const SizedBox(height: 15),

        // 1. SEARCH BAR
        TextField(
          onChanged: (val) => controller.searchText.value = val, // Update keyword di controller
          decoration: InputDecoration(
            hintText: "Cari judul materi...",
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            suffixIcon: Obx(() => controller.searchText.value.isNotEmpty 
              ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => controller.searchText.value = '')
              : const SizedBox.shrink()),
          ),
        ),
        const SizedBox(height: 15),

        // 2. LIST VIEW (Filtered)
        Obx(() {
          // Logic Filter sederhana di View (bisa dipindah ke controller nanti)
          var filtered = controller.materialsList.where((m) {
             var keyword = controller.searchText.value.toLowerCase();
             var title = m['title'].toString().toLowerCase();
             return title.contains(keyword);
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Materi tidak ditemukan.", style: TextStyle(color: Colors.grey[500])),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Scroll ikut body utama
            itemCount: filtered.length,
            separatorBuilder: (_,__) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              var item = filtered[i];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: const Offset(0,2))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(item['category']),
                    child: Icon(_getCategoryIcon(item['category']), color: Colors.white, size: 20),
                  ),
                  title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['category'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: "Edit",
                        onPressed: () => controller.editMaterial(item), // Panggil fungsi Edit
                      ),
                      // Tombol Hapus
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: "Hapus",
                        onPressed: () => controller.deleteMaterial(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  // Helper Warna Kategori
  Color _getCategoryColor(String? cat) {
    if (cat == 'Fisika') return Colors.blue;
    if (cat == 'Biologi') return Colors.green;
    if (cat == 'Kimia') return Colors.purple;
    return Colors.grey;
  }
  IconData _getCategoryIcon(String? cat) {
    if (cat == 'Fisika') return Icons.bolt;
    if (cat == 'Biologi') return Icons.spa;
    if (cat == 'Kimia') return Icons.science;
    return Icons.book;
  }

  // ==========================================
  // 2. FORM FUNFACT (Simple Input + List)
  // ==========================================
  // ==========================================
  // 2. FORM FUNFACT (REVISI: BISA EDIT)
  // ==========================================
  Widget _formFunFact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- BANNER MODE EDIT ---
        Obx(() {
          if (controller.isFunFactEditMode.value) {
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.orange),
                  const SizedBox(width: 10),
                  const Expanded(child: Text("Mode Edit FunFact", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold))),
                  InkWell(
                    onTap: controller.resetFunFactForm,
                    child: const Text("Batal", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        Card(
          color: Colors.amber[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.amber.shade200)),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(child: Text("Info: FunFact akan muncul secara acak di halaman home siswa.", style: TextStyle(color: Colors.brown))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        TextField(
          controller: controller.ffDescController, 
          decoration: _inputDecor("Isi Fakta Unik", hint: "Contoh: Tahukah kamu, madu tidak pernah basi?"), 
          maxLines: 3
        ),
        const SizedBox(height: 15),
        
        // Tombol Simpan / Update
        Obx(() => ElevatedButton.icon(
          icon: Icon(controller.isFunFactEditMode.value ? Icons.update : Icons.save, color: Colors.white),
          label: Text(controller.isFunFactEditMode.value ? "UPDATE FUNFACT" : "SIMPAN FUNFACT", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isFunFactEditMode.value ? Colors.orange : Colors.green, 
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          onPressed: () => controller.saveFunFact(), // Panggil pakai arrow function biar aman
        )),

        const Divider(height: 40, thickness: 1),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("List FunFact Aktif:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Obx(() => Text("Total: ${controller.funFactsList.length}", style: TextStyle(color: Colors.grey[600]))),
          ],
        ),
        const SizedBox(height: 10),
        
        // List FunFact
        Obx(() => ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.funFactsList.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            var item = controller.funFactsList[i];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(item['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange), 
                      onPressed: () => controller.editFunFact(item)
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red), 
                      onPressed: () => controller.deleteFunFact(item['id'])
                    ),
                  ],
                ),
              ),
            );
          },
        ))
      ],
    );
  }

  // =// ==========================================
  // 3. FORM KUIS (REVISI: COUNTER & EDIT MODE)
  // ==========================================
  Widget _formKuis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- DROPDOWN PEMILIH MATERI ---
        Card(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: InputDecorator(
              decoration: const InputDecoration(
                border: InputBorder.none, 
                labelText: "Materi Soal",
                icon: Icon(Icons.book, color: Colors.indigo),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() => DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text("Pilih Materi yang mau dibuatkan soal..."),
                  value: controller.selectedMaterialId.value,
                  items: controller.materialsList.map((e) => DropdownMenuItem<int>(
                    value: e['id'], 
                    child: Text(e['title'], style: const TextStyle(fontWeight: FontWeight.bold))
                  )).toList(),
                  onChanged: (v) => controller.selectedMaterialId.value = v,
                )),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // --- FORM INPUT ---
        // Cek apakah user sudah pilih materi?
        Obx(() {
          if (controller.selectedMaterialId.value == null) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.arrow_upward, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text("Pilih materi di atas dulu ya!", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Banner Edit Mode
              if (controller.isQuizEditMode.value)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange)),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Expanded(child: Text("Sedang Mengedit Soal", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold))),
                      InkWell(
                        onTap: controller.resetQuizForm,
                        child: const Text("Batal", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),

              // Form Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header Form
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Form Soal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          // Counter Jumlah Soal
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                            child: Text("Total: ${controller.quizzesList.length} Soal", style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 10),

                      TextField(controller: controller.questionController, decoration: _inputDecor("Pertanyaan", hint: "Contoh: Apa satuan gaya?"), maxLines: 2),
                      const SizedBox(height: 15),
                      
                      // Opsi Jawaban (Grid 2x2 biar hemat tempat)
                      Row(
                        children: [
                          Expanded(child: TextField(controller: controller.optionAController, decoration: _inputDecor("Opsi A", hint: "Jawaban A..."))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: controller.optionBController, decoration: _inputDecor("Opsi B", hint: "Jawaban B..."))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: controller.optionCController, decoration: _inputDecor("Opsi C", hint: "Jawaban C..."))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: controller.optionDController, decoration: _inputDecor("Opsi D", hint: "Jawaban D..."))),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      const Text("Kunci Jawaban Benar:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['A','B','C','D'].map((e) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: InkWell(
                            onTap: () => controller.correctAnswer.value = e,
                            borderRadius: BorderRadius.circular(50),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: controller.correctAnswer.value == e ? primaryColor : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: controller.correctAnswer.value == e ? primaryColor : Colors.grey.shade300),
                                boxShadow: [if(controller.correctAnswer.value == e) BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 6, offset: const Offset(0,2))]
                              ),
                              child: Text(e, style: TextStyle(fontWeight: FontWeight.bold, color: controller.correctAnswer.value == e ? Colors.white : Colors.grey[600])),
                            ),
                          ),
                        )).toList(),
                      ),

                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.saveQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.isQuizEditMode.value ? Colors.orange : primaryColor, 
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: Text(
                            controller.isQuizEditMode.value ? "UPDATE SOAL" : "TAMBAH SOAL KE LIST",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // --- LIST SOAL PREVIEW ---
              Row(
                children: [
                  const Icon(Icons.list_alt, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text("Daftar Soal (${controller.quizzesList.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),

              if (controller.quizzesList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text("Belum ada soal dibuat untuk materi ini.", style: TextStyle(color: Colors.grey[500])),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.quizzesList.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    var item = controller.quizzesList[i];
                    bool isEditingThis = controller.isQuizEditMode.value && controller.editingQuizId.value == item['id'];

                    return Container(
                      decoration: BoxDecoration(
                        color: isEditingThis ? Colors.orange[50] : Colors.white,
                        border: isEditingThis ? Border.all(color: Colors.orange) : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))]
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo[50], 
                          child: Text("${i+1}", style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold))
                        ),
                        title: Text(item['question'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(4)),
                                child: Text("Kunci: ${item['correct_answer']}", style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              tooltip: "Edit Soal",
                              onPressed: () => controller.editQuiz(item), // Panggil Controller Edit
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: "Hapus",
                              onPressed: () => controller.deleteQuiz(item['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
              const SizedBox(height: 50),
            ],
          );
        }),
      ],
    );
  }
}