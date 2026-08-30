import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/app_snackbar.dart';
import '../../../widgets/science_shimmer.dart';
import '../controllers/admin_learning_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _amberPrimary = Color(0xFFF59E0B);
const Color _amberVibrant = Color(0xFFFB923C);
const Color _amberBg = Color(0xFFFFFBEB);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _danger = Color(0xFFEF4444);

class AdminFunFactView extends StatefulWidget {
  const AdminFunFactView({super.key});

  @override
  State<AdminFunFactView> createState() => _AdminFunFactViewState();
}

class _AdminFunFactViewState extends State<AdminFunFactView> {
  final TextEditingController _searchController = TextEditingController();

  AdminLearningController get controller =>
      Get.find<AdminLearningController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          'Kelola Fakta Sains',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 17.5,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang data',
            onPressed: controller.loadFunFacts,
            icon: const Icon(
              Icons.refresh_rounded,
              color: _textDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFunFactForm(),
        backgroundColor: _amberPrimary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Tambah Fakta',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _amberPrimary,
        backgroundColor: Colors.white,
        onRefresh: controller.loadFunFacts,
        child: Obx(() {
          final List<Map<String, dynamic>> results =
              controller.filteredFunFacts;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              // 1. Hero Header (Cerah & Hangat)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: _FunFactHeader(),
                ),
              ),

              // 2. Search Box
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: _SearchBox(
                    searchController: _searchController,
                    controller: controller,
                  ),
                ),
              ),

              // 3. Counter Chip Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                  child: _CountCard(
                    total: controller.funFacts.length,
                    displayed: results.length,
                  ),
                ),
              ),

              // 4. Content List / States
              if (controller.isLoadingFunFacts.value &&
                  controller.funFacts.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: _LoadingState(),
                  ),
                )
              else if (controller.funFacts.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: _EmptyState(
                      message:
                          'Belum ada fakta sains yang tersimpan. Ketuk tombol Tambah Fakta untuk membuat data pertama.',
                    ),
                  ),
                )
              else if (results.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: _EmptyState(
                      message:
                          'Fakta sains tidak ditemukan dengan kata kunci tersebut. Coba cari kata kunci lain.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 110),
                  sliver: SliverList.separated(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return _FunFactCard(
                        item: item,
                        onEdit: () => _openFunFactForm(funFact: item),
                        onDelete: () => _confirmDelete(item),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: _danger,
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Hapus Fakta Sains?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Fakta sains yang dihapus tidak dapat dipulihkan kembali.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: _textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textDark,
                        side: const BorderSide(color: _border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Ya, Hapus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await controller.deleteFunFact(item);
    }
  }

  Future<void> _openFunFactForm({Map<String, dynamic>? funFact}) async {
    final int? funFactId = funFact == null
        ? null
        : AdminLearningController.intValue(funFact['id']);

    final bool? saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _FunFactFormDialog(
          funFactId: funFactId,
          initialText: (funFact?['fact_text'] ?? '').toString(),
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

    AppSnackbar.success(
      funFactId == null ? 'Fakta Sains Ditambahkan' : 'Fakta Sains Diperbarui',
      funFactId == null
          ? 'Fakta sains baru berhasil ditambahkan.'
          : 'Perubahan fakta sains berhasil disimpan.',
    );
  }
}

// =============================================================================
// 1. HERO HEADER (BRIGHT & VIBRANT AMBER GOLD)
// =============================================================================
class _FunFactHeader extends StatelessWidget {
  const _FunFactHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _amberPrimary,
            _amberVibrant,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _amberPrimary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fakta Sains & Wawasan Edukatif',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Kelola kumpulan fakta sains menarik yang akan ditampilkan kepada siswa sebagai wawasan inspiratif saat belajar.',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 11.5,
                    height: 1.4,
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

// =============================================================================
// 2. SEARCH BOX
// =============================================================================
class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.searchController,
    required this.controller,
  });

  final TextEditingController searchController;
  final AdminLearningController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: controller.updateFunFactSearch,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: _textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Cari fakta sains...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: _textMuted.withValues(alpha: 0.7),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _amberPrimary,
            size: 20,
          ),
          suffixIcon: controller.funFactSearchQuery.value.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    searchController.clear();
                    controller.clearFunFactSearch();
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _textMuted,
                    size: 18,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 3. COUNTER CARD
// =============================================================================
class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.total,
    required this.displayed,
  });

  final int total;
  final int displayed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.menu_book_rounded, size: 15, color: _textMuted),
            const SizedBox(width: 6),
            Text(
              displayed == total
                  ? 'Total $total Fakta Sains'
                  : 'Menampilkan $displayed dari $total Fakta',
              style: GoogleFonts.poppins(
                color: _textDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            color: _amberBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: const Text(
            'Inspirasi Sains',
            style: TextStyle(
              color: Color(0xFFD97706),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 4. FUN FACT CARD
// =============================================================================
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
    final String text = (item['fact_text'] ?? '').toString().trim();
    final String createdAt = (item['created_at'] ?? '').toString().trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _amberBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: _amberPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Metadata & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (createdAt.isNotEmpty)
                Text(
                  createdAt,
                  style: GoogleFonts.plusJakartaSans(
                    color: _textMuted,
                    fontSize: 10.5,
                  ),
                )
              else
                const SizedBox.shrink(),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _textDark,
                      side: const BorderSide(color: _border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 14, color: _danger),
                    label: Text(
                      'Hapus',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _danger,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _danger,
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 5. FORM DIALOG (MODERN & ACCESSIBLE)
// =============================================================================
class _FunFactFormDialog extends StatefulWidget {
  const _FunFactFormDialog({
    required this.funFactId,
    required this.initialText,
    required this.controller,
  });

  final int? funFactId;
  final String initialText;
  final AdminLearningController controller;

  @override
  State<_FunFactFormDialog> createState() => _FunFactFormDialogState();
}

class _FunFactFormDialogState extends State<_FunFactFormDialog> {
  late final TextEditingController _textController;
  String? _validationMessage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String value = _textController.text.trim();

    if (value.isEmpty) {
      setState(() {
        _validationMessage = 'Isi fakta sains tidak boleh kosong.';
      });
      AppSnackbar.warning(
        'Form Belum Lengkap',
        'Isi teks fakta sains tidak boleh kosong.',
      );
      return;
    }

    setState(() {
      _submitting = true;
      _validationMessage = null;
    });

    final bool success = await widget.controller.saveFunFact(
      funFactId: widget.funFactId,
      factText: value,
    );

    if (!mounted) return;

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
    final bool isEdit = widget.funFactId != null;

    return PopScope(
      canPop: !_submitting,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _amberBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_note_rounded : Icons.add_box_rounded,
                      color: _amberPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Edit Fakta Sains' : 'Tambah Fakta Sains',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Isi Fakta Sains',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _textController,
                autofocus: true,
                minLines: 4,
                maxLines: 7,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: _textDark,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Contoh: Air panas dapat membeku lebih cepat daripada air dingin dalam kondisi tertentu (Efek Mpemba).',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: _textMuted.withValues(alpha: 0.7),
                  ),
                  errorText: _validationMessage,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: _amberPrimary, width: 1.5),
                  ),
                ),
                onChanged: (_) {
                  if (_validationMessage != null) {
                    setState(() {
                      _validationMessage = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _textDark,
                      side: const BorderSide(color: _border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _amberPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      _submitting ? 'Menyimpan...' : 'Simpan Data',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
}

// =============================================================================
// 6. LOADING & EMPTY STATES
// =============================================================================
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const FunFactListShimmer();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: _textMuted,
            size: 38,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: _textMuted,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
