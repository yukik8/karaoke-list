import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/api_service.dart';
import 'register_page.dart';

// ---- Category data ----

class _Category {
  const _Category(this.label, this.colors, {this.genreId, this.searchQuery});
  final String label;
  final List<Color> colors;
  final int? genreId;       // Charts API で取得
  final String? searchQuery; // Search API にフォールバック
}

const _categories = [
  _Category('J-POP',        [Color(0xFFE91E8C), Color(0xFFFF6B6B)], genreId: 27),
  _Category('アニメ',       [Color(0xFF6C63FF), Color(0xFF9B59B6)], genreId: 29),
  _Category('演歌',         [Color(0xFFC0392B), Color(0xFF8E1A1A)], genreId: 28),
  _Category('ロック',       [Color(0xFF2C3E50), Color(0xFF4A4A4A)], searchQuery: '邦楽ロック'),
  _Category('バラード',     [Color(0xFF2980B9), Color(0xFF1A5276)], searchQuery: 'バラード'),
  _Category('R&B',          [Color(0xFFE67E22), Color(0xFFC0392B)], genreId: 15),
  _Category('アイドル',     [Color(0xFFFF6B9D), Color(0xFFFF8E53)], searchQuery: 'アイドル'),
  _Category('ボカロ',       [Color(0xFF00BCD4), Color(0xFF0097A7)], searchQuery: 'ボカロ'),
  _Category('K-POP',        [Color(0xFF9B59B6), Color(0xFF6C3483)], genreId: 51),
  _Category('ヒップホップ', [Color(0xFF1C1C2E), Color(0xFF2D2D44)], genreId: 18),
  _Category('90年代',       [Color(0xFFF39C12), Color(0xFFD35400)], searchQuery: '90年代 ヒット'),
  _Category('洋楽POP',      [Color(0xFF27AE60), Color(0xFF1E8449)], genreId: 14),
];

// ---- Page ----

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _api = KaraokeApiService.instance;

  String _query = '';
  String _submittedQuery = '';
  bool _isLoading = false;
  bool _hasError = false;
  int _page = 0;
  final List<Song> _results = [];

  static const _gold = Color(0xffC57E14);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        _page < 5) {
      _fetchMore();
    }
  }

  bool _isBrowsingCategory = false;
  int? _browsingGenreId;

  Future<void> _browseCategory(_Category cat) async {
    FocusScope.of(context).unfocus();
    _controller.clear();
    setState(() {
      _query = '';
      _submittedQuery = cat.label;
      _browsingGenreId = cat.genreId;
      _isBrowsingCategory = true;
      _results.clear();
      _page = 0;
      _isLoading = true;
      _hasError = false;
    });
    try {
      final songs = cat.genreId != null
          ? await _api.getChartSongs(genreId: cat.genreId!)
          : await _api.searchSongs(cat.searchQuery ?? cat.label, 1);
      if (mounted) setState(() => _results.addAll(songs));
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submittedQuery = q;
      _browsingGenreId = null;
      _isBrowsingCategory = false;
      _results.clear();
      _page = 0;
      _isLoading = true;
      _hasError = false;
    });
    await _fetchMore();
  }

  void _exitCategoryBrowse() {
    setState(() {
      _submittedQuery = '';
      _browsingGenreId = null;
      _isBrowsingCategory = false;
      _results.clear();
      _page = 0;
      _hasError = false;
    });
  }

  Future<void> _fetchMore() async {
    if (_isLoading && _page > 0) return;
    setState(() {
      _isLoading = true;
      _page++;
    });
    try {
      final songs = await _api.searchSongs(_submittedQuery, _page);
      setState(() => _results.addAll(songs));
    } catch (_) {
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openSong(Song song) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: RegisterPage(
          preUrl: song.previewUrl,
          name: song.name,
          id: song.id,
          imgUrl: song.artworkImgUrl,
          artistName: song.artistName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('曲を追加',
            style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          if (_isBrowsingCategory)
            // Category header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 18, color: Color(0xFF555555)),
                    onPressed: _exitCategoryBrowse,
                  ),
                  Text(
                    _submittedQuery,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            )
          else
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: '曲名・アーティスト名で検索',
                    hintStyle: const TextStyle(
                        fontSize: 14, color: Color(0xFFBBBBBB)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    prefixIcon: const Icon(Icons.search,
                        size: 20, color: Color(0xFFBBBBBB)),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _controller.clear();
                              setState(() {
                                _query = '';
                                _submittedQuery = '';
                                _isBrowsingCategory = false;
                                _results.clear();
                              });
                            },
                            child: const Icon(Icons.close,
                                size: 16, color: Color(0xFFBBBBBB)),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                  onSubmitted: _search,
                ),
              ),
            ),
          const Divider(height: 0.5),
          Expanded(
            child: _hasError
                ? const Center(
                    child: Text('エラーが発生しました',
                        style: TextStyle(color: Color(0xFFAAAAAA))))
                : _submittedQuery.isEmpty
                    ? _browseView()
                    : _resultsView(),
          ),
        ],
      ),
    );
  }

  // ---- Browse (empty state) ----

  Widget _browseView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'カテゴリから探す',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.9,
            ),
            itemCount: _categories.length,
            itemBuilder: (_, i) => _CategoryCard(
              category: _categories[i],
              onTap: () => _browseCategory(_categories[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Search results ----

  Widget _resultsView() {
    if (_isLoading && _results.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_off, size: 48, color: Color(0xFFDDDDDD)),
            const SizedBox(height: 12),
            Text(
              '「$_submittedQuery」は見つかりませんでした',
              style: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _isLoading ? _results.length + 1 : _results.length,
      itemBuilder: (_, i) {
        if (i == _results.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
            ),
          );
        }
        final song = _results[i];
        return _SongRow(song: song, onTap: () => _openSong(song));
      },
    );
  }
}

// ---- Category card ----

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});
  final _Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: category.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Decorative large character
            Positioned(
              right: -6,
              bottom: -14,
              child: Text(
                category.label.substring(0, 1),
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.15),
                  height: 1,
                ),
              ),
            ),
            // Label
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Text(
                category.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Song row ----

class _SongRow extends StatelessWidget {
  const _SongRow({required this.song, required this.onTap});
  final Song song;
  final VoidCallback onTap;

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
                      song.artworkUrl(52),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.artistName,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF828282)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff1A1A1A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.add_circle_outline,
                      color: Color(0xffC57E14), size: 22),
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
