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
    final created = await KaraokeApiService.instance.addHistory(
      userSongId, score, memo, sungAt: sungAt);
    // Patch the existing song's history in-place (newest-first) instead of
    // re-fetching the whole list — keeps the My List view snappy after singing.
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final s in current)
        if (s.id == userSongId)
          UserSong(
            id: s.id,
            song: s.song,
            key: s.key,
            season: s.season,
            tags: s.tags,
            createdAt: s.createdAt,
            history: [created, ...s.history],
          )
        else
          s,
    ]);
  }

  void reload() {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

final dataProvider =
    AsyncNotifierProvider<DataList, List<UserSong>>(() => DataList());
