import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/material_list_controller.dart';
import '../../root/controllers/root_controler.dart';
// --- 1. IMPORT MODEL BARU ---
import '../../../models/material_model.dart'; 

class MaterialListView extends GetView<MaterialListController> {
  const MaterialListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Karena ini adalah "ruangan" di dalam RootView, kita tidak perlu Scaffold.
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildCategoryFilters(),
          const SizedBox(height: 24),
          _buildMaterialList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
            onPressed: () {
              // Kembali ke halaman Dashboard (indeks 0)
              Get.find<RootController>().changeNavIndex(0); 
            },
          ),
          const Text(
            'Eksplorasi Materi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  // ... (_buildSearchBar, _buildCategoryFilters, _buildCategoryChip tetap sama)
   Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Mau belajar apa hari ini?',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(
        () => Row(
          children: [
            _buildCategoryChip('Biologi', Icons.biotech, controller.selectedCategory.value == 'Biologi'),
            const SizedBox(width: 12),
            _buildCategoryChip('Fisika', Icons.thermostat, controller.selectedCategory.value == 'Fisika'),
            const SizedBox(width: 12),
            _buildCategoryChip('Kimia', Icons.science_outlined, controller.selectedCategory.value == 'Kimia'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeCategory(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.black54),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMaterialList() {
    return Expanded(
      child: Obx(
        () {
          // --- 3. TAMBAHKAN LOGIKA LOADING ---
          // Cek "saklar" isLoading dari controller
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          // Setelah loading selesai, baru cek apakah list filternya kosong
          if (controller.filteredMaterials.isEmpty) {
            return const Center(child: Text("Tidak ada materi ditemukan."));
          }
          // Jika loading selesai dan ada isinya, tampilkan list
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: controller.filteredMaterials.length,
            itemBuilder: (context, index) {
              final item = controller.filteredMaterials[index];
              return _MaterialCard(item: item);
            },
          );
        },
      ),
    );
  }
}


class _MaterialCard extends StatelessWidget {
  final MaterialItem item;
  const _MaterialCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MaterialListController>();
    return GestureDetector(
      // --- 2. PERBAIKI ONTAP DI SINI ---
      onTap: () => controller.openMaterial(item), // Kirim seluruh objek 'item'
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(item.iconPath, height: 50),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: item.progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(item.progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

