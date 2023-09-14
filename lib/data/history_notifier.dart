import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/song.dart';

class HistoryList extends StateNotifier<List<List<dynamic>>> {
  // 引数に初期リストを入れる、なければ空のリスト
  HistoryList() : super([

  ]);

  void addHistory(List<dynamic> data) {
    state = [...state,
      data
    ];
  }

  void deleteHistory(List<dynamic> data) {

    state = [
      for (final song in state)
        if (song[0].id != data[0].id) song,
    ];
  }

  void deleteAllHistory() {
    state = [];
  }
}

final historyProvider = StateNotifierProvider<HistoryList, List<List<dynamic>>>((ref) {
  return HistoryList();
});