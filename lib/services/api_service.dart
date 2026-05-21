import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/singing_history_item.dart';
import '../models/song.dart';
import '../models/user_song.dart';

class KaraokeApiService {
  static KaraokeApiService instance = KaraokeApiService._();
  KaraokeApiService._();

  static const _baseUrl = 'https://karaoke-api-851518528050.asia-northeast1.run.app';

  Future<String> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return await user.getIdToken() ?? '';
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<UserSong>> getUserSongs() async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/v1/user-songs'),
      headers: await _headers(),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to load songs: ${resp.statusCode}');
    }
    final List<dynamic> data = json.decode(utf8.decode(resp.bodyBytes));
    return data.map((e) => UserSong.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<UserSong> createUserSong(UserSong userSong) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/v1/user-songs'),
      headers: await _headers(),
      body: json.encode(userSong.toCreateJson()),
    );
    if (resp.statusCode != 201) {
      throw Exception('Failed to create song: ${resp.statusCode}');
    }
    return UserSong.fromJson(
        json.decode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>);
  }

  Future<UserSong> updateUserSong(String id,
      {String? key, int? season, List<String>? tags}) async {
    final body = <String, dynamic>{};
    if (key != null) body['key'] = key;
    if (season != null) body['season'] = season;
    if (tags != null) body['tags'] = tags;
    final resp = await http.patch(
      Uri.parse('$_baseUrl/v1/user-songs/$id'),
      headers: await _headers(),
      body: json.encode(body),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to update song: ${resp.statusCode}');
    }
    return UserSong.fromJson(
        json.decode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>);
  }

  Future<void> deleteUserSong(String id) async {
    final resp = await http.delete(
      Uri.parse('$_baseUrl/v1/user-songs/$id'),
      headers: await _headers(),
    );
    if (resp.statusCode != 204) {
      throw Exception('Failed to delete song: ${resp.statusCode}');
    }
  }

  Future<void> deleteAccount() async {
    final resp = await http.delete(
      Uri.parse('$_baseUrl/v1/account'),
      headers: await _headers(),
    );
    if (resp.statusCode != 204) {
      throw Exception('Failed to delete account: ${resp.statusCode}');
    }
  }

  Future<List<Song>> getChartSongs({required int genreId, int limit = 20}) async {
    final uri = Uri.parse('$_baseUrl/v1/songs/charts').replace(
      queryParameters: {'genre': '$genreId', 'limit': '$limit'},
    );
    final resp = await http.get(uri, headers: await _headers());
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch charts: ${resp.statusCode}');
    }
    final List<dynamic> data = json.decode(utf8.decode(resp.bodyBytes));
    return data.map((e) => Song.fromBackendJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Song>> searchSongs(String query, int page) async {
    final offset = (page - 1) * 15;
    final uri = Uri.parse('$_baseUrl/v1/songs/search').replace(
      queryParameters: {'query': query, 'limit': '15', 'offset': '$offset'},
    );
    final resp = await http.get(uri, headers: await _headers());
    if (resp.statusCode != 200) {
      throw Exception('Failed to search songs: ${resp.statusCode}');
    }
    final List<dynamic> data = json.decode(utf8.decode(resp.bodyBytes));
    return data.map((e) => Song.fromBackendJson(e as Map<String, dynamic>)).toList();
  }

  Future<SingingHistoryItem> addHistory(String userSongId, double score, String? memo, {DateTime? sungAt}) async {
    final body = <String, dynamic>{'score': score};
    if (memo != null && memo.isNotEmpty) body['memo'] = memo;
    if (sungAt != null) body['sung_at'] = sungAt.toIso8601String();
    final resp = await http.post(
      Uri.parse('$_baseUrl/v1/user-songs/$userSongId/history'),
      headers: await _headers(),
      body: json.encode(body),
    );
    if (resp.statusCode != 201) {
      throw Exception('Failed to add history: ${resp.statusCode}');
    }
    return SingingHistoryItem.fromJson(
        json.decode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>);
  }
}
