import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpFunc {
  late http.Response response;
  Future<http.Response> httpGet(String url) async {
    WidgetsFlutterBinding.ensureInitialized();
    final fetchedAccessToken =  'INSERT ACCESS TOKEN';
      response = await http.get(Uri.parse(url),
          headers: {'Authorization': 'Bearer $fetchedAccessToken'});
    return response;
  }
}
