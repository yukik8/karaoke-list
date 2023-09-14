import 'package:flutter_riverpod/flutter_riverpod.dart';

class Season extends StateNotifier<int?> {
  // 引数に初期リストを入れる、なければ空のリスト
  Season() : super(null);


  void changeSeason(int? season) {
    state = season;
  }
  void deleteSeason() {
    state = null;
  }
}

final seasonProvider = StateNotifierProvider<Season, int?>((ref) {
  return Season();
});