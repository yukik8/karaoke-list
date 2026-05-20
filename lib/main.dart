import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:untitled/root.dart';
import 'package:untitled/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xffC57E14)),
              ),
            );
          }
          if (snapshot.hasData && !snapshot.data!.isAnonymous) {
            return Root(key: ValueKey(snapshot.data!.uid), page: 0);
          }
          return const LoginPage();
        },
      ),
    );
  }
}

