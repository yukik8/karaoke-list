import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/song.dart';

class SongList extends StateNotifier<List<Song>> {
  // 引数に初期リストを入れる、なければ空のリスト
  SongList() : super([

  ]);

  void addSong(String id,
  String name,
  String previewUrl,
  String artworkImgUrl,
  String artistName,) {
    state = [...state,
      Song(id: id, name: name, previewUrl: previewUrl, artworkImgUrl: artworkImgUrl, artistName: artistName)
    ];
  }

  // void addSong(String id,
  //     String name,
  //     String previewUrl,
  //     String artworkImgUrl,
  //     String artistName,
  //     List<String> tune) {
  //   Map<Song,List<String>> newTune = {Song(id: id, name: name, previewUrl: previewUrl, artworkImgUrl: artworkImgUrl, artistName: artistName):tune};
  //   state = [...state,
  //     newTune[Song(id: id, name: name, previewUrl: previewUrl, artworkImgUrl: artworkImgUrl, artistName: artistName)],
  //   ];
  // }

  void deleteSong(
      String id,
      String name,
      String previewUrl,
      String artworkImgUrl,
      String artistName,) {

    state = [
      for (final song in state)
        if (song.id != id) song,
    ];
  }

  void deleteAllSongs() {
    state = [];
  }

  void updateSongs(List<Song> newSongs) {
    state = [for (final song in newSongs) song];
  }
}

final songProvider = StateNotifierProvider<SongList, List<Song>>((ref) {
  return SongList();
});