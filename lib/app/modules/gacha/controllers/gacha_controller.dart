import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Enum untuk mengatur fase animasi gacha secara presisi
enum GachaState { idle, shaking, dropping, opening, result }

class GachaController extends GetxController {
  // Data Resource User
  var gachaTickets = 5.obs; // Angka awal untuk testing
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
    _loadDatabaseCards();
  }

  // 1. LOAD 3 KARTU DARI DATABASE BACKEND
  Future<void> _loadDatabaseCards() async {
    isLoading.value = true;
    
    // Simulasi pemanggilan API backend (fetch 3 kartu yang sudah di-upload)
    await Future.delayed(const Duration(milliseconds: 800));

    allMasterCards.value = [
      {
        'id': 'card_001',
        'set_name': 'Eksplorasi Awal',
        'name': 'Robert Hooke',
        'rarity': 'Common',
        'image_url': 'assets/cards/hooke.png', // Ganti dengan URL backend nanti
        'craft_cost': 100
      },
      {
        'id': 'card_002',
        'set_name': 'Eksplorasi Awal',
        'name': 'Hukum Gravitasi',
        'rarity': 'Rare',
        'image_url': 'assets/cards/gravity.png',
        'craft_cost': 250
      },
      {
        'id': 'card_003',
        'set_name': 'Eksplorasi Awal',
        'name': 'Termometer Gas',
        'rarity': 'Epic',
        'image_url': 'assets/cards/thermo.png',
        'craft_cost': 500
      },
    ];

    // Simulasi user baru punya 1 kartu (bisa dikosongkan jika user baru)
    ownedCardIds.add('card_001');
    
    isLoading.value = false;
  }

  // 2. ALUR ANIMASI PULL GACHA & KONVERSI SHARDS
  Future<void> pullGacha() async {
    // Cegah spam klik saat animasi berjalan
    if (currentState.value != GachaState.idle) return;

    if (gachaTickets.value <= 0) {
      Get.snackbar(
        'Tiket Habis',
        'Kumpulkan tiket dari misi harian atau modul!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Tiket dikurangi, mulai sekuens animasi
    gachaTickets.value -= 1;
    
    // FASE 1: Mesin bergetar
    currentState.value = GachaState.shaking;
    await Future.delayed(const Duration(milliseconds: 1200));

    // FASE 2: Bola kapsul jatuh
    currentState.value = GachaState.dropping;
    await Future.delayed(const Duration(milliseconds: 800));

    // FASE 3: Bola terbuka (Kalkulasi kartu acak di balik layar)
    currentState.value = GachaState.opening;
    
    // Tarik acak dari 3 kartu master
    final randomCard = allMasterCards[DateTime.now().millisecond % allMasterCards.length];
    pulledCard.value = randomCard;
    final cardId = randomCard['id'] as String;
    
    // Cek Duplikat & Rarity
    isDuplicate.value = ownedCardIds.contains(cardId);
    if (isDuplicate.value) {
      earnedShards.value = _calculateShards(randomCard['rarity'] as String);
      shards.value += earnedShards.value; // Tambahkan ke dompet
    } else {
      earnedShards.value = 0;
      ownedCardIds.add(cardId); // Tambahkan ke koleksi
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    // FASE 4: Munculkan popup hasil kartu
    currentState.value = GachaState.result;
  }

  // Reset mesin ke posisi awal setelah user menutup popup hasil
  void resetGachaMachine() {
    currentState.value = GachaState.idle;
    pulledCard.clear();
  }

  // 3. SISTEM CRAFTING (PITY SYSTEM)
  void craftCard(Map<String, dynamic> card) {
    final cardId = card['id'] as String;
    final cost = card['craft_cost'] as int;

    if (ownedCardIds.contains(cardId)) {
      Get.snackbar('Sudah Dimiliki', 'Kartu ini sudah ada di galerimu.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (shards.value < cost) {
      Get.snackbar(
        'Shards Kurang', 
        'Butuh $cost Shards untuk merakit kartu ini.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Eksekusi pembelian (crafting)
    shards.value -= cost;
    ownedCardIds.add(cardId);

    Get.snackbar(
      'Crafting Berhasil! ✨', 
      'Kartu ${card['name']} langsung ditambahkan ke koleksi!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // 4. HELPER: PENENTUAN HARGA JUAL DUPLIKAT
  int _calculateShards(String rarity) {
    switch (rarity.toLowerCase()) {
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