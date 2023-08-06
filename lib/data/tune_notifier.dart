import 'package:flutter_riverpod/flutter_riverpod.dart';

class TuneList extends StateNotifier<List<String>> {
  // 引数に初期リストを入れる、なければ空のリスト
  TuneList() : super([
    '盛り上がる',
    '泣ける',
    'ストレス発散',
    '失恋ソング',
    '応援ソング'
  ]);

  void addTune(String name) {
    state = [...state, name];
  }


  void deleteSong(String name) {
    state = [
      for (final tune in state)
        if (tune != name) tune,
    ];  }

  void deleteAllSongs() {
    state = [];
  }

  void updateSongs(List<String> newTunes) {
    state = [for (final tune in newTunes) tune];
  }
}

final tuneProvider = StateNotifierProvider<TuneList, List<String>>((ref) {
  return TuneList();
});