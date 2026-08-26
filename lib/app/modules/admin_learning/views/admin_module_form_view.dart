import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/api_service.dart';
import '../controllers/admin_learning_controller.dart';

const Color _primary = Color(0xFF2563EB);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _background = Color(0xFFF5F8FF);

class AdminModuleFormView
    extends StatefulWidget {
  const AdminModuleFormView({
    super.key,
    this.module,
  });

  final Map<String, dynamic>? module;

  bool get isEditing => module != null;

  @override
  State<AdminModuleFormView> createState() =>
      _AdminModuleFormViewState();
}

class _AdminModuleFormViewState
    extends State<AdminModuleFormView> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _titleController =
      TextEditingController();

  final TextEditingController
      _introController =
      TextEditingController();

  final TextEditingController
      _orderController =
      TextEditingController(text: '1');

  final TextEditingController
      _sceneController =
      TextEditingController();

  final TextEditingController
      _instructionsController =
      TextEditingController();

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

    final Map<String, dynamic>? module =
        widget.module;

    if (module != null) {
      _titleController.text =
          module['title']?.toString() ?? '';

      _introController.text =
          module['short_description']
                  ?.toString() ??
              '';

      _orderController.text =
          AdminLearningController.intValue(
        module['module_order'],
        fallback: 1,
      ).toString();

      _sceneController.text =
          module['unity_scene_id']
                  ?.toString() ??
              '';

      _instructionsController.text =
          module['instructions']
                  ?.toString() ??
              '';

      _existingImageUrl =
          module['image_url']
                  ?.toString()
                  .trim() ??
              '';

      final String category =
          module['category']?.toString() ??
              'Kimia';

      if (const <String>[
        'Fisika',
        'Kimia',
        'Biologi',
      ].contains(category)) {
        _category = category;
      }

      _level =
          AdminLearningController.intValue(
        module['level'],
        fallback: 1,
      ).clamp(1, 3);

      _isRequired =
          AdminLearningController.boolValue(
        module['is_required'],
        fallback: true,
      );

      _isPublished =
          AdminLearningController.boolValue(
        module['is_published'],
        fallback: true,
      );
    }

    _introController.addListener(
      _refreshCounter,
    );
  }

  void _refreshCounter() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _introController.removeListener(
      _refreshCounter,
    );

    _titleController.dispose();
    _introController.dispose();
    _orderController.dispose();
    _sceneController.dispose();
    _instructionsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int introLength =
        _introController.text.length;

    final bool introNearLimit =
        introLength >= 130;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit Modul'
              : 'Buat Modul',
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
            18,
            18,
            18,
            110,
          ),
          children: <Widget>[
            _SectionCard(
              title: 'Informasi utama',
              subtitle:
                  'Identitas modul yang dilihat siswa.',
              children: <Widget>[
                TextFormField(
                  controller:
                      _titleController,
                  textCapitalization:
                      TextCapitalization
                          .sentences,
                  decoration:
                      const InputDecoration(
                    labelText: 'Judul modul',
                    hintText:
                        'Contoh: Konsep Asam dan Basa',
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
                const SizedBox(height: 15),
                DropdownButtonFormField<
                    String>(
                  value: _category,
                  decoration:
                      const InputDecoration(
                    labelText: 'Mata pelajaran',
                    prefixIcon: Icon(
                      Icons.category_rounded,
                    ),
                  ),
                  items: const <String>[
                    'Fisika',
                    'Kimia',
                    'Biologi',
                  ].map((item) {
                    return DropdownMenuItem<
                        String>(
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
                const SizedBox(height: 15),
                DropdownButtonFormField<int>(
                  value: _level,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Level pembelajaran',
                    prefixIcon: Icon(
                      Icons.layers_rounded,
                    ),
                  ),
                  items: List<
                      DropdownMenuItem<int>>.generate(
                    3,
                    (index) {
                      final int level =
                          index + 1;

                      return DropdownMenuItem<
                          int>(
                        value: level,
                        child:
                            Text('Level $level'),
                      );
                    },
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _level = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 15),
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
                    labelText: 'Urutan modul',
                    hintText: '1',
                    prefixIcon: Icon(
                      Icons.format_list_numbered,
                    ),
                  ),
                  validator: (value) {
                    final int? order =
                        int.tryParse(
                      value?.trim() ?? '',
                    );

                    if (order == null ||
                        order < 0) {
                      return 'Urutan harus berupa angka.';
                    }

                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            _SectionCard(
              title: 'Intro singkat',
              subtitle:
                  'Gunakan gaya casual, fun, dan memancing rasa penasaran.',
              children: <Widget>[
                TextFormField(
                  controller:
                      _introController,
                  maxLines: 4,
                  maxLength:
                      AdminLearningController
                          .maxIntroLength,
                  inputFormatters: <
                      TextInputFormatter>[
                    LengthLimitingTextInputFormatter(
                      AdminLearningController
                          .maxIntroLength,
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText:
                        'Intro modul',
                    hintText:
                        'Pernah mikir gak kenapa...',
                    alignLabelWithHint: true,
                    helperText:
                        '1–2 kalimat pendek. Hindari definisi yang terlalu formal.',
                    counterStyle: TextStyle(
                      color: introNearLimit
                          ? const Color(
                              0xFFB45309,
                            )
                          : _muted,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  validator: (value) {
                    final String text =
                        value?.trim() ?? '';

                    if (text.isEmpty) {
                      return 'Intro modul wajib diisi.';
                    }

                    if (text.length >
                        AdminLearningController
                            .maxIntroLength) {
                      return 'Intro maksimal 150 karakter.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _IntroPreview(
                  title:
                      _titleController.text
                              .trim()
                              .isEmpty
                          ? 'Judul Modul'
                          : _titleController.text
                              .trim(),
                  intro:
                      _introController.text
                              .trim()
                              .isEmpty
                          ? 'Intro modul akan tampil di sini.'
                          : _introController.text
                              .trim(),
                  level: _level,
                  category: _category,
                ),
              ],
            ),
            const SizedBox(height: 15),
            _SectionCard(
              title: 'Laboratorium dan media',
              subtitle:
                  'Boleh dikosongkan untuk modul tanpa eksperimen.',
              children: <Widget>[
                TextFormField(
                  controller:
                      _sceneController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Unity Scene ID',
                    hintText:
                        'Contoh: Electrolysis',
                    prefixIcon: Icon(
                      Icons.science_rounded,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller:
                      _instructionsController,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Petunjuk laboratorium',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 15),
                _ModuleImagePickerCard(
                  selectedPath: _imagePath,
                  existingUrl:
                      _removeExistingImage
                          ? ''
                          : _existingImageUrl,
                  onPick: _pickImage,
                  onRemove: _removeImage,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Guru cukup memilih gambar dari galeri atau penyimpanan HP. Path akan dibuat otomatis oleh server.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _SectionCard(
              title: 'Status modul',
              subtitle:
                  'Atur akses dan publikasi konten.',
              children: <Widget>[
                SwitchListTile.adaptive(
                  contentPadding:
                      EdgeInsets.zero,
                  title: const Text(
                    'Modul wajib',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  subtitle: const Text(
                    'Wajib diselesaikan untuk membuka level berikutnya.',
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
                    'Siswa hanya melihat modul yang dipublikasikan.',
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
            18,
            12,
            18,
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
              onPressed:
                  _controller.isSaving.value
                      ? null
                      : _save,
              icon:
                  _controller.isSaving.value
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
                    : 'Buat Modul',
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
    });
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
      _removeExistingImage = true;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState
            ?.validate() ??
        false)) {
      return;
    }

    final bool success =
        await _controller.saveModule(
      materialId: widget.module == null
          ? null
          : AdminLearningController
              .intValue(
              widget.module!['id'],
            ),
      imagePath: _imagePath,
      data: <String, dynamic>{
        'title':
            _titleController.text.trim(),
        'category': _category,
        'level': _level,
        'module_order': int.parse(
          _orderController.text.trim(),
        ),
        'short_description':
            _introController.text.trim(),
        'unity_scene_id':
            _sceneController.text.trim(),
        'instructions':
            _instructionsController.text
                .trim(),
        'remove_image':
            _removeExistingImage,
        'is_required': _isRequired,
        'is_published': _isPublished,
      },
    );

    if (success) {
      Get.back<bool>(result: true);
    }
  }
}

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
                      BorderRadius.circular(16),
                  child: selectedPath != null
                      ? Image.file(
                          File(selectedPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) => const _ModuleImageError(),
                        )
                      : Image.network(
                          resolvedUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) => const _ModuleImageError(),
                        ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: <Widget>[
                      _ModuleImageAction(
                        icon: Icons.edit_rounded,
                        tooltip: 'Ganti gambar',
                        onTap: onPick,
                      ),
                      const SizedBox(width: 6),
                      _ModuleImageAction(
                        icon: Icons.delete_rounded,
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
              borderRadius:
                  BorderRadius.circular(17),
              onTap: onPick,
              child: const Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 43,
                    color: _primary,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih cover modul',
                    style: TextStyle(
                      color: _text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Pilih langsung dari HP',
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
            Icon(
              Icons.broken_image_outlined,
              color: _muted,
              size: 38,
            ),
            SizedBox(height: 7),
            Text(
              'Gambar tidak dapat ditampilkan',
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

class _ModuleImageAction extends StatelessWidget {
  const _ModuleImageAction({
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
          color: danger ? Colors.white : _text,
          size: 20,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

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
          Text(
            title,
            style: const TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 17),
          ...children,
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius:
            BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _PreviewPill(
                text: category,
              ),
              const SizedBox(width: 7),
              _PreviewPill(
                text: 'Level $level',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            intro,
            style: const TextStyle(
              color: Color(0xFFDCE9FF),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.17,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
