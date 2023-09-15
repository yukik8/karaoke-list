
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_database/firebase_database.dart';

class HttpFunc {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  late http.Response response;

  Future<http.Response> httpGet(String url) async {
    DataSnapshot snapshot = await dbRef.child('key').get();
    String jwtKey = snapshot.value as String;

    WidgetsFlutterBinding.ensureInitialized();
      response = await http.get(Uri.parse(url),
          headers: {'Authorization': 'Bearer $jwtKey'});
    return response;
  }
}
