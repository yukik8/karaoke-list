import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:untitled/root.dart';


void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
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

