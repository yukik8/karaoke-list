import 'package:flutter_riverpod/flutter_riverpod.dart';

class OneSongTune extends StateNotifier<List<String>> {
  // 引数に初期リストを入れる、なければ空のリスト
  OneSongTune() : super([]);

  void addTune(String name) {
    state = [...state, name];
  }


  void deleteTune(String name) {
    state = [
      for (final tune in state)
        if (tune != name) tune,
    ];  }

  void deleteAllTunes() {
    state = [];
  }

  void updateSongs(List<String> newTunes) {
    state = [for (final tune in newTunes) tune];
  }
}

final oneTuneProvider = StateNotifierProvider<OneSongTune, List<String>>((ref) {
  return OneSongTune();
});