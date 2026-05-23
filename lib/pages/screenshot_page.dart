import 'package:flutter/material.dart';
import 'package:untitled/pages/flying_page.dart';

// ─── Fake data ────────────────────────────────────────────────────────────────

class _Song {
  final String name;
  final String artist;
  final Color color;
  final String? key;
  final int? season;
  final List<String> tags;
  const _Song({
    required this.name,
    required this.artist,
    required this.color,
    this.key,
    this.season,
    this.tags = const [],
  });
}

class _HistoryEntry {
  final _Song song;
  final double score;
  final String? memo;
  final DateTime date;
  const _HistoryEntry(this.song, this.score, this.date, {this.memo});
}

const _songs = [
  _Song(name: 'ひかりのなかで',    artist: 'サンセットドリーム',    color: Color(0xffF4A261), key: '+2', season: 0, tags: ['バラード']),
  _Song(name: '夜明けのうた',      artist: 'ブルームーン',          color: Color(0xff457B9D),            season: 3, tags: ['夜', 'しっとり']),
  _Song(name: '波のリズム',        artist: 'オーシャンビート',       color: Color(0xff2A9D8F), key: '-1', season: 1, tags: ['ポップ', 'ドライブ']),
  _Song(name: '秋の終わりに',      artist: 'もみじロード',           color: Color(0xffE76F51),            season: 2, tags: ['しっとり']),
  _Song(name: '走れ！未来へ',      artist: 'ロケットボーイズ',       color: Color(0xff264653), key: '+1', season: 1),
  _Song(name: '夢の欠片',          artist: 'クリスタルボイス',       color: Color(0xff9B5DE5), key: '+1', season: 0, tags: ['バラード']),
  _Song(name: '君の声が聞こえる',  artist: 'エコーライン',           color: Color(0xff00BBF9),            season: 3),
  _Song(name: '空と海のあいだ',    artist: 'アクアマリン',           color: Color(0xff00F5D4),            season: 1, tags: ['爽やか']),
  _Song(name: '星が降る夜に',      artist: 'ムーンライトセレナーデ', color: Color(0xff6D6875), key: '+3', season: 2),
  _Song(name: 'あの日のままで',    artist: 'ソウルブリッジ',         color: Color(0xffFEE440),            season: 0, tags: ['ノリノリ', 'ドライブ']),
];

final _history = [
  _HistoryEntry(_songs[0], 92.5, DateTime(2026, 5, 20), memo: '上手く歌えた！'),
  _HistoryEntry(_songs[2], 85.0, DateTime(2026, 5, 20)),
  _HistoryEntry(_songs[5], 78.3, DateTime(2026, 5, 18), memo: '高音が難しい'),
  _HistoryEntry(_songs[1], 91.0, DateTime(2026, 5, 18)),
  _HistoryEntry(_songs[8], 67.5, DateTime(2026, 5, 15)),
  _HistoryEntry(_songs[3], 88.0, DateTime(2026, 4, 30)),
  _HistoryEntry(_songs[6], 95.5, DateTime(2026, 4, 28), memo: '最高記録！'),
  _HistoryEntry(_songs[9], 72.0, DateTime(2026, 4, 25)),
];

// ─── Screenshot page (PageView) ───────────────────────────────────────────────

class ScreenshotPage extends StatefulWidget {
  const ScreenshotPage({super.key});

  @override
  State<ScreenshotPage> createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> {
  final _controller = PageController();
  int _page = 0;


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: const [
              _MyListScreen(),
              _PickScreen(),
              _LogScreen(),
              _RegisterScreen(),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

Widget _artwork(Color color, {double size = 52}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: Container(
      width: size, height: size,
      color: color,
      child: Icon(Icons.music_note,
          color: Colors.white.withValues(alpha: 0.7), size: size * 0.5),
    ),
  );
}

Widget _tagChip(String label) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
  decoration: BoxDecoration(
    color: const Color(0xffF0F0F0),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF555555))),
);

const _seasonEmoji = ['🌸', '🌻', '🍁', '⛄️'];

Widget _bottomNav(int current) => BottomNavigationBar(
  backgroundColor: Colors.white,
  currentIndex: current,
  onTap: null,
  type: BottomNavigationBarType.fixed,
  selectedItemColor: const Color(0xffC57E14),
  unselectedFontSize: 10,
  selectedFontSize: 10,
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.queue_music, size: 40), label: 'マイリスト'),
    BottomNavigationBarItem(icon: Icon(Icons.mic, size: 40), label: 'おまかせ'),
    BottomNavigationBarItem(icon: Icon(Icons.history, size: 40), label: '記録'),
    BottomNavigationBarItem(icon: Icon(Icons.settings, size: 40), label: '設定'),
  ],
);

// ─── 1. マイリスト ────────────────────────────────────────────────────────────

class _MyListScreen extends StatelessWidget {
  const _MyListScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        backgroundColor: const Color(0xffC57E14),
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text('My List', style: TextStyle(color: Color(0xffC57E14))),
        actions: [
          IconButton(icon: const Icon(Icons.sort, size: 26, color: Color(0xff6F6565)), onPressed: null),
          IconButton(icon: const Icon(Icons.search, size: 30, color: Color(0xff6F6565)), onPressed: null),
        ],
      ),
      bottomNavigationBar: _bottomNav(0),
      body: Column(
        children: [
          const Divider(height: 0.5),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (_, i) {
                final s = _songs[i];
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(children: [
                      _artwork(s.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(children: [
                              Expanded(child: Text(s.artist,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF828282)),
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                              if (s.season != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Text(_seasonEmoji[s.season!],
                                      style: const TextStyle(fontSize: 14)),
                                ),
                            ]),
                            const SizedBox(height: 2),
                            Text(s.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff1A1A1A)),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (s.tags.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(children: s.tags.take(3).map((t) =>
                                Padding(padding: const EdgeInsets.only(right: 4), child: _tagChip(t))
                              ).toList()),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (s.key != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Text('key', style: TextStyle(fontSize: 9, color: Color(0xFF828282))),
                            Text(s.key!, style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xffC57E14))),
                          ]),
                        ),
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.more_vert, size: 20, color: Color(0xFF828282)),
                      ),
                    ]),
                  ),
                  const Divider(height: 1, thickness: 0.5, indent: 80),
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 2. Pick ──────────────────────────────────────────────────────────────────

