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
    state = AsyncData([...state.valueOrNull ?? [], created]);
  }

  Future<void> deleteData(String userSongId) async {
    await KaraokeApiService.instance.deleteUserSong(userSongId);
    state = AsyncData(
      (state.valueOrNull ?? []).where((s) => s.id != userSongId).toList(),
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
      (state.valueOrNull ?? [])
          .map((s) => s.id == userSongId ? updated : s)
          .toList(),
    );
  }

  Future<void> addHistory(String userSongId, double score, String? memo, {DateTime? sungAt}) async {
    await KaraokeApiService.instance.addHistory(userSongId, score, memo, sungAt: sungAt);
    // Reload to get updated history
    final songs = await KaraokeApiService.instance.getUserSongs();
    state = AsyncData(songs);
  }

  void reload() {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

final dataProvider =
    AsyncNotifierProvider<DataList, List<UserSong>>(() => DataList());
