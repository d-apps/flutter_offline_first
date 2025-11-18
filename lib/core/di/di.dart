import 'package:flutter_offline_first/core/model/note_model.dart';
import 'package:flutter_offline_first/core/model/pending_request_model.dart';
import 'package:flutter_offline_first/core/repositories/local_repository.dart';
import 'package:flutter_offline_first/core/repositories/local_repository_impl.dart';
import 'package:flutter_offline_first/core/repositories/remote_repository.dart';
import 'package:flutter_offline_first/core/repositories/remote_repository_impl.dart';
import 'package:flutter_offline_first/core/services/cache_service.dart';
import 'package:flutter_offline_first/core/services/connection_service.dart';
import 'package:flutter_offline_first/core/services/pending_request_service.dart';
import 'package:flutter_offline_first/core/services/sync_service.dart';
import 'package:get_it/get_it.dart';

Future<void> initializeDependencies() async {
  final getIt = GetIt.instance;

  final connectionService = ConnectionServiceImpl();
  connectionService.listenConnectivity();
  getIt.registerSingleton<ConnectionService>(connectionService);

  getIt.registerSingleton<CacheService>(
      CacheServiceImpl(boxName: "remote"), instanceName: "cache-remote"
  );
  getIt.registerSingleton<CacheService>(
      CacheServiceImpl(boxName: "local"), instanceName: "cache-local"
  );
  getIt.registerSingleton<CacheService>(
      CacheServiceImpl(boxName: "pending"), instanceName: "cache-pending"
  );

  getIt.registerSingleton<PendingRequestService>(PendingRequestServiceImpl(
      cacheService: getIt.get(instanceName: "cache-pending")
  ));

  getIt.registerSingleton<LocalRepository>(LocalRepositoryImpl(
      cacheService: getIt.get(instanceName: "cache-local"),
      pendingRequestService: getIt.get()
  ));
  getIt.registerSingleton<RemoteRepository>(RemoteRepositoryImpl(
      cacheService: getIt.get(instanceName: "cache-remote")
  ));



  final syncService = SyncServiceImpl(
    connectionService: getIt.get(),
    localRepository: getIt.get(),
    remoteRepository: getIt.get(),
    pendingRequestService: getIt.get(),
  );
  syncService.listenConnectivityToSync();
  await syncService.sync();
  getIt.registerSingleton<SyncService>(syncService);
}