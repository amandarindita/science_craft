import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/api_service.dart';
import '../controllers/learning_controller.dart';

const Color _checkpointPrimary = Color(0xFF2563EB);
const Color _checkpointDark = Color(0xFF172033);
const Color _checkpointMuted = Color(0xFF64748B);
const Color _checkpointBackground = Color(0xFFF5F8FF);
const Color _checkpointSuccess = Color(0xFF16A34A);
const Color _checkpointDanger = Color(0xFFDC2626);
const Color _checkpointBorder = Color(0xFFE2E8F0);

class CheckpointExerciseView extends StatefulWidget {
  const CheckpointExerciseView({
    super.key,
    required this.checkpoint,
  });

  final Map<String, dynamic> checkpoint;

  @override
  State<CheckpointExerciseView> createState() =>
      _CheckpointExerciseViewState();
}

class _CheckpointExerciseViewState extends State<CheckpointExerciseView> {
  final TextEditingController _textController = TextEditingController();

  String? _selectedOptionId;
  bool? _trueFalseAnswer;
  String? _selectedHotspotId;
  Map<String, dynamic>? _selectedHotspot;

  final Map<String, String> _matchingAnswers = <String, String>{};

  List<Map<String, dynamic>> _orderingItems = <Map<String, dynamic>>[];

  Map<String, dynamic>? _submitResult;

  LearningController get _controller => Get.find<LearningController>();

  String get _type =>
      widget.checkpoint['checkpoint_type']
          ?.toString()
          .trim()
          .toLowerCase() ??
      '';

  Map<String, dynamic> get _content =>
      LearningController.mapValue(widget.checkpoint['content']);

  int get _checkpointId =>
      LearningController.intValue(widget.checkpoint['id']);

  bool get _alreadyCompleted =>
      LearningController.boolValue(widget.checkpoint['is_completed']);

