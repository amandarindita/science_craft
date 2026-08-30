import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/material_model.dart';
import '../../../routes/app_pages.dart';
import '../../materi/controllers/material_list_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _cyan = Color(0xFF0891B2);
const Color _textDark = Color(0xFF0F172A);
const Color _textMuted = Color(0xFF64748B);
const Color _success = Color(0xFF10B981);
const Color _border = Color(0xFFE2E8F0);

class LabView extends StatefulWidget {
  const LabView({super.key});

  @override
  State<LabView> createState() => _LabViewState();
}

class _LabViewState extends State<LabView> {
  final MaterialListController materiController =
      Get.isRegistered<MaterialListController>()
          ? Get.find<MaterialListController>()
          : Get.put(MaterialListController());

  String selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Laboratorium 3D Virtual',
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat Ulang Lab',
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () => materiController.loadMaterialsFromServer(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (materiController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: _primaryBlue,
            ),
          );
        }

        final List<MaterialItem> realLabs = materiController.labMaterials;
        final bool isUsingPreview = realLabs.isEmpty;

        final List<MaterialItem> allLabMaterials = isUsingPreview
            ? _previewLabMaterials
            : realLabs;

        // Kategori dinamis
        final Set<String> categories = {'Semua'};
        for (final item in allLabMaterials) {
          if (item.category.trim().isNotEmpty) {
            categories.add(item.category.trim());
          }
        }

        // Filter list
        final List<MaterialItem> filteredLabs = selectedCategory == 'Semua'
            ? allLabMaterials
            : allLabMaterials
                .where((item) => item.category.trim() == selectedCategory)
                .toList();

        return RefreshIndicator(
          color: _primaryBlue,
          onRefresh: () => materiController.loadMaterialsFromServer(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: <Widget>[
              if (isUsingPreview) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: _primaryBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mode Pratinjau Interaktif: Menampilkan contoh simulasi lab virtual.',
                          style: GoogleFonts.plusJakartaSans(
                            color: _primaryBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // 1. Hero Science Lab Banner
              _LabHeroBanner(totalLabs: allLabMaterials.length),
              const SizedBox(height: 18),

              // 2. Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: categories.map((cat) {
                    final bool isSelected = selectedCategory == cat;
                    final int count = cat == 'Semua'
                        ? allLabMaterials.length
                        : allLabMaterials
                            .where((m) => m.category.trim() == cat)
                            .length;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => selectedCategory = cat),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryBlue : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? _primaryBlue : _border,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          _primaryBlue.withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cat,
                                style: GoogleFonts.plusJakartaSans(
                                  color: isSelected
                                      ? Colors.white
                                      : _textMuted,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: GoogleFonts.poppins(
                                    color: isSelected
                                        ? Colors.white
                                        : _textMuted,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Simulasi Praktikum',
                    style: GoogleFonts.poppins(
                      color: _textDark,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '${filteredLabs.length} Modul',
                    style: GoogleFonts.plusJakartaSans(
                      color: _textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Lab Cards List
              if (filteredLabs.isEmpty)
                const _LabEmptyState(
                  title: 'Tidak Ada Lab di Kategori Ini',
                  subtitle:
                      'Pilih kategori lain untuk melihat daftar eksperimen virtual.',
                )
              else
                ...filteredLabs.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _LabExperimentCard(
                      item: item,
                      onTap: () => _showLabInstructionSheet(context, item),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ===========================================================================
  // BOTTOM SHEET INSTRUKSI PRAKTIKUM
  // ===========================================================================
  void _showLabInstructionSheet(BuildContext context, MaterialItem item) {
    final List<Color> themeColors = _getCategoryTheme(item.category);

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header Sheet
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: themeColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: themeColors.first.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.biotech_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: themeColors.first.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: themeColors.first,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.title,
                          style: GoogleFonts.poppins(
                            color: _textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Instruction Box
              Text(
                'Petunjuk Pelaksanaan Praktikum:',
                style: GoogleFonts.poppins(
                  color: _textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 220),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    item.instructions?.trim().isNotEmpty == true
                        ? item.instructions!
                        : '1. Masuk ke dalam simulasi virtual 3D.\n'
                            '2. Ikuti setiap petunjuk instruktur laboratorium yang tampil di layar.\n'
                            '3. Amati perubahan variabel ilmiah dan catat hasil eksperimenmu.\n'
                            '4. Selesaikan misi simulasi untuk melengkapi syarat materi.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      height: 1.55,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Launch Unity Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Get.back(); // Tutup sheet
                    Get.toNamed(
                      Routes.SIMULATION,
                      arguments: {
                        'sceneId': item.unitySceneId,
                        'sceneName': item.title,
                        'materialId': item.id,
                      },
                    );
                  },
                  icon: const Icon(Icons.rocket_launch_rounded, size: 20),
                  label: Text(
                    'Paham, Mulai Eksperimen 3D',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// =============================================================================
// HERO SCIENCE LAB BANNER
// =============================================================================
class _LabHeroBanner extends StatelessWidget {
  const _LabHeroBanner({required this.totalLabs});

  final int totalLabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[_darkNavy, _primaryBlue, _cyan],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.science_rounded,
                  color: Color(0xFF67E8F9),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Laboratorium Virtual 3D',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Simulasi interaktif sains bertenaga Unity Engine',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFE2E8F0),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BannerMiniTag(
                  icon: Icons.biotech_rounded,
                  label: '$totalLabs Lab Praktikum',
                  color: const Color(0xFF67E8F9),
                ),
                Container(
                  width: 1,
                  height: 16,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const _BannerMiniTag(
                  icon: Icons.view_in_ar_rounded,
                  label: 'Simulasi 3D Realtime',
                  color: Color(0xFFFDE68A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerMiniTag extends StatelessWidget {
  const _BannerMiniTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// LAB EXPERIMENT CARD
// =============================================================================
class _LabExperimentCard extends StatelessWidget {
  const _LabExperimentCard({
    required this.item,
    required this.onTap,
  });

  final MaterialItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final List<Color> themeColors = _getCategoryTheme(item.category);
    final IconData categoryIcon = _getCategoryIcon(item.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Leading Icon Container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: themeColors.first.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                categoryIcon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: themeColors.first.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: themeColors.first,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: _success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Siap 3D',
                              style: GoogleFonts.poppins(
                                color: _success,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: _textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ketuk untuk melihat petunjuk & mulai eksperimen',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: _textMuted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Chevron Indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: _primaryBlue,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================
class _LabEmptyState extends StatelessWidget {
  const _LabEmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.biotech_rounded,
              color: _primaryBlue,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _textDark,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: _textMuted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// THEME HELPERS
// =============================================================================
List<Color> _getCategoryTheme(String category) {
  final String cat = category.toLowerCase().trim();
  if (cat.contains('biologi') || cat.contains('bio')) {
    return const [Color(0xFF059669), Color(0xFF10B981)];
  } else if (cat.contains('fisika') || cat.contains('physics')) {
    return const [Color(0xFF0284C7), Color(0xFF38BDF8)];
  } else if (cat.contains('kimia') || cat.contains('chem')) {
    return const [Color(0xFF7C3AED), Color(0xFFA855F7)];
  } else if (cat.contains('astronomi') || cat.contains('angkasa')) {
    return const [Color(0xFF1E1B4B), Color(0xFF4338CA)];
  }
  return const [_primaryBlue, _cyan];
}

IconData _getCategoryIcon(String category) {
  final String cat = category.toLowerCase().trim();
  if (cat.contains('biologi') || cat.contains('bio')) {
    return Icons.eco_rounded;
  } else if (cat.contains('fisika') || cat.contains('physics')) {
    return Icons.bolt_rounded;
  } else if (cat.contains('kimia') || cat.contains('chem')) {
    return Icons.science_rounded;
  } else if (cat.contains('astronomi') || cat.contains('angkasa')) {
    return Icons.public_rounded;
  }
  return Icons.biotech_rounded;
}

// =============================================================================
// PREVIEW SAMPLE LAB MATERIALS
// =============================================================================
final List<MaterialItem> _previewLabMaterials = [
  MaterialItem(
    id: 101,
    title: 'Praktikum: Struktur Sel Hewan & Tumbuhan',
    category: 'Biologi',
    progress: 0.75,
    iconPath: 'assets/chemistry.png',
    unitySceneId: 'scene_cell_structure',
    instructions:
        '1. Nyalakan mikroskop elektron virtual.\n'
        '2. Letakkan preparat sel gabus dan sel epitel pada meja mikroskop.\n'
        '3. Atur fokus lensa objektif 10x dan 40x menggunakan sekrup mikrometer.\n'
        '4. Identifikasi bagian dinding sel, membran sel, sitoplasma, dan inti sel.\n'
        '5. Catat perbedaan struktural antara sel hewan dan sel tumbuhan.',
  ),
  MaterialItem(
    id: 102,
    title: 'Praktikum: Hukum Hooke & Elastisitas Pegas',
    category: 'Fisika',
    progress: 0.30,
    iconPath: 'assets/chemistry.png',
    unitySceneId: 'scene_hooke_law',
    instructions:
        '1. Gantungkan pegas pada statif pengukur.\n'
        '2. Tambahkan beban bertingkat (50g, 100g, 150g, 200g) secara perlahan.\n'
        '3. Ukur pertambahan panjang pegas (Δx) menggunakan mistar virtual presisi.\n'
        '4. Buat grafik hubungan antara Gaya Beban (F) dan Pertambahan Panjang (Δx).\n'
        '5. Hitung nilai konstanta pegas (k) berdasarkan kemiringan grafik.',
  ),
  MaterialItem(
    id: 103,
    title: 'Praktikum: Titrasi Asam Basa & Indikator pH',
    category: 'Kimia',
    progress: 0.0,
    iconPath: 'assets/chemistry.png',
    unitySceneId: 'scene_acid_base_titration',
    instructions:
        '1. Isi buret virtual dengan larutan standar NaOH 0.1 M hingga batas skala nol.\n'
        '2. Masukkan 25 mL larutan asam cuka ke dalam labu erlenmeyer.\n'
        '3. Tambahkan 3 tetes indikator fenolftalein (PP) ke dalam erlenmeyer.\n'
        '4. Lakukan titrasi tetes demi tetes sambil menggoyang erlenmeyer hingga muncul warna merah muda stabil.\n'
        '5. Catat volume NaOH terpakai dan hitung konsentrasi larutan.',
  ),
  MaterialItem(
    id: 104,
    title: 'Praktikum: Simulasi Gravitasi & Orbit Planet',
    category: 'Astronomi',
    progress: 0.0,
    iconPath: 'assets/chemistry.png',
    unitySceneId: 'scene_solar_gravity',
    instructions:
        '1. Masuk ke ruang simulasi orbit tata surya 3D.\n'
        '2. Ubah massa matahari dan jarak orbit planet dari pusat gravitasi.\n'
        '3. Amati perubahan periode revolusi dan kecepatan orbit planet sesuai Hukum Kepler.\n'
        '4. Uji simulasi tabrakan dan gaya tarik gravitasi antar benda langit.',
  ),
];