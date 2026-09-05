import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_service.dart';

// Enum untuk mengatur fase animasi gacha secara presisi
enum GachaState { idle, shaking, dropping, opening, result }

class GachaController extends GetxController {
  // Data Resource User
  var gachaTickets = 0.obs;
  var shards = 0.obs;

  // Data Koleksi Kartu
  var isLoading = false.obs;
  var allMasterCards = <Map<String, dynamic>>[].obs;
  var ownedCardIds = <String>{}.obs;

  // State Animasi & Hasil Gacha
  var currentState = GachaState.idle.obs;
  var pulledCard = <String, dynamic>{}.obs;
  var isDuplicate = false.obs;
  var earnedShards = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadGachaData();
  }

  // 1. LOAD DATA DARI BACKEND & FALLBACK
  Future<void> loadGachaData() async {
    isLoading.value = true;

    try {
      // Synchronize User Gamification Stats (Tickets & Shards)
      final userData = await ApiService.getUserData();
      if (userData != null) {
        if (userData['gacha_tickets'] != null) {
          gachaTickets.value =
              int.tryParse(userData['gacha_tickets'].toString()) ?? 0;
        }
        if (userData['shards'] != null) {
          shards.value = int.tryParse(userData['shards'].toString()) ?? 0;
        }
      }

      // Fetch Gacha Overview from API
      final overview = await ApiService.getGachaOverview();
      if (overview != null && overview['master_cards'] != null) {
        if (overview['gacha_tickets'] != null) {
          gachaTickets.value =
              int.tryParse(overview['gacha_tickets'].toString()) ??
                  gachaTickets.value;
        }
        if (overview['shards'] != null) {
          shards.value =
              int.tryParse(overview['shards'].toString()) ?? shards.value;
        }

        final List<dynamic> rawCards =
            overview['master_cards'] as List<dynamic>? ?? <dynamic>[];
        allMasterCards.value =
            rawCards.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        final List<dynamic> rawOwned =
            overview['owned_card_ids'] as List<dynamic>? ?? <dynamic>[];
        ownedCardIds.assignAll(rawOwned.map((e) => e.toString()));
      } else {
        // Fallback Master Cards & Default Owned Cards (jika backend route belum siap)
        _loadFallbackData();
      }
    } catch (e) {
      debugPrint('[GachaController] Error loading gacha data: $e');
      _loadFallbackData();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadFallbackData() {
    allMasterCards.value = <Map<String, dynamic>>[
      {
        'id': 'card_001',
        'set_name': 'Eksplorasi Awal',
        'name': 'Robert Hooke',
        'rarity': 'Common',
        'image_url': 'assets/images/robert_hooke.png',
        'craft_cost': 100,
        'description':
            'Penemu sel pertama kali menggunakan mikroskop sederhana pada tahun 1665.',
      },
      {
        'id': 'card_002',
        'set_name': 'Eksplorasi Awal',
        'name': 'Hukum Gravitasi',
        'rarity': 'Rare',
        'image_url':
            'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&auto=format&fit=crop',
        'craft_cost': 250,
        'description':
            'Sir Isaac Newton merumuskan hukum gaya tarik bumi yang mengatur gerak planet.',
      },
      {
        'id': 'card_003',
        'set_name': 'Eksplorasi Awal',
        'name': 'Termometer Gas',
        'rarity': 'Epic',
        'image_url':
            'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=600&auto=format&fit=crop',
        'craft_cost': 500,
        'description':
            'Alat pengukur suhu berbasis ekspansi volume gas dengan presisi tinggi.',
      },
      {
        'id': 'card_004',
        'set_name': 'Eksplorasi Awal',
        'name': 'Prinsip Lensa',
        'rarity': 'Epic',
        'image_url':
            'https://images.unsplash.com/photo-1516339901601-2e1b62dc0c45?w=600&auto=format&fit=crop',
        'craft_cost': 500,
        'description':
            'Prinsip pembiasan cahaya pada lensa cembung dan cekung.',
      },
      {
        'id': 'card_005',
        'set_name': 'Eksplorasi Awal',
        'name': 'Teori Sel Awal',
        'rarity': 'Legendary',
        'image_url':
            'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=600&auto=format&fit=crop',
        'craft_cost': 1000,
        'description':
            'Fondasi biologis bahwa semua organisme hidup terdiri dari unit selular.',
      },
      {
        'id': 'card_006',
        'set_name': 'Pionir Biologi',
        'name': 'Gregor Mendel',
        'rarity': 'Common',
        'image_url':
            'https://images.unsplash.com/photo-1530210124550-912dc1381cb8?w=600&auto=format&fit=crop',
        'craft_cost': 100,
        'description':
            'Bapak genetika modern yang menemukan pola pewarisan sifat.',
      },
      {
        'id': 'card_007',
        'set_name': 'Pionir Biologi',
        'name': 'Struktur DNA',
        'rarity': 'Epic',
        'image_url':
            'https://images.unsplash.com/photo-1507413245164-6160d8298b31?w=600&auto=format&fit=crop',
        'craft_cost': 500,
        'description':
            'Model heliks ganda pembawa informasi genetik makhluk hidup.',
      },
      {
        'id': 'card_008',
        'set_name': 'Kosmos & Fisika',
        'name': 'Albert Einstein',
        'rarity': 'Legendary',
        'image_url':
            'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=600&auto=format&fit=crop',
        'craft_cost': 1000,
        'description':
            'Fisikawan jenius penemu Teori Relativitas E=mc².',
      },
    ];

    if (ownedCardIds.isEmpty) {
      ownedCardIds.add('card_001');
    }
  }

  // GETTER THEMATIC SETS UNTUK TAB GALERI
  List<Map<String, dynamic>> get thematicSets {
    final Map<String, List<Map<String, dynamic>>> grouped =
        <String, List<Map<String, dynamic>>>{};
    for (final card in allMasterCards) {
      final setName = (card['set_name'] ?? 'Lainnya').toString();
      grouped.putIfAbsent(setName, () => <Map<String, dynamic>>[]).add(card);
    }

    final List<Map<String, dynamic>> sets = <Map<String, dynamic>>[];
    int setIdx = 0;

    grouped.forEach((setName, cards) {
      setIdx++;
      final int collected = cards
          .where((c) => ownedCardIds.contains(c['id'].toString()))
          .length;
      final int total = cards.length;

      List<Color> gradient;
      switch (setIdx % 3) {
        case 1:
          gradient = const <Color>[Color(0xFF2563EB), Color(0xFF1E3A8A)];
          break;
        case 2:
          gradient = const <Color>[Color(0xFF059669), Color(0xFF047857)];
          break;
        case 0:
        default:
          gradient = const <Color>[Color(0xFF7C3AED), Color(0xFF5B21B6)];
          break;
      }

      sets.add(<String, dynamic>{
        'id': 'set_$setIdx',
        'title': setName,
        'desc': 'Koleksi kartu tema $setName',
        'collected': collected,
        'total': total,
        'isUnlocked': true,
        'unlockRequirement': 'Tersedia',
        'gradient': gradient,
        'cards': cards.map((c) {
          final String cardId = c['id'].toString();
          return <String, dynamic>{
            ...c,
            'isOwned': ownedCardIds.contains(cardId),
          };
        }).toList(),
      });
    });

    return sets;
  }

  // 2. ALUR ANIMASI PULL GACHA & SINKRONISASI BACKEND
  Future<void> pullGacha() async {
    if (currentState.value != GachaState.idle) return;

    if (gachaTickets.value <= 0) {
      Get.snackbar(
        'Tiket Habis',
        'Kumpulkan tiket gacha dari modul pembelajaran atau misi harian!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Tiket dikurangi lokal secara instan untuk responsivitas UI
    gachaTickets.value -= 1;

    // FASE 1: Mesin bergetar
    currentState.value = GachaState.shaking;

    // Panggil API Backend di belakang layar saat animasi berjalan
    Map<String, dynamic>? apiResult;
    try {
      apiResult = await ApiService.pullGachaApi();
    } catch (e) {
      debugPrint('[GachaController] Error pullGachaApi: $e');
    }

    await Future.delayed(const Duration(milliseconds: 1200));

    // FASE 2: Kapsul jatuh
    currentState.value = GachaState.dropping;
    await Future.delayed(const Duration(milliseconds: 800));

    // FASE 3: Kapsul terbuka & Kalkulasi Kartu
    currentState.value = GachaState.opening;

    if (apiResult != null && apiResult['card'] != null) {
      final cardData = Map<String, dynamic>.from(apiResult['card'] as Map);
      pulledCard.value = cardData;

      isDuplicate.value = apiResult['is_duplicate'] == true;
      earnedShards.value =
          int.tryParse(apiResult['earned_shards']?.toString() ?? '0') ?? 0;

      if (apiResult['gacha_tickets'] != null) {
        gachaTickets.value =
            int.tryParse(apiResult['gacha_tickets'].toString()) ??
                gachaTickets.value;
      }
      if (apiResult['shards'] != null) {
        shards.value =
            int.tryParse(apiResult['shards'].toString()) ?? shards.value;
      }

      final String cardId = cardData['id'].toString();
      if (!isDuplicate.value) {
        ownedCardIds.add(cardId);
      }
    } else {
      // Fallback RNG Lokal jika endpoint API backend belum siap
      if (allMasterCards.isEmpty) _loadFallbackData();

      final randomCard = allMasterCards[
          DateTime.now().microsecondsSinceEpoch % allMasterCards.length];
      pulledCard.value = randomCard;
      final cardId = randomCard['id'].toString();

      isDuplicate.value = ownedCardIds.contains(cardId);
      if (isDuplicate.value) {
        earnedShards.value = _calculateShards(randomCard['rarity'].toString());
        shards.value += earnedShards.value;
      } else {
        earnedShards.value = 0;
        ownedCardIds.add(cardId);
      }
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    // FASE 4: Popup Hasil
    currentState.value = GachaState.result;
  }

  void resetGachaMachine() {
    currentState.value = GachaState.idle;
    pulledCard.clear();
  }

  // 3. SISTEM CRAFTING (PITY SYSTEM) WITH BACKEND SYNC
  Future<void> craftCard(Map<String, dynamic> card) async {
    final cardId = card['id'].toString();
    final cost = int.tryParse(card['craft_cost']?.toString() ?? '100') ?? 100;
    final cardName = (card['name'] ?? 'Kartu').toString();

    if (ownedCardIds.contains(cardId)) {
      Get.snackbar(
        'Sudah Dimiliki',
        'Kartu $cardName sudah ada di galerimu.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (shards.value < cost) {
      Get.snackbar(
        'Shards Kurang 💎',
        'Butuh $cost Shards untuk merakit $cardName.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Panggil API Backend
    final apiResult = await ApiService.craftGachaCard(cardId);

    if (apiResult != null && apiResult['success'] == true) {
      if (apiResult['shards'] != null) {
        shards.value =
            int.tryParse(apiResult['shards'].toString()) ?? (shards.value - cost);
      } else {
        shards.value -= cost;
      }
      ownedCardIds.add(cardId);
    } else {
      // Fallback lokal jika endpoint server belum tersedia
      shards.value -= cost;
      ownedCardIds.add(cardId);
    }

    Get.snackbar(
      'Crafting Berhasil! ✨',
      'Kartu $cardName berhasil dirakit & ditambahkan ke koleksi!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  int _calculateShards(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return 100;
      case 'epic':
        return 50;
      case 'rare':
        return 25;
      case 'common':
      default:
        return 10;
    }
  }
}