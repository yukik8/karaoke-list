import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/register_notifier.dart';
import '../models/user_song.dart';
import 'my_song_page.dart';

class ListSearchPage extends ConsumerStatefulWidget {
  const ListSearchPage({super.key});

  @override
  ConsumerState<ListSearchPage> createState() => _ListSearchPageState();
}

class _ListSearchPageState extends ConsumerState<ListSearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _allTags(List<UserSong> all) {
    final tags = <String>{};
    for (final s in all) {
      tags.addAll(s.tags);
    }
    return tags.toList()..sort();
  }

  List<({UserSong song, int index})> _filtered(List<UserSong> all) {
    final q = _query.trim().toLowerCase();
    final indexed = all.indexed
        .map((e) => (song: e.$2, index: e.$1))
        .toList();
    return indexed.where((e) {
      final s = e.song;
      final matchesText = q.isEmpty ||
          s.song.name.toLowerCase().contains(q) ||
          s.song.artistName.toLowerCase().contains(q);
      final matchesTags = _selectedTags.isEmpty ||
          _selectedTags.every((t) => s.tags.contains(t));
      return matchesText && matchesTags;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allSongs = ref.watch(dataProvider).valueOrNull ?? [];
    final allTags = _allTags(allSongs);
    final results = _filtered(allSongs);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Container(
          height: 38,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: '曲名・アーティスト・タグ',
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFBBBBBB)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFFBBBBBB)),
              suffixIcon: _query.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(Icons.close, size: 16, color: Color(0xFFBBBBBB)),
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 0.5),
          // Tag filter chips
          if (allTags.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                children: allTags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        selected
                            ? _selectedTags.remove(tag)
                            : _selectedTags.add(tag);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xffC57E14)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? const Color(0xffC57E14)
                                : const Color(0xFFDDDDDD),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (allTags.isNotEmpty) const Divider(height: 0.5),
          if (_query.isNotEmpty || _selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
              child: Row(
                children: [
                  Text(
                    '${results.length}件',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty ? '' : '「$_query」は見つかりませんでした',
                      style: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
                    ),
                  )
                : ListView.builder(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final item = results[i];
                      return _SongRow(
                        song: item.song,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(10)),
                            ),
                            builder: (_) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: MySongPage(
                                index: item.index,
                                preUrl: item.song.song.previewUrl,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SongRow extends StatelessWidget {
  const _SongRow({required this.song, required this.onTap});
  final UserSong song;
  final VoidCallback onTap;

  static const _seasonEmojis = ['🌸', '🌻', '🍁', '⛄️'];

  Widget _tagChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF555555))),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      song.song.artworkUrl(52),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                song.song.artistName,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF828282)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (song.season != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  _seasonEmojis[song.season!.clamp(0, 3)],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song.song.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff1A1A1A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (song.tags.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...song.tags.take(3).map((t) => Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: _tagChip(t),
                                  )),
                              if (song.tags.length > 3)
                                _tagChip('+${song.tags.length - 3}'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (song.key != null && song.key!.isNotEmpty)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('key',
                            style: TextStyle(
                                fontSize: 9, color: Color(0xFF828282))),
                        Text(song.key!,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xffC57E14))),
                      ],
                    ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5, indent: 80),
          ],
        ),
      ),
    );
  }
}
