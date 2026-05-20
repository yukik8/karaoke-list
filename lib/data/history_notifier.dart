import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_song.dart';
import '../models/singing_history_item.dart';
import 'register_notifier.dart';

class HistoryEntry {
  final SingingHistoryItem history;
  final UserSong userSong;
  HistoryEntry({required this.history, required this.userSong});
}

// Derives all history entries from dataProvider, sorted by date descending
final historyProvider = Provider<List<HistoryEntry>>((ref) {
  final songs = ref.watch(dataProvider).value ?? [];
  final entries = <HistoryEntry>[];
  for (final song in songs) {
    for (final h in song.history) {
      entries.add(HistoryEntry(history: h, userSong: song));
    }
  }
  entries.sort((a, b) => b.history.sungAt.compareTo(a.history.sungAt));
  return entries;
});
