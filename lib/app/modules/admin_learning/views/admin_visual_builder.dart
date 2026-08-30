import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/api_service.dart';

// =============================================================================
// DESIGN TOKENS (UNIFIED & CONSISTENT WITH SCIENCECRAFT)
// =============================================================================
const Color _visualPrimary = Color(0xFF2563EB); // Science Blue
const Color _visualNavy = Color(0xFF1E3A8A); // Dark Navy
const Color _visualText = Color(0xFF1E293B); // Slate 800
const Color _visualMuted = Color(0xFF64748B); // Slate 500
const Color _visualBorder = Color(0xFFE2E8F0); // Slate 200
const Color _visualDanger = Color(0xFFEF4444); // Red 500
const Color _visualAmber = Color(0xFFF59E0B); // Amber 500
const Color _visualPurple = Color(0xFF7C3AED); // Purple 600
const Color _visualCardBg = Color(0xFFF8FAFC); // Slate 50

// =============================================================================
// INPUT DECORATION HELPER
// =============================================================================
InputDecoration _buildInputDecoration({
  String? labelText,
  String? hintText,
  IconData? prefixIcon,
  Widget? suffixIcon,
  String? errorText,
  bool alignLabelWithHint = false,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: GoogleFonts.plusJakartaSans(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: _visualMuted,
    ),
    hintText: hintText,
    hintStyle: GoogleFonts.plusJakartaSans(
      fontSize: 12.5,
      color: _visualMuted.withValues(alpha: 0.6),
    ),
    errorText: errorText,
    prefixIcon:
        prefixIcon != null
            ? Icon(prefixIcon, color: _visualPrimary, size: 19)
            : null,
    suffixIcon: suffixIcon,
    alignLabelWithHint: alignLabelWithHint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _visualBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _visualBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _visualPrimary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _visualDanger),
    ),
  );
}

// =============================================================================
// CONTROLLER
// =============================================================================
class AdminVisualBuilderController extends ChangeNotifier {
  AdminVisualBuilderController({
    required String initialType,
    Map<String, dynamic> initialData = const <String, dynamic>{},
  }) : visualType = initialType {
    loadData(initialData);
  }

  String visualType;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController formulaController = TextEditingController();
  final TextEditingController headerOneController = TextEditingController(
    text: 'Objek / Variabel',
  );
  final TextEditingController headerTwoController = TextEditingController(
    text: 'Nilai / Keterangan',
  );

  final List<VisualItemDraft> items = <VisualItemDraft>[];
  final List<VisualTableRowDraft> rows = <VisualTableRowDraft>[];
  final List<VisualHotspotDraft> hotspots = <VisualHotspotDraft>[];

