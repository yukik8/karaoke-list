import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/data/drop_down_notifier.dart';
import 'package:untitled/pages/list_edit_page.dart';
import 'package:untitled/pages/list_search_page.dart';
import 'package:untitled/pages/my_song_page.dart';
import 'package:untitled/pages/search_page.dart';
import '../data/one_song_tune.dart';
import '../data/register_notifier.dart';
import '../models/user_song.dart';




class MyListPage extends ConsumerStatefulWidget {
  const MyListPage({super.key});

  @override
  MyListPageState createState() => MyListPageState();
}

enum SortType { name, artistName, time }



class MyListPageState extends ConsumerState<MyListPage> {

  @override
  void initState() {
    super.initState();
  }

  void _showSortSheet(BuildContext context) {
    final current = ref.read(dropProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('並び替え',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff1A1A1A))),
                const SizedBox(height: 12),
                _SortOption(
                  icon: Icons.library_music_outlined,
                  label: '曲名順',
                  selected: current == SortType.name,
                  onTap: () {
                    ref.read(dropProvider.notifier).changeDrop(SortType.name);
                    Navigator.pop(context);
                  },
                ),
                _SortOption(
                  icon: Icons.person_outline_rounded,
                  label: 'アーティスト名順',
                  selected: current == SortType.artistName,
                  onTap: () {
                    ref.read(dropProvider.notifier).changeDrop(SortType.artistName);
                    Navigator.pop(context);
                  },
                ),
                _SortOption(
                  icon: Icons.schedule,
                  label: '登録した日付順',
                  selected: current == SortType.time,
                  onTap: () {
                    ref.read(dropProvider.notifier).changeDrop(SortType.time);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _loadingView() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xffC57E14)),
    );
  }

  Widget _seasonBadge(int season) {
    const labels = ['🌸', '🌻', '🍁', '⛄️'];
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(labels[season.clamp(0, 3)], style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _tagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xffF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF555555))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(dataProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        ),
        backgroundColor: const Color(0xffC57E14),
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text("My List",
          style: TextStyle(color: Color(0xffC57E14)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, size: 26, color: Color(0xff6F6565)),
            onPressed: () => _showSortSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.search,
                size: 30,color: Color(0xff6F6565)),
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListSearchPage()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 0.5),
          SizedBox(
            height: 8,
            child: Container(
              color: Colors.white,
            ),
          ),
          Expanded(
            child: asyncData.when(
              loading: () => _loadingView(),
              error: (err, _) => Center(child: Text('エラーが発生しました: $err')),
              data: (rawData) {
                // Apply sort based on current sort type
                final data = List<UserSong>.from(rawData);
                final sortType = ref.watch(dropProvider);
                switch (sortType) {
                  case SortType.name:
                    data.sort((a, b) => a.song.name.compareTo(b.song.name));
                    break;
                  case SortType.artistName:
                    data.sort((a, b) => a.song.artistName.compareTo(b.song.artistName));
                    break;
                  case SortType.time:
                    data.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                    break;
                  case null:
                    break;
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    if (index >= data.length) {
                      return const SizedBox.shrink();
                    }
                    final song = data[index];
                    // find the actual index in rawData for navigation
                    final rawIndex = rawData.indexOf(song);
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
                                child: MySongPage(index: rawIndex, preUrl: song.song.previewUrl),
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
                                                style: const TextStyle(fontSize: 11, color: Color(0xFF828282)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (song.season != null) _seasonBadge(song.season!),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          song.song.name,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff1A1A1A)),
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
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('key', style: TextStyle(fontSize: 9, color: Color(0xFF828282))),
                                          Text(song.key!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xffC57E14))),
                                        ],
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditPage(userSong: song)));
                                      ref.read(oneTuneProvider.notifier).deleteSongsAllTunes();
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.more_vert, size: 20, color: Color(0xFF828282)),
                                    ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: selected ? const Color(0xffC57E14) : const Color(0xFF999999)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? const Color(0xffC57E14) : const Color(0xFF333333),
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 18, color: Color(0xffC57E14)),
          ],
        ),
      ),
    );
  }
}
