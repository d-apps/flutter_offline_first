import 'package:dartz/dartz.dart';
import 'package:flutter_offline_first/core/model/note_model.dart';
import 'package:flutter_offline_first/core/repositories/remote_repository.dart';
import '../errors/failure.dart';
import '../services/cache_service.dart';

class RemoteRepositoryImpl implements RemoteRepository {
  final CacheService cacheService;
  RemoteRepositoryImpl({ required this.cacheService });

  @override
  final String key = "notes";

  @override
  Future<Either<Failure, List<NoteModel>>> getAll() async {
    print("getting all remotely...");
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
    print("putting remotely...");
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
      await cacheService.update(key, notes.map((e) => e.toJson()).toList());
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    print("deleting remotely...");
    try {
      final json = await cacheService.getAll(key);
      final notes = json.map((e) => NoteModel.fromJson(e)).toList();
      final old = notes.firstWhere((element) => element.id == id);
      final index = notes.indexOf(old);
      notes.removeAt(index);
      await cacheService.update(key, notes.map((e) => e.toJson()).toList());
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignAll(List<NoteModel> items) async {
    print("putting all remotely...");
    try {
      await cacheService.update(key, items.map((e) => e.toJson()).toList() );
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }



}