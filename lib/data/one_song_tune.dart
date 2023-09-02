import 'package:flutter_riverpod/flutter_riverpod.dart';

class OneSongTune extends StateNotifier<List<String>> {
  // 引数に初期リストを入れる、なければ空のリスト
  OneSongTune() : super([]);

  void addSongsTune(String name) {
    state = [...state, name];
  }


  void deleteSongsTune(String name) {
    state = [
      for (final tune in state)
        if (tune != name) tune,
    ];  }

  void deleteSongsAllTunes() {
    state = [];
  }

}

final oneTuneProvider = StateNotifierProvider<OneSongTune, List<String>>((ref) {
  return OneSongTune();
});