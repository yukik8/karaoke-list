import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class HttpFunc {
  final String jwtKey = dotenv.get('JWT_KEY');
  late http.Response response;
  Future<http.Response> httpGet(String url) async {
    WidgetsFlutterBinding.ensureInitialized();
      response = await http.get(Uri.parse(url),
          headers: {'Authorization': 'Bearer $jwtKey'});
    return response;
  }
}
