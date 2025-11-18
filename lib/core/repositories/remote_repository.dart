import 'package:dartz/dartz.dart';
import 'package:flutter_offline_first/core/model/note_model.dart';
import '../errors/failure.dart';

abstract class RemoteRepository {
  String get key;
  Future<Either<Failure, List<NoteModel>>> getAll();
  Future<Either<Failure, void>> addOrUpdate(NoteModel item);
  Future<Either<Failure, void>> assignAll(List<NoteModel> items);
  Future<Either<Failure, void>> delete(String id);
}