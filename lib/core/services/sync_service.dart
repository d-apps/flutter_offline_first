import 'package:flutter_offline_first/core/model/note_model.dart';
import 'package:flutter_offline_first/core/repositories/local_repository.dart';
import 'package:flutter_offline_first/core/repositories/remote_repository.dart';
import 'package:flutter_offline_first/core/services/connection_service.dart';

abstract class SyncService {
  Future<void> sync();
  Future<void> listenConnectivityToSync();
}

class SyncServiceImpl implements SyncService {
  final RemoteRepository remoteRepository;
  final LocalRepository localRepository;
  final ConnectionService connectionService;

  bool _isSyncing = false;

  SyncServiceImpl({
    required this.remoteRepository,
    required this.localRepository,
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
    await _runLocked(() async {
      await _push();
      await _pull();
    });
  }

  Future<void> _push() async {
    print("pushing first...");
    final either = await localRepository.getAll();
    return either.fold(
          (l) => print("Push error: $l"),
          (notes) async {

        for (final note in notes) {
          if(note.synced == false){
            final result = await remoteRepository.put(
                note.copyWith(synced: true)
            );
            result.fold(
                  (failure) => print("Failed to send note to server: ${failure.message}"),
                  (_){},
            );
          }
        }
      },
    );
  }

  Future<bool> _canPull() async {
    final either = await localRepository.getAll();
    return either.fold(
          (f){
            print("failed to get notes from local ${f.message}");
            return false;
          },
          (notes) async {
            final pending = notes
                .where((n) => n.synced == false)
                .toList();
            return pending.isEmpty;
      },
    );
  }

  Future<void> _pull() async {
    print("pulling...");
    final canPull = await _canPull();
    if(!canPull) return;
    final either = await remoteRepository.getAll();
    return either.fold(
          (l) => print("Pull error: $l"),
          (notes) async {
        await localRepository.putAll(notes);
      },
    );
  }

  Future<void> _runLocked(
      Future<void> Function() action
      ) async {
        if (!hasConnection || _isSyncing) return;
        _isSyncing = true;
        try {
          await action();
        } finally {
          _isSyncing = false;
        }
  }
}