  @override
  void initState() {
    super.initState();

    if (_type == 'ordering') {
      _orderingItems = _itemsFrom(
        _content['items'] ?? _content['options'],
        prefix: 'item',
      );

      if (_orderingItems.length > 1) {
        _orderingItems.shuffle();
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool completedNow =
        _alreadyCompleted ||
        LearningController.boolValue(
          _submitResult?['checkpoint_completed'],
        );

    return Scaffold(
      backgroundColor: _checkpointBackground,
      appBar: AppBar(
        title: Text(
          'Latihan Checkpoint',
          style: GoogleFonts.poppins(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: _checkpointDark,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _checkpointDark,
        elevation: 0,
        centerTitle: false,
        shape: const Border(
          bottom: BorderSide(color: _checkpointBorder, width: 1),
        ),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: <Widget>[
          _CheckpointHeader(
            checkpoint: widget.checkpoint,
            completed: completedNow,
          ),
          const SizedBox(height: 16),
          _QuestionCard(
            checkpoint: widget.checkpoint,
          ),
          const SizedBox(height: 16),
          _buildAnswerArea(),
          if (_submitResult != null) ...<Widget>[
            const SizedBox(height: 16),
            _ResultCard(result: _submitResult!),
          ],
        ],
      ),
      bottomNavigationBar: _buildBottomBar(completedNow),
    );
  }

  Widget _buildBottomBar(bool completedNow) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: _checkpointBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: completedNow
            ? SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Get.back<void>(),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(
                    'Selesai & Kembali ke Submateri',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _checkpointSuccess,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              )
            : Obx(
                () {
                  final bool submitting = _controller.isSubmittingCheckpoint(
                    _checkpointId,
                  );

                  return SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: submitting ? null : _submit,
                      icon: submitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 17),
                      label: Text(
                        submitting ? 'Memeriksa Jawaban...' : 'Kirim Jawaban',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: Colors.white,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _checkpointPrimary,
                        disabledBackgroundColor: _checkpointPrimary,
                        disabledForegroundColor:
                            Colors.white.withValues(alpha: 0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildAnswerArea() {
    switch (_type) {
      case 'multiple_choice':
        return _buildMultipleChoice();
      case 'true_false':
        return _buildTrueFalse();
      case 'matching':
        return _buildMatching();
      case 'ordering':
        return _buildOrdering();
      case 'image_hotspot':
        return _buildImageHotspot();
      case 'data_interpretation':
        return _buildDataInterpretation();
      default:
        return _buildTextAnswer(
          title: 'Jawaban Kamu',
          hint: 'Ketik jawabanmu di sini.',
        );
    }
  }

  Widget _buildMultipleChoice() {
    final options = _optionsFrom(
      _content['options'] ??
          _content['choices'] ??
          _content['items'],
    );

    if (options.isEmpty) {
      return const _ConfigurationWarning(
        message: 'Pilihan jawaban belum diisi oleh pembuat modul.',
      );
    }

    return _AnswerCard(
      title: 'Pilih Satu Jawaban yang Tepat',
      icon: Icons.checklist_rounded,
      child: Column(
        children: options.map((option) {
          final String id = option['id'].toString();
          final bool selected = _selectedOptionId == id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SelectableAnswer(
              label: option['text'].toString(),
              leadingText: id,
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedOptionId = id;
                  _submitResult = null;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrueFalse() {
    return _AnswerCard(
      title: 'Tentukan Benar atau Salah',
      icon: Icons.rule_rounded,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _BooleanAnswer(
              label: 'Benar',
              icon: Icons.check_circle_rounded,
              selected: _trueFalseAnswer == true,
              selectedColor: _checkpointSuccess,
              onTap: () {
                setState(() {
                  _trueFalseAnswer = true;
                  _submitResult = null;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BooleanAnswer(
              label: 'Salah',
              icon: Icons.cancel_rounded,
              selected: _trueFalseAnswer == false,
              selectedColor: _checkpointDanger,
              onTap: () {
                setState(() {
                  _trueFalseAnswer = false;
                  _submitResult = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatching() {
    final leftItems = _itemsFrom(
      _content['left'] ??
          _content['items_left'] ??
          _content['prompts'],
      prefix: 'left',
    );

    final rightItems = _itemsFrom(
      _content['right'] ??
          _content['items_right'] ??
          _content['choices'],
      prefix: 'right',
    );

    if (leftItems.isEmpty || rightItems.isEmpty) {
      return const _ConfigurationWarning(
        message: 'Data pasangan pernyataan belum lengkap.',
      );
    }

    return _AnswerCard(
      title: 'Pasangkan Setiap Pernyataan',
      icon: Icons.compare_arrows_rounded,
      child: Column(
        children: leftItems.map((left) {
          final String leftId = left['id'].toString();
          final String? selected = _matchingAnswers[leftId];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _checkpointBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  left['text'].toString(),
                  style: GoogleFonts.poppins(
                    color: _checkpointDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  key: ValueKey<String>('$leftId-${selected ?? 'empty'}'),
                  initialValue: selected,
                  isExpanded: true,
                  style: GoogleFonts.plusJakartaSans(
                    color: _checkpointDark,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Pilih pasangan...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: _checkpointMuted,
                      fontSize: 12.5,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _checkpointBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _checkpointBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _checkpointPrimary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: rightItems.map((right) {
                    return DropdownMenuItem<String>(
                      value: right['id'].toString(),
                      child: Text(
                        right['text'].toString(),
                        style: GoogleFonts.plusJakartaSans(
                          color: _checkpointDark,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _matchingAnswers[leftId] = value;
                      _submitResult = null;
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrdering() {
    if (_orderingItems.isEmpty) {
      return const _ConfigurationWarning(
        message: 'Daftar urutan belum tersedia.',
      );
    }

    return _AnswerCard(
      title: 'Geser untuk Menyusun Urutan',
      icon: Icons.reorder_rounded,
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: _orderingItems.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }

            final moved = _orderingItems.removeAt(oldIndex);
            _orderingItems.insert(newIndex, moved);
            _submitResult = null;
          });
        },
        itemBuilder: (context, index) {
          final item = _orderingItems[index];

          return Container(
            key: ValueKey<String>(item['_key'].toString()),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _checkpointBorder),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _checkpointPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['text'].toString(),
                    style: GoogleFonts.plusJakartaSans(
                      color: _checkpointDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: _checkpointMuted,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageHotspot() {
    final hotspots = _hotspotsFrom(
      _content['hotspots'] ?? _content['points'],
    );

    final imageUrl = ApiService.resolveMediaUrl(
      widget.checkpoint['image_url']?.toString(),
    );

    if (hotspots.isEmpty) {
      return const _ConfigurationWarning(
        message: 'Titik gambar belum diatur oleh pembuat modul.',
      );
    }

    return _AnswerCard(
      title: 'Sentuh Bagian Gambar yang Benar',
      icon: Icons.touch_app_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      if (imageUrl == null)
                        Container(
                          color: const Color(0xFFE2E8F0),
                          alignment: Alignment.center,
                          child: Text(
                            'Gambar checkpoint belum tersedia',
                            style: GoogleFonts.plusJakartaSans(
                              color: _checkpointMuted,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE2E8F0),
                              alignment: Alignment.center,
                              child: Text(
                                'Gambar tidak dapat dimuat',
                                style: GoogleFonts.plusJakartaSans(
                                  color: _checkpointMuted,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ...hotspots.map((hotspot) {
                        final String id = hotspot['id'].toString();
                        final double x = _coordinate(hotspot['x']);
                        final double y = _coordinate(hotspot['y']);
                        final bool selected = _selectedHotspotId == id;

                        return Positioned(
                          left: x * (constraints.maxWidth - 42),
                          top: y * (constraints.maxHeight - 42),
                          child: Tooltip(
                            message: hotspot['label'].toString(),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedHotspotId = id;
                                  _selectedHotspot = hotspot;
                                  _submitResult = null;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected
                                      ? _checkpointPrimary
                                      : Colors.white.withValues(alpha: 0.88),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.white
                                        : _checkpointPrimary,
                                    width: 3,
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.16,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  selected
                                      ? Icons.check_rounded
                                      : Icons.touch_app_rounded,
                                  color: selected
                                      ? Colors.white
                                      : _checkpointPrimary,
                                  size: 21,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedHotspotId == null
                ? 'Belum ada bagian yang dipilih.'
                : 'Bagian dipilih: ${_hotspotLabel(hotspots, _selectedHotspotId!)}',
            style: GoogleFonts.plusJakartaSans(
              color: _selectedHotspotId == null
                  ? _checkpointMuted
                  : _checkpointPrimary,
              fontWeight: _selectedHotspotId == null
                  ? FontWeight.normal
                  : FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (_selectedHotspot != null &&
              (_selectedHotspot!['explanation']
                      ?.toString()
                      .trim()
                      .isNotEmpty ??
                  false)) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.info_outline_rounded,
                        color: _checkpointPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          _selectedHotspot!['label']?.toString() ?? 'Penjelasan',
                          style: GoogleFonts.poppins(
                            color: _checkpointDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedHotspot!['explanation'].toString(),
                    style: GoogleFonts.plusJakartaSans(
                      color: _checkpointMuted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataInterpretation() {
    final options = _optionsFrom(
      _content['options'] ?? _content['choices'],
    );

    return Column(
      children: <Widget>[
        _DataDisplay(content: _content),
        const SizedBox(height: 14),
        if (options.isNotEmpty)
          _AnswerCard(
            title: 'Pilih Kesimpulan yang Tepat',
            icon: Icons.insights_rounded,
            child: Column(
              children: options.map((option) {
                final String id = option['id'].toString();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SelectableAnswer(
                    label: option['text'].toString(),
                    leadingText: id,
                    selected: _selectedOptionId == id,
                    onTap: () {
                      setState(() {
                        _selectedOptionId = id;
                        _submitResult = null;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          )
        else
          _buildTextAnswer(
            title: 'Tulis Hasil Analisismu',
            hint: 'Masukkan jawaban berdasarkan data di atas.',
          ),
      ],
    );
  }

  Widget _buildTextAnswer({
    required String title,
    required String hint,
  }) {
    return _AnswerCard(
      title: title,
      icon: Icons.edit_note_rounded,
      child: TextField(
        controller: _textController,
        minLines: 3,
        maxLines: 7,
        style: GoogleFonts.plusJakartaSans(
          color: _checkpointDark,
          fontSize: 13.5,
          height: 1.5,
        ),
        onChanged: (_) {
          if (_submitResult != null) {
            setState(() {
              _submitResult = null;
            });
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: _checkpointMuted,
            fontSize: 13,
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _checkpointBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _checkpointBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _checkpointPrimary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final dynamic answer = _buildAnswer();

    if (answer == null) {
      _controller.showError('Lengkapi jawaban terlebih dahulu.');
      return;
    }

    final result = await _controller.submitCheckpointAnswer(
      checkpointId: _checkpointId,
      answer: answer,
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _submitResult = result;
    });
  }

  dynamic _buildAnswer() {
    switch (_type) {
      case 'multiple_choice':
        return _selectedOptionId;
      case 'true_false':
        return _trueFalseAnswer;
      case 'matching':
        final leftItems = _itemsFrom(
          _content['left'] ??
              _content['items_left'] ??
              _content['prompts'],
          prefix: 'left',
        );

        if (leftItems.isEmpty ||
            leftItems.any(
              (item) =>
                  !_matchingAnswers.containsKey(item['id'].toString()),
            )) {
          return null;
        }

        return <String, dynamic>{
          'pairs': leftItems.map((left) {
            final String leftId = left['id'].toString();

            return <String, dynamic>{
              'left_id': leftId,
              'right_id': _matchingAnswers[leftId],
            };
          }).toList(),
        };
      case 'ordering':
        if (_orderingItems.isEmpty) {
          return null;
        }

        return <String, dynamic>{
          'order': _orderingItems
              .map((item) => item['id'].toString())
              .toList(),
        };
      case 'image_hotspot':
        if (_selectedHotspotId == null) {
          return null;
        }

        return <String, dynamic>{
          'hotspot_id': _selectedHotspotId,
        };
      case 'data_interpretation':
        final options = _optionsFrom(
          _content['options'] ?? _content['choices'],
        );

        if (options.isNotEmpty) {
          return _selectedOptionId;
        }

        final text = _textController.text.trim();
        return text.isEmpty ? null : text;
      default:
        final text = _textController.text.trim();
        return text.isEmpty ? null : text;
    }
  }

  List<Map<String, dynamic>> _optionsFrom(dynamic raw) {
    if (raw is Map) {
      return raw.entries.map((entry) {
        return <String, dynamic>{
          'id': entry.key.toString(),
          'text': entry.value.toString(),
        };
      }).toList();
    }

    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw.asMap().entries.map((entry) {
      final int index = entry.key;
      final dynamic item = entry.value;

      if (item is Map) {
        final map = Map<String, dynamic>.from(item);

        return <String, dynamic>{
          'id': (map['id'] ??
                  map['value'] ??
                  map['key'] ??
                  _letter(index))
              .toString(),
          'text': (map['text'] ??
                  map['label'] ??
                  map['title'] ??
                  map['value'] ??
                  '')
              .toString(),
        };
      }

      return <String, dynamic>{
        'id': _letter(index),
        'text': item.toString(),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _itemsFrom(
    dynamic raw, {
    required String prefix,
  }) {
    if (raw is Map) {
      return raw.entries.map((entry) {
        return <String, dynamic>{
          'id': entry.key.toString(),
          'text': entry.value.toString(),
          '_key': '$prefix-${entry.key}',
        };
      }).toList();
    }

    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw.asMap().entries.map((entry) {
      final int index = entry.key;
      final dynamic item = entry.value;

      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final String id = (map['id'] ??
                map['value'] ??
                map['key'] ??
                '$prefix-${index + 1}')
            .toString();

        return <String, dynamic>{
          'id': id,
          'text': (map['text'] ??
                  map['label'] ??
                  map['title'] ??
                  map['value'] ??
                  '')
              .toString(),
          '_key': '$prefix-$id-$index',
        };
      }

      return <String, dynamic>{
        'id': '$prefix-${index + 1}',
        'text': item.toString(),
        '_key': '$prefix-${index + 1}',
      };
    }).toList();
  }

  List<Map<String, dynamic>> _hotspotsFrom(dynamic raw) {
    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw.asMap().entries.map((entry) {
      final map = entry.value is Map
          ? Map<String, dynamic>.from(entry.value as Map)
          : <String, dynamic>{};

      return <String, dynamic>{
        'id': (map['id'] ??
                map['value'] ??
                'hotspot-${entry.key + 1}')
            .toString(),
        'label': (map['label'] ??
                map['text'] ??
                'Titik ${entry.key + 1}')
            .toString(),
        'x': map['x'] ??
            map['left'] ??
            map['x_percent'] ??
            0.5,
        'y': map['y'] ??
            map['top'] ??
            map['y_percent'] ??
            0.5,
        'explanation': (map['explanation'] ??
                map['description'] ??
                map['info'] ??
                '')
            .toString(),
      };
    }).toList();
  }

  double _coordinate(dynamic value) {
    final double parsed = double.tryParse(value?.toString() ?? '') ?? 0.5;
    final double normalized = parsed > 1 ? parsed / 100 : parsed;
    return normalized.clamp(0.0, 1.0);
  }

  String _hotspotLabel(
    List<Map<String, dynamic>> hotspots,
    String id,
  ) {
    final item = hotspots.firstWhereOrNull(
      (hotspot) => hotspot['id'].toString() == id,
    );

    return item?['label']?.toString() ?? id;
  }

  String _letter(int index) {
    if (index >= 0 && index < 26) {
      return String.fromCharCode(65 + index);
    }

    return '${index + 1}';
  }
}

class _CheckpointHeader extends StatelessWidget {
  const _CheckpointHeader({
    required this.checkpoint,
    required this.completed,
  });

  final Map<String, dynamic> checkpoint;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final String type =
        checkpoint['checkpoint_type']?.toString() ?? '';
    final int attempts = LearningController.intValue(
      checkpoint['attempts'],
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: completed
              ? const <Color>[
                  Color(0xFF15803D), // Green
                  Color(0xFF22C55E),
                ]
              : const <Color>[
                  Color(0xFF1E3A8A), // Navy / Blue
                  Color(0xFF2563EB),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (completed ? _checkpointSuccess : _checkpointPrimary)
                .withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              completed ? Icons.verified_rounded : _checkpointIcon(type),
              size: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  completed ? 'Checkpoint Selesai' : _checkpointLabel(type),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  attempts == 0
                      ? 'Belum pernah dicoba'
                      : '$attempts kali percobaan terselesaikan',
                  style: GoogleFonts.plusJakartaSans(
                    color: completed
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFDCE9FF),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.checkpoint,
  });

  final Map<String, dynamic> checkpoint;

  @override
  Widget build(BuildContext context) {
    final String? title = checkpoint['title']?.toString().trim();
    final String? instruction =
        checkpoint['instruction']?.toString().trim();
    final String question = checkpoint['question_text']?.toString() ??
        'Pertanyaan checkpoint';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _checkpointBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null && title.isNotEmpty) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: _checkpointPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            question,
            style: GoogleFonts.poppins(
              color: _checkpointDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          if (instruction != null && instruction.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _checkpointBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: _checkpointPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      instruction,
                      style: GoogleFonts.plusJakartaSans(
                        color: _checkpointMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.title,
    this.icon,
    required this.child,
  });

  final String title;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _checkpointBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
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
              if (icon != null) ...[
                Icon(icon, size: 18, color: _checkpointPrimary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: _checkpointDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SelectableAnswer extends StatelessWidget {
  const _SelectableAnswer({
    required this.label,
    required this.leadingText,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String leadingText;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _checkpointPrimary : _checkpointBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? _checkpointPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? _checkpointPrimary : _checkpointBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  leadingText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : _checkpointDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: _checkpointDark,
                    fontSize: 13.5,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? _checkpointPrimary : _checkpointMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BooleanAnswer extends StatelessWidget {
  const _BooleanAnswer({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? selectedColor.withValues(alpha: 0.10)
          : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? selectedColor : _checkpointBorder,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                icon,
                color: selected ? selectedColor : _checkpointMuted,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: selected ? selectedColor : _checkpointDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
  });

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final bool correct =
        LearningController.boolValue(result['is_correct']);
    final int xpAdded =
        LearningController.intValue(result['total_xp_added']);
    final bool xpAlreadyReceived =
        LearningController.boolValue(result['xp_already_received']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: correct ? const Color(0xFFA7F3D0) : const Color(0xFFFED7AA),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              correct
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              color: correct ? _checkpointSuccess : const Color(0xFFEA580C),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    correct ? 'Jawaban Benar!' : 'Jawaban Belum Tepat',
                    style: GoogleFonts.poppins(
                      color: correct
                          ? const Color(0xFF166534)
                          : const Color(0xFF9A3412),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (result['feedback'] ?? 'Tidak ada umpan balik.')
                        .toString(),
                    style: GoogleFonts.plusJakartaSans(
                      color: correct
                          ? const Color(0xFF166534)
                          : const Color(0xFF9A3412),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  if (correct &&
                      (xpAdded > 0 || xpAlreadyReceived)) ...<Widget>[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: xpAdded > 0
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            xpAdded > 0
                                ? Icons.bolt_rounded
                                : Icons.info_rounded,
                            size: 16,
                            color: xpAdded > 0
                                ? const Color(0xFF047857)
                                : const Color(0xFF1D4ED8),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              xpAdded > 0
                                  ? '+$xpAdded XP berhasil diperoleh'
                                  : 'XP checkpoint sudah pernah diterima',
                              style: GoogleFonts.plusJakartaSans(
                                color: xpAdded > 0
                                    ? const Color(0xFF047857)
                                    : const Color(0xFF1D4ED8),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigurationWarning extends StatelessWidget {
  const _ConfigurationWarning({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFED7AA),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFEA580C),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF9A3412),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataDisplay extends StatelessWidget {
  const _DataDisplay({
    required this.content,
  });

  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    final String? description =
        content['description']?.toString().trim();

    final List<String> headers = _stringList(content['headers']);

    final dynamic rawRows = content['rows'] ?? content['data'];

    final List<dynamic> rows =
        rawRows is List ? List<dynamic>.from(rawRows) : <dynamic>[];

    return _AnswerCard(
      title: content['title']?.toString() ?? 'Data Analisis',
      icon: Icons.table_chart_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (description?.isNotEmpty == true) ...<Widget>[
            Text(
              description!,
              style: GoogleFonts.plusJakartaSans(
                color: _checkpointMuted,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (rows.isEmpty)
            Text(
              'Data belum tersedia.',
              style: GoogleFonts.plusJakartaSans(
                color: _checkpointMuted,
                fontSize: 12,
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFEFF6FF),
                  ),
                  columns: _columnsFor(headers, rows),
                  rows: _rowsFor(headers, rows),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static List<DataColumn> _columnsFor(
    List<String> headers,
    List<dynamic> rows,
  ) {
    final effectiveHeaders = _effectiveHeaders(headers, rows);

    return effectiveHeaders
        .map(
          (header) => DataColumn(
            label: Text(
              header,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        )
        .toList();
  }

  static List<DataRow> _rowsFor(
    List<String> headers,
    List<dynamic> rows,
  ) {
    final effectiveHeaders = _effectiveHeaders(headers, rows);

    return rows.map((row) {
      if (row is Map) {
        return DataRow(
          cells: effectiveHeaders.map((header) {
            return DataCell(
              Text(
                row[header]?.toString() ??
                    row[header.toLowerCase()]?.toString() ??
                    '-',
                style: GoogleFonts.plusJakartaSans(fontSize: 12),
              ),
            );
          }).toList(),
        );
      }

      if (row is List) {
        return DataRow(
          cells: List<DataCell>.generate(
            effectiveHeaders.length,
            (index) => DataCell(
              Text(
                index < row.length ? row[index].toString() : '-',
                style: GoogleFonts.plusJakartaSans(fontSize: 12),
              ),
            ),
          ),
        );
      }

      return DataRow(
        cells: effectiveHeaders
            .map(
              (_) => DataCell(
                Text(
                  row.toString(),
                  style: GoogleFonts.plusJakartaSans(fontSize: 12),
                ),
              ),
            )
            .toList(),
      );
    }).toList();
  }

  static List<String> _effectiveHeaders(
    List<String> headers,
    List<dynamic> rows,
  ) {
    if (headers.isNotEmpty) {
      return headers;
    }

    if (rows.isNotEmpty && rows.first is Map) {
      return (rows.first as Map).keys.map((key) => key.toString()).toList();
    }

    if (rows.isNotEmpty && rows.first is List) {
      return List<String>.generate(
        (rows.first as List).length,
        (index) => 'Kolom ${index + 1}',
      );
    }

    return const <String>['Data'];
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) {
      return <String>[];
    }

    return raw.map((item) => item.toString()).toList();
  }
}

String _checkpointLabel(String type) {
  switch (type) {
    case 'multiple_choice':
      return 'Pilihan Ganda';
    case 'true_false':
      return 'Benar / Salah';
    case 'matching':
      return 'Pasangkan';
    case 'ordering':
      return 'Urutkan';
    case 'image_hotspot':
      return 'Tunjuk Bagian Gambar';
    case 'data_interpretation':
      return 'Analisis Data';
    default:
      return 'Latihan Soal Checkpoint';
  }
}

IconData _checkpointIcon(String type) {
  switch (type) {
    case 'multiple_choice':
      return Icons.list_alt_rounded;
    case 'true_false':
      return Icons.rule_rounded;
    case 'matching':
      return Icons.compare_arrows_rounded;
    case 'ordering':
      return Icons.reorder_rounded;
    case 'image_hotspot':
      return Icons.touch_app_rounded;
    case 'data_interpretation':
      return Icons.analytics_rounded;
    default:
      return Icons.task_alt_rounded;
  }
}
