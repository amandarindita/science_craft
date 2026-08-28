import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/api_service.dart';
import '../controllers/admin_learning_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _danger = Color(0xFFEF4444);
const Color _success = Color(0xFF10B981);

class AdminModuleFormView extends StatefulWidget {
  const AdminModuleFormView({super.key, this.module});

  final Map<String, dynamic>? module;

  bool get isEditing => module != null;

  @override
  State<AdminModuleFormView> createState() => _AdminModuleFormViewState();
}

class _AdminModuleFormViewState extends State<AdminModuleFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _introController = TextEditingController();
  final TextEditingController _orderController = TextEditingController(
    text: '1',
  );
  final TextEditingController _sceneController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  String? _imagePath;
  String _existingImageUrl = '';
  bool _removeExistingImage = false;

  String _category = 'Kimia';
  int _level = 1;
  bool _isRequired = true;
  bool _isPublished = true;

  AdminLearningController get _controller =>
      Get.find<AdminLearningController>();

  @override
  void initState() {
    super.initState();

    final Map<String, dynamic>? module = widget.module;

    if (module != null) {
      _titleController.text = module['title']?.toString() ?? '';
      _introController.text = module['short_description']?.toString() ?? '';
      _orderController.text =
          AdminLearningController.intValue(
            module['module_order'],
            fallback: 1,
          ).toString();
      _sceneController.text = module['unity_scene_id']?.toString() ?? '';
      _instructionsController.text = module['instructions']?.toString() ?? '';
      _existingImageUrl = module['image_url']?.toString().trim() ?? '';

      final String category = module['category']?.toString() ?? 'Kimia';
      if (const <String>['Fisika', 'Kimia', 'Biologi'].contains(category)) {
        _category = category;
      }

      _level = AdminLearningController.intValue(
        module['level'],
        fallback: 1,
      ).clamp(1, 3);

      _isRequired = AdminLearningController.boolValue(
        module['is_required'],
        fallback: true,
      );

      _isPublished = AdminLearningController.boolValue(
        module['is_published'],
        fallback: true,
      );
    }

    _introController.addListener(_refreshCounter);
    _titleController.addListener(_refreshCounter);
  }

  void _refreshCounter() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _introController.removeListener(_refreshCounter);
    _titleController.removeListener(_refreshCounter);
    _titleController.dispose();
    _introController.dispose();
    _orderController.dispose();
    _sceneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Modul Pembelajaran' : 'Buat Modul Baru',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
          children: <Widget>[
            // 1. Identitas Utama
            _SectionCard(
              title: 'Identitas & Klasifikasi Modul',
              subtitle:
                  'Atur nama, mata pelajaran, level materi, dan urutan modul.',
              icon: Icons.assignment_outlined,
              children: <Widget>[
                Text(
                  'Judul Modul Pembelajaran',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: _textDark,
                  ),
                  decoration: _buildInputDecoration(
                    hintText: 'Contoh: Konsep Asam dan Basa',
                    prefixIcon: Icons.menu_book_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul modul wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Mata Pelajaran
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mata Pelajaran',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _category,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                            decoration: _buildInputDecoration(
                              prefixIcon: Icons.science_rounded,
                            ),
                            items:
                                const <String>[
                                  'Fisika',
                                  'Kimia',
                                  'Biologi',
                                ].map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _category = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Level
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tingkat Level',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            initialValue: _level,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                            decoration: _buildInputDecoration(
                              prefixIcon: Icons.layers_rounded,
                            ),
                            items: List<DropdownMenuItem<int>>.generate(3, (
                              index,
                            ) {
                              final int level = index + 1;
                              return DropdownMenuItem<int>(
                                value: level,
                                child: Text('Level $level'),
                              );
                            }),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _level = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nomor Urut Modul',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _orderController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                  decoration: _buildInputDecoration(
                    hintText: '1',
                    prefixIcon: Icons.format_list_numbered_rounded,
                  ),
                  validator: (value) {
                    final int? order = int.tryParse(value?.trim() ?? '');
                    if (order == null || order < 0) {
                      return 'Urutan harus berupa angka valid.';
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2. Intro Singkat & Preview
            _SectionCard(
              title: 'Deskripsi & Teaser Modul',
              subtitle: 'Kalimat pemikat yang memancing rasa ingin tahu siswa.',
              icon: Icons.lightbulb_outline_rounded,
              children: <Widget>[
                Text(
                  'Intro Singkat',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _introController,
                  maxLines: 3,
                  maxLength: AdminLearningController.maxIntroLength,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(
                      AdminLearningController.maxIntroLength,
                    ),
                  ],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _textDark,
                    height: 1.4,
                  ),
                  decoration: _buildInputDecoration(
                    hintText:
                        'Contoh: Pernah mikir gak kenapa asam bisa melarutkan logam?',
                    helperText:
                        'Maksimal 150 karakter. Buat santai dan memantik rasa penasaran.',
                  ),
                  validator: (value) {
                    final String text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Intro singkat modul wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Tampilan Pratinjau untuk Siswa',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                _IntroPreview(
                  title:
                      _titleController.text.trim().isEmpty
                          ? 'Judul Modul Pembelajaran'
                          : _titleController.text.trim(),
                  intro:
                      _introController.text.trim().isEmpty
                          ? 'Intro singkat rasa penasaran akan tampil di kartu modul siswa seperti ini.'
                          : _introController.text.trim(),
                  level: _level,
                  category: _category,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. Eksperimen Virtual Lab & Media Cover
            _SectionCard(
              title: 'Eksperimen Virtual Lab & Cover',
              subtitle:
                  'Hubungkan dengan scene Unity 3D dan atur gambar cover.',
              icon: Icons.science_outlined,
              children: <Widget>[
                Text(
                  'Virtual Lab Scene ID (Opsional)',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _sceneController,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: _textDark,
                  ),
                  decoration: _buildInputDecoration(
                    hintText: 'Contoh: Electrolysis / AcidBaseLab',
                    prefixIcon: Icons.view_in_ar_rounded,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Petunjuk Eksperimen (Opsional)',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _textDark,
                  ),
                  decoration: _buildInputDecoration(
                    hintText: 'Panduan langkah kerja virtual lab bagi siswa...',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cover Gambar Modul',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                _ModuleImagePickerCard(
                  selectedPath: _imagePath,
                  existingUrl: _removeExistingImage ? '' : _existingImageUrl,
                  onPick: _pickImage,
                  onRemove: _removeImage,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. Status Modul
            _SectionCard(
              title: 'Pengaturan Visibilitas & Kelulusan',
              subtitle:
                  'Atur kriteria kelulusan level dan status publikasi siswa.',
              icon: Icons.tune_rounded,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        activeTrackColor: _primaryBlue,
                        title: Text(
                          'Modul Wajib Diselesaikan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _textDark,
                          ),
                        ),
                        subtitle: Text(
                          'Siswa wajib menuntaskan modul ini untuk membuka level materi selanjutnya.',
                          style: GoogleFonts.plusJakartaSans(
                            color: _textMuted,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                        value: _isRequired,
                        onChanged: (value) {
                          setState(() {
                            _isRequired = value;
                          });
                        },
                      ),
                      const Divider(height: 1, color: _border),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        activeTrackColor: _success,
                        title: Text(
                          'Publikasikan Modul',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _textDark,
                          ),
                        ),
                        subtitle: Text(
                          'Jika dinonaktifkan, modul disimpan sebagai draft dan disembunyikan dari siswa.',
                          style: GoogleFonts.plusJakartaSans(
                            color: _textMuted,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                        value: _isPublished,
                        onChanged: (value) {
                          setState(() {
                            _isPublished = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: _border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _controller.isSaving.value ? null : _save,
                icon:
                    _controller.isSaving.value
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(
                  _controller.isSaving.value
                      ? 'Menyimpan Modul...'
                      : (widget.isEditing
                          ? 'Simpan Perubahan Modul'
                          : 'Buat Modul Pembelajaran'),
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    String? hintText,
    String? helperText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      helperText: helperText,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        color: _textMuted.withValues(alpha: 0.7),
      ),
      helperStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: _textMuted),
      prefixIcon:
          prefixIcon != null
              ? Icon(prefixIcon, color: _primaryBlue, size: 20)
              : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
      ),
    );
  }

  Future<void> _pickImage() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    final String? path = result?.files.single.path;
    if (path == null) return;

    setState(() {
      _imagePath = path;
      _removeExistingImage = false;
    });
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
      _removeExistingImage = true;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final bool success = await _controller.saveModule(
      materialId:
          widget.module == null
              ? null
              : AdminLearningController.intValue(widget.module!['id']),
      imagePath: _imagePath,
      data: <String, dynamic>{
        'title': _titleController.text.trim(),
        'category': _category,
        'level': _level,
        'module_order': int.parse(_orderController.text.trim()),
        'short_description': _introController.text.trim(),
        'unity_scene_id': _sceneController.text.trim(),
        'instructions': _instructionsController.text.trim(),
        'remove_image': _removeExistingImage,
        'is_required': _isRequired,
        'is_published': _isPublished,
      },
    );

    if (success) {
      Get.back<bool>(result: true);
    }
  }
}

// =============================================================================
// SECTION CARD WRAPPER
// =============================================================================
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _primaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: _textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// =============================================================================
// INTRO LIVE PREVIEW CARD
// =============================================================================
class _IntroPreview extends StatelessWidget {
  const _IntroPreview({
    required this.title,
    required this.intro,
    required this.level,
    required this.category,
  });

  final String title;
  final String intro;
  final int level;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkNavy, _primaryBlue],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x221E3A8A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _PreviewPill(text: category),
              const SizedBox(width: 6),
              _PreviewPill(text: 'Level $level'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            intro,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFDCE9FF),
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// =============================================================================
// MODULE IMAGE PICKER DROPZONE
// =============================================================================
class _ModuleImagePickerCard extends StatelessWidget {
  const _ModuleImagePickerCard({
    required this.selectedPath,
    required this.existingUrl,
    required this.onPick,
    required this.onRemove,
  });

  final String? selectedPath;
  final String existingUrl;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String? resolvedUrl =
        existingUrl.trim().isEmpty
            ? null
            : ApiService.resolveMediaUrl(existingUrl);

    final bool hasImage = selectedPath != null || resolvedUrl != null;

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child:
          hasImage
              ? Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child:
                        selectedPath != null
                            ? Image.file(
                              File(selectedPath!),
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const _ModuleImageError(),
                            )
                            : Image.network(
                              resolvedUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const _ModuleImageError(),
                            ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      children: <Widget>[
                        _ImageActionButton(
                          icon: Icons.edit_rounded,
                          tooltip: 'Ganti cover',
                          onTap: onPick,
                        ),
                        const SizedBox(width: 6),
                        _ImageActionButton(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'Hapus cover',
                          onTap: onRemove,
                          danger: true,
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onPick,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 28,
                          color: _primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Pilih Cover Modul',
                        style: GoogleFonts.poppins(
                          color: _textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ketuk untuk memilih foto/ilustrasi dari penyimpanan',
                        style: GoogleFonts.plusJakartaSans(
                          color: _textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

class _ImageActionButton extends StatelessWidget {
  const _ImageActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: danger ? _danger : _textDark, size: 18),
      ),
    );
  }
}

class _ModuleImageError extends StatelessWidget {
  const _ModuleImageError();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.broken_image_outlined, color: _textMuted, size: 36),
            SizedBox(height: 6),
            Text(
              'Gambar tidak dapat dimuat',
              style: TextStyle(color: _textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
