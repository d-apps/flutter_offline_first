import 'package:flutter_offline_first/core/model/note_model.dart';
import 'package:hive_ce/hive.dart';

class NoteAdapter implements TypeAdapter<NoteModel>{
  @override
  NoteModel read(BinaryReader reader) {
    return NoteModel(
      id: reader.read(),
      title: reader.read(),
      createdAt: reader.read(),
      updatedAt: reader.read(),
      synced: reader.read(),
    );
  }

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.createdAt);
    writer.write(obj.updatedAt);
    writer.write(obj.synced);
  }

}