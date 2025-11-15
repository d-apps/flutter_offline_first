import 'package:dartz/dartz.dart';
import 'package:flutter_offline_first/core/repositories/repository.dart';
import 'package:flutter_offline_first/core/services/cache_service.dart';
import 'package:flutter_offline_first/core/model/note_model.dart';
import '../errors/failure.dart';

class ServerRepository implements Repository<NoteModel> {
  final CacheService<NoteModel> service;
  ServerRepository({ required this.service });

  @override
  final String key = "note";

  @override
  Future<Either<Failure, List<NoteModel>>> getAll() async {
    try {
      final response = await service.getAll(key);
      return Right(response);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> put(NoteModel item) async {
    try {
      final notes = await service.getAll(key);
      notes.add(item);
      await service.update(key, notes);
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> update(NoteModel item) async {
    try {
      final notes = await service.getAll(key);
      final old = notes.firstWhere((element) => element.id == item.id);
      final index = notes.indexOf(old);
      notes[index] = item;
      await service.update(key, notes);
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final notes = await service.getAll(key);
      final old = notes.firstWhere((element) => element.id == id);
      final index = notes.indexOf(old);
      notes.removeAt(index);
      await service.update(key, notes);
      return Right(null);
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }



}