class _PickScreen extends StatelessWidget {
  const _PickScreen();

  @override
  Widget build(BuildContext context) {
    const tags = ['バラード', 'ノリノリ', 'しっとり', '爽やか', 'ドライブ', '夜'];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text('Pick', style: TextStyle(color: Color(0xffC57E14))),
      ),
      bottomNavigationBar: _bottomNav(1),
      body: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 1),
            const Center(child: SplashPage(customPaintSize: 180)),
            const Spacer(flex: 1),
            Center(child: Column(children: [
              const Text('今歌う1曲を決める',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xff1A1A1A))),
              const SizedBox(height: 4),
              Text('${_songs.length}曲から選ぶ',
                style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
            ])),
            const Spacer(flex: 1),
            const Text('季節',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF888888))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                ),
                child: Text(_seasonEmoji[i], style: const TextStyle(fontSize: 18)),
              )),
            ),
            const SizedBox(height: 14),
            const Text('タグ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF888888))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                ),
                child: Text(t, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
              )).toList(),
            ),
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffC57E14),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: const Text('シャッフル',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 3. 記録 ──────────────────────────────────────────────────────────────────

class _LogScreen extends StatelessWidget {
  const _LogScreen();

  String _dateLabel(DateTime date) {
    final now = DateTime(2026, 5, 21);
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return '今日';
    if (d == today.subtract(const Duration(days: 1))) return '昨日';
    if (date.year == now.year) return '${date.month}月${date.day}日';
    return '${date.year}年${date.month}月${date.day}日';
  }

  @override
  Widget build(BuildContext context) {
    const months = ['全て', '2026年5月', '2026年4月'];

    final items = <Object>[];
    String? lastLabel;
    for (final e in _history) {
      final label = _dateLabel(e.date);
      if (label != lastLabel) { items.add(label); lastLabel = label; }
      items.add(e);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text('Log', style: TextStyle(color: Color(0xffC57E14))),
      ),
      bottomNavigationBar: _bottomNav(2),
      body: Column(children: [
        const Divider(height: 0.5),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: months.map((m) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: m == '全て' ? const Color(0xffC57E14) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: m == '全て' ? const Color(0xffC57E14) : const Color(0xFFDDDDDD)),
                ),
                child: Text(m, style: TextStyle(
                  fontSize: 13,
                  fontWeight: m == '全て' ? FontWeight.w600 : FontWeight.normal,
                  color: m == '全て' ? Colors.white : const Color(0xFF666666),
                )),
              ),
            )).toList(),
          ),
        ),
        const Divider(height: 0.5),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              if (item is String) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                  child: Row(children: [
                    Text(item, style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: Color(0xFF999999), letterSpacing: 0.5)),
                    const SizedBox(width: 8),
                    const Expanded(child: Divider(thickness: 0.5, color: Color(0xFFDDDDDD))),
                  ]),
                );
              }
              final e = item as _HistoryEntry;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    _artwork(e.song.color),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.song.artist,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF828282)),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(e.song.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff1A1A1A)),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (e.memo != null)
                          Text(e.memo!, style: const TextStyle(fontSize: 12, color: Color(0xFF828282)),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    )),
                    const SizedBox(width: 12),
                    _ScoreBadge(score: e.score),
                  ]),
                ),
                const Divider(height: 1, thickness: 0.5, indent: 80),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final Color text, bg, border;
    if (score >= 90) {
      text = const Color(0xFFB8860B); bg = const Color(0xFFFFF8DC); border = const Color(0xFFFFD700);
    } else if (score >= 70) {
      text = const Color(0xffC57E14);
      bg = const Color(0xffC57E14).withValues(alpha: 0.1);
      border = const Color(0xffC57E14).withValues(alpha: 0.3);
    } else {
      text = const Color(0xFF888888); bg = const Color(0xFFF0F0F0); border = const Color(0xFFCCCCCC);
    }
    final s = score % 1 == 0 ? score.toInt().toString() : score.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(s, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
    );
  }
}

// ─── 4. 曲登録 ────────────────────────────────────────────────────────────────

class _RegisterScreen extends StatelessWidget {
  const _RegisterScreen();

  @override
  Widget build(BuildContext context) {
    final song = _songs[0]; // ひかりのなかで
    final artworkSize = MediaQuery.of(context).size.width * 0.62;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Register', style: TextStyle(color: Color(0xffC57E14))),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: artworkSize,
                  height: artworkSize,
                  color: song.color,
                  child: Icon(Icons.music_note,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: artworkSize * 0.4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.artist,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
                const SizedBox(height: 3),
                Text(song.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xff1A1A1A))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.35,
                minHeight: 4,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xffC57E14)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 60,
              child: Stack(alignment: Alignment.center, children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.replay, size: 26, color: Color(0xFFAAAAAA)),
                ),
                Container(
                  width: 60, height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xffC57E14), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ),
              ]),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffC57E14),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: const Text('登録に進む',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
