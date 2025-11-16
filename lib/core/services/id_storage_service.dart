
import 'cache_service.dart';

abstract class IdStorageService {
  String get key;
  Future<List<String>> getIds();
  Future<void> add(String id);
  Future<void> remove(String id);
}

class IdStorageServiceImpl implements IdStorageService {

  @override
  String get key => "ids";

  final CacheService<String> service;
  IdStorageServiceImpl(this.service);

  @override
  Future<void> add(String id) async {
    final list = await service.getAll(key);
    final ids = List<String>.from(list);
    ids.add(id);
    await service.update(key, ids.toSet().toList());
  }

  @override
  Future<void> remove(String id) async {
    final list = await service.getAll(key);
    final ids = List<String>.from(list);
    ids.remove(id);
    await service.update(key, ids);
  }

  @override
  Future<List<String>> getIds() async {
    final list = await service.getAll(key);
    final ids = List<String>.from(list);
    return ids;
  }

}
