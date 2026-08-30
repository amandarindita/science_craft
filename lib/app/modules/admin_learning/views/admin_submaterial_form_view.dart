import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/api_service.dart';
import '../../../widgets/app_snackbar.dart';
import '../controllers/admin_learning_controller.dart';
import 'admin_visual_builder.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _success = Color(0xFF10B981);
const Color _danger = Color(0xFFEF4444);

class AdminSubmaterialFormView extends StatefulWidget {
  const AdminSubmaterialFormView({
    super.key,
    required this.materialId,
    this.submaterial,
  });

  final int materialId;
  final Map<String, dynamic>? submaterial;

  bool get isEditing => submaterial != null;

  @override
  State<AdminSubmaterialFormView> createState() =>
      _AdminSubmaterialFormViewState();
}

class _AdminSubmaterialFormViewState extends State<AdminSubmaterialFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _orderController =
      TextEditingController(text: '1');
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _readController = TextEditingController();
  final TextEditingController _ttsController = TextEditingController();
  final TextEditingController _visualJsonController = TextEditingController();

  String _visualType = 'infographic';
  bool _isRequired = true;
  bool _isPublished = true;

  String? _audioPath;
  String? _imagePath;

  String _existingAudioUrl = '';
  String _existingImageUrl = '';

  bool _removeExistingAudio = false;
  bool _removeExistingImage = false;

  late final AdminVisualBuilderController _visualBuilder;

  AdminLearningController get controller =>
      Get.find<AdminLearningController>();

  @override
  void initState() {
    super.initState();

    final Map<String, dynamic>? data = widget.submaterial;

    Map<String, dynamic> initialVisualData = <String, dynamic>{};

    if (data != null) {
      _titleController.text = data['title']?.toString() ?? '';
      _orderController.text = AdminLearningController.intValue(
        data['order_index'],
        fallback: 1,
      ).toString();
      _summaryController.text = data['summary']?.toString() ?? '';
      _readController.text = data['read_content']?.toString() ?? '';
      _ttsController.text = data['tts_text']?.toString() ?? '';
      _existingAudioUrl = data['audio_url']?.toString().trim() ?? '';
      _existingImageUrl = data['image_url']?.toString().trim() ?? '';

      final String visualType =
          data['visual_type']?.toString().trim() ?? '';
      if (visualType.isNotEmpty) {
        _visualType = visualType;
      }

      initialVisualData =
          AdminLearningController.mapValue(data['visual_data']);

      _visualJsonController.text = initialVisualData.isEmpty
          ? _templateFor(_visualType)
          : const JsonEncoder.withIndent('  ').convert(initialVisualData);

      _isRequired = AdminLearningController.boolValue(
        data['is_required'],
        fallback: true,
      );

      _isPublished = AdminLearningController.boolValue(
        data['is_published'],
        fallback: true,
      );
    } else {
      _visualJsonController.text = _templateFor(_visualType);
      initialVisualData = Map<String, dynamic>.from(
        jsonDecode(_visualJsonController.text) as Map,
      );
    }

    _visualBuilder = AdminVisualBuilderController(
      initialType: _visualType,
      initialData: initialVisualData,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    _summaryController.dispose();
    _readController.dispose();
    _ttsController.dispose();
    _visualJsonController.dispose();
    _visualBuilder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasRead = _readController.text.trim().isNotEmpty;
    final bool hasListen = _ttsController.text.trim().isNotEmpty ||
        _audioPath != null ||
        (_existingAudioUrl.isNotEmpty && !_removeExistingAudio);
    final bool hasVisual = _imagePath != null ||
        (_existingImageUrl.isNotEmpty && !_removeExistingImage) ||
        _visualBuilder.hasContent;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Submateri' : 'Tambah Submateri Baru',
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
            // 1. Informasi Dasar Submateri
            _SectionCard(
              title: 'Identitas & Urutan Submateri',
              subtitle: 'Atur judul bab dan nomor urutan materi.',
              icon: Icons.bookmark_border_rounded,
              children: <Widget>[
                Text(
                  'Judul Submateri',
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
                    hintText: 'Contoh: Teori Arrhenius & Bronsted-Lowry',
                    prefixIcon: Icons.title_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul submateri wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Nomor Urut Submateri',
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
                    final int? number = int.tryParse(value?.trim() ?? '');
                    if (number == null || number < 1) {
                      return 'Urutan minimal 1.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Ringkasan Singkat (Opsional)',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _summaryController,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _textDark,
                  ),
                  decoration: _buildInputDecoration(
                    hintText: 'Gambaran umum ringkas isi submateri ini...',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Mode Completion Status Indicators
            _ModeStatusCard(
              hasRead: hasRead,
              hasListen: hasListen,
              hasVisual: hasVisual,
            ),

            const SizedBox(height: 16),

            // 2. MODE BACA
            _SectionCard(
              title: 'Mode Baca (Teks Materi)',
              subtitle: 'Materi teks lengkap yang dibaca siswa saat belajar.',
              icon: Icons.menu_book_rounded,
              children: <Widget>[
                Text(
                  'Isi Teks Pembelajaran',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _readController,
                  minLines: 6,
                  maxLines: 15,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: _textDark,
                    height: 1.45,
                  ),
                  decoration: _buildInputDecoration(
                    hintText:
                        'Tulis materi secara terstruktur dengan bahasa yang jelas dan mudah dipahami siswa...',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. MODE DENGARKAN
            _SectionCard(
              title: 'Mode Dengarkan (Audio / TTS)',
              subtitle:
                  'Gunakan rekaman suara audio atau naskah suara robot Text-to-Speech.',
              icon: Icons.headphones_rounded,
              children: <Widget>[
                Text(
                  'Naskah Text-to-Speech (TTS)',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _ttsController,
                  minLines: 4,
                  maxLines: 10,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _textDark,
                    height: 1.4,
                  ),
                  decoration: _buildInputDecoration(
                    hintText:
                        'Tulis naskah narasi suara yang nyaman untuk didengarkan...',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Atau Unggah File Audio Rekaman',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                _FilePickerCard(
                  icon: Icons.audio_file_rounded,
                  title: 'File Audio',
                  subtitle: 'Format: MP3, WAV, M4A, AAC, atau OGG',
                  selectedPath: _audioPath,
                  existingUrl:
                      _removeExistingAudio ? '' : _existingAudioUrl,
                  onPick: _pickAudio,
                  onRemove: _removeAudio,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. MODE VISUAL & VISUAL BUILDER
            _SectionCard(
              title: 'Mode Visual Interaktif',
              subtitle:
                  'Ilustrasi visual & model interaktif untuk memperkuat pemahaman sains siswa.',
              icon: Icons.auto_awesome_rounded,
              children: <Widget>[
                Text(
                  'Ilustrasi / Gambar Utama Submateri (Opsional)',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                _ImagePickerCard(
                  selectedPath: _imagePath,
                  existingUrl:
                      _removeExistingImage ? '' : _existingImageUrl,
                  onPick: _pickImage,
                  onRemove: _removeImage,
                ),
                const SizedBox(height: 18),
                const Divider(height: 1, color: _border),
                const SizedBox(height: 18),
                Obx(() {
                  final List<Map<String, dynamic>> types =
                      controller.visualTypes;

                  final List<Map<String, dynamic>> effectiveTypes =
                      types.isEmpty
                          ? const <Map<String, dynamic>>[
                              <String, dynamic>{
                                'value': 'infographic',
                                'label': 'Infografik',
                              },
                              <String, dynamic>{
                                'value': 'comparison',
                                'label': 'Perbandingan',
                              },
                              <String, dynamic>{
                                'value': 'flow',
                                'label': 'Alur',
                              },
                              <String, dynamic>{
                                'value': 'chart',
                                'label': 'Grafik/Data',
                              },
                              <String, dynamic>{
                                'value': 'formula',
                                'label': 'Rumus',
                              },
                              <String, dynamic>{
                                'value': 'hotspot',
                                'label': 'Titik Gambar',
                              },
                              <String, dynamic>{
                                'value': 'sequence',
                                'label': 'Urutan Proses',
                              },
                            ]
                          : types;

                  return AdminVisualBuilder(
                    controller: _visualBuilder,
                    visualTypes: effectiveTypes,
                    imagePath: _imagePath,
                    existingImageUrl:
                        _removeExistingImage ? '' : _existingImageUrl,
                    onPickImage: _pickImage,
                    onRemoveImage: _removeImage,
                    onChanged: () {
                      _syncVisualData();
                      setState(() {});
                    },
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            // 5. STATUS SUBMATERI
            _SectionCard(
              title: 'Status & Visibilitas',
              subtitle: 'Atur kewajiban submateri dan status publikasi.',
              icon: Icons.tune_rounded,
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                          'Submateri Wajib',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _textDark,
                          ),
                        ),
                        subtitle: Text(
                          'Diperhitungkan dalam syarat kelulusan modul pembelajaran.',
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
                          'Dipublikasikan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _textDark,
                          ),
                        ),
                        subtitle: Text(
                          'Siswa dapat melihat dan mengakses submateri ini.',
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
                onPressed: controller.isSavingSubmaterial.value ? null : _save,
                icon: controller.isSavingSubmaterial.value
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
                  controller.isSavingSubmaterial.value
                      ? 'Menyimpan Submateri...'
                      : (widget.isEditing
                          ? 'Simpan Perubahan Submateri'
                          : 'Buat Submateri'),
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
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        color: _textMuted.withValues(alpha: 0.7),
      ),
      prefixIcon: prefixIcon != null
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

  Future<void> _pickAudio() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>[
        'mp3',
        'wav',
        'm4a',
        'aac',
        'ogg',
      ],
      allowMultiple: false,
    );

    final String? path = result?.files.single.path;
    if (path == null) return;

    setState(() {
      _audioPath = path;
      _removeExistingAudio = false;
    });
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
      if (_visualBuilder.visualType == 'hotspot') {
        _visualBuilder.clearHotspots();
      }
    });
  }

  void _removeAudio() {
    setState(() {
      _audioPath = null;
      _removeExistingAudio = true;
    });
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
      _removeExistingImage = true;
      _visualBuilder.clearHotspots();
    });
  }

  void _syncVisualData() {
    _visualType = _visualBuilder.visualType;
    _visualJsonController.text = const JsonEncoder.withIndent('  ').convert(
      _visualBuilder.buildData(),
    );
  }

  bool _visualJsonHasContent() {
    final String text = _visualJsonController.text.trim();
    return text.isNotEmpty && text != '{}' && text != '{\n}';
  }

  bool _validateVisualJson({bool showSuccess = true}) {
    final String text = _visualJsonController.text.trim();
    if (text.isEmpty) {
      return true;
    }

    try {
      final dynamic decoded = jsonDecode(text);
      if (decoded is! Map) {
        controller.showError('Data visual harus berupa objek JSON.');
        return false;
      }

      return true;
    } catch (e) {
      controller.showError('JSON tidak valid: $e');
      return false;
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppSnackbar.warning(
        'Form Belum Lengkap',
        'Mohon periksa dan lengkapi judul serta urutan submateri.',
      );
      return;
    }

    final bool hasVisualImage = _imagePath != null ||
        (_existingImageUrl.isNotEmpty && !_removeExistingImage);

    final String? visualError = _visualBuilder.validate(
      hasImage: hasVisualImage,
    );

    if (visualError != null) {
      AppSnackbar.warning('Data Visual Belum Lengkap', visualError);
      return;
    }

    _syncVisualData();

    if (!_validateVisualJson(showSuccess: false)) {
      return;
    }

    final bool hasAnyMode = _readController.text.trim().isNotEmpty ||
        _ttsController.text.trim().isNotEmpty ||
        _audioPath != null ||
        (_existingAudioUrl.isNotEmpty && !_removeExistingAudio) ||
        _imagePath != null ||
        (_existingImageUrl.isNotEmpty && !_removeExistingImage) ||
        _visualJsonHasContent();

    if (!hasAnyMode) {
      AppSnackbar.warning(
        'Mode Pembelajaran Kosong',
        'Isi minimal satu mode: Baca, Dengarkan (Suara/Audio), atau Visual.',
      );
      return;
    }

    final String jsonText = _visualJsonController.text.trim();
    final Map<String, dynamic> visualData = jsonText.isEmpty
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(jsonText) as Map);

    final Map<String, dynamic> data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'order_index': int.parse(_orderController.text.trim()),
      'summary': _summaryController.text.trim(),
      'read_content': _readController.text.trim(),
      'tts_text': _ttsController.text.trim(),
      'visual_type': _visualType,
      'visual_data': visualData,
      'is_required': _isRequired,
      'is_published': _isPublished,
      if (_removeExistingAudio && _audioPath == null) 'audio_url': '',
      if (_removeExistingImage && _imagePath == null) 'image_url': '',
    };

    final bool success = await controller.saveSubmaterial(
      submaterialId: widget.submaterial == null
          ? null
          : AdminLearningController.intValue(widget.submaterial!['id']),
      materialId: widget.materialId,
      data: data,
      audioPath: _audioPath,
      imagePath: _imagePath,
    );

    if (success) {
      Get.back<bool>(result: true);
      AppSnackbar.success(
        widget.submaterial != null ? 'Submateri Diperbarui' : 'Submateri Berhasil Dibuat',
        widget.submaterial != null
            ? 'Perubahan konten submateri berhasil disimpan.'
            : 'Submateri baru berhasil ditambahkan ke modul ini.',
      );
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
    required this.children,
    this.icon,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final IconData? icon;

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
            children: <Widget>[
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _primaryBlue, size: 18),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
// MODE STATUS OVERVIEW CARD
// =============================================================================
class _ModeStatusCard extends StatelessWidget {
  const _ModeStatusCard({
    required this.hasRead,
    required this.hasListen,
    required this.hasVisual,
  });

  final bool hasRead;
  final bool hasListen;
  final bool hasVisual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkNavy, _primaryBlue],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x221E3A8A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ModeStatus(
              icon: Icons.menu_book_rounded,
              label: 'Mode Baca',
              active: hasRead,
            ),
          ),
          Container(
            height: 28,
            width: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _ModeStatus(
              icon: Icons.headphones_rounded,
              label: 'Dengarkan',
              active: hasListen,
            ),
          ),
          Container(
            height: 28,
            width: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _ModeStatus(
              icon: Icons.auto_awesome_rounded,
              label: 'Visual 3D',
              active: hasVisual,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeStatus extends StatelessWidget {
  const _ModeStatus({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(
          active ? Icons.check_circle_rounded : icon,
          color: active ? const Color(0xFF86EFAC) : const Color(0xFF93C5FD),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: active ? Colors.white : const Color(0xFFDCE9FF),
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// FILE PICKER CARD
// =============================================================================
class _FilePickerCard extends StatelessWidget {
  const _FilePickerCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selectedPath,
    required this.existingUrl,
    required this.onPick,
    required this.onRemove,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? selectedPath;
  final String existingUrl;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bool hasFile = selectedPath != null || existingUrl.isNotEmpty;
    final String fileName = selectedPath != null
        ? File(selectedPath!).uri.pathSegments.last
        : existingUrl.isNotEmpty
            ? Uri.tryParse(existingUrl)?.pathSegments.last ?? existingUrl
            : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasFile ? _success : _border,
          width: hasFile ? 1.2 : 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (hasFile ? _success : _primaryBlue).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasFile ? Icons.check_circle_rounded : icon,
              color: hasFile ? _success : _primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hasFile ? fileName : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _textDark,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasFile ? 'File audio siap digunakan' : subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: hasFile ? _success : _textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (hasFile)
            IconButton(
              tooltip: 'Hapus file',
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: _danger,
                size: 20,
              ),
            ),
          OutlinedButton(
            onPressed: onPick,
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryBlue,
              side: const BorderSide(color: _border),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              hasFile ? 'Ganti' : 'Pilih',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// IMAGE PICKER CARD
// =============================================================================
class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({
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
    final String? resolvedUrl = existingUrl.isEmpty
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
      child: hasImage
          ? Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: selectedPath != null
                      ? Image.file(
                          File(selectedPath!),
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          resolvedUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Text(
                              'Gambar gagal dimuat',
                              style: TextStyle(color: _textMuted, fontSize: 11),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: <Widget>[
                      _ImageAction(
                        icon: Icons.edit_rounded,
                        tooltip: 'Ganti gambar',
                        onTap: onPick,
                      ),
                      const SizedBox(width: 6),
                      _ImageAction(
                        icon: Icons.delete_outline_rounded,
                        tooltip: 'Hapus gambar',
                        onTap: onRemove,
                        danger: true,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : InkWell(
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
                      size: 26,
                      color: _primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih Gambar Visual',
                    style: GoogleFonts.poppins(
                      color: _textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'JPG, JPEG, PNG, GIF, atau WEBP',
                    style: GoogleFonts.plusJakartaSans(
                      color: _textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ImageAction extends StatelessWidget {
  const _ImageAction({
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
        icon: Icon(
          icon,
          color: danger ? _danger : _textDark,
          size: 18,
        ),
      ),
    );
  }
}

String _templateFor(String type) {
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');

  switch (type) {
    case 'comparison':
      return encoder.convert(
        <String, dynamic>{
          'title': 'Judul perbandingan',
          'description': 'Penjelasan singkat.',
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'title': 'Bagian A',
              'description': 'Penjelasan bagian A.',
            },
            <String, dynamic>{
              'title': 'Bagian B',
              'description': 'Penjelasan bagian B.',
            },
          ],
        },
      );

    case 'flow':
    case 'sequence':
      return encoder.convert(
        <String, dynamic>{
          'title': 'Judul proses',
          'description': 'Penjelasan singkat.',
          'steps': <Map<String, dynamic>>[
            <String, dynamic>{
              'title': 'Langkah 1',
              'description': 'Penjelasan langkah pertama.',
            },
            <String, dynamic>{
              'title': 'Langkah 2',
              'description': 'Penjelasan langkah kedua.',
            },
          ],
        },
      );

    case 'chart':
      return encoder.convert(
        <String, dynamic>{
          'title': 'Judul data',
          'headers': <String>[
            'Objek',
            'Nilai',
            'Keterangan',
          ],
          'rows': <List<dynamic>>[
            <dynamic>[
              'A',
              10,
              'Contoh',
            ],
            <dynamic>[
              'B',
              20,
              'Contoh',
            ],
          ],
        },
      );

    case 'formula':
      return encoder.convert(
        <String, dynamic>{
          'title': 'Judul rumus',
          'formula': 'M₁ × V₁ = M₂ × V₂',
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'title': 'M',
              'description': 'Molaritas',
            },
            <String, dynamic>{
              'title': 'V',
              'description': 'Volume',
            },
          ],
        },
      );

    case 'hotspot':
      return encoder.convert(
        <String, dynamic>{
          'title': 'Bagian gambar',
          'description': 'Titik penting pada gambar.',
          'hotspots': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'bagian_1',
              'label': 'Bagian 1',
              'x': 0.35,
              'y': 0.25,
            },
          ],
        },
      );

    default:
      return encoder.convert(
        <String, dynamic>{
          'title': 'Judul infografik',
          'description': 'Penjelasan singkat.',
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'title': 'Poin 1',
              'description': 'Penjelasan poin pertama.',
            },
            <String, dynamic>{
              'title': 'Poin 2',
              'description': 'Penjelasan poin kedua.',
            },
          ],
        },
      );
  }
}
