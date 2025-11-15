import 'package:dartz/dartz.dart';

import '../errors/failure.dart';

abstract class Repository<T> {
  String get key;
  Future<Either<Failure, List<T>>> getAll();
  Future<Either<Failure, void>> put(T item);
  Future<Either<Failure, void>> update(T item);
  Future<Either<Failure, void>> delete(String id);
}