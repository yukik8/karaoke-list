import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_song.dart';
import '../services/api_service.dart';

class DataList extends AsyncNotifier<List<UserSong>> {
  @override
  Future<List<UserSong>> build() async {
    return KaraokeApiService.instance.getUserSongs();
  }

  Future<void> addData(UserSong userSong) async {
    final created = await KaraokeApiService.instance.createUserSong(userSong);
    state = AsyncData([...state.value ?? [], created]);
  }

  Future<void> deleteData(String userSongId) async {
    await KaraokeApiService.instance.deleteUserSong(userSongId);
    state = AsyncData(
      (state.value ?? []).where((s) => s.id != userSongId).toList(),
    );
  }

  Future<void> updateData(String userSongId,
      {String? key, int? season, List<String>? tags}) async {
    final updated = await KaraokeApiService.instance.updateUserSong(
      userSongId,
      key: key,
      season: season,
      tags: tags,
    );
    state = AsyncData(
      (state.value ?? [])
          .map((s) => s.id == userSongId ? updated : s)
          .toList(),
    );
  }

  Future<void> addHistory(String userSongId, double score, String? memo, {DateTime? sungAt}) async {
    await KaraokeApiService.instance.addHistory(userSongId, score, memo, sungAt: sungAt);
    final songs = await KaraokeApiService.instance.getUserSongs();
    state = AsyncData(songs);
  }

  Future<void> deleteHistory(String userSongId, String historyId) async {
    await KaraokeApiService.instance.deleteHistory(userSongId, historyId);
    state = AsyncData(
      (state.value ?? []).map((s) {
        if (s.id != userSongId) return s;
        s.history.removeWhere((h) => h.id == historyId);
        return s;
      }).toList(),
    );
  }

  Future<void> updateHistory(
      String userSongId, String historyId, {double? score, String? memo}) async {
    final updated = await KaraokeApiService.instance
        .updateHistory(userSongId, historyId, score: score, memo: memo);
    state = AsyncData(
      (state.value ?? []).map((s) {
        if (s.id != userSongId) return s;
        s.history = s.history.map((h) => h.id == historyId ? updated : h).toList();
        return s;
      }).toList(),
    );
  }

  void reload() {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

final dataProvider =
    AsyncNotifierProvider<DataList, List<UserSong>>(() => DataList());
