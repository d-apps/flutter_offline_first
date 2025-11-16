import 'package:hive_ce/hive.dart';

abstract class CacheService<T> {
  Future<List<T>> getAll(String key);
  Future<void> update(String key, List<T> value);
}

class CacheServiceImpl<T> implements CacheService<T> {

  final String boxName;
  CacheServiceImpl({ required this.boxName });

  @override
  Future<List<T>> getAll(String key) async {
    try {
      final box = await Hive.openBox(boxName);
      return box.get(key) ?? <T>[];
    } catch(e){
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> update(String key, List<T> value) async {
    try {
      final box = await Hive.openBox(boxName);
      box.put(key, value);
    } catch(e){
      throw Exception(e.toString());
    }
  }

}