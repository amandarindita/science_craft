import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/gacha_controller.dart';


const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _purple = Color(0xFF7C3AED);
const Color _textDark = Color(0xFF0F172A);
const Color _textMuted = Color(0xFF64748B);
const Color _success = Color(0xFF10B981);
const Color _warning = Color(0xFFF59E0B);
const Color _border = Color(0xFFE2E8F0);

class GachaView extends GetView<GachaController> {
  const GachaView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: _textDark,
          centerTitle: true,
          title: Text(
            'Laboratorium Gacha',
            style: GoogleFonts.poppins(
              color: _textDark,
              fontWeight: FontWeight.w700,
              fontSize: 17.5,
              letterSpacing: -0.2,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x140F172A),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: _primaryBlue,
                  unselectedLabelColor: _textMuted,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  tabs: const <Widget>[
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.card_giftcard_rounded, size: 15),
                          SizedBox(width: 5),
                          Text('Gacha'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.collections_bookmark_rounded, size: 15),
                          SizedBox(width: 5),
                          Text('Galeri'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.diamond_rounded, size: 15),
                          SizedBox(width: 5),
                          Text('Crafting'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryBlue),
            );
          }

          return TabBarView(
            children: <Widget>[
              _buildPullTab(controller),
              _buildGalleryTab(controller),
              _buildCraftingTab(controller),
            ],
          );
        }),
      ),
    );
  }
