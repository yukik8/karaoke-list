import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/my_list_page.dart';

class DropDown extends StateNotifier<SortType?> {
  // 引数に初期リストを入れる、なければ空のリスト
  DropDown() : super(null);


  void changeDrop(SortType? season) {
    state = season;
  }
  void deleteDrop() {
    state = null;
  }
}

final dropProvider = StateNotifierProvider<DropDown, SortType?>((ref) {
  return DropDown();
});