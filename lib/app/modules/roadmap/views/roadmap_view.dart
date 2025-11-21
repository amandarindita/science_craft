import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/roadmap_controller.dart';

class LevelRoadmapView extends GetView<LevelRoadmapController> {
  const LevelRoadmapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Level Kamu'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Obx( // Bungkus dengan Obx agar UI update saat XP user berubah
        () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.allLevels.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final level = controller.allLevels[index];
            // Cek status levelnya
            final status = controller.getLevelStatus(level); 
            return _LevelStepCard(level: level, status: status);
          },
        ),
      ),
    );
  }
}

// Widget private untuk tampilan satu kartu level
class _LevelStepCard extends StatelessWidget {
  final LevelModel level;
  final LevelStatus status;

  const _LevelStepCard({
    Key? key,
    required this.level,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;
    bool isLocked = false;

    // Tentukan ikon dan warna berdasarkan status
    switch (status) {
      case LevelStatus.completed:
        iconData = Icons.check_circle; // Ikon centang
        color = Colors.green;
        break;
      case LevelStatus.current:
        iconData = Icons.stars; // Ikon bintang (level saat ini)
        color = Colors.blueAccent;
        break;
      case LevelStatus.locked:
      default:
        iconData = Icons.lock; // Ikon gembok
        color = Colors.grey.shade400;
        isLocked = true;
    }

    // Gunakan Opacity agar level terkunci terlihat pudar
    return Opacity(
      opacity: isLocked ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          children: [
            Icon(iconData, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${level.levelNumber}: ${level.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      // Warna teks juga pudar jika terkunci
                      color: isLocked ? Colors.grey.shade600 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hadiah: ${level.rewardDescription}',
                    style: TextStyle(
                      color: isLocked ? Colors.grey.shade500 : Colors.black54,
                    ),
                  ),
                  // Tampilkan XP yang dibutuhkan jika level terkunci
                  if (isLocked)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '(${level.xpRequired} XP Dibutuhkan)',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}