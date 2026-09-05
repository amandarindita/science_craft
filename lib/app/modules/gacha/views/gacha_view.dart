import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/api_service.dart';
import '../controllers/gacha_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _purple = Color(0xFF7C3AED);
const Color _textDark = Color(0xFF0F172A);
const Color _textMuted = Color(0xFF64748B);
const Color _success = Color(0xFF10B981);
const Color _border = Color(0xFFE2E8F0);

class GachaView extends GetView<GachaController> {
  const GachaView({super.key});

  Widget _buildCardImage(
    Map<String, dynamic> card, {
    double iconSize = 40,
    Color? iconColor,
  }) {
    final String? rawImg = card['image_url']?.toString() ??
        card['image']?.toString() ??
        card['image_path']?.toString() ??
        card['imageUrl']?.toString() ??
        card['avatar']?.toString();

    if (rawImg != null && rawImg.trim().isNotEmpty) {
      final String clean = rawImg.trim();
      if (clean.startsWith('assets/')) {
        return Image.asset(
          clean,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              Icons.science_rounded,
              size: iconSize,
              color: iconColor ?? Colors.white,
            ),
          ),
        );
      }

      final String? mediaUrl = ApiService.resolveMediaUrl(clean);
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        return Image.network(
          mediaUrl,
          fit: BoxFit.cover,
          headers: const <String, String>{
            'ngrok-skip-browser-warning': 'true',
            'User-Agent': 'ScienceCraftApp',
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: iconColor ?? Colors.white,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('[GachaImage] Error loading network image $mediaUrl: $error');
            return Center(
              child: Icon(
                Icons.science_rounded,
                size: iconSize,
                color: iconColor ?? Colors.white,
              ),
            );
          },
        );
      }
    }

    return Center(
      child: Icon(
        Icons.science_rounded,
        size: iconSize,
        color: iconColor ?? Colors.white,
      ),
    );
  }

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
                        children: <Widget>[
                          Icon(Icons.card_giftcard_rounded, size: 15),
                          SizedBox(width: 5),
                          Text('Gacha'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.collections_bookmark_rounded, size: 15),
                          SizedBox(width: 5),
                          Text('Galeri'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
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
              Obx(() => _HeaderChip(
                    icon: Icons.local_activity_rounded,
                    color: const Color(0xFFEC4899),
                    value: '${controller.gachaTickets.value}',
                    label: 'Tiket Gacha',
                  )),
              Obx(() => _HeaderChip(
                    icon: Icons.diamond_rounded,
                    color: const Color(0xFF06B6D4),
                    value: '${controller.shards.value}',
                    label: 'Shards',
                  )),
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
                // Visual Mesin Animasi Dinamis
                _AnimatedGachaMachine(state: state),

                // Tombol Tarik (Muncul saat Idle)
                if (state == GachaState.idle)
                  Positioned(
                    bottom: 30,
                    child: ElevatedButton.icon(
                      onPressed: controller.pullGacha,
                      icon: const Icon(Icons.touch_app_rounded, size: 22),
                      label: Text(
                        'Tarik Gacha (1 Tiket)',
                        style: GoogleFonts.poppins(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        shadowColor: _primaryBlue.withValues(alpha: 0.5),
                      ),
                    ),
                  ),

                // Popup Hasil Kartu (Muncul saat State Result)
                if (state == GachaState.result)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.82),
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: _buildResultCard(controller),
                        ),
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

  // Tampilan Kartu Hasil Tarikan
  Widget _buildResultCard(GachaController controller) {
    final card = controller.pulledCard;
    final bool isDup = controller.isDuplicate.value;
    final int shards = controller.earnedShards.value;
    final String rarity = (card['rarity'] ?? 'Common').toString();
    final String name = (card['name'] ?? 'Kartu Sains').toString();
    final String desc =
        (card['description'] ?? 'Penemuan ilmu pengetahuan yang menakjubkan.')
            .toString();

    List<Color> rarityGradient;
    Color rarityBadgeColor;

    switch (rarity.toLowerCase()) {
      case 'legendary':
        rarityGradient = const <Color>[Color(0xFFF59E0B), Color(0xFFD97706)];
        rarityBadgeColor = const Color(0xFFD97706);
        break;
      case 'epic':
        rarityGradient = const <Color>[Color(0xFF8B5CF6), Color(0xFF6D28D9)];
        rarityBadgeColor = const Color(0xFF7C3AED);
        break;
      case 'rare':
        rarityGradient = const <Color>[Color(0xFF06B6D4), Color(0xFF0284C7)];
        rarityBadgeColor = const Color(0xFF0284C7);
        break;
      case 'common':
      default:
        rarityGradient = const <Color>[Color(0xFF10B981), Color(0xFF059669)];
        rarityBadgeColor = const Color(0xFF059669);
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Status Banner (New vs Duplicate)
        if (isDup)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF7C3AED), Color(0xFF5B21B6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              '♻️ Kartu Duplikat! +$shards Shards',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          )
        else
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF10B981), Color(0xFF047857)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              '✨ PENEMUAN BARU! ✨',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),

        // Desain Kartu Fisik
        Container(
          width: 260,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: rarityBadgeColor, width: 3.5),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: rarityBadgeColor.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Visual Gambar Kartu
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: rarityGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: _buildCardImage(card, iconSize: 70),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            rarity.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Detail Informasi Kartu
              Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                desc,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: _textMuted,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Tombol Tutup & Kumpulkan
        ElevatedButton(
          onPressed: controller.resetGachaMachine,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _textDark,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: Text(
            'Kumpulkan Kartu',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: GALERI KOLEKSI (GRID SET TEMATIK DINAMIS)
  // ===========================================================================
  Widget _buildGalleryTab(GachaController controller) {
    final sets = controller.thematicSets;

    if (sets.isEmpty) {
      return Center(
        child: Text(
          'Belum ada set kartu tersedia.',
          style: GoogleFonts.plusJakartaSans(color: _textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: sets.length,
      itemBuilder: (BuildContext context, int index) {
        final setItem = sets[index];
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
                      'Set Terkunci 🔒',
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
                                colors: isUnlocked
                                    ? gradientColors
                                    : <Color>[
                                        Colors.grey[400]!,
                                        Colors.grey[600]!
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              isUnlocked
                                  ? Icons.auto_awesome_rounded
                                  : Icons.lock_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? _primaryBlue.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.2),
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
                            isUnlocked
                                ? setItem['desc'] as String
                                : 'Syarat: ${setItem['unlockRequirement']}',
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

  // Modal Detail Kartu di Dalam Set
  void _showSetDetailModal(
      BuildContext context, Map<String, dynamic> setItem) {
    final List cards = setItem['cards'] as List;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.72,
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
              'Daftar kartu ilmuwan & penemuan dalam set tematik ini.',
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
                  childAspectRatio: 0.75,
                ),
                itemCount: cards.length,
                itemBuilder: (BuildContext context, int index) {
                  final card = Map<String, dynamic>.from(cards[index] as Map);
                  final bool isOwned = card['isOwned'] == true;
                  final String name = (card['name'] ?? 'Unknown').toString();
                  final String rarity = (card['rarity'] ?? 'Common').toString();

                  return Container(
                    decoration: BoxDecoration(
                      color: isOwned
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isOwned ? _border : Colors.transparent,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                if (isOwned)
                                  _buildCardImage(
                                    card,
                                    iconSize: 34,
                                    iconColor: _primaryBlue,
                                  )
                                else
                                  const Center(
                                    child: Icon(
                                      Icons.lock_rounded,
                                      color: Colors.white54,
                                      size: 34,
                                    ),
                                  ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      rarity,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 9,
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
                              color: isOwned
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    isOwned ? name : 'Kartu Rahasia',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color:
                                          isOwned ? _textDark : Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isOwned ? 'Milik Sendiri' : 'Terkunci',
                                    style: GoogleFonts.plusJakartaSans(
                                      color:
                                          isOwned ? _success : Colors.white54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
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
              colors: <Color>[
                Color(0xFF581C87),
                Color(0xFF7C3AED),
                Color(0xFF9333EA)
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: <BoxShadow>[
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
                child: const Icon(
                  Icons.diamond_rounded,
                  color: Colors.white,
                  size: 26,
                ),
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
                      'Tukar serpihan (shards) duplikat untuk merakit kartu incaranmu tanpa gacha.',
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

        // Subtitle & Balance Display
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

        // List Katalog Kartu Master dari Controller untuk Dicraft
        Obx(() {
          if (controller.allMasterCards.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: _purple),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.allMasterCards.length,
            itemBuilder: (BuildContext context, int index) {
              final card = controller.allMasterCards[index];
              final String cardId = card['id'].toString();
              final bool isOwned = controller.ownedCardIds.contains(cardId);
              final int craftCost =
                  int.tryParse(card['craft_cost']?.toString() ?? '100') ?? 100;
              final String name = (card['name'] ?? 'Kartu').toString();
              final String setName =
                  (card['set_name'] ?? 'Umum').toString();
              final String rarity =
                  (card['rarity'] ?? 'Common').toString();

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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildCardImage(
                          card,
                          iconSize: 22,
                          iconColor: _purple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: _textDark,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Set: $setName • $rarity',
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
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

// Widget Animasi Mesin Gacha Dinamis
class _AnimatedGachaMachine extends StatefulWidget {
  final GachaState state;
  const _AnimatedGachaMachine({required this.state});

  @override
  State<_AnimatedGachaMachine> createState() => _AnimatedGachaMachineState();
}

class _AnimatedGachaMachineState extends State<_AnimatedGachaMachine>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _shakeAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedGachaMachine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == GachaState.shaking) {
      _shakeController.repeat(reverse: true);
    } else {
      _shakeController.stop();
      _shakeController.reset();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.state) {
      case GachaState.shaking:
        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _shakeAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.vibration_rounded,
                      size: 90,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Mesin Mengaduk Kapsul...',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case GachaState.dropping:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: -50, end: 0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.bounceOut,
              builder: (context, val, child) {
                return Transform.translate(
                  offset: Offset(0, val),
                  child: child,
                );
              },
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.catching_pokemon_rounded,
                  size: 80,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kapsul Rahasia Keluar!',
              style: GoogleFonts.poppins(
                color: const Color(0xFF059669),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        );

      case GachaState.opening:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.2),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, val, child) {
                return Transform.scale(
                  scale: val,
                  child: child,
                );
              },
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.flare_rounded,
                  size: 90,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Membuka Kapsul Penemuan...',
              style: GoogleFonts.poppins(
                color: const Color(0xFF7C3AED),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        );

      case GachaState.result:
        return const SizedBox.shrink();

      case GachaState.idle:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: _primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _primaryBlue.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.casino_rounded,
                size: 90,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Mesin Gacha Siap',
              style: GoogleFonts.poppins(
                color: _textDark,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gunakan tiketmu untuk menemukan kartu ilmuwan baru!',
              style: GoogleFonts.plusJakartaSans(
                color: _textMuted,
                fontSize: 12,
              ),
            ),
          ],
        );
    }
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