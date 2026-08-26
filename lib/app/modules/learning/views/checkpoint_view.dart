import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/api_service.dart';
import '../controllers/learning_controller.dart';

const Color _checkpointPrimary = Color(0xFF2563EB);
const Color _checkpointDark = Color(0xFF172033);
const Color _checkpointMuted = Color(0xFF64748B);
const Color _checkpointBackground = Color(0xFFF5F8FF);
const Color _checkpointSuccess = Color(0xFF16A34A);
const Color _checkpointDanger = Color(0xFFDC2626);

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

class _CheckpointExerciseViewState
    extends State<CheckpointExerciseView> {
  final TextEditingController _textController =
      TextEditingController();

  String? _selectedOptionId;
  bool? _trueFalseAnswer;
  String? _selectedHotspotId;
  Map<String, dynamic>? _selectedHotspot;

  final Map<String, String> _matchingAnswers =
      <String, String>{};

  List<Map<String, dynamic>> _orderingItems =
      <Map<String, dynamic>>[];

  Map<String, dynamic>? _submitResult;

  LearningController get _controller =>
      Get.find<LearningController>();

  String get _type =>
      widget.checkpoint['checkpoint_type']
          ?.toString()
          .trim()
          .toLowerCase() ??
      '';

  Map<String, dynamic> get _content =>
      LearningController.mapValue(
        widget.checkpoint['content'],
      );

  int get _checkpointId =>
      LearningController.intValue(
        widget.checkpoint['id'],
      );

  bool get _alreadyCompleted =>
      LearningController.boolValue(
        widget.checkpoint['is_completed'],
      );

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
        title: const Text('Checkpoint'),
        backgroundColor: Colors.white,
        foregroundColor: _checkpointDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          34,
        ),
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
          const SizedBox(height: 22),
          if (completedNow)
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: Get.back,
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  'Kembali ke Submateri',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _checkpointSuccess,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            )
          else
            Obx(
              () {
                final submitting =
                    _controller.isSubmittingCheckpoint(
                  _checkpointId,
                );

                return SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: submitting
                        ? null
                        : _submit,
                    icon: submitting
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
                            Icons.send_rounded,
                          ),
                    label: Text(
                      submitting
                          ? 'Memeriksa...'
                          : 'Kirim Jawaban',
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          _checkpointPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
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
          title: 'Jawaban',
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
        message:
            'Pilihan jawaban belum diisi oleh admin.',
      );
    }

    return _AnswerCard(
      title: 'Pilih satu jawaban',
      child: Column(
        children: options.map((option) {
          final String id =
              option['id'].toString();
          final bool selected =
              _selectedOptionId == id;

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
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
      title: 'Tentukan benar atau salah',
      child: Row(
        children: <Widget>[
          Expanded(
            child: _BooleanAnswer(
              label: 'Benar',
              icon: Icons.check_circle_rounded,
              selected: _trueFalseAnswer == true,
              selectedColor:
                  _checkpointSuccess,
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
              selected:
                  _trueFalseAnswer == false,
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
        message:
            'Data pasangan kiri dan kanan belum lengkap.',
      );
    }

    return _AnswerCard(
      title: 'Pasangkan setiap pernyataan',
      child: Column(
        children: leftItems.map((left) {
          final String leftId =
              left['id'].toString();
          final String? selected =
              _matchingAnswers[leftId];

          return Container(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius:
                  BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  left['text'].toString(),
                  style: const TextStyle(
                    color: _checkpointDark,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  key: ValueKey<String>(
                    '$leftId-${selected ?? 'empty'}',
                  ),
                  value: selected,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Pilih pasangan',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(
                        color:
                            Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  items: rightItems.map((right) {
                    return DropdownMenuItem<String>(
                      value:
                          right['id'].toString(),
                      child: Text(
                        right['text'].toString(),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _matchingAnswers[leftId] =
                          value;
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
        message:
            'Daftar yang harus diurutkan belum tersedia.',
      );
    }

    return _AnswerCard(
      title: 'Geser untuk menyusun urutan',
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: _orderingItems.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }

            final moved =
                _orderingItems.removeAt(oldIndex);
            _orderingItems.insert(
              newIndex,
              moved,
            );
            _submitResult = null;
          });
        },
        itemBuilder: (context, index) {
          final item = _orderingItems[index];

          return Container(
            key: ValueKey<String>(
              item['_key'].toString(),
            ),
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 15,
                  backgroundColor:
                      const Color(0xFFEAF1FF),
                  foregroundColor:
                      _checkpointPrimary,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    item['text'].toString(),
                    style: const TextStyle(
                      color: _checkpointDark,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: _checkpointMuted,
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
      _content['hotspots'] ??
          _content['points'],
    );

    final imageUrl = ApiService.resolveMediaUrl(
      widget.checkpoint['image_url']
          ?.toString(),
    );

    if (hotspots.isEmpty) {
      return const _ConfigurationWarning(
        message:
            'Titik gambar belum diatur oleh admin.',
      );
    }

    return _AnswerCard(
      title: 'Sentuh bagian gambar yang benar',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ClipRRect(
                  borderRadius:
                      BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      if (imageUrl == null)
                        Container(
                          color:
                              const Color(0xFFE2E8F0),
                          alignment: Alignment.center,
                          child: const Text(
                            'Gambar checkpoint belum tersedia',
                            style: TextStyle(
                              color:
                                  _checkpointMuted,
                            ),
                          ),
                        )
                      else
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              color: const Color(
                                0xFFE2E8F0,
                              ),
                              alignment:
                                  Alignment.center,
                              child: const Text(
                                'Gambar tidak dapat dimuat',
                                style: TextStyle(
                                  color:
                                      _checkpointMuted,
                                ),
                              ),
                            );
                          },
                        ),
                      ...hotspots.map((hotspot) {
                        final String id =
                            hotspot['id'].toString();
                        final double x =
                            _coordinate(
                          hotspot['x'],
                        );
                        final double y =
                            _coordinate(
                          hotspot['y'],
                        );
                        final bool selected =
                            _selectedHotspotId ==
                                id;

                        return Positioned(
                          left: x *
                              (constraints.maxWidth -
                                  42),
                          top: y *
                              (constraints.maxHeight -
                                  42),
                          child: Tooltip(
                            message:
                                hotspot['label']
                                    .toString(),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedHotspotId =
                                      id;
                                  _selectedHotspot =
                                      hotspot;
                                  _submitResult =
                                      null;
                                });
                              },
                              child:
                                  AnimatedContainer(
                                duration:
                                    const Duration(
                                  milliseconds: 180,
                                ),
                                width: 42,
                                height: 42,
                                decoration:
                                    BoxDecoration(
                                  shape:
                                      BoxShape.circle,
                                  color: selected
                                      ? _checkpointPrimary
                                      : Colors.white
                                          .withValues(
                                          alpha: 0.88,
                                        ),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.white
                                        : _checkpointPrimary,
                                    width: 3,
                                  ),
                                  boxShadow: <
                                      BoxShadow>[
                                    BoxShadow(
                                      color: Colors
                                          .black
                                          .withValues(
                                        alpha: 0.16,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  selected
                                      ? Icons
                                          .check_rounded
                                      : Icons
                                          .touch_app_rounded,
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
          const SizedBox(height: 10),
          Text(
            _selectedHotspotId == null
                ? 'Belum ada bagian yang dipilih.'
                : 'Bagian dipilih: ${_hotspotLabel(hotspots, _selectedHotspotId!)}',
            style: const TextStyle(
              color: _checkpointMuted,
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
                color: const Color(0xFFEAF1FF),
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFBFDBFE),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.info_rounded,
                        color: _checkpointPrimary,
                        size: 19,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          _selectedHotspot!['label']
                                  ?.toString() ??
                              'Penjelasan',
                          style: const TextStyle(
                            color: _checkpointDark,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _selectedHotspot!['explanation']
                        .toString(),
                    style: const TextStyle(
                      color: _checkpointMuted,
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
      _content['options'] ??
          _content['choices'],
    );

    return Column(
      children: <Widget>[
        _DataDisplay(content: _content),
        const SizedBox(height: 14),
        if (options.isNotEmpty)
          _AnswerCard(
            title: 'Pilih kesimpulan yang tepat',
            child: Column(
              children: options.map((option) {
                final String id =
                    option['id'].toString();

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: _SelectableAnswer(
                    label:
                        option['text'].toString(),
                    leadingText: id,
                    selected:
                        _selectedOptionId == id,
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
            title: 'Tulis hasil analisismu',
            hint:
                'Masukkan jawaban berdasarkan data di atas.',
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
      child: TextField(
        controller: _textController,
        minLines: 3,
        maxLines: 7,
        onChanged: (_) {
          if (_submitResult != null) {
            setState(() {
              _submitResult = null;
            });
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final dynamic answer = _buildAnswer();

    if (answer == null) {
      _controller.showError(
        'Lengkapi jawaban terlebih dahulu.',
      );
      return;
    }

    final result =
        await _controller.submitCheckpointAnswer(
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
                  !_matchingAnswers.containsKey(
                item['id'].toString(),
              ),
            )) {
          return null;
        }

        return <String, dynamic>{
          'pairs': leftItems.map((left) {
            final String leftId =
                left['id'].toString();

            return <String, dynamic>{
              'left_id': leftId,
              'right_id':
                  _matchingAnswers[leftId],
            };
          }).toList(),
        };
      case 'ordering':
        if (_orderingItems.isEmpty) {
          return null;
        }

        return <String, dynamic>{
          'order': _orderingItems
              .map(
                (item) => item['id'].toString(),
              )
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
          _content['options'] ??
              _content['choices'],
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

  List<Map<String, dynamic>> _optionsFrom(
    dynamic raw,
  ) {
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
        final map =
            Map<String, dynamic>.from(item);

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
          '_key':
              '$prefix-${entry.key}',
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
        final map =
            Map<String, dynamic>.from(item);
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

  List<Map<String, dynamic>> _hotspotsFrom(
    dynamic raw,
  ) {
    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw.asMap().entries.map((entry) {
      final map = entry.value is Map
          ? Map<String, dynamic>.from(
              entry.value as Map,
            )
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
        'explanation':
            (map['explanation'] ??
                    map['description'] ??
                    map['info'] ??
                    '')
                .toString(),
      };
    }).toList();
  }

  double _coordinate(dynamic value) {
    final double parsed = double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.5;

    final double normalized =
        parsed > 1 ? parsed / 100 : parsed;

    return normalized.clamp(0.0, 1.0);
  }

  String _hotspotLabel(
    List<Map<String, dynamic>> hotspots,
    String id,
  ) {
    final item = hotspots.firstWhereOrNull(
      (hotspot) =>
          hotspot['id'].toString() == id,
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
        checkpoint['checkpoint_type']
            ?.toString() ??
        '';
    final int attempts =
        LearningController.intValue(
      checkpoint['attempts'],
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: completed
              ? const <Color>[
                  Color(0xFF15803D),
                  Color(0xFF22C55E),
                ]
              : const <Color>[
                  Color(0xFF1E3A8A),
                  Color(0xFF2563EB),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 25,
            backgroundColor:
                Colors.white.withValues(
              alpha: 0.18,
            ),
            foregroundColor: Colors.white,
            child: Icon(
              completed
                  ? Icons.check_rounded
                  : _checkpointIcon(type),
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  completed
                      ? 'Checkpoint selesai'
                      : _checkpointLabel(type),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  attempts == 0
                      ? 'Belum pernah dicoba'
                      : '$attempts kali percobaan',
                  style: const TextStyle(
                    color: Color(0xFFDCE9FF),
                    fontSize: 12,
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
    final String? instruction =
        checkpoint['instruction']
            ?.toString()
            .trim();

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          if (checkpoint['title']
                      ?.toString()
                      .trim()
                      .isNotEmpty ==
                  true) ...<Widget>[
            Text(
              checkpoint['title'].toString(),
              style: const TextStyle(
                color: _checkpointPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            checkpoint['question_text']
                    ?.toString() ??
                'Pertanyaan checkpoint',
            style: const TextStyle(
              color: _checkpointDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.4,
            ),
          ),
          if (instruction?.isNotEmpty == true) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              instruction!,
              style: const TextStyle(
                color: _checkpointMuted,
                height: 1.4,
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
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              color: _checkpointDark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 13),
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
      color: selected
          ? const Color(0xFFEAF1FF)
          : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? _checkpointPrimary
                  : const Color(0xFFE2E8F0),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundColor: selected
                    ? _checkpointPrimary
                    : Colors.white,
                foregroundColor: selected
                    ? Colors.white
                    : _checkpointMuted,
                child: Text(
                  leadingText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: _checkpointDark,
                    fontWeight: selected
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? _checkpointPrimary
                    : _checkpointMuted,
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
            vertical: 22,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? selectedColor
                  : const Color(0xFFE2E8F0),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                icon,
                color: selected
                    ? selectedColor
                    : _checkpointMuted,
                size: 34,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? selectedColor
                      : _checkpointDark,
                  fontWeight: FontWeight.w900,
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
        LearningController.boolValue(
      result['is_correct'],
    );
    final int xpAdded =
        LearningController.intValue(
      result['total_xp_added'],
    );
    final bool xpAlreadyReceived =
        LearningController.boolValue(
      result['xp_already_received'],
    );

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: correct
            ? const Color(0xFFE7F8EE)
            : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: correct
              ? const Color(0xFF86EFAC)
              : const Color(0xFFFDBA74),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            correct
                ? Icons.check_circle_rounded
                : Icons.info_rounded,
            color: correct
                ? _checkpointSuccess
                : const Color(0xFFEA580C),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  correct
                      ? 'Jawaban benar'
                      : 'Jawaban belum tepat',
                  style: TextStyle(
                    color: correct
                        ? const Color(0xFF166534)
                        : const Color(0xFF9A3412),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  (result['feedback'] ??
                          'Tidak ada umpan balik.')
                      .toString(),
                  style: TextStyle(
                    color: correct
                        ? const Color(0xFF166534)
                        : const Color(0xFF9A3412),
                    height: 1.4,
                  ),
                ),
                if (correct &&
                    (xpAdded > 0 ||
                        xpAlreadyReceived)) ...<Widget>[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: xpAdded > 0
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFDBEAFE),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          xpAdded > 0
                              ? Icons.bolt_rounded
                              : Icons.info_rounded,
                          size: 18,
                          color: xpAdded > 0
                              ? const Color(0xFF047857)
                              : const Color(0xFF1D4ED8),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            xpAdded > 0
                                ? '+$xpAdded XP berhasil diperoleh'
                                : 'XP checkpoint ini sudah pernah diterima',
                            style: TextStyle(
                              color: xpAdded > 0
                                  ? const Color(0xFF047857)
                                  : const Color(0xFF1D4ED8),
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w800,
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
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDBA74),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFEA580C),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF9A3412),
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
        content['description']
            ?.toString()
            .trim();

    final List<String> headers =
        _stringList(content['headers']);

    final dynamic rawRows =
        content['rows'] ?? content['data'];

    final List<dynamic> rows = rawRows is List
        ? List<dynamic>.from(rawRows)
        : <dynamic>[];

    return _AnswerCard(
      title: content['title']?.toString() ??
          'Data yang harus dianalisis',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          if (description?.isNotEmpty == true) ...<Widget>[
            Text(
              description!,
              style: const TextStyle(
                color: _checkpointMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (rows.isEmpty)
            const Text(
              'Data belum tersedia.',
              style: TextStyle(
                color: _checkpointMuted,
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(
                  const Color(0xFFEAF1FF),
                ),
                columns: _columnsFor(
                  headers,
                  rows,
                ),
                rows: _rowsFor(
                  headers,
                  rows,
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
    final effectiveHeaders =
        _effectiveHeaders(headers, rows);

    return effectiveHeaders
        .map(
          (header) => DataColumn(
            label: Text(
              header,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
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
    final effectiveHeaders =
        _effectiveHeaders(headers, rows);

    return rows.map((row) {
      if (row is Map) {
        return DataRow(
          cells: effectiveHeaders.map((header) {
            return DataCell(
              Text(
                row[header]?.toString() ??
                    row[header.toLowerCase()]
                        ?.toString() ??
                    '-',
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
                index < row.length
                    ? row[index].toString()
                    : '-',
              ),
            ),
          ),
        );
      }

      return DataRow(
        cells: effectiveHeaders
            .map(
              (_) => DataCell(
                Text(row.toString()),
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
      return (rows.first as Map)
          .keys
          .map((key) => key.toString())
          .toList();
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

    return raw
        .map((item) => item.toString())
        .toList();
  }
}

String _checkpointLabel(String type) {
  switch (type) {
    case 'multiple_choice':
      return 'Pilihan';
    case 'true_false':
      return 'Benar/Salah';
    case 'matching':
      return 'Pasangkan';
    case 'ordering':
      return 'Urutkan';
    case 'image_hotspot':
      return 'Tunjuk Bagian';
    case 'data_interpretation':
      return 'Analisis Data';
    default:
      return 'Checkpoint';
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
