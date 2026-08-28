import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/science_shimmer.dart';

import '../../../data/api_service.dart';
import '../controllers/admin_learning_controller.dart';

const Color _primary = Color(0xFF7C3AED);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _background = Color(0xFFF5F8FF);
const Color _danger = Color(0xFFDC2626);
const Color _success = Color(0xFF16A34A);

class AdminCheckpointManagerView extends StatefulWidget {
  const AdminCheckpointManagerView({super.key, required this.submaterial});

  final Map<String, dynamic> submaterial;

  @override
  State<AdminCheckpointManagerView> createState() =>
      _AdminCheckpointManagerViewState();
}

class _AdminCheckpointManagerViewState
    extends State<AdminCheckpointManagerView> {
  AdminLearningController get controller => Get.find<AdminLearningController>();

  int get submaterialId =>
      AdminLearningController.intValue(widget.submaterial['id']);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.openCheckpointManager(widget.submaterial),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Kelola Checkpoint'),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Get.to<bool>(
              () => AdminCheckpointFormView(submaterialId: submaterialId),
            ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text(
          'Tambah Checkpoint',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadCheckpoints(submaterialId),
        child: Obx(() {
          if (controller.isLoadingCheckpoints.value &&
              controller.checkpoints.isEmpty) {
            return const AdminModuleListShimmer(itemCount: 3);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: <Widget>[
              _Header(
                title: widget.submaterial['title']?.toString() ?? 'Submateri',
              ),
              const SizedBox(height: 14),
              if (controller.checkpoints.isEmpty)
                const _EmptyState()
              else
                ...controller.checkpoints.map(
                  (checkpoint) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CheckpointCard(
                      checkpoint: checkpoint,
                      onEdit:
                          () => Get.to<bool>(
                            () => AdminCheckpointFormView(
                              submaterialId: submaterialId,
                              checkpoint: checkpoint,
                            ),
                          ),
                      onDelete: () => controller.deleteCheckpoint(checkpoint),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class AdminCheckpointFormView extends StatefulWidget {
  const AdminCheckpointFormView({
    super.key,
    required this.submaterialId,
    this.checkpoint,
  });

  final int submaterialId;
  final Map<String, dynamic>? checkpoint;

  bool get isEditing => checkpoint != null;

  @override
  State<AdminCheckpointFormView> createState() =>
      _AdminCheckpointFormViewState();
}

class _AdminCheckpointFormViewState extends State<AdminCheckpointFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController(
    text: 'Cek Pemahaman',
  );
  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _orderController = TextEditingController(
    text: '1',
  );
  final TextEditingController _correctFeedbackController =
      TextEditingController(text: 'Mantap, jawabanmu benar!');
  final TextEditingController _wrongFeedbackController = TextEditingController(
    text: 'Belum tepat. Pelajari kembali bagian ini lalu coba lagi.',
  );

  final List<TextEditingController> _choiceControllers =
      List<TextEditingController>.generate(4, (_) => TextEditingController());

  String _correctChoice = 'A';
  bool _trueFalseAnswer = true;

  final List<_MatchingDraft> _matchingItems = <_MatchingDraft>[];

  final List<TextEditingController> _orderingItems = <TextEditingController>[];

  final TextEditingController _dataTitleController = TextEditingController(
    text: 'Data Pengamatan',
  );
  final TextEditingController _dataDescriptionController =
      TextEditingController();
  final TextEditingController _headerOneController = TextEditingController(
    text: 'Objek',
  );
  final TextEditingController _headerTwoController = TextEditingController(
    text: 'Nilai',
  );
  final List<_TableRowDraft> _tableRows = <_TableRowDraft>[];
  final List<TextEditingController> _analysisOptionControllers =
      List<TextEditingController>.generate(4, (_) => TextEditingController());
  String _analysisCorrectChoice = 'A';

  final List<_HotspotDraft> _hotspots = <_HotspotDraft>[];

  String _type = 'multiple_choice';
  bool _isRequired = true;
  String? _imagePath;
  String _existingImageUrl = '';
  bool _removeImage = false;

  AdminLearningController get controller => Get.find<AdminLearningController>();

  @override
  void initState() {
    super.initState();

    _setDefaultTypeValues();

    final Map<String, dynamic>? data = widget.checkpoint;

    if (data == null) {
      return;
    }

    _type = data['checkpoint_type']?.toString() ?? 'multiple_choice';
    _titleController.text = data['title']?.toString() ?? 'Cek Pemahaman';
    _instructionController.text = data['instruction']?.toString() ?? '';
    _questionController.text = data['question_text']?.toString() ?? '';
    _orderController.text =
        AdminLearningController.intValue(
          data['order_index'],
          fallback: 1,
        ).toString();
    _correctFeedbackController.text =
        data['correct_feedback']?.toString() ?? '';
    _wrongFeedbackController.text = data['wrong_feedback']?.toString() ?? '';
    _isRequired = AdminLearningController.boolValue(
      data['is_required'],
      fallback: true,
    );
    _existingImageUrl = data['image_url']?.toString().trim() ?? '';

    _loadTypeValues(
      AdminLearningController.mapValue(data['content']),
      AdminLearningController.mapValue(data['answer']),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionController.dispose();
    _questionController.dispose();
    _orderController.dispose();
    _correctFeedbackController.dispose();
    _wrongFeedbackController.dispose();

    for (final TextEditingController item in _choiceControllers) {
      item.dispose();
    }

    for (final _MatchingDraft item in _matchingItems) {
      item.dispose();
    }

    for (final TextEditingController item in _orderingItems) {
      item.dispose();
    }

    _dataTitleController.dispose();
    _dataDescriptionController.dispose();
    _headerOneController.dispose();
    _headerTwoController.dispose();

    for (final _TableRowDraft row in _tableRows) {
      row.dispose();
    }

    for (final TextEditingController item in _analysisOptionControllers) {
      item.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? resolvedImage =
        _existingImageUrl.isEmpty || _removeImage
            ? null
            : ApiService.resolveMediaUrl(_existingImageUrl);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Checkpoint' : 'Tambah Checkpoint'),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: <Widget>[
            _InfoBanner(type: _type),
            const SizedBox(height: 14),
            _Section(
              title: 'Informasi Dasar',
              children: <Widget>[
                Obx(() {
                  final List<Map<String, dynamic>> types =
                      controller.checkpointTypes.isEmpty
                          ? _fallbackTypes
                          : controller.checkpointTypes;

                  return DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Jenis checkpoint',
                    ),
                    items:
                        types
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item['value'].toString(),
                                child: Text(
                                  item['label']?.toString() ??
                                      item['value'].toString(),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (String? value) {
                      if (value == null || value == _type) {
                        return;
                      }

                      setState(() {
                        _type = value;
                        _setDefaultTypeValues();
                      });
                    },
                  );
                }),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul checkpoint',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _instructionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Instruksi',
                    hintText: 'Contoh: Pilih jawaban yang paling tepat.',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _questionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Pertanyaan utama',
                    alignLabelWithHint: true,
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _orderController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(labelText: 'Urutan'),
                  validator: (String? value) {
                    final int? number = int.tryParse(value?.trim() ?? '');

                    if (number == null || number < 1) {
                      return 'Urutan minimal 1.';
                    }

                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildAnswerEditor(resolvedImage),
            const SizedBox(height: 14),
            if (_type != 'image_hotspot') _buildOptionalImage(resolvedImage),
            if (_type != 'image_hotspot') const SizedBox(height: 14),
            _Section(
              title: 'Feedback dan Status',
              children: <Widget>[
                TextFormField(
                  controller: _correctFeedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Feedback jawaban benar',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _wrongFeedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Feedback jawaban salah',
                    alignLabelWithHint: true,
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Checkpoint wajib'),
                  subtitle: const Text(
                    'Siswa harus menyelesaikannya untuk menuntaskan submateri.',
                  ),
                  value: _isRequired,
                  onChanged: (bool value) {
                    setState(() {
                      _isRequired = value;
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Obx(
            () => FilledButton.icon(
              onPressed: controller.isSavingCheckpoint.value ? null : _save,
              icon:
                  controller.isSavingCheckpoint.value
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.save_rounded),
              label: Text(
                widget.isEditing ? 'Simpan Perubahan' : 'Buat Checkpoint',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerEditor(String? resolvedImage) {
    switch (_type) {
      case 'true_false':
        return _buildTrueFalseEditor();
      case 'matching':
        return _buildMatchingEditor();
      case 'ordering':
        return _buildOrderingEditor();
      case 'image_hotspot':
        return _buildHotspotEditor(resolvedImage);
      case 'data_interpretation':
        return _buildDataEditor();
      case 'multiple_choice':
      default:
        return _buildChoiceEditor();
    }
  }

  Widget _buildChoiceEditor() {
    return _Section(
      title: 'Pilihan Jawaban',
      children: <Widget>[
        const Text(
          'Isi empat pilihan, lalu pilih jawaban yang benar.',
          style: TextStyle(color: _muted, height: 1.4),
        ),
        const SizedBox(height: 12),
        ...List<Widget>.generate(4, (int index) {
          final String letter = String.fromCharCode(65 + index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Radio<String>(
                  value: letter,
                  groupValue: _correctChoice,
                  onChanged: (String? value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _correctChoice = value;
                    });
                  },
                ),
                Expanded(
                  child: TextFormField(
                    controller: _choiceControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Pilihan $letter',
                      hintText: 'Isi jawaban $letter',
                    ),
                    validator: _required,
                  ),
                ),
              ],
            ),
          );
        }),
        const Text(
          'Lingkaran yang dipilih merupakan kunci jawaban.',
          style: TextStyle(color: _muted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildTrueFalseEditor() {
    return _Section(
      title: 'Kunci Jawaban',
      children: <Widget>[
        const Text(
          'Tentukan apakah pernyataan pada pertanyaan benar atau salah.',
          style: TextStyle(color: _muted, height: 1.4),
        ),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
          segments: const <ButtonSegment<bool>>[
            ButtonSegment<bool>(
              value: true,
              icon: Icon(Icons.check_circle_rounded),
              label: Text('Benar'),
            ),
            ButtonSegment<bool>(
              value: false,
              icon: Icon(Icons.cancel_rounded),
              label: Text('Salah'),
            ),
          ],
          selected: <bool>{_trueFalseAnswer},
          onSelectionChanged: (Set<bool> selected) {
            setState(() {
              _trueFalseAnswer = selected.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMatchingEditor() {
    return _Section(
      title: 'Pasangan Jawaban',
      children: <Widget>[
        const Text(
          'Setiap baris adalah satu pasangan yang benar. Siswa nanti memasangkan kolom kiri dan kanan.',
          style: TextStyle(color: _muted, height: 1.4),
        ),
        const SizedBox(height: 12),
        ..._matchingItems.asMap().entries.map((
          MapEntry<int, _MatchingDraft> entry,
        ) {
          final int index = entry.key;
          final _MatchingDraft item = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 11),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Pasangan ${index + 1}',
                        style: const TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (_matchingItems.length > 2)
                      IconButton(
                        tooltip: 'Hapus pasangan',
                        onPressed: () {
                          setState(() {
                            final removed = _matchingItems.removeAt(index);
                            removed.dispose();
                          });
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: _danger,
                        ),
                      ),
                  ],
                ),
                TextFormField(
                  controller: item.leftController,
                  decoration: const InputDecoration(
                    labelText: 'Isi kolom kiri',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 9),
                TextFormField(
                  controller: item.rightController,
                  decoration: const InputDecoration(
                    labelText: 'Pasangan yang benar',
                  ),
                  validator: _required,
                ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _matchingItems.add(_MatchingDraft());
            });
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah Pasangan'),
        ),
      ],
    );
  }

  Widget _buildOrderingEditor() {
    return _Section(
      title: 'Urutan yang Benar',
      children: <Widget>[
        const Text(
          'Isi langkah sesuai urutan yang benar. Tekan dan geser ikon di kanan untuk mengubah posisi.',
          style: TextStyle(color: _muted, height: 1.4),
        ),
        const SizedBox(height: 12),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _orderingItems.length,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }

              final TextEditingController item = _orderingItems.removeAt(
                oldIndex,
              );
              _orderingItems.insert(newIndex, item);
            });
          },
          itemBuilder: (BuildContext context, int index) {
            return Container(
              key: ObjectKey(_orderingItems[index]),
              margin: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFEDE9FE),
                    foregroundColor: _primary,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: TextFormField(
                      controller: _orderingItems[index],
                      decoration: InputDecoration(
                        labelText: 'Langkah ${index + 1}',
                      ),
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.drag_handle_rounded, color: _muted),
                    ),
                  ),
                  if (_orderingItems.length > 2)
                    IconButton(
                      tooltip: 'Hapus langkah',
                      onPressed: () {
                        setState(() {
                          final removed = _orderingItems.removeAt(index);
                          removed.dispose();
                        });
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: _danger,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _orderingItems.add(TextEditingController());
            });
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah Langkah'),
        ),
      ],
    );
  }

  Widget _buildHotspotEditor(String? resolvedImage) {
    final bool hasImage = _imagePath != null || resolvedImage != null;

    return Column(
      children: <Widget>[
        _Section(
          title: 'Gambar Interaktif',
          children: <Widget>[
            const Text(
              '1. Pilih gambar. 2. Ketuk bagian gambar untuk menambahkan titik. 3. Isi nama dan penjelasan titik.',
              style: TextStyle(color: _muted, height: 1.45),
            ),
            const SizedBox(height: 12),
            if (!hasImage)
              _ImagePickerPlaceholder(
                label: 'Pilih gambar terlebih dahulu',
                onTap: _pickImage,
              )
            else ...<Widget>[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        _createHotspot(
                          details.localPosition,
                          Size(constraints.maxWidth, constraints.maxHeight),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            if (_imagePath != null)
                              Image.file(File(_imagePath!), fit: BoxFit.cover)
                            else
                              Image.network(
                                resolvedImage!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const _ImageError(),
                              ),
                            ..._hotspots.map((_HotspotDraft hotspot) {
                              return Positioned(
                                left: hotspot.x * (constraints.maxWidth - 40),
                                top: hotspot.y * (constraints.maxHeight - 40),
                                child: GestureDetector(
                                  onTap: () => _editHotspot(hotspot),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          hotspot.isCorrect
                                              ? _success
                                              : _primary,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: const <BoxShadow>[
                                        BoxShadow(
                                          color: Color(0x33000000),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${_hotspots.indexOf(hotspot) + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image_search_rounded),
                      label: const Text('Ganti Gambar'),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _imagePath = null;
                          _removeImage = true;
                          _hotspots.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: _danger),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Hapus Gambar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        _Section(
          title: 'Titik Penjelasan',
          children: <Widget>[
            if (_hotspots.isEmpty)
              const _InlineEmpty(
                text:
                    'Belum ada titik. Ketuk bagian gambar yang ingin dijadikan hotspot.',
              )
            else
              ..._hotspots.asMap().entries.map((
                MapEntry<int, _HotspotDraft> entry,
              ) {
                final int index = entry.key;
                final _HotspotDraft item = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        item.isCorrect
                            ? const Color(0xFFE7F8EE)
                            : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          item.isCorrect
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: item.isCorrect ? _success : _primary,
                        foregroundColor: Colors.white,
                        child: Text('${index + 1}'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: _text,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.explanation.isEmpty
                                  ? 'Belum ada penjelasan'
                                  : item.explanation,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                              ),
                            ),
                            if (item.isCorrect) ...<Widget>[
                              const SizedBox(height: 4),
                              const Text(
                                'Jawaban benar',
                                style: TextStyle(
                                  color: _success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit titik',
                        onPressed: () => _editHotspot(item),
                        icon: const Icon(Icons.edit_rounded, color: _primary),
                      ),
                      IconButton(
                        tooltip: 'Hapus titik',
                        onPressed: () {
                          setState(() {
                            _hotspots.removeAt(index);
                          });
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: _danger,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ],
    );
  }

  Widget _buildDataEditor() {
    return _Section(
      title: 'Data dan Pilihan Jawaban',
      children: <Widget>[
        const Text(
          'Guru cukup mengisi tabel sederhana dan pilihan kesimpulan. JSON dibuat otomatis oleh aplikasi.',
          style: TextStyle(color: _muted, height: 1.4),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _dataTitleController,
          decoration: const InputDecoration(labelText: 'Judul data'),
          validator: _required,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _dataDescriptionController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Keterangan data'),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: _headerOneController,
                decoration: const InputDecoration(labelText: 'Judul kolom 1'),
                validator: _required,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: TextFormField(
                controller: _headerTwoController,
                decoration: const InputDecoration(labelText: 'Judul kolom 2'),
                validator: _required,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._tableRows.asMap().entries.map((
          MapEntry<int, _TableRowDraft> entry,
        ) {
          final int index = entry.key;
          final _TableRowDraft row = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: row.firstController,
                    decoration: InputDecoration(
                      labelText: 'Baris ${index + 1} kolom 1',
                    ),
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: row.secondController,
                    decoration: InputDecoration(
                      labelText: 'Baris ${index + 1} kolom 2',
                    ),
                    validator: _required,
                  ),
                ),
                if (_tableRows.length > 2)
                  IconButton(
                    tooltip: 'Hapus baris',
                    onPressed: () {
                      setState(() {
                        final removed = _tableRows.removeAt(index);
                        removed.dispose();
                      });
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: _danger,
                    ),
                  ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _tableRows.add(_TableRowDraft());
            });
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah Baris Data'),
        ),
        const Divider(height: 28),
        const Text(
          'Pilihan kesimpulan',
          style: TextStyle(color: _text, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...List<Widget>.generate(4, (int index) {
          final String letter = String.fromCharCode(65 + index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Radio<String>(
                  value: letter,
                  groupValue: _analysisCorrectChoice,
                  onChanged: (String? value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _analysisCorrectChoice = value;
                    });
                  },
                ),
                Expanded(
                  child: TextFormField(
                    controller: _analysisOptionControllers[index],
                    decoration: InputDecoration(labelText: 'Pilihan $letter'),
                    validator: _required,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOptionalImage(String? resolvedImage) {
    return _Section(
      title: 'Gambar Opsional',
      children: <Widget>[
        SizedBox(
          height: 180,
          width: double.infinity,
          child:
              _imagePath != null || resolvedImage != null
                  ? Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child:
                            _imagePath != null
                                ? Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover,
                                )
                                : Image.network(
                                  resolvedImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const _ImageError(),
                                ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          children: <Widget>[
                            _CircleAction(
                              icon: Icons.edit_rounded,
                              onTap: _pickImage,
                            ),
                            const SizedBox(width: 6),
                            _CircleAction(
                              icon: Icons.delete_rounded,
                              onTap: () {
                                setState(() {
                                  _imagePath = null;
                                  _removeImage = true;
                                });
                              },
                              danger: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  : _ImagePickerPlaceholder(
                    label: 'Pilih gambar checkpoint',
                    onTap: _pickImage,
                  ),
        ),
      ],
    );
  }

  void _setDefaultTypeValues() {
    if (_choiceControllers.every(
      (TextEditingController item) => item.text.trim().isEmpty,
    )) {
      _choiceControllers[0].text = 'Pilihan A';
      _choiceControllers[1].text = 'Pilihan B';
      _choiceControllers[2].text = 'Pilihan C';
      _choiceControllers[3].text = 'Pilihan D';
    }

    if (_matchingItems.isEmpty) {
      _matchingItems.addAll(<_MatchingDraft>[
        _MatchingDraft(),
        _MatchingDraft(),
      ]);
    }

    if (_orderingItems.isEmpty) {
      _orderingItems.addAll(<TextEditingController>[
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    }

    if (_tableRows.isEmpty) {
      _tableRows.addAll(<_TableRowDraft>[_TableRowDraft(), _TableRowDraft()]);
    }

    if (_analysisOptionControllers.every(
      (TextEditingController item) => item.text.trim().isEmpty,
    )) {
      _analysisOptionControllers[0].text = 'Kesimpulan A';
      _analysisOptionControllers[1].text = 'Kesimpulan B';
      _analysisOptionControllers[2].text = 'Kesimpulan C';
      _analysisOptionControllers[3].text = 'Kesimpulan D';
    }
  }

  void _loadTypeValues(
    Map<String, dynamic> content,
    Map<String, dynamic> answer,
  ) {
    switch (_type) {
      case 'true_false':
        _trueFalseAnswer = AdminLearningController.boolValue(
          answer['correct'],
          fallback: true,
        );
        break;

      case 'matching':
        for (final _MatchingDraft item in _matchingItems) {
          item.dispose();
        }
        _matchingItems.clear();

        final List<Map<String, dynamic>> left = _mapList(content['left']);
        final List<Map<String, dynamic>> right = _mapList(content['right']);
        final List<Map<String, dynamic>> pairs = _mapList(answer['pairs']);

        final Map<String, String> rightTextById = <String, String>{
          for (final Map<String, dynamic> item in right)
            item['id'].toString(): item['text']?.toString() ?? '',
        };

        final Map<String, String> rightIdByLeft = <String, String>{
          for (final Map<String, dynamic> pair in pairs)
            pair['left_id'].toString(): pair['right_id'].toString(),
        };

        for (final Map<String, dynamic> item in left) {
          final String leftId = item['id'].toString();
          final String rightId = rightIdByLeft[leftId] ?? '';

          _matchingItems.add(
            _MatchingDraft(
              left: item['text']?.toString() ?? '',
              right: rightTextById[rightId] ?? '',
            ),
          );
        }

        if (_matchingItems.length < 2) {
          _matchingItems.addAll(
            List<_MatchingDraft>.generate(
              2 - _matchingItems.length,
              (_) => _MatchingDraft(),
            ),
          );
        }
        break;

      case 'ordering':
        for (final TextEditingController item in _orderingItems) {
          item.dispose();
        }
        _orderingItems.clear();

        final List<Map<String, dynamic>> items = _mapList(content['items']);
        final List<dynamic> order =
            answer['order'] is List ? answer['order'] as List : <dynamic>[];

        final Map<String, String> textById = <String, String>{
          for (final Map<String, dynamic> item in items)
            item['id'].toString(): item['text']?.toString() ?? '',
        };

        final Iterable<String> ids =
            order.isNotEmpty
                ? order.map((dynamic item) => item.toString())
                : items.map(
                  (Map<String, dynamic> item) => item['id'].toString(),
                );

        for (final String id in ids) {
          _orderingItems.add(TextEditingController(text: textById[id] ?? ''));
        }

        while (_orderingItems.length < 2) {
          _orderingItems.add(TextEditingController());
        }
        break;

      case 'image_hotspot':
        _hotspots.clear();

        final String correctId = answer['hotspot_id']?.toString() ?? '';

        for (final Map<String, dynamic> item in _mapList(content['hotspots'])) {
          final String id =
              item['id']?.toString() ?? 'hotspot_${_hotspots.length + 1}';

          _hotspots.add(
            _HotspotDraft(
              id: id,
              label: item['label']?.toString() ?? 'Titik',
              explanation:
                  item['explanation']?.toString() ??
                  item['description']?.toString() ??
                  '',
              x: _coordinate(item['x']),
              y: _coordinate(item['y']),
              isCorrect: id == correctId,
            ),
          );
        }
        break;

      case 'data_interpretation':
        _dataTitleController.text =
            content['title']?.toString() ?? 'Data Pengamatan';
        _dataDescriptionController.text =
            content['description']?.toString() ?? '';

        final List<dynamic> headers =
            content['headers'] is List
                ? content['headers'] as List
                : <dynamic>[];

        if (headers.isNotEmpty) {
          _headerOneController.text = headers.first.toString();
        }

        if (headers.length > 1) {
          _headerTwoController.text = headers[1].toString();
        }

        for (final _TableRowDraft row in _tableRows) {
          row.dispose();
        }
        _tableRows.clear();

        final List<dynamic> rows =
            content['rows'] is List ? content['rows'] as List : <dynamic>[];

        for (final dynamic rawRow in rows) {
          if (rawRow is List) {
            _tableRows.add(
              _TableRowDraft(
                first: rawRow.isNotEmpty ? rawRow[0].toString() : '',
                second: rawRow.length > 1 ? rawRow[1].toString() : '',
              ),
            );
          }
        }

        while (_tableRows.length < 2) {
          _tableRows.add(_TableRowDraft());
        }

        final List<Map<String, dynamic>> analysisOptions = _mapList(
          content['options'],
        );

        for (int index = 0; index < 4; index++) {
          _analysisOptionControllers[index].text =
              index < analysisOptions.length
                  ? analysisOptions[index]['text']?.toString() ?? ''
                  : '';
        }

        _analysisCorrectChoice = answer['correct']?.toString() ?? 'A';
        break;

      case 'multiple_choice':
      default:
        final List<Map<String, dynamic>> options = _mapList(content['options']);

        for (int index = 0; index < 4; index++) {
          _choiceControllers[index].text =
              index < options.length
                  ? options[index]['text']?.toString() ?? ''
                  : '';
        }

        _correctChoice = answer['correct']?.toString() ?? 'A';
    }

    _setDefaultTypeValues();
  }

  Future<void> _pickImage() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    final String? path = result?.files.single.path;

    if (path == null) {
      return;
    }

    setState(() {
      _imagePath = path;
      _removeImage = false;

      if (_type == 'image_hotspot') {
        _hotspots.clear();
      }
    });
  }

  Future<void> _createHotspot(Offset position, Size size) async {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final _HotspotDraft draft = _HotspotDraft(
      id: 'hotspot_${DateTime.now().microsecondsSinceEpoch}',
      label: 'Titik ${_hotspots.length + 1}',
      explanation: '',
      x: (position.dx / size.width).clamp(0.0, 1.0),
      y: (position.dy / size.height).clamp(0.0, 1.0),
      isCorrect: _hotspots.isEmpty,
    );

    final bool saved = await _showHotspotDialog(draft);

    if (!saved || !mounted) {
      return;
    }

    setState(() {
      if (draft.isCorrect) {
        for (final _HotspotDraft item in _hotspots) {
          item.isCorrect = false;
        }
      }

      _hotspots.add(draft);
    });
  }

  Future<void> _editHotspot(_HotspotDraft hotspot) async {
    final _HotspotDraft edited = hotspot.copy();

    final bool saved = await _showHotspotDialog(edited);

    if (!saved || !mounted) {
      return;
    }

    setState(() {
      if (edited.isCorrect) {
        for (final _HotspotDraft item in _hotspots) {
          item.isCorrect = false;
        }
      }

      final int index = _hotspots.indexOf(hotspot);

      if (index >= 0) {
        _hotspots[index] = edited;
      }
    });
  }

  Future<bool> _showHotspotDialog(_HotspotDraft hotspot) async {
    final TextEditingController labelController = TextEditingController(
      text: hotspot.label,
    );
    final TextEditingController explanationController = TextEditingController(
      text: hotspot.explanation,
    );

    bool correct = hotspot.isCorrect;
    String? validation;

    final bool result =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return StatefulBuilder(
              builder: (
                BuildContext context,
                void Function(void Function()) setDialogState,
              ) {
                return AlertDialog(
                  title: const Text('Atur Titik Gambar'),
                  content: SizedBox(
                    width: 480,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: labelController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Nama bagian',
                            hintText: 'Contoh: Buret',
                            errorText: validation,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: explanationController,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Penjelasan saat titik diklik',
                            hintText:
                                'Contoh: Buret digunakan untuk mengalirkan larutan secara terukur.',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Jadikan jawaban benar'),
                          subtitle: const Text(
                            'Hanya satu titik yang menjadi kunci jawaban.',
                          ),
                          value: correct,
                          onChanged: (bool value) {
                            setDialogState(() {
                              correct = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () {
                        final String label = labelController.text.trim();

                        if (label.isEmpty) {
                          setDialogState(() {
                            validation = 'Nama bagian wajib diisi.';
                          });
                          return;
                        }

                        hotspot.label = label;
                        hotspot.explanation = explanationController.text.trim();
                        hotspot.isCorrect = correct;

                        Navigator.of(dialogContext).pop(true);
                      },
                      child: const Text('Simpan Titik'),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;

    labelController.dispose();
    explanationController.dispose();

    return result;
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi.';
    }

    return null;
  }

  String? _validateTypeSpecific() {
    if (_type == 'image_hotspot') {
      final bool hasImage =
          _imagePath != null || (_existingImageUrl.isNotEmpty && !_removeImage);

      if (!hasImage) {
        return 'Pilih gambar untuk checkpoint hotspot.';
      }

      if (_hotspots.length < 2) {
        return 'Tambahkan minimal dua titik pada gambar.';
      }

      if (!_hotspots.any((_HotspotDraft item) => item.isCorrect)) {
        return 'Tentukan satu titik sebagai jawaban benar.';
      }
    }

    return null;
  }

  Map<String, dynamic> _buildContent() {
    switch (_type) {
      case 'true_false':
        return <String, dynamic>{};

      case 'matching':
        return <String, dynamic>{
          'left':
              _matchingItems
                  .asMap()
                  .entries
                  .map(
                    (entry) => <String, dynamic>{
                      'id': 'left_${entry.key + 1}',
                      'text': entry.value.leftController.text.trim(),
                    },
                  )
                  .toList(),
          'right':
              _matchingItems
                  .asMap()
                  .entries
                  .map(
                    (entry) => <String, dynamic>{
                      'id': 'right_${entry.key + 1}',
                      'text': entry.value.rightController.text.trim(),
                    },
                  )
                  .toList(),
        };

      case 'ordering':
        return <String, dynamic>{
          'items':
              _orderingItems
                  .asMap()
                  .entries
                  .map(
                    (entry) => <String, dynamic>{
                      'id': 'item_${entry.key + 1}',
                      'text': entry.value.text.trim(),
                    },
                  )
                  .toList(),
        };

      case 'image_hotspot':
        return <String, dynamic>{
          'hotspots':
              _hotspots
                  .map(
                    (_HotspotDraft item) => <String, dynamic>{
                      'id': item.id,
                      'label': item.label,
                      'explanation': item.explanation,
                      'x': item.x,
                      'y': item.y,
                    },
                  )
                  .toList(),
        };

      case 'data_interpretation':
        return <String, dynamic>{
          'title': _dataTitleController.text.trim(),
          'description': _dataDescriptionController.text.trim(),
          'headers': <String>[
            _headerOneController.text.trim(),
            _headerTwoController.text.trim(),
          ],
          'rows':
              _tableRows
                  .map(
                    (_TableRowDraft row) => <String>[
                      row.firstController.text.trim(),
                      row.secondController.text.trim(),
                    ],
                  )
                  .toList(),
          'options': List<Map<String, dynamic>>.generate(
            4,
            (int index) => <String, dynamic>{
              'id': String.fromCharCode(65 + index),
              'text': _analysisOptionControllers[index].text.trim(),
            },
          ),
        };

      case 'multiple_choice':
      default:
        return <String, dynamic>{
          'options': List<Map<String, dynamic>>.generate(
            4,
            (int index) => <String, dynamic>{
              'id': String.fromCharCode(65 + index),
              'text': _choiceControllers[index].text.trim(),
            },
          ),
        };
    }
  }

  Map<String, dynamic> _buildAnswer() {
    switch (_type) {
      case 'true_false':
        return <String, dynamic>{'correct': _trueFalseAnswer};

      case 'matching':
        return <String, dynamic>{
          'pairs': List<Map<String, dynamic>>.generate(
            _matchingItems.length,
            (int index) => <String, dynamic>{
              'left_id': 'left_${index + 1}',
              'right_id': 'right_${index + 1}',
            },
          ),
        };

      case 'ordering':
        return <String, dynamic>{
          'order': List<String>.generate(
            _orderingItems.length,
            (int index) => 'item_${index + 1}',
          ),
        };

      case 'image_hotspot':
        final _HotspotDraft correct = _hotspots.firstWhere(
          (_HotspotDraft item) => item.isCorrect,
        );

        return <String, dynamic>{'hotspot_id': correct.id};

      case 'data_interpretation':
        return <String, dynamic>{'correct': _analysisCorrectChoice};

      case 'multiple_choice':
      default:
        return <String, dynamic>{'correct': _correctChoice};
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final String? typeError = _validateTypeSpecific();

    if (typeError != null) {
      controller.showError(typeError);
      return;
    }

    final bool success = await controller.saveCheckpoint(
      checkpointId:
          widget.checkpoint == null
              ? null
              : AdminLearningController.intValue(widget.checkpoint!['id']),
      submaterialId: widget.submaterialId,
      imagePath: _imagePath,
      data: <String, dynamic>{
        'checkpoint_type': _type,
        'title': _titleController.text.trim(),
        'instruction': _instructionController.text.trim(),
        'question_text': _questionController.text.trim(),
        'content': _buildContent(),
        'answer': _buildAnswer(),
        'correct_feedback': _correctFeedbackController.text.trim(),
        'wrong_feedback': _wrongFeedbackController.text.trim(),
        'order_index': int.parse(_orderController.text),
        'is_required': _isRequired,
        if (_removeImage && _imagePath == null) 'image_url': '',
      },
    );

    if (success) {
      Get.back<bool>(result: true);
    }
  }

  static List<Map<String, dynamic>> _mapList(dynamic raw) {
    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw
        .whereType<Map>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static double _coordinate(dynamic raw) {
    final double value = double.tryParse(raw?.toString() ?? '') ?? 0.5;

    return (value > 1 ? value / 100 : value).clamp(0.0, 1.0);
  }
}

class _MatchingDraft {
  _MatchingDraft({String left = '', String right = ''})
    : leftController = TextEditingController(text: left),
      rightController = TextEditingController(text: right);

  final TextEditingController leftController;
  final TextEditingController rightController;

  void dispose() {
    leftController.dispose();
    rightController.dispose();
  }
}

class _TableRowDraft {
  _TableRowDraft({String first = '', String second = ''})
    : firstController = TextEditingController(text: first),
      secondController = TextEditingController(text: second);

  final TextEditingController firstController;
  final TextEditingController secondController;

  void dispose() {
    firstController.dispose();
    secondController.dispose();
  }
}

class _HotspotDraft {
  _HotspotDraft({
    required this.id,
    required this.label,
    required this.explanation,
    required this.x,
    required this.y,
    required this.isCorrect,
  });

  String id;
  String label;
  String explanation;
  double x;
  double y;
  bool isCorrect;

  _HotspotDraft copy() {
    return _HotspotDraft(
      id: id,
      label: label,
      explanation: explanation,
      x: x,
      y: y,
      isCorrect: isCorrect,
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.auto_awesome_rounded, color: _primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _typeHelp(type),
              style: const TextStyle(color: _text, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

String _typeHelp(String type) {
  switch (type) {
    case 'true_false':
      return 'Guru cukup menulis pernyataan dan memilih Benar atau Salah.';
    case 'matching':
      return 'Isi pasangan yang benar. Sistem akan mengacak sisi kanan untuk siswa.';
    case 'ordering':
      return 'Isi langkah dalam urutan yang benar. Sistem akan mengacaknya untuk siswa.';
    case 'image_hotspot':
      return 'Unggah gambar, ketuk titik penting, lalu isi nama dan penjelasannya.';
    case 'data_interpretation':
      return 'Isi tabel data sederhana dan pilihan kesimpulan yang benar.';
    default:
      return 'Isi empat pilihan dan tandai satu jawaban benar. Tidak perlu menulis JSON.';
  }
}

class _ImagePickerPlaceholder extends StatelessWidget {
  const _ImagePickerPlaceholder({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 42,
              color: _primary,
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(color: _text, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      alignment: Alignment.center,
      child: const Text(
        'Gambar tidak dapat dimuat',
        style: TextStyle(color: _muted),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _muted, height: 1.4),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF4C1D95), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'CHECKPOINT SUBMATERI',
            style: TextStyle(
              color: Color(0xFFE9D5FF),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckpointCard extends StatelessWidget {
  const _CheckpointCard({
    required this.checkpoint,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> checkpoint;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.task_alt_rounded, color: _primary),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  checkpoint['title']?.toString() ?? 'Checkpoint',
                  style: const TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  checkpoint['question_text']?.toString() ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, height: 1.4),
                ),
                const SizedBox(height: 9),
                Text(
                  '${checkpoint['checkpoint_label'] ?? checkpoint['checkpoint_type']} • urutan ${checkpoint['order_index'] ?? 1}',
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'edit') {
                onEdit();
              } else {
                onDelete();
              }
            },
            itemBuilder:
                (_) => const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                  PopupMenuItem<String>(value: 'delete', child: Text('Hapus')),
                ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: danger ? _danger : Colors.white,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: danger ? Colors.white : _text),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(35),
      child: Column(
        children: <Widget>[
          Icon(Icons.task_alt_outlined, size: 60, color: _muted),
          SizedBox(height: 12),
          Text(
            'Belum ada checkpoint',
            style: TextStyle(
              color: _text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

const List<Map<String, dynamic>> _fallbackTypes = <Map<String, dynamic>>[
  {'value': 'multiple_choice', 'label': 'Pilihan'},
  {'value': 'true_false', 'label': 'Benar/Salah'},
  {'value': 'matching', 'label': 'Pasangkan'},
  {'value': 'ordering', 'label': 'Urutkan'},
  {'value': 'image_hotspot', 'label': 'Tunjuk Bagian'},
  {'value': 'data_interpretation', 'label': 'Analisis Data'},
];
