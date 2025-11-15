import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'features/home/home_page.dart';

void initHiveDB() {
  final path = Directory.current.path;
  Hive.init(path);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initHiveDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Offline-first',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}
