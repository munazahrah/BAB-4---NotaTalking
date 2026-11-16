class Note {
  final String id;
  final String title;
  final String content;
  final String lastModified; // Properti baru SOAL 4
  final bool hasImage;
  final int imageCount; // Menyimpan jumlah lampiran (0 - 3) SOAL 5

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.lastModified,
    this.hasImage = false,
    this.imageCount = 0,
  });
}
