import 'package:flutter_offline_first/core/model/note_model.dart';
import 'package:flutter_offline_first/core/repositories/local_repository.dart';
import 'package:flutter_offline_first/core/repositories/local_repository_impl.dart';
import 'package:flutter_offline_first/core/repositories/remote_repository.dart';
import 'package:flutter_offline_first/core/repositories/remote_repository_impl.dart';
import 'package:flutter_offline_first/core/services/cache_service.dart';
import 'package:flutter_offline_first/core/services/connection_service.dart';
import 'package:flutter_offline_first/core/services/id_storage_service.dart';
import 'package:flutter_offline_first/core/services/sync_service.dart';
import 'package:get_it/get_it.dart';

Future<void> initializeDependencies() async {
  final getIt = GetIt.instance;

  final connectionService = ConnectionServiceImpl();
  connectionService.listenConnectivity();
  getIt.registerSingleton<ConnectionService>(connectionService);

  getIt.registerSingleton<CacheService<NoteModel>>(
      CacheServiceImpl(boxName: "remote"), instanceName: "cache-remote"
  );
  getIt.registerSingleton<CacheService<NoteModel>>(
      CacheServiceImpl(boxName: "local"), instanceName: "cache-local"
  );
  getIt.registerSingleton<CacheService<String>>(
      CacheServiceImpl(boxName: "ids"), instanceName: "cache-ids"
  );

  getIt.registerSingleton<LocalRepository>(LocalRepositoryImpl(
      cacheService: getIt.get(instanceName: "cache-local")
  ));
  getIt.registerSingleton<RemoteRepository>(RemoteRepositoryImpl(
      cacheService: getIt.get(instanceName: "cache-remote")
  ));

  getIt.registerSingleton<IdStorageService>(IdStorageServiceImpl(
    cacheService: getIt.get(instanceName: "cache-ids")
  ));

  final syncService = SyncServiceImpl(
    connectionService: getIt.get(),
    localRepository: getIt.get(),
    remoteRepository: getIt.get(),
    idStorageService: getIt.get(),
  );
  syncService.listenConnectivityToSync();
  await syncService.sync();
  getIt.registerSingleton<SyncService>(syncService);
}