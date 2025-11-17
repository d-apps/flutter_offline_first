import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_offline_first/core/di/di.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'core/model/note_adapter.dart';
import 'features/home/home_page.dart';

Future<void> initHiveDB() async {
  final path = (await getApplicationDocumentsDirectory()).path;
  Hive.init(path);
  Hive.registerAdapter(NoteAdapter());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveDB();
  await initializeDependencies();
  runApp(const MyApp());
}

final getIt = GetIt.instance;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Offline-first',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(
        local: getIt.get(),
        syncService: getIt.get(),
        connectionService: getIt.get(),
      ),
    );
  }
}
