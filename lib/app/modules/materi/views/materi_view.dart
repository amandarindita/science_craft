import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';

// Pastikan import ini sesuai dengan lokasi file kamu
import '../controllers/materi_controller.dart';
import '../../../models/material_model.dart'; 
import 'package:tuple/tuple.dart';
import '../../../routes/app_pages.dart';
import '../../../data/api_service.dart';

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
                                children: List.generate(content.theorySections.length, (index) {
                                  return TheoryCardWidget(
                                    section: content.theorySections[index],
                                    imageUrl: content.imageUrl,
                                    showImage: index == 0,
                                  );
                                }),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Tombol Aksi Bawah
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _buildActionButtons(content),
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
  String _buildImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.trim().isEmpty) return '';

  if (imageUrl.startsWith('http')) {
    return imageUrl;
  }

  if (imageUrl.startsWith('/')) {
    return '${ApiService.baseUrl}$imageUrl';
  }

  return imageUrl;
}
Widget _buildMaterialImage(String? imageUrl) {
  final fullUrl = _buildImageUrl(imageUrl);

  if (fullUrl.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 24),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBEB),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 14,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        fullUrl,
        height: 170,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 140,
            alignment: Alignment.center,
            color: Colors.grey[100],
            child: Text(
              "Gambar materi gagal dimuat",
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        },
      ),
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
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFFD700), width: 3),
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
      style: const TextStyle(
        color: Color(0xFF374151),
        fontSize: 14.5,
        height: 1.65,
        letterSpacing: 0.15,
        fontWeight: FontWeight.w400,
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
  Widget _buildActionButtons(MaterialContent content) {
  final sceneId = content.unitySceneId?.trim() ?? '';
  final hasExperiment = sceneId.isNotEmpty;

  return Column(
    children: [
      if (hasExperiment) ...[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.toNamed(
                Routes.SIMULATION,
                arguments: {
                  'sceneId': sceneId,
                  'materialId': content.id,
                  'materialName': content.title,
                },
              );
            },
            icon: const Icon(Icons.science, color: Colors.white),
            label: const Text(
              'Mulai Praktikum',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => controller.goToQuiz(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD166),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Lanjut ke Kuis!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),

      const SizedBox(height: 12),

      TextButton(
        onPressed: () => controller.saveAndReturn(),
        child: Text(
          'Simpan dan Kembali',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
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
  final String? imageUrl;
  final bool showImage;

  const TheoryCardWidget({
    super.key,
    required this.section,
    this.imageUrl,
    this.showImage = false,
  });
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
  String _buildImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.trim().isEmpty) return '';

  if (imageUrl.startsWith('http')) {
    return imageUrl;
  }

  if (imageUrl.startsWith('/')) {
    return '${ApiService.baseUrl}$imageUrl';
  }

  return imageUrl;
}

  Widget _buildImageInsideCard() {
    if (!widget.showImage) return const SizedBox.shrink();

    final fullUrl = _buildImageUrl(widget.imageUrl);

    if (fullUrl.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          color: const Color(0xFFFFFBEB),
          padding: const EdgeInsets.all(10),
          child: Image.network(
            fullUrl,
            height: 170,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 140,
                alignment: Alignment.center,
                color: Colors.grey[100],
                child: Text(
                  "Gambar materi gagal dimuat",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(18),
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
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildImageInsideCard(),
          // 🌟 PERUBAHAN UI: QUILL EDITOR DIBIKIN LEBIH RENGGANG 🌟
          QuillEditor(
            focusNode: _focusNode,
            scrollController: ScrollController(),
            configurations: QuillEditorConfigurations(
              controller: _quillController, // Dipindahin ke dalam configurations kalau versi baru
              scrollable: false, 
              autoFocus: false,
              expands: false,
              padding: const EdgeInsets.symmetric(vertical: 8), // Kasih napas dikit di atas/bawah teks
              showCursor: false, 
              enableInteractiveSelection: false, 
              // 🌟 RAHASIA BIAR TEKS GAK NUMPUK (VERSI QUILL 10+) 🌟
              customStyles: const DefaultStyles(
                paragraph: DefaultTextBlockStyle(
                  TextStyle(
                    color: Color(0xFF374151), // Warna abu-abu gelap biar gak sakit di mata
                    fontSize: 15, // Digedein dikit
                    height: 1.6, // INI KUNCINYA: Jarak antar baris dibikin renggang!
                    letterSpacing: 0.3, 
                  ),
                  HorizontalSpacing(0, 0),  // Argumen 2: Horizontal Spacing
                  VerticalSpacing(10, 0), // Argumen 3: Vertical Spacing (Jarak Enter)
                  VerticalSpacing(0, 0),  // Argumen 4: Line Spacing
                  null,                   // Argumen 5: Decoration (Kasih null aja)
                ),
              ),
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
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 14,
                      height: 1.5,
                    ),
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