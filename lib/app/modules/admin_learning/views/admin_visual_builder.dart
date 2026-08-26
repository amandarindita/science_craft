import 'dart:io';

import 'package:flutter/material.dart';

import '../../../data/api_service.dart';

const Color _visualPrimary = Color(0xFF2563EB);
const Color _visualText = Color(0xFF172033);
const Color _visualMuted = Color(0xFF64748B);
const Color _visualDanger = Color(0xFFDC2626);
const Color _visualSuccess = Color(0xFF16A34A);

class AdminVisualBuilderController
    extends ChangeNotifier {
  AdminVisualBuilderController({
    required String initialType,
    Map<String, dynamic> initialData =
        const <String, dynamic>{},
  }) : visualType = initialType {
    loadData(initialData);
  }

  String visualType;

  final TextEditingController titleController =
      TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();
  final TextEditingController formulaController =
      TextEditingController();
  final TextEditingController headerOneController =
      TextEditingController(text: 'Objek');
  final TextEditingController headerTwoController =
      TextEditingController(text: 'Nilai');

  final List<VisualItemDraft> items =
      <VisualItemDraft>[];
  final List<VisualTableRowDraft> rows =
      <VisualTableRowDraft>[];
  final List<VisualHotspotDraft> hotspots =
      <VisualHotspotDraft>[];

  bool get hasContent {
    if (titleController.text.trim().isNotEmpty ||
        descriptionController.text.trim().isNotEmpty) {
      return true;
    }

    switch (visualType) {
      case 'chart':
        return rows.any((row) =>
            row.firstController.text.trim().isNotEmpty ||
            row.secondController.text.trim().isNotEmpty);
      case 'formula':
        return formulaController.text.trim().isNotEmpty ||
            items.any((item) => item.hasContent);
      case 'hotspot':
        return hotspots.isNotEmpty;
      default:
        return items.any((item) => item.hasContent);
    }
  }

  void loadData(Map<String, dynamic> data) {
    titleController.text =
        data['title']?.toString() ?? '';
    descriptionController.text =
        data['description']?.toString() ?? '';
    formulaController.text =
        data['formula']?.toString() ?? '';

    _disposeItems();
    _disposeRows();
    hotspots.clear();

    final dynamic rawItems =
        data['items'] ?? data['steps'];
    if (rawItems is List) {
      for (final dynamic raw in rawItems) {
        if (raw is Map) {
          final map = Map<String, dynamic>.from(raw);
          items.add(
            VisualItemDraft(
              title: map['title']?.toString() ?? '',
              description:
                  map['description']?.toString() ?? '',
            ),
          );
        } else {
          items.add(
            VisualItemDraft(
              title: raw.toString(),
            ),
          );
        }
      }
    }

    final dynamic rawHeaders = data['headers'];
    if (rawHeaders is List && rawHeaders.isNotEmpty) {
      headerOneController.text =
          rawHeaders.first.toString();
      if (rawHeaders.length > 1) {
        headerTwoController.text =
            rawHeaders[1].toString();
      }
    }

    final dynamic rawRows = data['rows'];
    if (rawRows is List) {
      for (final dynamic raw in rawRows) {
        if (raw is List) {
          rows.add(
            VisualTableRowDraft(
              first: raw.isNotEmpty
                  ? raw[0].toString()
                  : '',
              second: raw.length > 1
                  ? raw[1].toString()
                  : '',
            ),
          );
        }
      }
    }

    final dynamic rawHotspots = data['hotspots'];
    if (rawHotspots is List) {
      for (final dynamic raw in rawHotspots) {
        if (raw is! Map) {
          continue;
        }

        final map = Map<String, dynamic>.from(raw);
        hotspots.add(
          VisualHotspotDraft(
            id: map['id']?.toString() ??
                'point_${hotspots.length + 1}',
            label: map['label']?.toString() ??
                'Titik ${hotspots.length + 1}',
            explanation:
                (map['explanation'] ??
                        map['description'] ??
                        '')
                    .toString(),
            x: _coordinate(map['x']),
            y: _coordinate(map['y']),
          ),
        );
      }
    }

    ensureDefaults();
  }

  void setVisualType(String type) {
    if (visualType == type) {
      return;
    }

    visualType = type;
    ensureDefaults();
    notifyListeners();
  }

  void ensureDefaults() {
    if (titleController.text.trim().isEmpty) {
      titleController.text = _defaultTitle(visualType);
    }

    if (visualType == 'chart') {
      while (rows.length < 2) {
        rows.add(VisualTableRowDraft());
      }
    } else if (visualType != 'hotspot') {
      while (items.length < 2) {
        items.add(VisualItemDraft());
      }
    }

    if (visualType == 'formula' &&
        formulaController.text.trim().isEmpty) {
      formulaController.text = 'M₁ × V₁ = M₂ × V₂';
    }
  }

  void changed() {
    notifyListeners();
  }

  void addItem() {
    items.add(VisualItemDraft());
    notifyListeners();
  }

  void removeItem(int index) {
    if (index < 0 || index >= items.length) {
      return;
    }

    items.removeAt(index).dispose();
    notifyListeners();
  }

  void moveItem(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    notifyListeners();
  }

  void addRow() {
    rows.add(VisualTableRowDraft());
    notifyListeners();
  }

  void removeRow(int index) {
    if (index < 0 || index >= rows.length) {
      return;
    }

    rows.removeAt(index).dispose();
    notifyListeners();
  }

  void addHotspot(VisualHotspotDraft hotspot) {
    hotspots.add(hotspot);
    notifyListeners();
  }

  void replaceHotspot(
    VisualHotspotDraft oldValue,
    VisualHotspotDraft newValue,
  ) {
    final index = hotspots.indexOf(oldValue);
    if (index < 0) {
      return;
    }

    hotspots[index] = newValue;
    notifyListeners();
  }

  void removeHotspot(int index) {
    if (index < 0 || index >= hotspots.length) {
      return;
    }

    hotspots.removeAt(index);
    notifyListeners();
  }

  void clearHotspots() {
    hotspots.clear();
    notifyListeners();
  }

  String? validate({required bool hasImage}) {
    if (titleController.text.trim().isEmpty) {
      return 'Judul visual wajib diisi.';
    }

    switch (visualType) {
      case 'chart':
        if (headerOneController.text.trim().isEmpty ||
            headerTwoController.text.trim().isEmpty) {
          return 'Judul kedua kolom wajib diisi.';
        }
        if (!rows.any((row) => row.hasContent)) {
          return 'Tambahkan minimal satu baris data.';
        }
        break;
      case 'formula':
        if (formulaController.text.trim().isEmpty) {
          return 'Rumus wajib diisi.';
        }
        break;
      case 'hotspot':
        if (!hasImage) {
          return 'Pilih gambar sebelum menambahkan titik.';
        }
        if (hotspots.isEmpty) {
          return 'Tambahkan minimal satu titik pada gambar.';
        }
        break;
      default:
        if (!items.any((item) => item.hasContent)) {
          return 'Tambahkan minimal satu poin visual.';
        }
    }

    return null;
  }

  Map<String, dynamic> buildData() {
    final result = <String, dynamic>{
      'title': titleController.text.trim(),
      if (descriptionController.text.trim().isNotEmpty)
        'description':
            descriptionController.text.trim(),
    };

    switch (visualType) {
      case 'chart':
        result['headers'] = <String>[
          headerOneController.text.trim(),
          headerTwoController.text.trim(),
        ];
        result['rows'] = rows
            .where((row) => row.hasContent)
            .map((row) => <String>[
                  row.firstController.text.trim(),
                  row.secondController.text.trim(),
                ])
            .toList();
        break;
      case 'formula':
        result['formula'] = formulaController.text.trim();
        result['items'] = _buildItems();
        break;
      case 'hotspot':
        result['hotspots'] = hotspots
            .map((item) => <String, dynamic>{
                  'id': item.id,
                  'label': item.label,
                  'explanation': item.explanation,
                  'x': item.x,
                  'y': item.y,
                })
            .toList();
        break;
      case 'flow':
      case 'sequence':
        result['steps'] = _buildItems();
        break;
      default:
        result['items'] = _buildItems();
    }

    return result;
  }

  List<Map<String, dynamic>> _buildItems() {
    return items
        .where((item) => item.hasContent)
        .map((item) => <String, dynamic>{
              'title': item.titleController.text.trim(),
              'description':
                  item.descriptionController.text.trim(),
            })
        .toList();
  }

  void _disposeItems() {
    for (final item in items) {
      item.dispose();
    }
    items.clear();
  }

  void _disposeRows() {
    for (final row in rows) {
      row.dispose();
    }
    rows.clear();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    formulaController.dispose();
    headerOneController.dispose();
    headerTwoController.dispose();
    _disposeItems();
    _disposeRows();
    super.dispose();
  }

  static double _coordinate(dynamic raw) {
    final value = double.tryParse(raw?.toString() ?? '') ?? 0.5;
    return (value > 1 ? value / 100 : value)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static String _defaultTitle(String type) {
    switch (type) {
      case 'comparison':
        return 'Perbandingan Konsep';
      case 'flow':
      case 'sequence':
        return 'Urutan Proses';
      case 'chart':
        return 'Data Pengamatan';
      case 'formula':
        return 'Rumus Penting';
      case 'hotspot':
        return 'Bagian Penting pada Gambar';
      default:
        return 'Ringkasan Visual';
    }
  }
}

class AdminVisualBuilder extends StatefulWidget {
  const AdminVisualBuilder({
    super.key,
    required this.controller,
    required this.visualTypes,
    required this.imagePath,
    required this.existingImageUrl,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onChanged,
  });

  final AdminVisualBuilderController controller;
  final List<Map<String, dynamic>> visualTypes;
  final String? imagePath;
  final String existingImageUrl;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onChanged;

  @override
  State<AdminVisualBuilder> createState() =>
      _AdminVisualBuilderState();
}

class _AdminVisualBuilderState
    extends State<AdminVisualBuilder> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: widget.controller.visualType,
              decoration: const InputDecoration(
                labelText: 'Jenis visual',
                prefixIcon: Icon(
                  Icons.dashboard_customize_rounded,
                ),
              ),
              items: widget.visualTypes
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
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                widget.controller.setVisualType(value);
                widget.onChanged();
              },
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Isi visual melalui form berikut. Sistem menyimpan format teknis secara otomatis.',
                style: TextStyle(
                  color: _visualText,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: widget.controller.titleController,
              decoration: const InputDecoration(
                labelText: 'Judul visual',
                hintText: 'Contoh: Komponen Penyusun Enzim',
              ),
              onChanged: (_) => _changed(),
            ),
            const SizedBox(height: 11),
            TextFormField(
              controller:
                  widget.controller.descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Pengantar singkat',
                hintText:
                    'Jelaskan tujuan atau isi visual secara singkat.',
                alignLabelWithHint: true,
              ),
              onChanged: (_) => _changed(),
            ),
            const SizedBox(height: 16),
            _buildTypeEditor(),
          ],
        );
      },
    );
  }

  Widget _buildTypeEditor() {
    switch (widget.controller.visualType) {
      case 'chart':
        return _buildChartEditor();
      case 'formula':
        return _buildFormulaEditor();
      case 'hotspot':
        return _buildHotspotEditor();
      case 'flow':
      case 'sequence':
        return _buildItemsEditor(
          title: 'Langkah Proses',
          addLabel: 'Tambah Langkah',
          reorderable: true,
        );
      case 'comparison':
        return _buildItemsEditor(
          title: 'Bagian yang Dibandingkan',
          addLabel: 'Tambah Bagian',
        );
      default:
        return _buildItemsEditor(
          title: 'Poin Visual',
          addLabel: 'Tambah Poin',
        );
    }
  }

  Widget _buildItemsEditor({
    required String title,
    required String addLabel,
    bool reorderable = false,
  }) {
    final items = widget.controller.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: _visualText,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        if (reorderable)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) {
              widget.controller.moveItem(oldIndex, newIndex);
              widget.onChanged();
            },
            itemBuilder: (context, index) {
              return _VisualItemCard(
                key: ObjectKey(items[index]),
                index: index,
                item: items[index],
                showDrag: true,
                canDelete: items.length > 1,
                onChanged: _changed,
                onDelete: () {
                  widget.controller.removeItem(index);
                  widget.onChanged();
                },
              );
            },
          )
        else
          ...items.asMap().entries.map(
                (entry) => _VisualItemCard(
                  index: entry.key,
                  item: entry.value,
                  canDelete: items.length > 1,
                  onChanged: _changed,
                  onDelete: () {
                    widget.controller.removeItem(entry.key);
                    widget.onChanged();
                  },
                ),
              ),
        OutlinedButton.icon(
          onPressed: () {
            widget.controller.addItem();
            widget.onChanged();
          },
          icon: const Icon(Icons.add_rounded),
          label: Text(addLabel),
        ),
      ],
    );
  }

  Widget _buildFormulaEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          controller: widget.controller.formulaController,
          decoration: const InputDecoration(
            labelText: 'Rumus',
            hintText: 'Contoh: F = k × Δx',
            prefixIcon: Icon(Icons.functions_rounded),
          ),
          onChanged: (_) => _changed(),
        ),
        const SizedBox(height: 14),
        _buildItemsEditor(
          title: 'Arti Simbol',
          addLabel: 'Tambah Simbol',
        ),
      ],
    );
  }

  Widget _buildChartEditor() {
    final rows = widget.controller.rows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Tabel Data',
          style: TextStyle(
            color: _visualText,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller:
                    widget.controller.headerOneController,
                decoration: const InputDecoration(
                  labelText: 'Judul kolom 1',
                ),
                onChanged: (_) => _changed(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller:
                    widget.controller.headerTwoController,
                decoration: const InputDecoration(
                  labelText: 'Judul kolom 2',
                ),
                onChanged: (_) => _changed(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: row.firstController,
                    decoration: InputDecoration(
                      labelText: 'Baris ${index + 1}',
                    ),
                    onChanged: (_) => _changed(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: row.secondController,
                    decoration: const InputDecoration(
                      labelText: 'Nilai/Keterangan',
                    ),
                    onChanged: (_) => _changed(),
                  ),
                ),
                if (rows.length > 1)
                  IconButton(
                    tooltip: 'Hapus baris',
                    onPressed: () {
                      widget.controller.removeRow(index);
                      widget.onChanged();
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: _visualDanger,
                    ),
                  ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {
            widget.controller.addRow();
            widget.onChanged();
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah Baris Data'),
        ),
      ],
    );
  }

  Widget _buildHotspotEditor() {
    final String? networkUrl =
        widget.existingImageUrl.trim().isEmpty
            ? null
            : ApiService.resolveMediaUrl(
                widget.existingImageUrl,
              );
    final bool hasImage =
        widget.imagePath != null || networkUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Titik Penjelasan pada Gambar',
          style: TextStyle(
            color: _visualText,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ketuk bagian gambar, lalu isi nama dan penjelasannya. Siswa akan melihat penjelasan ketika titik tersebut diketuk.',
          style: TextStyle(
            color: _visualMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        if (!hasImage)
          _VisualImagePlaceholder(
            onTap: widget.onPickImage,
          )
        else ...<Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) {
                    _createHotspot(
                      details.localPosition,
                      Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        if (widget.imagePath != null)
                          Image.file(
                            File(widget.imagePath!),
                            fit: BoxFit.cover,
                          )
                        else
                          Image.network(
                            networkUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const _VisualImageError(),
                          ),
                        ...widget.controller.hotspots.map(
                          (point) {
                            final double left =
                                (point.x * constraints.maxWidth - 18)
                                    .clamp(
                              0.0,
                              constraints.maxWidth - 36,
                            )
                                    .toDouble();
                            final double top =
                                (point.y * constraints.maxHeight - 18)
                                    .clamp(
                              0.0,
                              constraints.maxHeight - 36,
                            )
                                    .toDouble();
                            return Positioned(
                              left: left,
                              top: top,
                              child: GestureDetector(
                                onTap: () => _editHotspot(point),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _visualPrimary,
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
                                    '${widget.controller.hotspots.indexOf(point) + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
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
                  onPressed: widget.onPickImage,
                  icon: const Icon(Icons.image_search_rounded),
                  label: const Text('Ganti Gambar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    widget.controller.clearHotspots();
                    widget.onRemoveImage();
                    widget.onChanged();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _visualDanger,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Hapus Gambar'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (widget.controller.hotspots.isEmpty)
          const _VisualEmptyHint(
            text:
                'Belum ada titik. Ketuk bagian gambar untuk menambahkan penjelasan.',
          )
        else
          ...widget.controller.hotspots
              .asMap()
              .entries
              .map((entry) {
            final point = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _visualPrimary,
                    foregroundColor: Colors.white,
                    child: Text('${entry.key + 1}'),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          point.label,
                          style: const TextStyle(
                            color: _visualText,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          point.explanation.isEmpty
                              ? 'Belum ada penjelasan'
                              : point.explanation,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _visualMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit titik',
                    onPressed: () => _editHotspot(point),
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: _visualPrimary,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Hapus titik',
                    onPressed: () {
                      widget.controller.removeHotspot(entry.key);
                      widget.onChanged();
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: _visualDanger,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Future<void> _createHotspot(
    Offset position,
    Size size,
  ) async {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final draft = VisualHotspotDraft(
      id: 'point_${DateTime.now().microsecondsSinceEpoch}',
      label:
          'Titik ${widget.controller.hotspots.length + 1}',
      explanation: '',
      x: (position.dx / size.width)
          .clamp(0.0, 1.0)
          .toDouble(),
      y: (position.dy / size.height)
          .clamp(0.0, 1.0)
          .toDouble(),
    );

    final result = await showModalBottomSheet<VisualHotspotDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VisualHotspotSheet(initial: draft),
    );

    if (result == null || !mounted) {
      return;
    }

    widget.controller.addHotspot(result);
    widget.onChanged();
  }

  Future<void> _editHotspot(
    VisualHotspotDraft point,
  ) async {
    final result = await showModalBottomSheet<VisualHotspotDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VisualHotspotSheet(
        initial: point.copy(),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    widget.controller.replaceHotspot(point, result);
    widget.onChanged();
  }

  void _changed() {
    widget.controller.changed();
    widget.onChanged();
  }
}

class _VisualItemCard extends StatelessWidget {
  const _VisualItemCard({
    super.key,
    required this.index,
    required this.item,
    required this.canDelete,
    required this.onChanged,
    required this.onDelete,
    this.showDrag = false,
  });

  final int index;
  final VisualItemDraft item;
  final bool canDelete;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  final bool showDrag;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFFEAF1FF),
                foregroundColor: _visualPrimary,
                child: Text('${index + 1}'),
              ),
              const Spacer(),
              if (showDrag)
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: _visualMuted,
                    ),
                  ),
                ),
              if (canDelete)
                IconButton(
                  tooltip: 'Hapus',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: _visualDanger,
                  ),
                ),
            ],
          ),
          TextFormField(
            controller: item.titleController,
            decoration: const InputDecoration(
              labelText: 'Judul',
              hintText: 'Contoh: Apoenzim',
            ),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 9),
          TextFormField(
            controller: item.descriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Penjelasan',
              alignLabelWithHint: true,
            ),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}

class _VisualHotspotSheet extends StatefulWidget {
  const _VisualHotspotSheet({required this.initial});

  final VisualHotspotDraft initial;

  @override
  State<_VisualHotspotSheet> createState() =>
      _VisualHotspotSheetState();
}

class _VisualHotspotSheetState
    extends State<_VisualHotspotSheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _explanationController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.initial.label,
    );
    _explanationController = TextEditingController(
      text: widget.initial.explanation,
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(26),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Atur Titik Gambar',
                style: TextStyle(
                  color: _visualText,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Isi nama bagian dan penjelasan yang akan dibaca siswa.',
                style: TextStyle(
                  color: _visualMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _labelController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Nama bagian',
                  hintText: 'Contoh: Situs aktif enzim',
                  errorText: _error,
                ),
                onChanged: (_) {
                  if (_error != null) {
                    setState(() => _error = null);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _explanationController,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Penjelasan saat titik diklik',
                  hintText:
                      'Jelaskan fungsi atau arti bagian tersebut.',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Simpan Titik'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(() => _error = 'Nama bagian wajib diisi.');
      return;
    }

    Navigator.of(context).pop(
      VisualHotspotDraft(
        id: widget.initial.id,
        label: label,
        explanation: _explanationController.text.trim(),
        x: widget.initial.x,
        y: widget.initial.y,
      ),
    );
  }
}

class VisualItemDraft {
  VisualItemDraft({
    String title = '',
    String description = '',
  })  : titleController = TextEditingController(text: title),
        descriptionController =
            TextEditingController(text: description);

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  bool get hasContent =>
      titleController.text.trim().isNotEmpty ||
      descriptionController.text.trim().isNotEmpty;

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}

class VisualTableRowDraft {
  VisualTableRowDraft({
    String first = '',
    String second = '',
  })  : firstController = TextEditingController(text: first),
        secondController = TextEditingController(text: second);

  final TextEditingController firstController;
  final TextEditingController secondController;

  bool get hasContent =>
      firstController.text.trim().isNotEmpty ||
      secondController.text.trim().isNotEmpty;

  void dispose() {
    firstController.dispose();
    secondController.dispose();
  }
}

class VisualHotspotDraft {
  VisualHotspotDraft({
    required this.id,
    required this.label,
    required this.explanation,
    required this.x,
    required this.y,
  });

  final String id;
  final String label;
  final String explanation;
  final double x;
  final double y;

  VisualHotspotDraft copy() {
    return VisualHotspotDraft(
      id: id,
      label: label,
      explanation: explanation,
      x: x,
      y: y,
    );
  }
}

class _VisualImagePlaceholder extends StatelessWidget {
  const _VisualImagePlaceholder({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 42,
              color: _visualPrimary,
            ),
            SizedBox(height: 8),
            Text(
              'Pilih gambar terlebih dahulu',
              style: TextStyle(
                color: _visualText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisualImageError extends StatelessWidget {
  const _VisualImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      alignment: Alignment.center,
      child: const Text(
        'Gambar tidak dapat dimuat',
        style: TextStyle(color: _visualMuted),
      ),
    );
  }
}

class _VisualEmptyHint extends StatelessWidget {
  const _VisualEmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _visualMuted,
          height: 1.4,
        ),
      ),
    );
  }
}
