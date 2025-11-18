import 'package:hive_ce/hive.dart';

abstract class CacheService {
  Future<List<dynamic>> getAll(String key);
  Future<void> update(String key, List<Map<String, dynamic>> value);
}

class CacheServiceImpl implements CacheService {

  final String boxName;
  CacheServiceImpl({ required this.boxName });

  @override
  Future<List<dynamic>> getAll(String key) async {
    try {
      final box = await Hive.openBox(boxName);
      final data = box.get(key);
      return data != null ? List<dynamic>.from(data) : [];
    } catch(e){
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> update(String key, List<Map<String, dynamic>> value) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.put(key, value);
    } catch(e){
      throw Exception(e.toString());
    }
  }

}