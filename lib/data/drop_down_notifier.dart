import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/my_list_page.dart';

const _kSortKey = 'sort_type';

class DropDown extends StateNotifier<SortType?> {
  DropDown() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kSortKey);
    state = SortType.values.where((e) => e.name == saved).firstOrNull;
  }

  Future<void> changeDrop(SortType? value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_kSortKey);
    } else {
      await prefs.setString(_kSortKey, value.name);
    }
  }

  void deleteDrop() => changeDrop(null);
}

final dropProvider = StateNotifierProvider<DropDown, SortType?>((ref) {
  return DropDown();
});
