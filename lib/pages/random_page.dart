import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/data/register_notifier.dart';
import 'package:untitled/data/tune_name.dart';
import 'package:untitled/pages/flying_page.dart';
import 'package:untitled/pages/my_song_page.dart';

class RandomPage extends ConsumerStatefulWidget {
  const RandomPage({super.key});

  @override
  RandomPageState createState() => RandomPageState();
}

class RandomPageState extends ConsumerState<RandomPage> {
  final random = Random();
  int? _selectedSeason;
  final Set<String> _selectedTags = {};

  bool _isAnimating = false;
  String _animArtworkUrl = '';
  String _animSongName = '';
  String _animArtistName = '';

  Future<void> _shuffle(List filtered, List data) async {
    final picked = filtered[random.nextInt(filtered.length)];
    final index = data.indexOf(picked);

    setState(() {
      _isAnimating = true;
      final t = filtered[random.nextInt(filtered.length)];
      _animArtworkUrl = t.song.artworkUrl(200);
      _animSongName = '';
      _animArtistName = '';
    });

    // スロットマシン: 速い → 遅くなる
    final delays = [60, 60, 70, 80, 100, 130, 170, 220, 280, 350];
    for (final d in delays) {
      await Future.delayed(Duration(milliseconds: d));
      if (!mounted) return;
      final temp = filtered[random.nextInt(filtered.length)];
      setState(() => _animArtworkUrl = temp.song.artworkUrl(200));
    }

    // 結果に着地
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _animArtworkUrl = picked.song.artworkUrl(200);
      _animSongName = picked.song.name;
      _animArtistName = picked.song.artistName;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isAnimating = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MySongPage(index: index, preUrl: picked.song.previewUrl),
      ),
    );
  }

  static const _seasonEmojis = ['🌸', '🌻', '🍁', '⛄️'];
  static const _seasonColors = [
    Color(0xfff19ec2), Color(0xff00a0e9), Color(0xfff39800), Color(0xff84ccc9),
  ];

  Widget _seasonChip(int index) {
    final isSelected = _selectedSeason == index;
    final color = _seasonColors[index];
    return GestureDetector(
      onTap: () => setState(() => _selectedSeason = isSelected ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : const Color(0xFFDDDDDD)),
        ),
        child: Text(
          _seasonEmojis[index],
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _tagChip(String tag) {
    final isSelected = _selectedTags.contains(tag);
    return GestureDetector(
      onTap: () => setState(() {
        isSelected ? _selectedTags.remove(tag) : _selectedTags.add(tag);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffC57E14) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xffC57E14) : const Color(0xFFDDDDDD),
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : const Color(0xFF888888),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider).valueOrNull ?? [];
    final allTags = ref.watch(tuneProvider);

    final filtered = data.where((song) {
      final seasonMatch = _selectedSeason == null || song.season == _selectedSeason;
      final tagMatch = _selectedTags.isEmpty ||
          _selectedTags.any((t) => song.tags.contains(t));
      return seasonMatch && tagMatch;
    }).toList();

    final hasFilter = _selectedSeason != null || _selectedTags.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pick', style: TextStyle(color: Color(0xffC57E14))),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
        padding: EdgeInsets.fromLTRB(
            24, 0, 24, MediaQuery.of(context).padding.bottom + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 1),
            const Center(child: SplashPage(customPaintSize: 180)),
            const Spacer(flex: 1),
            Center(
              child: Column(
                children: [
                  const Text(
                    '今歌う1曲を決める',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xff1A1A1A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasFilter
                        ? '${filtered.length}曲が対象'
                        : '${data.length}曲から選ぶ',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
            // Season filter
            const Text('季節', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF888888))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) => _seasonChip(i)),
            ),
            if (allTags.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('タグ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF888888))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: allTags.map((t) => _tagChip(t)).toList(),
              ),
            ],
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: filtered.isEmpty
                      ? const Color(0xFFCCCCCC)
                      : const Color(0xffC57E14),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isAnimating ? null : () {
                  if (data.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('マイリストに曲がありません'),
                        content: const Text('左上の＋ボタンから曲を追加してください。'),
                        actions: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Padding(padding: EdgeInsets.all(8), child: Text('戻る')),
                          ),
                        ],
                      ),
                    );
                  } else if (filtered.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('対象の曲がありません'),
                        content: const Text('フィルターを変えて試してみてください。'),
                        actions: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Padding(padding: EdgeInsets.all(8), child: Text('戻る')),
                          ),
                        ],
                      ),
                    );
                  } else {
                    _shuffle(filtered, data);
                  }
                },
                child: Text(
                  filtered.isEmpty ? '対象曲なし' : 'シャッフル',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
          // Slot machine overlay
          if (_isAnimating)
            Container(
              color: Colors.black.withOpacity(0.65),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 80),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: child,
                      ),
                      child: ClipRRect(
                        key: ValueKey(_animArtworkUrl),
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _animArtworkUrl,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedOpacity(
                      opacity: _animSongName.isEmpty ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        children: [
                          Text(
                            _animSongName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _animArtistName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
