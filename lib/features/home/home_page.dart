import 'package:flutter/material.dart';
import 'package:flutter_offline_first/core/repositories/local_repository.dart';
import 'package:flutter_offline_first/core/services/sync_service.dart';
import 'package:uuid/uuid.dart';

import '../../core/model/note_model.dart';

class HomePage extends StatefulWidget {
  final LocalRepository local;
  final SyncService syncService;

  const HomePage({
    required this.local,
    required this.syncService,
    super.key
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LocalRepository get local => widget.local;
  SyncService get syncService => widget.syncService;

  final List<NoteModel> notes = [];
  NoteModel? currentNote;
  final TextEditingController controller = .new();
  bool isLoading = true;

  final uuid = const Uuid();

  @override
  void initState() {
    getNotes();
    super.initState();
  }

  Future<void> getNotes() async {
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

  Future<void> addNote() async {
    final note = NoteModel(
      id: uuid.v1(),
      title: controller.text,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
    final either = await local.put(note);
    either.fold(
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
        updatedAt: DateTime.now()
    );
    final either = await local.update(note);
    either.fold(
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
    either.fold(
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

    return Scaffold(
      appBar: AppBar(
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
            makeListOfNotes(notes),
            makeBottomField()
          ],
        ),
      ),
    );
  }

  Widget makeListOfNotes(List<NoteModel> notes){
    return Expanded(
      child: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (_, index) {
          final note = notes[index];

          bool isCurrent = currentNote?.id == note.id;

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
                onPressed: (){
                  deleteNote(note.id);
                },
                icon: Icon(Icons.close)
            ),
            onTap: (){
              setState(() {
                currentNote = note;
                controller.text = note.title;
              });
            },
          );
        },
      ),
    );
  }

  Widget makeBottomField(){
    return Row(
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
    );
  }

}
