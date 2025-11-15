import 'package:hive_ce/hive.dart';

abstract class CacheService<T> {
  Future<List<T>> getAll(String key);
  Future<void> update(String key, List<T> value);
}