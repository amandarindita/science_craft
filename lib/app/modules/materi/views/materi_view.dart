import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';

// Pastikan import ini sesuai dengan lokasi file kamu
import '../controllers/materi_controller.dart';
import '../../../models/material_model.dart'; 

class MaterialDetailView extends GetView<MaterialDetailController> {
  const MaterialDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND PATTERN & BASE COLOR
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F6FA), // Base background color
              image: DecorationImage(
                image: AssetImage('assets/pattern.png'),
                repeat: ImageRepeat.repeat,
                opacity: 0.05, // Dibikin lebih soft dikit biar konten lebih menonjol
                scale: 1.0,
              ),
            ),
          ),

          // 2. KONTEN UTAMA (Scrollable)
          SingleChildScrollView(
            controller: controller.scrollController,
            child: Stack(
              children: [
                // BACKGROUND BIRU HEADER (Dibikin melengkung dan tingginya pas biar numpuk di card kuning)
                Container(
                  height: 240, 
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4285F4), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),

                // ISI KONTEN
                SafeArea(
                  child: Column(
                    children: [
                      // Header (Back button & Title)
                      _buildHeader(),
                      const SizedBox(height: 15), // Jarak antara judul dan card kuning
                      
                      Obx(() {
                        if (controller.materialContent.value == null) {
                          return _buildLoading();
                        }

                        final content = controller.materialContent.value!;
                        return Column(
                          children: [
                            // Card Intro Kuning (Numpuk di garis batas biru)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _buildIntroductionCard(content.introduction),
                            ),
                            const SizedBox(height: 24),
                            
                            // List Theory Cards (Materi)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: content.theorySections
                                    .map((section) => TheoryCardWidget(section: section))
                                    .toList(),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Tombol Aksi Bawah
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _buildActionButtons(),
                            ),
                            const SizedBox(height: 50),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildHeader() {
    return Padding(
      // Layout Row persis seperti desain (Icon kiri, teks tengah rata)
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28), 
            onPressed: () => controller.saveAndReturn(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0), 
              child: Obx(() => Text(
                controller.materialContent.value?.title ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              )),
            ),
          ),
          const SizedBox(width: 48), // Ruang kosong biar teks beneran pas di tengah
        ],
      ),
    );
  }

  Widget _buildIntroductionCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 3), // Border Kuning mirip figma
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        // Ini kuncinya biar ga kepanjangan: maksimal 6 baris, lebih dari itu jadi "..."
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: 20, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => controller.goToQuiz(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD166),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 4,
            ),
            child: const Text(
              'Lanjut ke Kuis!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => controller.saveAndReturn(),
          child: Text(
            'Simpan dan Kembali',
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// =========================================================
// WIDGET TERPISAH: THEORY CARD (Tetap Sama, Aman!)
// =========================================================
class TheoryCardWidget extends StatefulWidget {
  final TheorySection section;

  const TheoryCardWidget({super.key, required this.section});

  @override
  State<TheoryCardWidget> createState() => _TheoryCardWidgetState();
}

class _TheoryCardWidgetState extends State<TheoryCardWidget> {
  late QuillController _quillController;
  final FocusNode _focusNode = FocusNode(); 

  @override
  void initState() {
    super.initState();
    _quillController = _jsonToQuillController(widget.section.content);
  }

  @override
  void dispose() {
    _quillController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  QuillController _jsonToQuillController(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      return QuillController(
        document: Document.fromJson(json),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    } catch (e) {
      return QuillController(
        document: Document()..insert(0, jsonString),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImage = widget.section.imagePath != null && widget.section.imagePath!.isNotEmpty;
    File? imageFile = hasImage ? File(widget.section.imagePath!) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Shadow ditipisin dikit biar lebih elegan
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.science, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.section.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (hasImage && imageFile!.existsSync()) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imageFile,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 100,
                  color: Colors.grey[100],
                  child: const Center(child: Text("Gambar gagal dimuat")),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Ilustrasi: ${widget.section.title}",
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 16),
          ],

          QuillEditor.basic(
            controller: _quillController,
            focusNode: _focusNode,
            configurations: const QuillEditorConfigurations(
              scrollable: false, 
              autoFocus: false,
              expands: false,
              padding: EdgeInsets.zero,
              showCursor: false, 
              enableInteractiveSelection: false, 
            ),
          ),

          if (widget.section.examples != null && widget.section.examples!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFF0284C7)),
                      SizedBox(width: 8),
                      Text("Contoh Nyata:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.section.examples!,
                    style: const TextStyle(color: Colors.black87, height: 1.4),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}