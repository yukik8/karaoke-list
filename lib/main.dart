import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/song.dart';
import 'package:untitled/root.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

final numberProvider = StateProvider<int>((ref) => 0);
final songListProvider = StateProvider<List<String>>((ref) => []);
final masterProvider = StateProvider<List<String>>((ref) => []);
final tagProvider = StateProvider<List<String>>((ref) => []);


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const Root(page: 0,),
    );
  }
}

