import 'package:flutter_offline_first/core/model/note_model.dart';
import 'package:flutter_offline_first/core/repositories/local_repository.dart';
import 'package:flutter_offline_first/core/repositories/remote_repository.dart';
import 'package:flutter_offline_first/core/services/connection_service.dart';
import 'package:flutter_offline_first/core/services/id_storage_service.dart';

abstract class SyncService {
  Future<void> sync();
  Future<void> _push();
  Future<void> _pull();
  Future<void> listenConnectivityToSync();
}

class SyncServiceImpl implements SyncService {
  final RemoteRepository remoteRepository;
  final LocalRepository localRepository;
  final IdStorageService idStorageService;
  final ConnectionService connectionService;

  bool _isSyncing = false;

  SyncServiceImpl({
    required this.remoteRepository,
    required this.localRepository,
    required this.idStorageService,
    required this.connectionService,
  });

  bool get hasConnection => connectionService.hasConnection.value;

  @override
  Future<void> listenConnectivityToSync() async {
    connectionService.hasConnection.addListener(() async {
      if (!hasConnection) return;
      await sync();
    });
  }

  @override
  Future<void> sync() async {
    if(!hasConnection) return;
    await _runLocked(() async {
      await _push();

      final pending = await idStorageService.getIds();
      if (pending.isEmpty) {
        await _pull();
      } else {
        print("Pending sync...cannot pull!");
      }
    });
  }

  @override
  Future<void> _pull() async {
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
  Future<void> _push() async {
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
              result.fold(
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
