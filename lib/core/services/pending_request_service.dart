import 'package:dartz/dartz.dart';
import 'package:flutter_offline_first/core/errors/failure.dart';
import 'package:flutter_offline_first/core/services/cache_service.dart';
import '../model/pending_request_model.dart';

abstract class PendingRequestService {
  String get key;
  Future<Either<Failure, List<PendingRequestModel>>> getAll();
  Future<Either<Failure, void>> put(PendingRequestModel item);
  Future<Either<Failure, void>> delete(String id);
}

class PendingRequestServiceImpl implements PendingRequestService {
  final CacheService cacheService;

  PendingRequestServiceImpl({
    required this.cacheService
  });

  @override
  final String key = "pending-requests";

  @override
  Future<Either<Failure, void>> put(PendingRequestModel item) async {
    try {
      final json = await cacheService.getAll(key);
      final pending = json.map((e) => PendingRequestModel.fromJson(e)).toList();
      pending.add(item);
      await cacheService.update(key, pending.map((e) => e.toJson()).toList() );
      return Right(null);
    } catch(e){
       throw Exception(e.toString());
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final list = await cacheService.getAll(key);
      final pending = list.map((e) => PendingRequestModel.fromJson(e)).toList();
      pending.removeWhere((element) => element.id == id);
      await cacheService.update(key, pending.map((e) => e.toJson()).toList() );
      return Right(null);
    } catch(e){
      throw Exception(e.toString());
    }
  }

  @override
  Future<Either<Failure, List<PendingRequestModel>>> getAll() async {
    try {
      final pending = await cacheService.getAll(key);
      return Right(pending.map((e) => PendingRequestModel.fromJson(e)).toList());
    } catch(e){
      throw Exception(e.toString());
    }
  }


}