import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../../data/api_service.dart';
import '../../../data/auth_service.dart';
import 'package:flutter/material.dart'; // Ini buat ngebunuh error Colors, Dialog, Text, Container, dll
import '../../profile/controllers/profile_controller.dart'; // Ini buat ngebunuh error ProfileController
import '../../dashboard/controllers/dashboard_controller.dart';

// Model sederhana
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class QuizController extends GetxController {
  // --- STATE ---
  final isLoading = true.obs;
  final isQuizFinished = false.obs;
  final questions = <QuizQuestion>[].obs;
  final currentQuestionIndex = 0.obs;
  final selectedAnswers = <int, int?>{}.obs; 
  final score = 0.0.obs;

  late int materialId;

  @override
  void onInit() {
    super.onInit();
    var arg = Get.arguments;
    
    if (arg != null) {
      materialId = (arg is int) ? arg : int.parse(arg.toString());
      loadQuizData();
    } else {
      print("Error: Tidak ada ID yang dikirim lewat arguments!");
      isLoading.value = false;
    }
  }

  // --- LOAD DATA DARI SERVER FLASK ---
  Future<void> loadQuizData() async {
    isLoading(true);
    try {
      // Panggil API Get Questions by Material ID
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/admin/questions/$materialId'),
        headers: {'Authorization': 'Bearer ${Get.find<AuthService>().token}'},
      );

      if (response.statusCode == 200) {
        List<dynamic> dbData = jsonDecode(response.body);

        if (dbData.isEmpty) {
          questions.clear(); 
        } else {
          // Mapping dari JSON Flask ke Model (QuizQuestion)
          questions.assignAll(dbData.map((item) {
          return QuizQuestion(
            question: item['question_text']?.toString() ?? '',
            options: [
              item['option_a']?.toString() ?? '',
              item['option_b']?.toString() ?? '',
              item['option_c']?.toString() ?? '',
              item['option_d']?.toString() ?? '',
            ],
            correctAnswerIndex: _parseAnswer(item['correct_answer']?.toString() ?? 'A'),
          );
        }).toList());

          // Siapkan slot jawaban kosong
          selectedAnswers.value = Map.fromIterables(
            List.generate(questions.length, (i) => i),
            List.generate(questions.length, (i) => null),
          );
        }
      } else {
        print("Gagal mengambil soal kuis dari server.");
      }
    } catch (e) {
      print("Error load quiz: $e");
    } finally {
      isLoading(false);
    }
  }

  // Helper konversi Huruf ke Angka (Tetap dipertahankan)
  int _parseAnswer(String letter) {
    switch (letter.toUpperCase()) {
      case 'A': return 0;
      case 'B': return 1;
      case 'C': return 2;
      case 'D': return 3;
      default: return 0;
    }
  }

  // --- LOGIKA GAMEPLAY (TIDAK ADA PERUBAHAN) ---
  
  void selectAnswer(int qIndex, int ansIndex) {
    selectedAnswers[qIndex] = ansIndex;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }
  String _levelTitle(int level) {
      if (level == 1) {
        return "Level 1: Siswa Baru 🔬";
      } else if (level == 2) {
        return "Level 2: Peneliti Junior 🧪";
      } else if (level == 3) {
        return "Level 3: Asisten Lab 🧬";
      } else if (level == 4) {
        return "Level 4: Ahli Sains 🌌";
      } else {
        return "Level $level: Professor Madya 🧠";
      }
    }
  // --- LOGIKA FINISH KUIS (VERSI API & GAMIFIKASI) ---
  Future<void> finishQuiz() async {
    isLoading.value = true; // Munculin loading bentar pas ngirim jawaban
    bool submitSuccess = false;
    int correctCount = 0;
    
    selectedAnswers.forEach((qIndex, ansIndex) {
      if (ansIndex != null) {
        if (ansIndex == questions[qIndex].correctAnswerIndex) {
          correctCount++;
        }
      }
    });

    int totalSoal = questions.length;
    if (totalSoal > 0) {
      score.value = (correctCount / totalSoal) * 100;
    } else {
      score.value = 0;
    }

    // 🌟 1. TEMBAK DATA KE SERVER FLASK BUAT DAPET XP & BADGE 🌟
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/quiz/submit'), // Sesuai rute API Flask lu
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Get.find<AuthService>().token}'
        },
        body: jsonEncode({
          "material_id": materialId,
          "total_correct": correctCount,
          "total_soal": totalSoal
        }),
      );
      if (response.statusCode == 200) {
        submitSuccess = true;
        final responseData = jsonDecode(response.body);

        final xpAdded = int.tryParse(
          (responseData['xp_added'] ?? 0).toString(),
        ) ?? 0;

        final levelUp = responseData['level_up'] == true ||
            responseData['level_up'].toString() == 'true';

        final level = int.tryParse(
          (responseData['level'] ?? 1).toString(),
        ) ?? 1;

        // DAILY QUEST: cukup panggil langsung ke API, jangan dobel lewat DashboardController
        await ApiService.updateDailyQuestProgress('do_quiz');

        if (xpAdded > 0) {
          await ApiService.updateDailyQuestProgress(
            'collect_xp',
            amount: xpAdded,
          );
        }

        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchDailyQuest();
        }

        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchUserProfile();
        }

        final message = xpAdded > 0
            ? "Luar biasa! Kamu mendapatkan tambahan +$xpAdded XP!"
            : "Kuis selesai! XP kuis ini sudah pernah kamu dapatkan sebelumnya.";

        Get.snackbar(
          "Kuis Selesai! 🎉",
          message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
        );

        if (levelUp) {
          Get.dialog(
            LevelUpPopup(newLevel: _levelTitle(level)),
            barrierDismissible: false,
          );
        }

        List<dynamic> newBadges = responseData['new_badges_unlocked'] ?? [];
        if (newBadges.isNotEmpty) {
          for (var badgeName in newBadges) {
            _showQuizBadgePopup(badgeName.toString());
          }
        }
      } else {
        print("Gagal submit kuis. Status: ${response.statusCode}");
        print("Body: ${response.body}");
      }
    } catch (e) {
      print("Error submit kuis: $e");
    } finally {
      isLoading.value = false;
      if (submitSuccess){
        isQuizFinished.value = true;
      }
       // Lanjut tampilin halaman Skor UI
    }
  }

  // --- WIDGET HELPER: POPUP BADGE KHUSUS KUIS DENGAN EFEK GLOW ---
  void _showQuizBadgePopup(String badgeName) {
    // Cari path gambar dinamis
    String getImagePath(String name) {
      switch (name) {
        case "Grand Analyst": return "assets/badge/6.png";
        case "Flawless Victory": return "assets/badge/11.png";
        default: return "assets/badge/8.png";
      }
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 60),
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("PENCAPAIAN KUIS!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF6C63FF))),
                  const SizedBox(height: 8),
                  Container(width: 50, height: 4, decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 20),
                  Text("Sempurna! Kamu membuka lencana:\n\n$badgeName", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Color(0xFF374151), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text("MANTAP!", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -10,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white,
                  boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.6), blurRadius: 35, spreadRadius: 8)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(getImagePath(badgeName), fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
  // --- FUNGSI NAVIGASI YANG KETELEN PAS COPY-PASTE 😂 ---
  void startExperiment() {
    Get.toNamed('/experiment'); 
  }

  void backToMaterial() {
    Get.back(); 
  }
}