# Walkthrough: Implementasi Refresh Token & Auto-Retry di Flutter

Kami telah mengimplementasikan sistem **Refresh Token otomatis dengan antrian Mutex (Single-flight Completer)** di sisi Flutter untuk menangani kedaluwarsa JWT access token secara mulus tanpa mengganggu alur pengguna.

---

## Ringkasan Perubahan

### 1. `ApiClient` — Centralized HTTP Client dengan Auto Refresh & Mutex
File: [`api_client.dart`](file:///d:/Antigravity/science_craft/lib/app/data/api_client.dart)

- **Auto Authorization Header**: Otomatis menyisipkan `Authorization: Bearer <access_token>` pada setiap request.
- **Deteksi HTTP 401 & Auto Refresh**:
  - Jika request mendapatkan status 401 (misal `Token has expired`), `ApiClient` otomatis memanggil endpoint backend `POST /auth/refresh` menggunakan `Authorization: Bearer <refresh_token>`.
  - Jika refresh berhasil (HTTP 200), access token baru disimpan ke `GetStorage('authToken')`.
  - Request yang sempat gagal otomatis di-**retry** dengan access token baru dan mengembalikan respons yang berhasil tanpa melempar error ke UI.
- **Thread-safe Concurrency Mutex**:
  - Menggunakan `Completer<String?>` sehingga jika beberapa request terjadi serentak saat token expired (misal mengambil quest, materi, dan fakta unik sekaligus), hanya **1 panggilan refresh token** yang dikirim ke server. Request lainnya akan menunggu hasil refresh tersebut lalu bersama-sama mengulang request masing-masing.
- **Handling Sesi Berakhir (Refresh Token Expired / Invalid)**:
  - Jika refresh token juga sudah kedaluwarsa atau tidak valid, aplikasi membersihkan data sesi dan mengarahkan pengguna kembali ke halaman Login dengan pesan peringatan: *"Sesi login kamu telah kedaluwarsa. Silakan masuk kembali."*
- **Safe JSON Decoding**:
  - Method `decodeMap` dan `decodeMapList` dilengkapi proteksi `try-catch` agar tidak terjadi crash `FormatException: Unexpected character <!doctype html>` jika server mengembalikan halaman HTML (seperti 404 atau 502).

---

### 2. Update `AuthService`
File: [`auth_service.dart`](file:///d:/Antigravity/science_craft/lib/app/data/auth_service.dart)

- Menyimpan `refreshToken` ke `GetStorage` saat login manual, Google login, dan registrasi.
- Menambahkan getter `refreshToken`.
- Menghapus `authToken` dan `refreshToken` saat logout.
- Menggunakan parser JSON aman dari `ApiClient`.

---

### 3. Update `ApiService`
File: [`api_service.dart`](file:///d:/Antigravity/science_craft/lib/app/data/api_service.dart)

- Seluruh method API di `ApiService` (Learning, Quests, Gamification, Sync Progress, Fun Fact, XP, Profile) kini dialihkan menggunakan method `ApiClient.get`, `ApiClient.post`, `ApiClient.put`, `ApiClient.delete`.
- Semua request otomatis mendapatkan perlindungan refresh token dan retry.

---

### 4. Update Controller & Service Lainnya
- [`milestone_api_service.dart`](file:///d:/Antigravity/science_craft/lib/app/modules/milestone/services/milestone_api_service.dart): Dialihkan menggunakan `ApiClient` dan penanganan HTML response yang aman.
- [`dashboard_controller.dart`](file:///d:/Antigravity/science_craft/lib/app/modules/dashboard/controllers/dashboard_controller.dart): Menggunakan `ApiClient.get` untuk memuat data materi dan fun fact.
- [`material_list_controller.dart`](file:///d:/Antigravity/science_craft/lib/app/modules/materi/controllers/material_list_controller.dart): Menggunakan `ApiClient.get`.
- [`materi_controller.dart`](file:///d:/Antigravity/science_craft/lib/app/modules/materi/controllers/materi_controller.dart): Menggunakan `ApiClient.get`.
- [`main.dart`](file:///d:/Antigravity/science_craft/lib/main.dart): Memeriksa keberadaan `authToken` atau `refreshToken` saat menentukan route awal aplikasi.

---

## Verifikasi & Hasil

1. **Analisis Kode**:
   - `flutter analyze` dijalankan dan mengonfirmasi tidak ada error sintaks atau kegagalan tipe data.
2. **Uji Alur**:
   - Saat login, token akses dan refresh token tersimpan di storage.
   - Saat token akses kedaluwarsa (15 menit), request berikutnya (seperti `getTodayDailyQuest` atau `fetchInProgressMaterials`) yang menerima respons 401 akan secara transparan disegarkan via `/auth/refresh` lalu di-retry otomatis.
