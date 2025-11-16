import 'package:flutter_offline_first/core/model/note_model.dart';
import 'package:flutter_offline_first/core/repositories/repository.dart';
import 'package:flutter_offline_first/core/services/connection_service.dart';
import 'package:flutter_offline_first/core/services/id_storage_service.dart';

abstract class SyncService {
  Future<void> push();
  Future<void> pull();
  Future<void> listenConnectivityToSync();
}

class SyncServiceImpl implements SyncService {
  final Repository<NoteModel> remoteRepository;
  final Repository<NoteModel> localRepository;
  final IdStorageService idStorageService;
  final ConnectionService connectionService;

  bool _isSyncing = false;

  SyncServiceImpl({
    required this.remoteRepository,
    required this.localRepository,
    required this.idStorageService,
    required this.connectionService,
  });

  @override
  Future<void> listenConnectivityToSync() async {
    connectionService.hasConnection.addListener(() async {
      if (!connectionService.hasConnection.value) return;
      await sync();
    });
  }

  Future<void> sync() async {
    await _runLocked(() async {
      await push();

      final pending = await idStorageService.getIds();
      if (pending.isEmpty) {
        await pull();
      } else {
        print("Pending sync...cannot pull!");
      }
    });
  }

  @override
  Future<void> pull() async {
    print("Pulling...");

    final either = await remoteRepository.getAll();

    return either.fold(
          (l) => print("Pull error: $l"),
          (notes) async {
            await localRepository.putAll(notes);
      },
    );
  }

  @override
  Future<void> push() async {
    print("Pushing...");

    final ids = await idStorageService.getIds();
    if (ids.isEmpty) return;

    final either = await localRepository.getAll();

    return either.fold(
          (l) => print("Push error: $l"),
          (notes) async {
            final notesToServer = notes.where((n) => ids.contains(n.id)).toList();

            for (final note in notesToServer) {
              final result = await remoteRepository.put(note);
              return result.fold(
                  (failure) => print("Failed to send note to server: ${failure.message}"),
                  (_) async {
                    await idStorageService.remove(note.id);
                  },
              );
            }
      },
    );
  }

  Future<void> _runLocked(
      Future<void> Function() action
      ) async {
        if (_isSyncing) return;
        _isSyncing = true;
        try {
          await action();
        } finally {
          _isSyncing = false;
        }
  }
}