// ===========================================================================
  // TAB 1: AREA MESIN GACHA & ANIMASI (PULL TAB)
  // ===========================================================================
  Widget _buildPullTab(GachaController controller) {
    return Column(
      children: <Widget>[
        // Header Info Saldo
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _HeaderChip(
                icon: Icons.local_activity_rounded,
                color: const Color(0xFFEC4899),
                value: '${controller.gachaTickets.value}',
                label: 'Tiket',
              ),
              _HeaderChip(
                icon: Icons.diamond_rounded,
                color: const Color(0xFF06B6D4),
                value: '${controller.shards.value}',
                label: 'Shards',
              ),
            ],
          ),
        ),

        // Area Utama Animasi Mesin Gacha
        Expanded(
          child: Obx(() {
            final GachaState state = controller.currentState.value;

            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // 1. VISUAL MESIN GACHA (Berubah berdasarkan State)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildMachineVisual(state),
                ),

                // 2. TOMBOL TARIK (Hanya muncul saat Idle)
                if (state == GachaState.idle)
                  Positioned(
                    bottom: 40,
                    child: ElevatedButton.icon(
                      onPressed: controller.pullGacha,
                      icon: const Icon(Icons.touch_app_rounded, size: 22),
                      label: Text(
                        'Tarik (1 Tiket)',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                      ),
                    ),
                  ),

                // 3. POPUP HASIL KARTU (Muncul saat State Result)
                if (state == GachaState.result)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.8), // Overlay gelap
                      child: Center(
                        child: _buildResultCard(controller),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  // Visual Placeholder untuk setiap Fase Animasi
  Widget _buildMachineVisual(GachaState state) {
    switch (state) {
      case GachaState.shaking:
        return Column(
          key: const ValueKey('shaking'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.vibration_rounded, size: 120, color: Color(0xFFF59E0B)),
            SizedBox(height: 16),
            Text('Mesin Mengaduk...', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        );
      case GachaState.dropping:
        return Column(
          key: const ValueKey('dropping'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.catching_pokemon_rounded, size: 100, color: Color(0xFF10B981)), // Icon Bola Jatuh
            SizedBox(height: 16),
            Text('Kapsul Keluar!', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        );
      case GachaState.opening:
        return Column(
          key: const ValueKey('opening'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.flare_rounded, size: 140, color: Color(0xFF8B5CF6)), // Icon Cahaya Membuka
            SizedBox(height: 16),
            Text('Membuka Kapsul...', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        );
      case GachaState.result:
        return const SizedBox.shrink(); // Disembunyikan karena ditimpa overlay hasil
      case GachaState.idle:
      default:
        return Column(
          key: const ValueKey('idle'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.casino_rounded, size: 160, color: Color(0xFF334155)), // Icon Mesin Gacha Standby
            SizedBox(height: 20),
            Text('Mesin Siap', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        );
    }
  }

  // Tampilan Kartu Hasil Tarikan
  Widget _buildResultCard(GachaController controller) {
    final card = controller.pulledCard;
    final bool isDup = controller.isDuplicate.value;
    final int shards = controller.earnedShards.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label Duplikat
        if (isDup)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '♻️ Duplikat! +$shards Shards',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        else
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '✨ PENEMUAN BARU! ✨',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

        // Desain Kartu Fisik
        Container(
          width: 220,
          height: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 4),
            boxShadow: [
              BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 10),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: const Center(
                    child: Icon(Icons.science_rounded, size: 80, color: Color(0xFF64748B)),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card['name'] ?? 'Unknown',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card['rarity'] ?? 'Common',
                        style: GoogleFonts.plusJakartaSans(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
        
        // Tombol Tutup & Reset
        ElevatedButton(
          onPressed: controller.resetGachaMachine,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('Kumpulkan'),
        ),
      ],
    );
  }// ===========================================================================
  // TAB 2: GALERI KOLEKSI (GRID SET TEMATIK YANG ELEGAN)
  // ===========================================================================
  Widget _buildGalleryTab(GachaController controller) {
    final List<Map<String, dynamic>> thematicSets = [
      {
        'id': 'set_1',
        'title': 'Eksplorasi Awal',
        'desc': 'Fisika dasar & hukum alam',
        'collected': 3,
        'total': 5,
        'isUnlocked': true,
        'gradient': const <Color>[Color(0xFF2563EB), Color(0xFF1E3A8A)],
        'cards': [
          {'name': 'Robert Hooke', 'rarity': 'Common', 'isOwned': true},
          {'name': 'Hukum Gravitasi', 'rarity': 'Common', 'isOwned': true},
          {'name': 'Termometer Gas', 'rarity': 'Rare', 'isOwned': true},
          {'name': 'Prinsip Lensa', 'rarity': 'Epic', 'isOwned': false},
          {'name': 'Teori Sel Awal', 'rarity': 'Legendary', 'isOwned': false},
        ],
      },
      {
        'id': 'set_2',
        'title': 'Pionir Biologi',
        'desc': 'Misteri sel & genetika',
        'collected': 0,
        'total': 4,
        'isUnlocked': false,
        'unlockRequirement': 'Level 3',
        'gradient': const <Color>[Color(0xFF059669), Color(0xFF047857)],
        'cards': [],
      },
      {
        'id': 'set_3',
        'title': 'Kosmos & Fisika',
        'desc': 'Galaksi & lubang hitam',
        'collected': 0,
        'total': 6,
        'isUnlocked': false,
        'unlockRequirement': '10 Modul',
        'gradient': const <Color>[Color(0xFF7C3AED), Color(0xFF5B21B6)],
        'cards': [],
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Bentuk grid 2 kolom ke samping
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85, // Proporsi kartu set yang pas dan compact
      ),
      itemCount: thematicSets.length,
      itemBuilder: (BuildContext context, int index) {
        final setItem = thematicSets[index];
        final bool isUnlocked = setItem['isUnlocked'] as bool;
        final int collected = setItem['collected'] as int;
        final int total = setItem['total'] as int;
        final double progress = total > 0 ? collected / total : 0.0;
        final List<Color> gradientColors = setItem['gradient'] as List<Color>;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: isUnlocked 
                    ? gradientColors.first.withValues(alpha: 0.2) 
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Material(
              color: isUnlocked ? Colors.white : const Color(0xFFF1F5F9),
              child: InkWell(
                onTap: () {
                  if (isUnlocked) {
                    _showSetDetailModal(context, setItem);
                  } else {
                    Get.snackbar(
                      'Set Masih Terkunci 🔒',
                      'Syarat: ${setItem['unlockRequirement']}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: _darkNavy,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isUnlocked ? _border : const Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isUnlocked ? gradientColors : <Color>[Colors.grey[400]!, Colors.grey[600]!],
                              ),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              isUnlocked ? Icons.auto_awesome_rounded : Icons.lock_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isUnlocked ? _primaryBlue.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isUnlocked ? '$collected/$total' : 'Terkunci',
                              style: GoogleFonts.poppins(
                                color: isUnlocked ? _primaryBlue : _textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            setItem['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: isUnlocked ? _textDark : _textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isUnlocked ? setItem['desc'] as String : 'Syarat: ${setItem['unlockRequirement']}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: _textMuted,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: isUnlocked ? progress : 0.0,
                          minHeight: 5,
                          color: gradientColors.first,
                          backgroundColor: const Color(0xFFF1F5F9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MODAL DETAIL KARTU DI DALAM SET (KETIKA SET DIKLIK)
  // ===========================================================================
  void _showSetDetailModal(BuildContext context, Map<String, dynamic> setItem) {
    final List cards = setItem['cards'] as List;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              setItem['title'] as String,
              style: GoogleFonts.poppins(
                color: _textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Daftar kartu penemuan dalam set tematik ini.',
              style: GoogleFonts.plusJakartaSans(
                color: _textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: cards.length,
                itemBuilder: (BuildContext context, int index) {
                  final card = cards[index];
                  final bool isOwned = card['isOwned'] as bool;
                  final String name = card['name'] as String;
                  final String rarity = card['rarity'] as String;

                  return Container(
                    decoration: BoxDecoration(
                      color: isOwned ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isOwned ? _border : Colors.transparent,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                Center(
                                  child: Icon(
                                    isOwned ? Icons.science_rounded : Icons.lock_rounded,
                                    color: isOwned ? _primaryBlue : Colors.white54,
                                    size: 32,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      rarity,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              color: isOwned ? Colors.white : const Color(0xFF0F172A),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    isOwned ? name : 'Kartu Rahasia',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: isOwned ? _textDark : Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isOwned ? 'Milik Sendiri' : 'Terkunci (??? পারা)',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isOwned ? _success : Colors.white54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
  // ===========================================================================
  // TAB 3: CRAFTING & SHARDS PITY SYSTEM
  // ===========================================================================
  Widget _buildCraftingTab(GachaController controller) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        // Banner Info Saldo Shards & Pity System
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF581C87), Color(0xFF7C3AED), Color(0xFF9333EA)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.diamond_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Laboratorium Crafting',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tukar serpihan (shards) duplikat untuk klaim kartu incaranmu tanpa gacha.',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFF3E8FF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Subtitle Daftar Kartu yang Bisa Ditebus
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Katalog Penukaran Shards',
              style: GoogleFonts.poppins(
                color: _textDark,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            Obx(() => Text(
                  'Saldo: ${controller.shards.value} Shards',
                  style: GoogleFonts.poppins(
                    color: _purple,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                )),
          ],
        ),
        const SizedBox(height: 12),

        // List Katalog Kartu Master dari Database untuk Dicraft
        Obx(() {
          if (controller.allMasterCards.isEmpty) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('Memuat katalog kartu...'),
            ));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.allMasterCards.length,
            itemBuilder: (BuildContext context, int index) {
              final card = controller.allMasterCards[index];
              final String cardId = card['id'].toString();
              final bool isOwned = controller.ownedCardIds.contains(cardId);
              const int craftCost = 100; // Biaya shards per kartu

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.science_rounded, color: _purple, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            card['name'] as String,
                            style: GoogleFonts.poppins(
                              color: _textDark,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Set: ${card['set_name']} • ${card['rarity']}',
                            style: GoogleFonts.plusJakartaSans(
                              color: _textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    isOwned
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Dimiliki',
                              style: GoogleFonts.poppins(
                                color: _success,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () => controller.craftCard(card),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _purple,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Tukar ($craftCost)',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}