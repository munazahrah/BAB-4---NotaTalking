# Note-Taking App 

Aplikasi pencatat sederhana (*Note-Taking App*) berbasis Flutter yang mendemonstrasikan mekanisme penyimpanan data lokal menggunakan operasi baca dan tulis berkas secara langsung pada sistem berkas perangkat (*file system*). Proyek ini menerapkan konsep *Data Persistence III* dengan memanfaatkan pustaka bawaan `dart:io` serta paket pendukung lintas platform.

## Fitur Utama

* **Manajemen Catatan (CRUD):** Membuat, membaca, menyunting, dan menghapus catatan secara lokal.
* **Penyimpanan Berbasis Sistem Berkas:** Setiap catatan disimpan di dalam direktori privat aplikasi (`getApplicationDocumentsDirectory()`) menggunakan folder unik berbasis *timestamp* (`note_{timestamp}/`).
* **Lampiran Gambar & Kompresi Otomatis:** Mendukung pengambilan gambar dari galeri perangkat dan melakukan kompresi ukuran berkas secara otomatis sebelum disimpan ke penyimpanan lokal (mendukung hingga 3 lampiran gambar per catatan).
* **Pencatatan Waktu Modifikasi:** Menyimpan stempel waktu pembaruan terakhir dalam format ISO 8601 pada setiap catatan.
* **Ekspor Catatan:** Menyalin isi catatan ke berkas `.txt` sementara di dalam direktori `getTemporaryDirectory()`.

## Struktur Direktori Proyek

Struktur kode menerapkan prinsip *separation of concerns* untuk memisahkan logika data, operasi berkas, dan antarmuka pengguna:

```text
lib/
├── main.dart                   # Titik masuk (entry point) dan konfigurasi tema aplikasi
├── models/
│   └── note.dart               # Model representasi data catatan
├── helpers/
│   └── file_helper.dart        # Kelas Singleton untuk seluruh operasi I/O sistem berkas
└── screens/
    ├── note_list_screen.dart   # Halaman utama untuk menampilkan daftar catatan
    └── note_editor_screen.dart # Halaman untuk membuat, membaca, dan menyunting catatan
```

## Dependensi Utama

Aplikasi ini menggunakan beberapa paket tambahan yang dikonfigurasi pada berkas `pubspec.yaml`:

* **`path_provider` (`^2.1.2`):** Menentukan lokasi direktori penyimpanan dokumen dan direktori sementara pada Android maupun iOS.
* **`path` (`^1.9.0`):** Memanipulasi dan menggabungkan jalur berkas (*file path*) secara aman lintas platform.
* **`image_picker` (`^1.0.7`):** Memilih gambar dari galeri perangkat.
* **`flutter_image_compress` (`^2.1.0`):** Mengompres data biner gambar (`Uint8List`) untuk menghemat ruang penyimpanan.

## Konfigurasi Platform

Agar fitur pemilihan gambar berjalan dengan baik pada perangkat fisik, pastikan konfigurasi izin berikut telah diterapkan:

### Android
1. Pastikan `minSdkVersion` pada `android/app/build.gradle` minimal versi **21**.
2. Tambahkan izin berikut di dalam `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
   ```

### iOS
Tambahkan deskripsi penggunaan kamera dan galeri pada berkas `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses ke galeri untuk melampirkan gambar pada catatan.</string>
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses ke kamera untuk mengambil foto baru.</string>
```

## Langkah-langkah Menjalankan Aplikasi

Pastikan Anda sudah menginstal Flutter SDK di perangkat atau komputer Anda.

### 1. Clone repositori

Clone repositori ini ke komputer lokal Anda:

```bash
git clone https://github.com/munazahrah/BAB-4---NotaTalking.git
```

### 2. Masuk ke direktori project

Masuk ke dalam direktori project:

```bash
cd notetalking
```

### 3. Unduh package

Unduh seluruh package / dependensi:

```bash
flutter pub get
```

### 4. Jalankan aplikasi

Jalankan aplikasi di emulator atau perangkat fisik yang sudah terhubung:

```bash
flutter run
```
