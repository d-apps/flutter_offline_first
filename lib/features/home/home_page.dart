import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline_first/core/repositories/local_repository.dart';
import 'package:flutter_offline_first/core/services/connection_service.dart';
import 'package:flutter_offline_first/core/services/sync_service.dart';
import 'package:flutter_offline_first/features/home/widgets/note_tile.dart';
import 'package:uuid/uuid.dart';

import '../../core/model/note_model.dart';

class HomePage extends StatefulWidget {
  final LocalRepository local;
  final SyncService syncService;
  final ConnectionService connectionService;

  const HomePage({
    required this.local,
    required this.syncService,
    required this.connectionService,
    super.key
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LocalRepository get local => widget.local;
  SyncService get syncService => widget.syncService;
  ConnectionService get connectionService => widget.connectionService;

  final List<NoteModel> notes = [];
  NoteModel? currentNote;
  final TextEditingController controller = .new();
  bool isLoading = true;

  final uuid = const Uuid();

  Future<void> getNotes() async {
    setState(() {
      isLoading = true;
    });
    notes.clear();
    final either = await local.getAll();
    either.fold(
            (failure){
          print(failure.message);
        },
            (r) {
          setState(() {
            notes.addAll(r);
            isLoading = false;
          });
        }
    );
  }


  @override
  void initState() {
    getNotes();
    super.initState();
  }

  Future<void> addNote() async {
    final note = NoteModel(
      id: uuid.v1(),
      title: controller.text,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
    final either = await local.addOrUpdate(note);
    return either.fold(
          (failure){
            print(failure.message);
        },
        (_) async {
          await syncService.sync();
          getNotes();
        },
    );
  }


  Future<void> updateNote() async {
    final note = currentNote!.copyWith(
        title: controller.text,
        updatedAt: DateTime.now(),
    );
    final either = await local.addOrUpdate(note);
    return either.fold(
        (failure){
          print(failure.message);
        },
        (_) async {
          await syncService.sync();
          getNotes();
        }
    );
  }

  Future<void> deleteNote(String id) async {
    final either = await local.delete(id);
    return either.fold(
        (failure){
          print(failure.message);
        },
        (_) async {
          await syncService.sync();
          getNotes();
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<bool>(
      valueListenable: connectionService.hasConnection,
      builder: (context, hasConnection, child){
        return Scaffold(
          appBar: AppBar(
            backgroundColor: hasConnection ? Colors.blue : Colors.red,
            title: Text("Notes"),
            actions: [
              IconButton(
                  onPressed: (){
                    setState(() {
                      currentNote = null;
                      controller.clear();
                    });
                  },
                  icon: Icon(Icons.add)
              )
            ],
          ),
          body: isLoading ? Center(
            child: CircularProgressIndicator(),
          )
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (_, index) {
                      final note = notes[index];
                      return NoteTile(
                        note: note,
                        isCurrent: currentNote?.id == note.id,
                        onNoteTap: (NoteModel note){
                          setState(() {
                            currentNote = note;
                            controller.text = note.title;
                          });
                        },
                        onDeleteNote: deleteNote,
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                        onPressed: (){
                          if(currentNote == null){
                            addNote();
                          } else {
                            updateNote();
                          }
                        },
                        icon: Icon(currentNote == null ? Icons.send : Icons.update)
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

}