  bool get hasContent {
    if (titleController.text.trim().isNotEmpty ||
        descriptionController.text.trim().isNotEmpty) {
      return true;
    }

    switch (visualType) {
      case 'chart':
        return rows.any(
          (row) =>
              row.firstController.text.trim().isNotEmpty ||
              row.secondController.text.trim().isNotEmpty,
        );
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
    titleController.text = data['title']?.toString() ?? '';
    descriptionController.text = data['description']?.toString() ?? '';
    formulaController.text = data['formula']?.toString() ?? '';

    _disposeItems();
    _disposeRows();
    hotspots.clear();

    final dynamic rawItems = data['items'] ?? data['steps'];
    if (rawItems is List) {
      for (final dynamic raw in rawItems) {
        if (raw is Map) {
          final map = Map<String, dynamic>.from(raw);
          items.add(
            VisualItemDraft(
              title: map['title']?.toString() ?? '',
              description: map['description']?.toString() ?? '',
            ),
          );
        } else {
          items.add(VisualItemDraft(title: raw.toString()));
        }
      }
    }

    final dynamic rawHeaders = data['headers'];
    if (rawHeaders is List && rawHeaders.isNotEmpty) {
      headerOneController.text = rawHeaders.first.toString();
      if (rawHeaders.length > 1) {
        headerTwoController.text = rawHeaders[1].toString();
      }
    }

    final dynamic rawRows = data['rows'];
    if (rawRows is List) {
      for (final dynamic raw in rawRows) {
        if (raw is List) {
          rows.add(
            VisualTableRowDraft(
              first: raw.isNotEmpty ? raw[0].toString() : '',
              second: raw.length > 1 ? raw[1].toString() : '',
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
            id: map['id']?.toString() ?? 'point_${hotspots.length + 1}',
            label: map['label']?.toString() ?? 'Titik ${hotspots.length + 1}',
            explanation:
                (map['explanation'] ?? map['description'] ?? '').toString(),
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

    if (visualType == 'formula' && formulaController.text.trim().isEmpty) {
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
        'description': descriptionController.text.trim(),
    };

    switch (visualType) {
      case 'chart':
        result['headers'] = <String>[
          headerOneController.text.trim(),
          headerTwoController.text.trim(),
        ];
        result['rows'] =
            rows
                .where((row) => row.hasContent)
                .map(
                  (row) => <String>[
                    row.firstController.text.trim(),
                    row.secondController.text.trim(),
                  ],
                )
                .toList();
        break;
      case 'formula':
        result['formula'] = formulaController.text.trim();
        result['items'] = _buildItems();
        break;
      case 'hotspot':
        result['hotspots'] =
            hotspots
                .map(
                  (item) => <String, dynamic>{
                    'id': item.id,
                    'label': item.label,
                    'explanation': item.explanation,
                    'x': item.x,
                    'y': item.y,
                  },
                )
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
        .map(
          (item) => <String, dynamic>{
            'title': item.titleController.text.trim(),
            'description': item.descriptionController.text.trim(),
          },
        )
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
    return (value > 1 ? value / 100 : value).clamp(0.0, 1.0).toDouble();
  }

  static String _defaultTitle(String type) {
    switch (type) {
      case 'comparison':
        return 'Perbandingan Konsep';
      case 'flow':
      case 'sequence':
        return 'Urutan Proses Sains';
      case 'chart':
        return 'Tabel Data Pengamatan';
      case 'formula':
        return 'Rumus & Persamaan Penting';
      case 'hotspot':
        return 'Bagian Penting pada Ilustrasi';
      default:
        return 'Ringkasan & Poin Visual';
    }
  }
}

// =============================================================================
// MAIN ADMIN VISUAL BUILDER WIDGET
// =============================================================================
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
  State<AdminVisualBuilder> createState() => _AdminVisualBuilderState();
}

class _AdminVisualBuilderState extends State<AdminVisualBuilder> {
  // Definition of Visual Types with icons and descriptive labels
  static const Map<String, _VisualTypeMeta> _metaMap = {
    'infographic': _VisualTypeMeta(
      icon: Icons.auto_stories_rounded,
      label: 'Infografik',
      subtitle: 'Poin ringkasan materi & fakta',
      accentColor: _visualPrimary,
    ),
    'comparison': _VisualTypeMeta(
      icon: Icons.compare_arrows_rounded,
      label: 'Perbandingan',
      subtitle: 'Komparasi 2 atau lebih konsep',
      accentColor: Color(0xFF0D9488),
    ),
    'flow': _VisualTypeMeta(
      icon: Icons.account_tree_rounded,
      label: 'Alur Proses',
      subtitle: 'Tahapan proses bersambung',
      accentColor: _visualPurple,
    ),
    'sequence': _VisualTypeMeta(
      icon: Icons.format_list_numbered_rounded,
      label: 'Urutan Langkah',
      subtitle: 'Langkah kronologis bernomor',
      accentColor: Color(0xFFEA580C),
    ),
    'chart': _VisualTypeMeta(
      icon: Icons.table_chart_rounded,
      label: 'Tabel Data',
      subtitle: 'Tabel 2 kolom data pengamatan',
      accentColor: Color(0xFF0284C7),
    ),
    'formula': _VisualTypeMeta(
      icon: Icons.functions_rounded,
      label: 'Rumus Sains',
      subtitle: 'Persamaan & arti tiap simbol',
      accentColor: Color(0xFF4F46E5),
    ),
    'hotspot': _VisualTypeMeta(
      icon: Icons.touch_app_rounded,
      label: 'Titik Gambar',
      subtitle: 'Pin interaktif di atas ilustrasi',
      accentColor: _visualAmber,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final currentType = widget.controller.visualType;
        final currentMeta =
            _metaMap[currentType] ??
            const _VisualTypeMeta(
              icon: Icons.dashboard_customize_rounded,
              label: 'Visual Standar',
              subtitle: 'Elemen grafis pendukung materi',
              accentColor: _visualPrimary,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Label Tipe Visual
            Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 16,
                  color: _visualMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Pilih Model Visual Interaktif',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _visualText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 2. Interactive Visual Type Selector Carousel/Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children:
                    _metaMap.entries.map((entry) {
                      final key = entry.key;
                      final meta = entry.value;
                      final isSelected = currentType == key;

                      return _VisualTypeChip(
                        meta: meta,
                        isSelected: isSelected,
                        onTap: () {
                          widget.controller.setVisualType(key);
                          widget.onChanged();
                        },
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // 3. Informative Mode Context Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: currentMeta.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: currentMeta.accentColor.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: currentMeta.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      currentMeta.icon,
                      color: currentMeta.accentColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mode ${currentMeta.label}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _visualText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentMeta.subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: _visualMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Judul & Pengantar Visual
            Text(
              'Judul Visual Interaktif',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _visualText,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: widget.controller.titleController,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _visualText,
              ),
              decoration: _buildInputDecoration(
                hintText: 'Contoh: ${currentMeta.label} Konsep Utama',
                prefixIcon: Icons.title_rounded,
              ),
              onChanged: (_) => _changed(),
            ),
            const SizedBox(height: 12),

            Text(
              'Pengantar Singkat Visual (Opsional)',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _visualText,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: widget.controller.descriptionController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _visualText,
              ),
              decoration: _buildInputDecoration(
                hintText: 'Ringkasan singkat yang dibaca siswa...',
                alignLabelWithHint: true,
              ),
              onChanged: (_) => _changed(),
            ),
            const SizedBox(height: 18),

            // 5. Type-Specific Content Editor
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
          title: 'Langkah-Langkah Proses',
          addLabel: 'Tambah Langkah',
          itemPrefix: 'Langkah',
          reorderable: true,
        );
      case 'comparison':
        return _buildItemsEditor(
          title: 'Objek / Aspek yang Dibandingkan',
          addLabel: 'Tambah Objek',
          itemPrefix: 'Aspek',
        );
      default:
        return _buildItemsEditor(
          title: 'Poin-Poin Visual',
          addLabel: 'Tambah Poin',
          itemPrefix: 'Poin',
        );
    }
  }

  Widget _buildItemsEditor({
    required String title,
    required String addLabel,
    required String itemPrefix,
    bool reorderable = false,
  }) {
    final items = widget.controller.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: _visualText,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: _visualPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${items.length} Item',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _visualPrimary,
                ),
              ),
            ),
          ],
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
                prefix: itemPrefix,
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
              prefix: itemPrefix,
              canDelete: items.length > 1,
              onChanged: _changed,
              onDelete: () {
                widget.controller.removeItem(entry.key);
                widget.onChanged();
              },
            ),
          ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            onPressed: () {
              widget.controller.addItem();
              widget.onChanged();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _visualPrimary,
              side: const BorderSide(color: _visualPrimary, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 19),
            label: Text(
              addLabel,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormulaEditor() {
    final formulaText = widget.controller.formulaController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Preview Box Formula
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_visualNavy, _visualPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _visualPrimary.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Pratinjau Rumus',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFDCE9FF),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formulaText.isEmpty ? 'Ketik rumus di bawah...' : formulaText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Text(
          'Teks Rumus Sains',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: _visualText,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller.formulaController,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _visualText,
          ),
          decoration: _buildInputDecoration(
            hintText: 'Contoh: F = m × a  atau  PV = nRT',
            prefixIcon: Icons.functions_rounded,
          ),
          onChanged: (_) {
            setState(() {});
            _changed();
          },
        ),
        const SizedBox(height: 18),

        _buildItemsEditor(
          title: 'Keterangan Simbol & Satuan',
          addLabel: 'Tambah Simbol',
          itemPrefix: 'Simbol',
        ),
      ],
    );
  }

  Widget _buildChartEditor() {
    final rows = widget.controller.rows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tabel Data Pengamatan',
          style: GoogleFonts.poppins(
            color: _visualText,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 10),

        // Headers Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _visualCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _visualBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Judul Kolom Tabel',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _visualMuted,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: widget.controller.headerOneController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _visualText,
                      ),
                      decoration: _buildInputDecoration(
                        labelText: 'Kolom 1 (Kiri)',
                        hintText: 'Misal: Konsentrasi (M)',
                      ),
                      onChanged: (_) => _changed(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: widget.controller.headerTwoController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _visualText,
                      ),
                      decoration: _buildInputDecoration(
                        labelText: 'Kolom 2 (Kanan)',
                        hintText: 'Misal: Laju Reaksi',
                      ),
                      onChanged: (_) => _changed(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Data Rows
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _visualBorder),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _visualPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _visualPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: row.firstController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: _visualText,
                    ),
                    decoration: _buildInputDecoration(
                      hintText: 'Nilai kolom 1',
                    ),
                    onChanged: (_) => _changed(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: row.secondController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: _visualText,
                    ),
                    decoration: _buildInputDecoration(
                      hintText: 'Nilai kolom 2',
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
                      size: 20,
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),

        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            onPressed: () {
              widget.controller.addRow();
              widget.onChanged();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _visualPrimary,
              side: const BorderSide(color: _visualPrimary, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 19),
            label: Text(
              'Tambah Baris Data',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotspotEditor() {
    final String? networkUrl =
        widget.existingImageUrl.trim().isEmpty
            ? null
            : ApiService.resolveMediaUrl(widget.existingImageUrl);
    final bool hasImage = widget.imagePath != null || networkUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Titik Penjelasan pada Gambar',
          style: GoogleFonts.poppins(
            color: _visualText,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ketuk bagian gambar di bawah untuk menempatkan pin interaktif. Siswa dapat mengetuk pin untuk membaca penjelasan.',
          style: GoogleFonts.plusJakartaSans(
            color: _visualMuted,
            fontSize: 11.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),

        if (!hasImage)
          _VisualImagePlaceholder(onTap: widget.onPickImage)
        else ...<Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) {
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
                        if (widget.imagePath != null)
                          Image.file(
                            File(widget.imagePath!),
                            fit: BoxFit.cover,
                          )
                        else
                          Image.network(
                            networkUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const _VisualImageError(),
                          ),
                        ...widget.controller.hotspots.map((point) {
                          final double left =
                              (point.x * constraints.maxWidth - 18)
                                  .clamp(0.0, constraints.maxWidth - 36)
                                  .toDouble();
                          final double top =
                              (point.y * constraints.maxHeight - 18)
                                  .clamp(0.0, constraints.maxHeight - 36)
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
                                  gradient: const LinearGradient(
                                    colors: [_visualNavy, _visualPrimary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                  boxShadow: const <BoxShadow>[
                                    BoxShadow(
                                      color: Color(0x44000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${widget.controller.hotspots.indexOf(point) + 1}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
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
                  onPressed: widget.onPickImage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _visualPrimary,
                    side: const BorderSide(color: _visualBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.image_search_rounded, size: 18),
                  label: Text(
                    'Ganti Gambar',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                    side: const BorderSide(color: Color(0xFFFEE2E2)),
                    backgroundColor: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(
                    'Hapus Gambar',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),

        if (widget.controller.hotspots.isEmpty)
          const _VisualEmptyHint(
            text:
                'Belum ada titik interaktif. Ketuk bagian gambar untuk menambahkan pin dan penjelasan.',
          )
        else
          ...widget.controller.hotspots.asMap().entries.map((entry) {
            final point = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _visualBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_visualNavy, _visualPrimary],
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.key + 1}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          point.label,
                          style: GoogleFonts.poppins(
                            color: _visualText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          point.explanation.isEmpty
                              ? 'Belum ada penjelasan'
                              : point.explanation,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: _visualMuted,
                            fontSize: 11.5,
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
                      size: 19,
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
                      size: 19,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Future<void> _createHotspot(Offset position, Size size) async {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final draft = VisualHotspotDraft(
      id: 'point_${DateTime.now().microsecondsSinceEpoch}',
      label: 'Titik ${widget.controller.hotspots.length + 1}',
      explanation: '',
      x: (position.dx / size.width).clamp(0.0, 1.0).toDouble(),
      y: (position.dy / size.height).clamp(0.0, 1.0).toDouble(),
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

  Future<void> _editHotspot(VisualHotspotDraft point) async {
    final result = await showModalBottomSheet<VisualHotspotDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VisualHotspotSheet(initial: point.copy()),
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

// =============================================================================
// VISUAL TYPE CHIP ITEM
// =============================================================================
class _VisualTypeMeta {
  const _VisualTypeMeta({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color accentColor;
}

class _VisualTypeChip extends StatelessWidget {
  const _VisualTypeChip({
    required this.meta,
    required this.isSelected,
    required this.onTap,
  });

  final _VisualTypeMeta meta;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? meta.accentColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? meta.accentColor : _visualBorder,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: meta.accentColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                      : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  meta.icon,
                  size: 16,
                  color: isSelected ? Colors.white : meta.accentColor,
                ),
                const SizedBox(width: 7),
                Text(
                  meta.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : _visualText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// VISUAL ITEM CARD
// =============================================================================
class _VisualItemCard extends StatelessWidget {
  const _VisualItemCard({
    super.key,
    required this.index,
    required this.item,
    required this.prefix,
    required this.canDelete,
    required this.onChanged,
    required this.onDelete,
    this.showDrag = false,
  });

  final int index;
  final VisualItemDraft item;
  final String prefix;
  final bool canDelete;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  final bool showDrag;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _visualBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_visualNavy, _visualPrimary],
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                '$prefix ${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _visualText,
                ),
              ),
              const Spacer(),
              if (showDrag)
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: _visualMuted,
                      size: 20,
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
                    size: 19,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: item.titleController,
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _visualText,
            ),
            decoration: _buildInputDecoration(
              labelText: 'Judul / Nama $prefix',
              hintText: 'Contoh: Nama komponen atau langkah',
            ),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: item.descriptionController,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: _visualText,
            ),
            decoration: _buildInputDecoration(
              labelText: 'Penjelasan Lengkap',
              hintText: 'Tulis penjelasan rinci yang mudah dipahami siswa...',
              alignLabelWithHint: true,
            ),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HOTSPOT BOTTOM SHEET
// =============================================================================
class _VisualHotspotSheet extends StatefulWidget {
  const _VisualHotspotSheet({required this.initial});

  final VisualHotspotDraft initial;

  @override
  State<_VisualHotspotSheet> createState() => _VisualHotspotSheetState();
}

class _VisualHotspotSheetState extends State<_VisualHotspotSheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _explanationController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.initial.label);
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
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _visualAmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.touch_app_rounded,
                      color: _visualAmber,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Atur Titik Gambar',
                    style: GoogleFonts.poppins(
                      color: _visualText,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Isi nama bagian dan penjelasan yang akan tampil saat titik diketuk siswa.',
                style: GoogleFonts.plusJakartaSans(
                  color: _visualMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _labelController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _visualText,
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Nama Bagian / Komponen',
                  hintText: 'Contoh: Anode / Katode / Mitokondria',
                  prefixIcon: Icons.label_important_outline_rounded,
                  errorText: _error,
                ),
                onChanged: (_) {
                  if (_error != null) {
                    setState(() => _error = null);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _explanationController,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: _visualText,
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Penjelasan saat Titik Diketuk',
                  hintText: 'Jelaskan fungsi atau arti bagian tersebut...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _visualText,
                        side: const BorderSide(color: _visualBorder),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _visualPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                        'Simpan Titik',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
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

// =============================================================================
// DRAFT MODELS
// =============================================================================
class VisualItemDraft {
  VisualItemDraft({String title = '', String description = ''})
    : titleController = TextEditingController(text: title),
      descriptionController = TextEditingController(text: description);

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
  VisualTableRowDraft({String first = '', String second = ''})
    : firstController = TextEditingController(text: first),
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

// =============================================================================
// HELPER PLACEHOLDERS & EMPTY STATES
// =============================================================================
class _VisualImagePlaceholder extends StatelessWidget {
  const _VisualImagePlaceholder({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _visualCardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _visualBorder, style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _visualPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 32,
                  color: _visualPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pilih Ilustrasi Gambar Terlebih Dahulu',
                style: GoogleFonts.poppins(
                  color: _visualText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Klik untuk mengunggah gambar pendukung hotspot',
                style: GoogleFonts.plusJakartaSans(
                  color: _visualMuted,
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

class _VisualImageError extends StatelessWidget {
  const _VisualImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image_rounded,
            color: _visualMuted,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            'Gambar tidak dapat dimuat',
            style: GoogleFonts.plusJakartaSans(
              color: _visualMuted,
              fontSize: 11.5,
            ),
          ),
        ],
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
        color: _visualCardBg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _visualBorder),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          color: _visualMuted,
          fontSize: 11.5,
          height: 1.45,
        ),
      ),
    );
  }
}
