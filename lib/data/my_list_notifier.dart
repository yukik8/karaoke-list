import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/song.dart';

class MyList extends StateNotifier<List<List<dynamic>>> {
  // 引数に初期リストを入れる、なければ空のリスト
  MyList() : super([

  ]);

  void addMyList(List<dynamic> data) {
    state = [...state,
      data
    ];
  }

  void deleteMyList(List<dynamic> data) {

    state = [
      for (final song in state)
        if (song[0].id != data[0].id) song,
    ];
  }

  void deleteAllMyList() {
    state = [];
  }
}

final myListProvider = StateNotifierProvider<MyList, List<List<dynamic>>>((ref) {
  return MyList();
});