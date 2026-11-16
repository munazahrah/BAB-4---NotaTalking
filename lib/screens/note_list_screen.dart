import 'package:flutter/material.dart';
import '../models/note.dart';
import '../helpers/file_helper.dart';
import 'note_editor_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final FileHelper _fileHelper = FileHelper();
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final notes = await _fileHelper.getAllNotes();
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  Future<void> _deleteNote(String noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text(
          'Catatan beserta gambar pendampingnya akan dihapus secara permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _fileHelper.deleteNote(noteId);
      _loadNotes();
    }
  }

  Future<void> _navigateToEditor({Note? note}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(
              child: Text(
                'Belum ada catatan.\nTekan + untuk membuat catatan baru.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: note.hasImage
                        ? const Icon(Icons.image, color: Colors.blue)
                        : const Icon(
                            Icons.article_outlined,
                            color: Colors.grey,
                          ),
                    title: Text(
                      note.title.isEmpty ? '(Tanpa judul)' : note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    //versi lama
                    // subtitle: Text(
                    //   note.content.isEmpty ? '(Tidak ada isi)' : note.content,
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    //versi baru SOAL 4: Menambahkan properti lastModified
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.content.isEmpty
                              ? '(Tidak ada isi)'
                              : note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note.lastModified.isNotEmpty
                              ? 'Diperbarui: ${note.lastModified.length >= 10 ? note.lastModified.substring(0, 10) : note.lastModified}'
                              : '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Tombol Ekspor Catatan (Baru) [SOAL 3]
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.green),
                          tooltip: 'Ekspor Catatan',
                          onPressed: () async {
                            final exportPath = await _fileHelper.exportNote(
                              note.id,
                            );
                            if (mounted && exportPath != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Catatan diekspor ke: $exportPath',
                                  ),
                                ),
                              );
                            }
                          },
                        ),

                        // 2. Tombol Hapus Catatan
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Hapus Catatan',
                          onPressed: () => _deleteNote(note.id),
                        ),
                      ],
                    ),
                    onTap: () => _navigateToEditor(note: note),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
