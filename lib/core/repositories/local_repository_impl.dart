import 'package:dartz/dartz.dart';
import 'package:flutter_offline_first/core/enums/operation_type_enum.dart';
import 'package:flutter_offline_first/core/model/note_model.dart';
import 'package:flutter_offline_first/core/model/pending_request_model.dart';
import 'package:flutter_offline_first/core/repositories/local_repository.dart';
import 'package:flutter_offline_first/core/services/pending_request_service.dart';
import 'package:uuid/uuid.dart';
import '../errors/failure.dart';
import '../services/cache_service.dart';

class LocalRepositoryImpl implements LocalRepository {
  final CacheService cacheService;
  final PendingRequestService pendingRequestService;

  LocalRepositoryImpl({
    required this.cacheService,
    required this.pendingRequestService,
  });

  final uuid = Uuid();

  @override
  final String key = "notes";

  @override
  Future<Either<Failure, List<NoteModel>>> getAll() async {
    print("getting all locally...");
    try {
      final json = await cacheService.getAll(key);
      final notes = json.map((e) => NoteModel.fromJson(e)).toList();
      return Right(notes);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addOrUpdate(NoteModel item) async {
    print("putting locally...");
    try {
      final json = await cacheService.getAll(key);
      final notes = json.map((e) => NoteModel.fromJson(e)).toList();
      if(!notes.any((n) => n.id == item.id)){
        notes.add(item);
      } else {
        final old = notes.firstWhere((n) => n.id == item.id);
        final index = notes.indexOf(old);
        notes[index] = item;
      }
      await cacheService.update(key, notes.map((e) => e.toJson()).toList() );
      final pendingRequest = PendingRequestModel(
          id: uuid.v1(),
          type: OperationTypeEnum.addOrUpdate,
          note: item
      );
      await pendingRequestService.put(pendingRequest);
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    print("deleting locally...");
    try {
      final json = await cacheService.getAll(key);
      final notes = json.map((e) => NoteModel.fromJson(e)).toList();
      final old = notes.firstWhere((n) => n.id == id);
      notes.removeAt(notes.indexOf(old));
      await cacheService.update(key, notes.map((e) => e.toJson()).toList() );
      final pendingRequest = PendingRequestModel(
          id: uuid.v1(),
          type: OperationTypeEnum.delete,
          note: old
      );
      await pendingRequestService.put(pendingRequest);
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignAll(List<NoteModel> items) async {
    print("putting all locally...");
    try {
      await cacheService.update(key, items.map((e) => e.toJson()).toList() );
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

}