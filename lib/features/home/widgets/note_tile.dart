import 'package:flutter/material.dart';
import 'package:flutter_offline_first/core/model/note_model.dart';

class NoteTile extends StatelessWidget {
  final NoteModel note;
  final bool isCurrent;
  final void Function(NoteModel note) onNoteTap;
  final void Function(String id) onDeleteNote;

  const NoteTile({
    required this.note,
    required this.isCurrent,
    required this.onNoteTap,
    required this.onDeleteNote,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isCurrent ? Colors.black54 :
              Colors.transparent
          )
      ),
      title: Text(note.title),
      trailing: IconButton(
          onPressed: () => onDeleteNote(note.id),
          icon: Icon(Icons.close)
      ),
      onTap: () => onNoteTap(note),
    );
  }
}
