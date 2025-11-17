import 'package:dartz/dartz.dart';
import '../errors/failure.dart';
import '../model/note_model.dart';

abstract class LocalRepository {
  String get key;
  Future<Either<Failure, List<NoteModel>>> getAll();
  Future<Either<Failure, void>> put(NoteModel item);
  Future<Either<Failure, void>> putAll(List<NoteModel> items);
  Future<Either<Failure, void>> update(NoteModel item);
  Future<Either<Failure, void>> delete(String id);
}