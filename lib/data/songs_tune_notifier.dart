import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongsTuneList extends StateNotifier<List<List<String>>> {

  // 引数に初期リストを入れる、なければ空のリスト
  SongsTuneList() : super([
    []
  ]);

  void addTune(List<String> name) {
    state = [...state, name];
  }


  void deleteTune(List<String> name) {
    state = [
      for (final tune in state)
        if (tune != name) tune,
    ];  }

  void deleteAllTune() {
    state = [];
  }

  void updateTunes(List<List<String>> newTunes) {
    state = [for (final tune in newTunes) tune];
  }
}

final songsTuneProvider = StateNotifierProvider<SongsTuneList, List<List<String>>>((ref) {
  return SongsTuneList();
});