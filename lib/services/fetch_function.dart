import 'dart:convert';
import 'dart:async';
import 'package:untitled/models/song.dart';
import 'package:untitled/services/http_function.dart';

class AppleMusicStore {
  AppleMusicStore._privateConstructor();

  static final AppleMusicStore instance = AppleMusicStore._privateConstructor();
  static const storeFront = 'jp';
  static const baseUrl = 'https://api.music.apple.com/v1/catalog';

  Future<dynamic> _fetchJSON(var url) async {
    final response = await HttpFunc().httpGet(url);
    if (response.statusCode == 200) {
      // print("success ${response.statusCode}");
      return json.decode(response.body);
    } else {
      // print("failed ${response.statusCode}");
      throw Exception('Failed to fetch data');
    }
  }

  Future<Song> fetchSongById(String id) async {
    final json = await _fetchJSON("$baseUrl/$storeFront/songs/$id");
    return Song.fromJson(json['data'][0]);
  }

  Future<List<Song>> search(String query,int page) async {
    int offset = (page-1) * 15;
    var url = "$baseUrl/$storeFront/search?types=artists,albums,songs&limit=15&offset=$offset&term=$query";
    final response = await HttpFunc().httpGet(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(
          response.body)['results'];
      final List<dynamic> artistData = jsonMap['songs']['data'];
      final items = artistData.map((item) {
        return Song.fromJson(item);
      }).toList();
      return items;
    } else {
      throw Exception('Failed to fetch article ${response.statusCode}');
    }
  }
}