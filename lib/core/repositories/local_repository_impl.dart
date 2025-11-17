import 'package:dartz/dartz.dart';
import 'package:flutter_offline_first/core/model/note_model.dart';
import 'package:flutter_offline_first/core/repositories/local_repository.dart';
import '../errors/failure.dart';
import '../services/cache_service.dart';

class LocalRepositoryImpl implements LocalRepository {
  final CacheService<NoteModel> cacheService;

  LocalRepositoryImpl({
    required this.cacheService,
  });

  @override
  final String key = "notes";

  @override
  Future<Either<Failure, List<NoteModel>>> getAll() async {
    print("getting all locally...");
    try {
      final response = await cacheService.getAll(key);
      return Right(response);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> put(NoteModel item) async {
    print("putting locally...");
    try {
      final notes = await cacheService.getAll(key);
      notes.add(item);
      await cacheService.update(key, notes);
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> update(NoteModel item) async {
    print("updating locally...");
    try {
      final notes = await cacheService.getAll(key);
      final old = notes.firstWhere((element) => element.id == item.id);
      final index = notes.indexOf(old);
      notes[index] = item;
      await cacheService.update(key, notes);
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    print("deleting locally...");
    try {
      final notes = await cacheService.getAll(key);
      final old = notes.firstWhere((element) => element.id == id);
      final index = notes.indexOf(old);
      notes.removeAt(index);
      await cacheService.update(key, notes);
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> putAll(List<NoteModel> items) async {
    print("putting all locally...");
    try {
      final notes = await cacheService.getAll(key);
      notes.addAll(items);
      await cacheService.update(key, notes);
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }



}