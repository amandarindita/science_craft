import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/api_service.dart';
import '../controllers/admin_learning_controller.dart';
import 'admin_visual_builder.dart';

const Color _primary = Color(0xFF2563EB);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _background = Color(0xFFF5F8FF);

class AdminSubmaterialFormView
    extends StatefulWidget {
  const AdminSubmaterialFormView({
    super.key,
    required this.materialId,
    this.submaterial,
  });

  final int materialId;
  final Map<String, dynamic>? submaterial;

  bool get isEditing =>
      submaterial != null;

  @override
  State<AdminSubmaterialFormView>
      createState() =>
          _AdminSubmaterialFormViewState();
}

class _AdminSubmaterialFormViewState
    extends State<AdminSubmaterialFormView> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _titleController =
      TextEditingController();

  final TextEditingController
      _orderController =
      TextEditingController(text: '1');

  final TextEditingController
      _summaryController =
      TextEditingController();

  final TextEditingController
      _readController =
      TextEditingController();

  final TextEditingController
      _ttsController =
      TextEditingController();

  final TextEditingController
      _visualJsonController =
      TextEditingController();

  String _visualType = 'infographic';
  bool _isRequired = true;
  bool _isPublished = true;

  String? _audioPath;
  String? _imagePath;

  String _existingAudioUrl = '';
  String _existingImageUrl = '';

  bool _removeExistingAudio = false;
  bool _removeExistingImage = false;

  String? _visualJsonError;

  late final AdminVisualBuilderController _visualBuilder;

  AdminLearningController get controller =>
      Get.find<AdminLearningController>();

  @override
  void initState() {
    super.initState();

    final Map<String, dynamic>? data =
        widget.submaterial;

    Map<String, dynamic> initialVisualData =
        <String, dynamic>{};

    if (data != null) {
      _titleController.text =
          data['title']?.toString() ?? '';

      _orderController.text =
          AdminLearningController.intValue(
        data['order_index'],
        fallback: 1,
      ).toString();

      _summaryController.text =
          data['summary']?.toString() ?? '';

      _readController.text =
          data['read_content']
                  ?.toString() ??
              '';

      _ttsController.text =
          data['tts_text']?.toString() ??
              '';

      _existingAudioUrl =
          data['audio_url']
                  ?.toString()
                  .trim() ??
              '';

      _existingImageUrl =
          data['image_url']
                  ?.toString()
                  .trim() ??
              '';

      final String visualType =
          data['visual_type']
                  ?.toString()
                  .trim() ??
              '';

      if (visualType.isNotEmpty) {
        _visualType = visualType;
      }

      initialVisualData =
          AdminLearningController.mapValue(
        data['visual_data'],
      );

      _visualJsonController.text =
          initialVisualData.isEmpty
              ? _templateFor(_visualType)
              : const JsonEncoder.withIndent('  ')
                  .convert(initialVisualData);

      _isRequired =
          AdminLearningController.boolValue(
        data['is_required'],
        fallback: true,
      );

      _isPublished =
          AdminLearningController.boolValue(
        data['is_published'],
        fallback: true,
      );
    } else {
      _visualJsonController.text =
          _templateFor(_visualType);
      initialVisualData =
          Map<String, dynamic>.from(
        jsonDecode(_visualJsonController.text)
            as Map,
      );
    }

    _visualBuilder =
        AdminVisualBuilderController(
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
    final bool hasRead =
        _readController.text.trim().isNotEmpty;

    final bool hasListen =
        _ttsController.text.trim().isNotEmpty ||
            _audioPath != null ||
            (_existingAudioUrl.isNotEmpty &&
                !_removeExistingAudio);

    final bool hasVisual =
        _imagePath != null ||
            (_existingImageUrl.isNotEmpty &&
                !_removeExistingImage) ||
            _visualBuilder.hasContent;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit Submateri'
              : 'Tambah Submateri',
        ),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            17,
            16,
            110,
          ),
          children: <Widget>[
            _SectionCard(
              title: 'Informasi dasar',
              subtitle:
                  'Identitas dan urutan submateri.',
              children: <Widget>[
                TextFormField(
                  controller:
                      _titleController,
                  textCapitalization:
                      TextCapitalization
                          .sentences,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Judul submateri',
                    hintText:
                        'Contoh: Pengertian Asam dan Basa',
                    prefixIcon: Icon(
                      Icons.title_rounded,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Judul wajib diisi.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller:
                      _orderController,
                  keyboardType:
                      TextInputType.number,
                  inputFormatters: <
                      TextInputFormatter>[
                    FilteringTextInputFormatter
                        .digitsOnly,
                  ],
                  decoration:
                      const InputDecoration(
                    labelText: 'Urutan',
                    prefixIcon: Icon(
                      Icons.format_list_numbered,
                    ),
                  ),
                  validator: (value) {
                    final int? number =
                        int.tryParse(
                      value?.trim() ?? '',
                    );

                    if (number == null ||
                        number < 1) {
                      return 'Urutan minimal 1.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller:
                      _summaryController,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Ringkasan singkat',
                    hintText:
                        'Gambaran isi submateri',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ModeStatusCard(
              hasRead: hasRead,
              hasListen: hasListen,
              hasVisual: hasVisual,
            ),
            const SizedBox(height: 14),

            // MODE BACA
            _SectionCard(
              title: 'Mode Baca',
              subtitle:
                  'Isi utama yang dibaca siswa.',
              icon: Icons.menu_book_rounded,
              children: <Widget>[
                TextFormField(
                  controller:
                      _readController,
                  minLines: 8,
                  maxLines: 18,
                  onChanged: (_) =>
                      setState(() {}),
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Isi materi baca',
                    hintText:
                        'Tulis materi dengan paragraf singkat dan bahasa yang mudah dipahami.',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // MODE DENGARKAN
            _SectionCard(
              title: 'Mode Dengarkan',
              subtitle:
                  'Prioritas audio file. Jika kosong, aplikasi memakai teks TTS.',
              icon: Icons.headphones_rounded,
              children: <Widget>[
                TextFormField(
                  controller:
                      _ttsController,
                  minLines: 5,
                  maxLines: 12,
                  onChanged: (_) =>
                      setState(() {}),
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Naskah Text-to-Speech',
                    hintText:
                        'Tulis narasi yang nyaman didengarkan.',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                _FilePickerCard(
                  icon: Icons.audio_file_rounded,
                  title: 'File audio',
                  subtitle:
                      'MP3, WAV, M4A, AAC, atau OGG',
                  selectedPath: _audioPath,
                  existingUrl:
                      _removeExistingAudio
                          ? ''
                          : _existingAudioUrl,
                  onPick: _pickAudio,
                  onRemove: _removeAudio,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // MODE VISUAL
            _SectionCard(
              title: 'Mode Visual',
              subtitle:
                  'Gambar utama dan data visual interaktif.',
              icon:
                  Icons.auto_awesome_rounded,
              children: <Widget>[
                _ImagePickerCard(
                  selectedPath: _imagePath,
                  existingUrl:
                      _removeExistingImage
                          ? ''
                          : _existingImageUrl,
                  onPick: _pickImage,
                  onRemove: _removeImage,
                ),
                const SizedBox(height: 14),
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
                    existingImageUrl: _removeExistingImage
                        ? ''
                        : _existingImageUrl,
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
            const SizedBox(height: 14),

            _SectionCard(
              title: 'Status',
              subtitle:
                  'Atur kewajiban dan publikasi.',
              children: <Widget>[
                SwitchListTile.adaptive(
                  contentPadding:
                      EdgeInsets.zero,
                  title: const Text(
                    'Submateri wajib',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  subtitle: const Text(
                    'Diperhitungkan dalam penyelesaian modul.',
                  ),
                  value: _isRequired,
                  onChanged: (value) {
                    setState(() {
                      _isRequired = value;
                    });
                  },
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding:
                      EdgeInsets.zero,
                  title: const Text(
                    'Dipublikasikan',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  subtitle: const Text(
                    'Siswa dapat melihat submateri ini.',
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
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Obx(
            () => FilledButton.icon(
              onPressed: controller
                      .isSavingSubmaterial
                      .value
                  ? null
                  : _save,
              icon: controller
                      .isSavingSubmaterial
                      .value
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.save_rounded,
                    ),
              label: Text(
                widget.isEditing
                    ? 'Simpan Perubahan'
                    : 'Buat Submateri',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAudio() async {
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(
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

    final String? path =
        result?.files.single.path;

    if (path == null) {
      return;
    }

    setState(() {
      _audioPath = path;
      _removeExistingAudio = false;
    });
  }

  Future<void> _pickImage() async {
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    final String? path =
        result?.files.single.path;

    if (path == null) {
      return;
    }

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
    _visualJsonController.text =
        const JsonEncoder.withIndent('  ').convert(
      _visualBuilder.buildData(),
    );
    _visualJsonError = null;
  }

  bool _visualJsonHasContent() {
    final String text =
        _visualJsonController.text.trim();

    return text.isNotEmpty &&
        text != '{}' &&
        text != '{\n}';
  }

  bool _validateVisualJson({
    bool showSuccess = true,
  }) {
    final String text =
        _visualJsonController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _visualJsonError = null;
      });

      return true;
    }

    try {
      final dynamic decoded =
          jsonDecode(text);

      if (decoded is! Map) {
        setState(() {
          _visualJsonError =
              'Data visual harus berupa objek JSON.';
        });

        return false;
      }

      setState(() {
        _visualJsonError = null;
      });

      if (showSuccess) {
        Get.snackbar(
          'JSON valid',
          'Format data visual dapat disimpan.',
          snackPosition:
              SnackPosition.BOTTOM,
          backgroundColor:
              const Color(0xFFE7F8EE),
          colorText:
              const Color(0xFF166534),
        );
      }

      return true;
    } catch (e) {
      setState(() {
        _visualJsonError =
            'JSON tidak valid: $e';
      });

      return false;
    }
  }

  void _applyTemplate() {
    final bool hasCustom =
        _visualJsonHasContent();

    if (hasCustom) {
      Get.defaultDialog(
        title: 'Ganti data visual?',
        middleText:
            'Isi JSON sekarang akan diganti dengan template ${_visualTypeLabel(_visualType)}.',
        textCancel: 'Batal',
        textConfirm: 'Ganti',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back<void>();

          setState(() {
            _visualJsonController.text =
                _templateFor(
              _visualType,
            );
            _visualJsonError = null;
          });
        },
      );

      return;
    }

    setState(() {
      _visualJsonController.text =
          _templateFor(
        _visualType,
      );
      _visualJsonError = null;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState
            ?.validate() ??
        false)) {
      return;
    }

    final bool hasVisualImage =
        _imagePath != null ||
        (_existingImageUrl.isNotEmpty &&
            !_removeExistingImage);

    final String? visualError =
        _visualBuilder.validate(
      hasImage: hasVisualImage,
    );

    if (visualError != null) {
      controller.showError(visualError);
      return;
    }

    _syncVisualData();

    if (!_validateVisualJson(
      showSuccess: false,
    )) {
      return;
    }

    final bool hasAnyMode =
        _readController.text
                .trim()
                .isNotEmpty ||
            _ttsController.text
                .trim()
                .isNotEmpty ||
            _audioPath != null ||
            (_existingAudioUrl.isNotEmpty &&
                !_removeExistingAudio) ||
            _imagePath != null ||
            (_existingImageUrl.isNotEmpty &&
                !_removeExistingImage) ||
            _visualJsonHasContent();

    if (!hasAnyMode) {
      controller.showError(
        'Isi minimal satu mode: Baca, Dengarkan, atau Visual.',
      );
      return;
    }

    final String jsonText =
        _visualJsonController.text.trim();

    final Map<String, dynamic>
        visualData =
        jsonText.isEmpty
            ? <String, dynamic>{}
            : Map<String, dynamic>.from(
                jsonDecode(jsonText)
                    as Map,
              );

    final Map<String, dynamic> data =
        <String, dynamic>{
      'title':
          _titleController.text.trim(),
      'order_index': int.parse(
        _orderController.text.trim(),
      ),
      'summary':
          _summaryController.text.trim(),
      'read_content':
          _readController.text.trim(),
      'tts_text':
          _ttsController.text.trim(),
      'visual_type': _visualType,
      'visual_data': visualData,
      'is_required': _isRequired,
      'is_published': _isPublished,
      if (_removeExistingAudio &&
          _audioPath == null)
        'audio_url': '',
      if (_removeExistingImage &&
          _imagePath == null)
        'image_url': '',
    };

    final bool success =
        await controller.saveSubmaterial(
      submaterialId:
          widget.submaterial == null
              ? null
              : AdminLearningController
                  .intValue(
                  widget.submaterial!['id'],
                ),
      materialId: widget.materialId,
      data: data,
      audioPath: _audioPath,
      imagePath: _imagePath,
    );

    if (success) {
      Get.back<bool>(result: true);
    }
  }
}

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
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFEAF1FF,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: _primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF172554),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ModeStatus(
              icon: Icons.menu_book_rounded,
              label: 'Baca',
              active: hasRead,
            ),
          ),
          Expanded(
            child: _ModeStatus(
              icon: Icons.headphones_rounded,
              label: 'Dengar',
              active: hasListen,
            ),
          ),
          Expanded(
            child: _ModeStatus(
              icon:
                  Icons.auto_awesome_rounded,
              label: 'Visual',
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
          active
              ? Icons.check_circle_rounded
              : icon,
          color: active
              ? const Color(0xFF86EFAC)
              : const Color(0xFF94A3B8),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: active
                ? Colors.white
                : const Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

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
    final bool hasFile =
        selectedPath != null ||
            existingUrl.isNotEmpty;

    final String fileName =
        selectedPath != null
            ? File(selectedPath!)
                .uri
                .pathSegments
                .last
            : existingUrl.isNotEmpty
                ? Uri.tryParse(existingUrl)
                        ?.pathSegments
                        .last ??
                    existingUrl
                : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: _primary,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hasFile ? fileName : title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasFile
                      ? 'Siap digunakan'
                      : subtitle,
                  style: const TextStyle(
                    color: _muted,
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
                color: Color(0xFFDC2626),
              ),
            ),
          OutlinedButton(
            onPressed: onPick,
            child: Text(
              hasFile ? 'Ganti' : 'Pilih',
            ),
          ),
        ],
      ),
    );
  }
}

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
    final String? resolvedUrl =
        existingUrl.isEmpty
            ? null
            : ApiService.resolveMediaUrl(
                existingUrl,
              );

    final bool hasImage =
        selectedPath != null ||
            resolvedUrl != null;

    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: hasImage
          ? Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  child: selectedPath != null
                      ? Image.file(
                          File(
                            selectedPath!,
                          ),
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          resolvedUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Center(
                              child: Text(
                                'Gambar gagal dimuat',
                              ),
                            );
                          },
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: <Widget>[
                      _ImageAction(
                        icon:
                            Icons.edit_rounded,
                        tooltip: 'Ganti',
                        onTap: onPick,
                      ),
                      const SizedBox(width: 6),
                      _ImageAction(
                        icon:
                            Icons.delete_rounded,
                        tooltip: 'Hapus',
                        onTap: onRemove,
                        danger: true,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : InkWell(
              borderRadius:
                  BorderRadius.circular(17),
              onTap: onPick,
              child: const Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons
                        .add_photo_alternate_outlined,
                    size: 43,
                    color: _primary,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih gambar visual',
                    style: TextStyle(
                      color: _text,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'JPG, JPEG, PNG, GIF, atau WEBP',
                    style: TextStyle(
                      color: _muted,
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
      color: danger
          ? const Color(0xFFDC2626)
          : Colors.white,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(
          icon,
          color:
              danger ? Colors.white : _text,
          size: 20,
        ),
      ),
    );
  }
}

String _visualTypeLabel(String type) {
  switch (type) {
    case 'comparison':
      return 'Perbandingan';
    case 'flow':
      return 'Alur';
    case 'chart':
      return 'Grafik/Data';
    case 'formula':
      return 'Rumus';
    case 'hotspot':
      return 'Titik Gambar';
    case 'sequence':
      return 'Urutan Proses';
    default:
      return 'Infografik';
  }
}

String _templateFor(String type) {
  const JsonEncoder encoder =
      JsonEncoder.withIndent('  ');

  switch (type) {
    case 'comparison':
      return encoder.convert(
        <String, dynamic>{
          'title': 'Judul perbandingan',
          'description':
              'Penjelasan singkat.',
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'title': 'Bagian A',
              'description':
                  'Penjelasan bagian A.',
            },
            <String, dynamic>{
              'title': 'Bagian B',
              'description':
                  'Penjelasan bagian B.',
            },
          ],
        },
      );

    case 'flow':
    case 'sequence':
      return encoder.convert(
        <String, dynamic>{
          'title': 'Judul proses',
          'description':
              'Penjelasan singkat.',
          'steps': <Map<String, dynamic>>[
            <String, dynamic>{
              'title': 'Langkah 1',
              'description':
                  'Penjelasan langkah pertama.',
            },
            <String, dynamic>{
              'title': 'Langkah 2',
              'description':
                  'Penjelasan langkah kedua.',
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
          'description':
              'Titik penting pada gambar.',
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
          'description':
              'Penjelasan singkat.',
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'title': 'Poin 1',
              'description':
                  'Penjelasan poin pertama.',
            },
            <String, dynamic>{
              'title': 'Poin 2',
              'description':
                  'Penjelasan poin kedua.',
            },
          ],
        },
      );
  }
}
