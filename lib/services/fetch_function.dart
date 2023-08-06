import 'dart:convert';
import 'dart:async';
import 'package:untitled/models/song.dart';
import 'package:untitled/services/http_function.dart';


class AppleMusicStore {
  AppleMusicStore._privateConstructor();
  static final AppleMusicStore instance = AppleMusicStore._privateConstructor();
  static const storeFront = 'jp';
  static const baseUrl = 'https://api.music.apple.com/v1/catalog';
  // static const GENRE_URL = "$baseUrl/$storeFront/genres";
  // static const _SONG_URL = "$baseUrl/$storeFront/songs";
  // static const _ALBUM_URL = "$baseUrl/$storeFront/albums";
  // static const _CHART_URL = "$baseUrl/$storeFront/charts";
  // static const _ARTIST_URL = "$baseUrl/$storeFront/artists";
  // static const _SEARCH_URL = "$baseUrl/$storeFront/search";

    // Future<List<Article>> fetchArticle({String? searchText, int? page}) async {
    //   var url = '';
    //   if (searchText != null) {
    //     url =
    //     'https://qiita.com/api/v2/items?page=$page&per_page=20&query=body%3A$searchText+title%3A$searchText';
    //   }
    //   final response = await HttpFunc().httpGet(url);
    //   if (response.statusCode == 200) {
    //     final List<dynamic> jsonArray = json.decode(response.body);
    //     final items = jsonArray.map((item) {
    //       return Article.fromJson(item);
    //     }).toList();
    //     return items;
    //   } else {
    //     throw Exception('Failed to fetch article');
    //   }
    // }

  Future<dynamic> _fetchJSON(var url) async {
    final response = await HttpFunc().httpGet(url);
    if (response.statusCode == 200) {
      print("success ${response.statusCode}");
      return json.decode(response.body);
    } else {
      print("failed ${response.statusCode}");
      throw Exception('Failed to fetch data');
    }
  }

  Future<Song> fetchSongById(String id) async {
    final json = await _fetchJSON("$baseUrl/$storeFront/songs/$id");
    return Song.fromJson(json['data'][0]);
  }

  // Future<List<Genre>> fetchGenres() async {
  //   final json = await _fetchJSON("$baseUrl/$storeFront/genres");
  //   final data = json['data'] as List;
  //   final genres = data.map((d) => Genre.fromJson(d));
  //   return genres.toList();
  // }

  // Future<Chart> fetchAlbumsAndSongsTopChart() async {
  //   final url = "$_CHART_URL?types=songs,albums";
  //   final json = await _fetchJSON(url);
  //   final songChartJSON = json['results']['songs'][0];
  //   final songChart = SongChart.fromJson(songChartJSON);
  //
  //   final albumChartJSON = json['results']['albums'][0];
  //   final albumChart = AlbumChart.fromJson(albumChartJSON);
  //
  //   final chart = Chart(albumChart: albumChart, songChart: songChart);
  //   return chart;
  // }

  Future<List<Song>> search(String? query) async {
      var url =
          query == ""
              ? "$baseUrl/$storeFront/search?types=artists,albums,songs&limit=15&term=Apple"
              :"$baseUrl/$storeFront/search?types=artists,albums,songs&limit=15&term=$query" ;
      print(baseUrl);
      print(url);
      final response = await HttpFunc().httpGet(url);
      if (response.statusCode == 200) {
        print(json.decode(response.body)['results']);
        final Map<String, dynamic> jsonMap = json.decode(response.body)['results'];
        print("a");
        final List<dynamic> artistData= jsonMap['songs']['data'];
        final items = artistData.map((item) {
          return Song.fromJson(item);
        }).toList();
        //  items = List<Song>.from(jsonArray.map((Song) => Song.fromJson(Song)));
        return items;
      } else {
        throw Exception('Failed to fetch article ${response.statusCode}');
      }
      // :"$baseUrl/$storeFront/search?types=artists,albums,songs";
    // final encoded = Uri.encodeFull(url);
    // final json = await _fetchJSON(url);
    //
    // final List<Album> albums = [];
    // final List<Song> songs = [];
    // final List<Artist> artists = [];
    //
    // final artistJSON = json['results']['artists'];
    // if (artistJSON != null) {
    //   artists
    //       .addAll((artistJSON['data'] as List).map((a) => Artist.fromJson(a)));
    // }
    //
    // final albumsJSON = json['results']['albums'];
    // if (albumsJSON != null) {
    //   albums.addAll((albumsJSON['data'] as List).map((a) => Album.fromJson(a)));
    // }
    //
    // final songJSON = json['results']['songs'];
    // if (songJSON != null) {
    //   songs.addAll((songJSON['data'] as List).map((a) => Song.fromJson(a)));
    // }
    //
    // return Search(albums: albums, songs: songs, artists: artists, term: query);
  }

//   Future<Home> fetchBrowseHome() async {
//     final chart = await fetchAlbumsAndSongsTopChart();
//     final List<Album> albums = [];
//
//     final album3 = await fetchAlbumById('1340242365');
//
//     albums.add(album3);
//
//     return Home(chart: chart, albums: albums);
//   }
}