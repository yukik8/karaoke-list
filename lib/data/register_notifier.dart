import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/song.dart';

class DataList extends StateNotifier<List<List<dynamic>>> {
  // 引数に初期リストを入れる、なければ空のリスト
  DataList() : super([

  ]);

  void addData(List<dynamic> data) {
    state = [...state,
      data
    ];
  }

  void deleteData(List<dynamic> data) {

    state = [
      for (final song in state)
        if (song[0].id != data[0].id) song,
    ];
  }

  void deleteAllData() {
    state = [];
  }
}

final dataProvider = StateNotifierProvider<DataList, List<List<dynamic>>>((ref) {
  return DataList();
});