import 'package:flutter/material.dart';

// CATATAN: Nama kelas sekarang tidak diawali '_' agar bisa diakses dari file lain (publik)
class ContinueLearningCard extends StatelessWidget {
  final String title;
  final double progress;
  final String iconPath;
  final VoidCallback? onTap; // <-- 1. TAMBAHKAN PROPERTI INI

  const ContinueLearningCard(
      {super.key,
      required this.title,
      required this.progress,
      required this.iconPath,
      this.onTap // <-- 2. TAMBAHKAN DI CONSTRUCTOR
      });

  @override
  Widget build(BuildContext context) {
    // 3. BUNGKUS DENGAN INKWELL AGAR BISA DI-KLIK
    return InkWell(
      onTap: onTap, // <-- 4. SAMBUNGKAN FUNGSINYA KE SINI
      borderRadius: BorderRadius.circular(20), // Biar efek kliknya rapi
      child: Container(
        // Ini adalah container asli Anda, tidak ada yang diubah di dalamnya
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5)
          ],
        ),
        child: Row(
          children: [
            Image.asset(iconPath, height: 50),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${(progress * 100).toInt()}%'),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}