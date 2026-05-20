import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:untitled/pages/history_detail_page.dart';
import '../data/history_notifier.dart';
import '../data/tune_name.dart';




String _formatScore(double score) =>
    score % 1 == 0 ? score.toInt().toString() : score.toStringAsFixed(1);

String _dateLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return '今日';
  if (d == today.subtract(const Duration(days: 1))) return '昨日';
  if (date.year == now.year) return DateFormat('M月d日').format(date);
  return DateFormat('yyyy年M月d日').format(date);
}

// Returns a flat list of either String (date header) or HistoryEntry
List<Object> _buildListItems(List<HistoryEntry> history) {
  final items = <Object>[];
  String? lastLabel;
  for (final entry in history) {
    final label = _dateLabel(entry.history.sungAt);
    if (label != lastLabel) {
      items.add(label);
      lastLabel = label;
    }
    items.add(entry);
  }
  return items;
}

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  MyListPageState createState() => MyListPageState();
}

enum SortType {
  name,
  artistName,
  time
}



class MyListPageState extends ConsumerState<HistoryPage> {
  List<String> tunesList = [];
  DateTime? _selectedMonth; // null = 全て

  @override
  Widget build(BuildContext context) {
    tunesList = ref.watch(tuneProvider);
    final history = ref.watch(historyProvider);

    // 存在する月を新しい順に抽出
    final months = history
        .map((e) => DateTime(e.history.sungAt.year, e.history.sungAt.month))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    // 選択月でフィルタ
    final filtered = _selectedMonth == null
        ? history
        : history.where((e) =>
            e.history.sungAt.year == _selectedMonth!.year &&
            e.history.sungAt.month == _selectedMonth!.month).toList();

    final items = _buildListItems(filtered);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text("Log",
          style: TextStyle(color: Color(0xffC57E14)),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 0.5),
          // 月フィルターチップ
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _MonthChip(
                  label: '全て',
                  selected: _selectedMonth == null,
                  onTap: () => setState(() => _selectedMonth = null),
                ),
                ...months.map((m) => _MonthChip(
                  label: DateFormat('yyyy年M月').format(m),
                  selected: _selectedMonth == m,
                  onTap: () => setState(() => _selectedMonth = m),
                )),
              ],
            ),
          ),
          const Divider(height: 0.5),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                if (item is String) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                    child: Row(
                      children: [
                        Text(
                          item,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF999999),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Divider(thickness: 0.5, color: Color(0xFFDDDDDD)),
                        ),
                      ],
                    ),
                  );
                }

                final entry = item as HistoryEntry;
                return Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet<void>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: HistoryDetail(userSong: entry.userSong, history: entry.history),
                          );
                        },
                      );
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  entry.userSong.song.artworkUrl(52),
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(entry.userSong.song.artistName,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF828282)),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(entry.userSong.song.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff1A1A1A)),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    if (entry.history.memo != null && entry.history.memo!.isNotEmpty)
                                      Text(entry.history.memo!,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF828282)),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              _ScoreBadge(score: entry.history.score),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 0.5, indent: 80),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final double score;

  static _ScoreStyle _style(double score) {
    if (score >= 90) {
      return _ScoreStyle(
        text: const Color(0xFFB8860B),
        bg: const Color(0xFFFFF8DC),
        border: const Color(0xFFFFD700),
      );
    } else if (score >= 70) {
      return _ScoreStyle(
        text: const Color(0xffC57E14),
        bg: const Color(0xffC57E14).withOpacity(0.1),
        border: const Color(0xffC57E14).withOpacity(0.3),
      );
    } else {
      return _ScoreStyle(
        text: const Color(0xFF888888),
        bg: const Color(0xFFF0F0F0),
        border: const Color(0xFFCCCCCC),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.border, width: 1),
      ),
      child: Text(
        _formatScore(score),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: s.text,
        ),
      ),
    );
  }
}

class _ScoreStyle {
  const _ScoreStyle({required this.text, required this.bg, required this.border});
  final Color text;
  final Color bg;
  final Color border;
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xffC57E14) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? const Color(0xffC57E14) : const Color(0xFFDDDDDD),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? Colors.white : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }
}
