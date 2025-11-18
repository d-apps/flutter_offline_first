import 'package:flutter_offline_first/core/enums/operation_type_enum.dart';
import 'package:flutter_offline_first/core/model/note_model.dart';
import 'package:flutter_offline_first/core/model/pending_request_model.dart';
import 'package:flutter_offline_first/core/repositories/local_repository.dart';
import 'package:flutter_offline_first/core/repositories/remote_repository.dart';
import 'package:flutter_offline_first/core/services/connection_service.dart';
import 'package:flutter_offline_first/core/services/pending_request_service.dart';

abstract class SyncService {
  Future<void> sync();
  Future<void> listenConnectivityToSync();
}

class SyncServiceImpl implements SyncService {
  final RemoteRepository remoteRepository;
  final LocalRepository localRepository;
  final PendingRequestService pendingRequestService;
  final ConnectionService connectionService;

  bool _isSyncing = false;

  SyncServiceImpl({
    required this.remoteRepository,
    required this.localRepository,
    required this.pendingRequestService,
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
    print("pushing...");
    final either = await pendingRequestService.getAll();
    if(either.isLeft()) throw Exception("Failed to get pending requests");
    final pending = either.getOrElse(() => []);

    for (final item in pending) {
      bool success = false;

      switch(item.type){
        case OperationTypeEnum.addOrUpdate:
          final either = await remoteRepository.addOrUpdate(item.note);
          success = either.isRight();
          break;
        case OperationTypeEnum.delete:
          final either = await remoteRepository.delete(item.note.id);
          success = either.isRight();
          break;
      }

      if(success){
        await pendingRequestService.delete(item.id);
      }
    }
  }

  Future<bool> _canPull() async {
    final either = await pendingRequestService.getAll();
    if(either.isLeft()) return false;
    final pending = either.getOrElse(() => []);
    return pending.isEmpty;
  }

  Future<void> _pull() async {
    print("pulling...");
    final canPull = await _canPull();
    if(!canPull) return;
    final either = await remoteRepository.getAll();
    if(either.isLeft()) return;
    final notes = either.getOrElse(() => []);
    await localRepository.assignAll(notes);
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
