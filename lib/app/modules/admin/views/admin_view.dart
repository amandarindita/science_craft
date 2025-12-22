import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../../routes/app_pages.dart'; 

class AdminView extends GetView<AdminController> {
  @override
  Widget build(BuildContext context) {
    Get.put(AdminController()); 

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () {
               Get.defaultDialog(
                title: "Keluar Admin?",
                middleText: "Kamu akan kembali ke halaman Login.",
                textConfirm: "Ya, Keluar",
                textCancel: "Batal",
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  Get.offAllNamed(Routes.LOGIN); 
                },
              );
            }
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              _tabBtn(0, "Materi"), SizedBox(width: 5),
              _tabBtn(1, "FunFact"), SizedBox(width: 5),
              _tabBtn(2, "Kuis"),
            ]),
            Divider(height: 30),
            Obx(() {
              if (controller.currentTab.value == 0) return _formMateri();
              if (controller.currentTab.value == 1) return _formFunFact();
              return _formKuis();
            }),
          ],
        ),
      ),
    );
  }

  Widget _tabBtn(int i, String title) {
    return Obx(() => ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.currentTab.value == i ? Colors.blue : Colors.grey),
      onPressed: () => controller.currentTab.value = i,
      child: Text(title),
    ));
  }

  // --- FORM MATERI (ADA DROPDOWN) ---
  Widget _formMateri() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(controller: controller.titleController, decoration: InputDecoration(labelText: "Judul Materi")),
      SizedBox(height: 10),
      
      // DROPDOWN KATEGORI
      Text("Kategori:", style: TextStyle(fontWeight: FontWeight.bold)),
      Obx(() => Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: controller.selectedCategory.value,
            items: controller.categories.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (val) => controller.selectedCategory.value = val!,
          ),
        ),
      )),

      TextField(controller: controller.introController, decoration: InputDecoration(labelText: "Intro Singkat"), maxLines: 2),
      SizedBox(height: 10),
      
      Text("Sub-Bab / Isi Materi:", style: TextStyle(fontWeight: FontWeight.bold)),
      Obx(() => Column(children: List.generate(controller.sections.length, (i) => Card(
        color: Colors.grey[100],
        child: Padding(padding: EdgeInsets.all(8), child: Column(children: [
          TextField(decoration: InputDecoration(labelText: "Judul Sub-Bab"), onChanged: (v)=>controller.updateSection(i,'title',v)),
          TextField(decoration: InputDecoration(labelText: "Isi"), maxLines:3, onChanged: (v)=>controller.updateSection(i,'content',v)),
          TextField(decoration: InputDecoration(labelText: "Contoh (Opsional)"), onChanged: (v)=>controller.updateSection(i,'examples',v)),
          if(controller.sections.length > 1)
            TextButton(onPressed: ()=>controller.removeSection(i), child: Text("Hapus", style: TextStyle(color:Colors.red)))
        ]))
      )))),
      TextButton(onPressed: controller.addSectionField, child: Text("+ Tambah Sub-Bab")),
      ElevatedButton(onPressed: controller.saveMaterial, child: Text("SIMPAN MATERI")),
      
      Divider(),
      Obx(() => Column(children: controller.materialsList.map((m) => ListTile(
        title: Text(m['title']), 
        subtitle: Text(m['category']),
        trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: ()=>controller.deleteMaterial(m['id'])),
      )).toList()))
    ]);
  }

  // --- FORM FUNFACT (TANPA JUDUL, ADA LIST) ---
  Widget _formFunFact() {
    return Column(children: [
      Container(
        width: double.infinity, padding: EdgeInsets.all(10), color: Colors.yellow[100],
        child: Text("Judul otomatis: 'Tahukah Kamu?'", style: TextStyle(fontStyle: FontStyle.italic)),
      ),
      SizedBox(height: 10),
      TextField(controller: controller.ffDescController, decoration: InputDecoration(labelText: "Isi Fakta Unik", border: OutlineInputBorder()), maxLines: 3),
      SizedBox(height: 10),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: controller.saveFunFact, child: Text("SIMPAN FUNFACT", style: TextStyle(color: Colors.white))),
      
      Divider(height: 40, thickness: 2),
      Text("List FunFact Aktif:", style: TextStyle(fontWeight: FontWeight.bold)),
      
      // LIST PREVIEW FUNFACT
      Obx(() => ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.funFactsList.length,
        itemBuilder: (ctx, i) {
          var item = controller.funFactsList[i];
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.lightbulb, color: Colors.orange),
              title: Text(item['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => controller.deleteFunFact(item['id']),
              ),
            ),
          );
        },
      ))
    ]);
  }

  // --- FORM KUIS (ADA LIST) ---
  Widget _formKuis() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Pilih Materi:", style: TextStyle(fontWeight: FontWeight.bold)),
      Obx(() => DropdownButton<int>(
        isExpanded: true,
        hint: Text("Pilih Materi..."),
        value: controller.selectedMaterialId.value,
        items: controller.materialsList.map((e) => DropdownMenuItem<int>(value: e['id'], child: Text(e['title']))).toList(),
        onChanged: (v) => controller.selectedMaterialId.value = v,
      )),
      TextField(controller: controller.questionController, decoration: InputDecoration(labelText: "Pertanyaan")),
      Row(children: [
        Expanded(child: TextField(controller: controller.optionAController, decoration: InputDecoration(labelText: "Opsi A"))),
        Expanded(child: TextField(controller: controller.optionBController, decoration: InputDecoration(labelText: "Opsi B"))),
      ]),
      Row(children: [
        Expanded(child: TextField(controller: controller.optionCController, decoration: InputDecoration(labelText: "Opsi C"))),
        Expanded(child: TextField(controller: controller.optionDController, decoration: InputDecoration(labelText: "Opsi D"))),
      ]),
      Text("Jawaban Benar:"),
      Obx(() => Row(children: ['A','B','C','D'].map((e) => Row(children: [
        Radio(value: e, groupValue: controller.correctAnswer.value, onChanged: (v)=>controller.correctAnswer.value = v.toString()),
        Text(e)
      ])).toList())),
      ElevatedButton(onPressed: controller.saveQuiz, child: Text("SIMPAN SOAL")),

      Divider(height: 40, thickness: 2),
      
      // LIST PREVIEW KUIS (MUNCUL SESUAI MATERI YG DIPILIH)
      Obx(() {
        if (controller.selectedMaterialId.value == null) {
          return Text("Pilih materi di atas untuk melihat daftar soal.");
        }
        if (controller.quizzesList.isEmpty) {
          return Text("Belum ada soal untuk materi ini.");
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.quizzesList.length,
          itemBuilder: (ctx, i) {
            var item = controller.quizzesList[i];
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text("${i+1}")),
                title: Text(item['question']),
                subtitle: Text("Jawaban: ${item['correct_answer']}"),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteQuiz(item['id']),
                ),
              ),
            );
          },
        );
      })
    ]);
  }
}