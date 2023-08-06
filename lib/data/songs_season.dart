import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongSeason extends StateNotifier<List<int>> {
  // 引数に初期リストを入れる、なければ空のリスト
  SongSeason() : super([]);

  void addTune(int name) {
    state = [...state, name];
  }


  void deleteTune(int name) {
    state = [
      for (final tune in state)
        if (tune != name) tune,
    ];  }

  void deleteAllTunes() {
    state = [];
  }

  void updateSongs(List<int> newTunes) {
    state = [for (final tune in newTunes) tune];
  }
}

final songSeasonProvider = StateNotifierProvider<SongSeason, List<int>>((ref) {
  return SongSeason();
});