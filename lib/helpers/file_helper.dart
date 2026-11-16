import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/note.dart';

class FileHelper {
  static final FileHelper instance = FileHelper._internal();
  FileHelper._internal();
  factory FileHelper() => instance;

  // Mendapatkan direktori notes dan memastikan keberadaannya
  Future<Directory> _getNotesDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory(join(docsDir.path, 'notes'));
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    return notesDir;
  }

  // Menghasilkan ID unik berbasis stempel waktu
  String generateNoteId() {
    return 'note_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Menyimpan catatan (judul pada baris pertama, isi pada baris berikutnya)
  //versi lama
  // Future<void> saveNote(String noteId, String title, String content) async {
  //   final notesDir = await _getNotesDirectory();
  //   final noteDir = Directory(join(notesDir.path, noteId));
  //   if (!await noteDir.exists()) {
  //     await noteDir.create(recursive: true);
  //   }
  //   final file = File(join(noteDir.path, 'content.txt'));
  //   await file.writeAsString('$title\n$content');
  // }

  //versi baru SOAL 4: Menyimpan catatan dengan menambahkan properti lastModified
  Future<void> saveNote(String noteId, String title, String content) async {
    final notesDir = await _getNotesDirectory();
    final noteDir = Directory(join(notesDir.path, noteId));
    if (!await noteDir.exists()) {
      await noteDir.create(recursive: true);
    }
    final file = File(join(noteDir.path, 'content.txt'));
    final timeNow = DateTime.now().toIso8601String();
    // Baris 1: Judul, Baris 2: Waktu Modifikasi, Baris 3+: Konten
    await file.writeAsString('$title\n$timeNow\n$content');
  }

  // Membaca satu catatan berdasarkan ID
  //versi lama
  // Future<Note?> readNote(String noteId) async {
  //   final notesDir = await _getNotesDirectory();
  //   final file = File(join(notesDir.path, noteId, 'content.txt'));
  //   if (!await file.exists()) return null;

  //   final rawContent = await file.readAsString();
  //   final lines = rawContent.split('\n');
  //   final title = lines.first;
  //   final content = lines.length > 1 ? lines.sublist(1).join('\n') : '';

  //   final imageFile = File(join(notesDir.path, noteId, 'image.jpg'));
  //   final hasImage = await imageFile.exists();

  //   return Note(id: noteId, title: title, content: content, hasImage: hasImage);
  // }

  //versi baru SOAL 4: Membaca satu catatan berdasarkan ID dengan properti lastModified
  Future<Note?> readNote(String noteId) async {
    final notesDir = await _getNotesDirectory();
    final file = File(join(notesDir.path, noteId, 'content.txt'));
    if (!await file.exists()) return null;

    final rawContent = await file.readAsString();
    final lines = rawContent.split('\n');
    final title = lines.isNotEmpty ? lines[0] : '';
    final lastModified = lines.length > 1 ? lines[1] : '';
    final content = lines.length > 2 ? lines.sublist(2).join('\n') : '';

    final imageFile = File(join(notesDir.path, noteId, 'image.jpg'));
    final hasImage = await imageFile.exists();

    //versi baru SOAL 5: Menghitung jumlah lampiran gambar (0 - 3)
    int imageCount = 0;
    for (int i = 1; i <= 3; i++) {
      final imgFile = File(join(notesDir.path, noteId, 'image_$i.jpg'));
      if (await imgFile.exists()) {
        imageCount++;
      }
    }

    return Note(
      id: noteId,
      title: title,
      content: content,
      lastModified: lastModified,
      hasImage: hasImage,
      imageCount: imageCount, // Menyimpan jumlah lampiran (0 - 3) SOAL 5
    );
  }

  // Memindai seluruh catatan yang tersimpan
  Future<List<Note>> getAllNotes() async {
    final notesDir = await _getNotesDirectory();
    final List<String> noteIds = [];

    await for (final entity in notesDir.list()) {
      if (entity is Directory) {
        noteIds.add(entity.path.split(Platform.pathSeparator).last);
      }
    }

    // Mengurutkan ID dari yang terbaru
    noteIds.sort((a, b) => b.compareTo(a));

    final List<Note> notes = [];
    for (final id in noteIds) {
      final note = await readNote(id);
      if (note != null) notes.add(note);
    }
    return notes;
  }

  // Melakukan kompresi dan menyimpan gambar ke folder catatan
  Future<void> saveNoteImage(String noteId, String sourcePath) async {
    final notesDir = await _getNotesDirectory();
    final noteDir = Directory(join(notesDir.path, noteId));
    if (!await noteDir.exists()) {
      await noteDir.create(recursive: true);
    }

    final originalBytes = await File(sourcePath).readAsBytes();
    final compressedBytes = await FlutterImageCompress.compressWithList(
      originalBytes,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    final imageFile = File(join(noteDir.path, 'image.jpg'));
    await imageFile.writeAsBytes(compressedBytes);
  }

  // Mengambil referensi berkas gambar catatan
  Future<File?> getNoteImageFile(String noteId) async {
    final notesDir = await _getNotesDirectory();
    final imageFile = File(join(notesDir.path, noteId, 'image.jpg'));
    if (!await imageFile.exists()) return null;
    return imageFile;
  }

  // Menghapus direktori catatan secara permanen beserta isinya
  Future<void> deleteNote(String noteId) async {
    final notesDir = await _getNotesDirectory();
    final noteDir = Directory(join(notesDir.path, noteId));
    if (await noteDir.exists()) {
      await noteDir.delete(recursive: true);
    }
  }

  //menambahkan fungsi untuk mengekspor catatan ke file teks di direktori sementara
  Future<String?> exportNote(String noteId) async {
    final notesDir = await _getNotesDirectory();
    final sourceFile = File(join(notesDir.path, noteId, 'content.txt'));
    if (!await sourceFile.exists()) return null;

    final content = await sourceFile.readAsString();
    final tempDir = await getTemporaryDirectory();
    final exportFile = File(join(tempDir.path, 'export_$noteId.txt'));

    await exportFile.writeAsString(content);
    return exportFile.path;
  }

  //versi baru SOAL 5: Menyimpan gambar dengan indeks tertentu (image_1.jpg, image_2.jpg, image_3.jpg)
  Future<void> saveNoteImageByIndex(
    String noteId,
    int index,
    String sourcePath,
  ) async {
    final notesDir = await _getNotesDirectory();
    final noteDir = Directory(join(notesDir.path, noteId));
    if (!await noteDir.exists()) await noteDir.create(recursive: true);

    final originalBytes = await File(sourcePath).readAsBytes();
    final compressedBytes = await FlutterImageCompress.compressWithList(
      originalBytes,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    final imageFile = File(join(noteDir.path, 'image_$index.jpg'));
    await imageFile.writeAsBytes(compressedBytes);
  }

  Future<void> deleteNoteImageByIndex(String noteId, int index) async {
    final notesDir = await _getNotesDirectory();
    final imageFile = File(join(notesDir.path, noteId, 'image_$index.jpg'));
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
  }
}
