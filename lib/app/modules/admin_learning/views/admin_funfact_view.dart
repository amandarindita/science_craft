import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/science_shimmer.dart';

import '../controllers/admin_learning_controller.dart';

const Color _primary = Color(0xFFF59E0B);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _background = Color(0xFFF5F8FF);
const Color _danger = Color(0xFFDC2626);

class AdminFunFactView
    extends StatefulWidget {
  const AdminFunFactView({
    super.key,
  });

  @override
  State<AdminFunFactView> createState() =>
      _AdminFunFactViewState();
}

class _AdminFunFactViewState
    extends State<AdminFunFactView> {
  final TextEditingController
      _searchController =
      TextEditingController();

  AdminLearningController get controller =>
      Get.find<AdminLearningController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      controller.clearFunFactSearch();
      controller.loadFunFacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Kelola Fun Fact'),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang',
            onPressed:
                controller.loadFunFacts,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () =>
            _openFunFactForm(),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Tambah Fun Fact',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh:
            controller.loadFunFacts,
        child: Obx(
          () {
            final List<
                Map<String, dynamic>>
                results =
                controller
                    .filteredFunFacts;

            return ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                110,
              ),
              children: <Widget>[
                const _FunFactHeader(),
                const SizedBox(height: 14),
                _SearchBox(
                  searchController:
                      _searchController,
                  controller: controller,
                ),
                const SizedBox(height: 14),
                _CountCard(
                  total:
                      controller.funFacts.length,
                  displayed: results.length,
                ),
                const SizedBox(height: 14),
                if (controller
                        .isLoadingFunFacts
                        .value &&
                    controller.funFacts.isEmpty)
                  const _LoadingState()
                else if (controller
                    .funFacts.isEmpty)
                  const _EmptyState(
                    message:
                        'Belum ada Fun Fact. Tekan tombol Tambah Fun Fact untuk membuat data pertama.',
                  )
                else if (results.isEmpty)
                  const _EmptyState(
                    message:
                        'Fun Fact tidak ditemukan. Coba kata kunci lain.',
                  )
                else
                  ...results.map(
                    (item) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 11,
                      ),
                      child: _FunFactCard(
                        item: item,
                        onEdit: () =>
                            _openFunFactForm(
                          funFact: item,
                        ),
                        onDelete: () =>
                            controller
                                .deleteFunFact(
                          item,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openFunFactForm({
    Map<String, dynamic>? funFact,
  }) async {
    final int? funFactId =
        funFact == null
            ? null
            : AdminLearningController.intValue(
                funFact['id'],
              );

    final bool? saved =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _FunFactFormDialog(
          funFactId: funFactId,
          initialText:
              (funFact?['fact_text'] ?? '')
                  .toString(),
          controller: controller,
        );
      },
    );

    if (saved != true || !mounted) {
      return;
    }

    await controller.loadFunFacts();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              const Color(0xFF166534),
          content: Text(
            funFactId == null
                ? 'Fun Fact berhasil ditambahkan.'
                : 'Fun Fact berhasil diperbarui.',
          ),
        ),
      );
  }

}



class _FunFactFormDialog
    extends StatefulWidget {
  const _FunFactFormDialog({
    required this.funFactId,
    required this.initialText,
    required this.controller,
  });

  final int? funFactId;
  final String initialText;
  final AdminLearningController controller;

  @override
  State<_FunFactFormDialog> createState() =>
      _FunFactFormDialogState();
}

class _FunFactFormDialogState
    extends State<_FunFactFormDialog> {
  late final TextEditingController
      _textController;
  String? _validationMessage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(
      text: widget.initialText,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String value =
        _textController.text.trim();

    if (value.isEmpty) {
      setState(() {
        _validationMessage =
            'Isi Fun Fact wajib diisi.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _validationMessage = null;
    });

    final bool success =
        await widget.controller.saveFunFact(
      funFactId: widget.funFactId,
      factText: value,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: AlertDialog(
        title: Text(
          widget.funFactId == null
              ? 'Tambah Fun Fact'
              : 'Edit Fun Fact',
        ),
        content: SizedBox(
          width: 480,
          child: TextField(
            controller: _textController,
            autofocus: true,
            minLines: 4,
            maxLines: 8,
            textCapitalization:
                TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Isi Fun Fact',
              hintText:
                  'Contoh: Madu dapat bertahan sangat lama karena kadar airnya rendah.',
              alignLabelWithHint: true,
              errorText: _validationMessage,
              border:
                  const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_validationMessage != null) {
                setState(() {
                  _validationMessage = null;
                });
              }
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _submitting
                ? null
                : () =>
                    Navigator.of(context)
                        .pop(false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed:
                _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
            ),
            icon: _submitting
                ? const SizedBox(
                    width: 17,
                    height: 17,
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
              _submitting
                  ? 'Menyimpan...'
                  : 'Simpan',
            ),
          ),
        ],
      ),
    );
  }
}

class _FunFactHeader
    extends StatelessWidget {
  const _FunFactHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFFF59E0B),
            Color(0xFFF97316),
          ],
        ),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.lightbulb_rounded,
            color: Colors.white,
            size: 34,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Fun Fact Sains',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Kelola fakta singkat yang ditampilkan kepada siswa. Data yang sudah ada akan muncul otomatis.',
                  style: TextStyle(
                    color: Color(0xFFFFF7ED),
                    fontSize: 12,
                    height: 1.45,
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

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.searchController,
    required this.controller,
  });

  final TextEditingController
      searchController;
  final AdminLearningController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      onChanged:
          controller.updateFunFactSearch,
      decoration: InputDecoration(
        hintText: 'Cari Fun Fact...',
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon:
            controller
                    .funFactSearchQuery
                    .value
                    .isEmpty
                ? null
                : IconButton(
                    tooltip:
                        'Hapus pencarian',
                    onPressed: () {
                      searchController.clear();
                      controller
                          .clearFunFactSearch();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: _primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.total,
    required this.displayed,
  });

  final int total;
  final int displayed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.auto_awesome_rounded,
            color: _primary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              displayed == total
                  ? '$total Fun Fact tersimpan'
                  : '$displayed dari $total Fun Fact ditampilkan',
              style: const TextStyle(
                color: _text,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FunFactCard extends StatelessWidget {
  const _FunFactCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final String createdAt =
        (item['created_at'] ?? '')
            .toString()
            .trim();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFFFF4D8,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  (item['fact_text'] ?? '')
                      .toString(),
                  style: const TextStyle(
                    color: _text,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (createdAt.isNotEmpty) ...<Widget>[
            const SizedBox(height: 11),
            Text(
              'Dibuat: $createdAt',
              style: const TextStyle(
                color: _muted,
                fontSize: 10,
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                  ),
                  label:
                      const Text('Edit'),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        _danger,
                    side: const BorderSide(
                      color: Color(
                        0xFFFECACA,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                  ),
                  label:
                      const Text('Hapus'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingState
    extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const FunFactListShimmer();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: _muted,
            size: 42,
          ),
          const SizedBox(height: 11),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
