import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/data/register_notifier.dart';
import 'package:untitled/pages/my_song_page.dart';

final onSearchProvider = StateProvider((ref) => false);
final StateProvider<List<int>> searchIndexListProvider =
StateProvider((ref) => []);

class ListSearchPage extends ConsumerWidget {
  const ListSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSearchNotifier = ref.watch(onSearchProvider.notifier);
    final onSearch = ref.watch(onSearchProvider);
    final searchIndexListNotifier = ref.watch(searchIndexListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
          title: onSearch
              ? _searchTextField(ref)
              : const Text("Search",
          style: TextStyle(color: Color(0xffC57E14)),),
          actions: onSearch
              ? [
            IconButton(
                onPressed: () {
                  onSearchNotifier.state = false;
                },
                icon: const Icon(Icons.clear)),
          ]
              : [
            IconButton(
                onPressed: () {
                  onSearchNotifier.state = true;
                  searchIndexListNotifier.state = [];
                },
                icon: const Icon(Icons.search)),
          ]),
      body: onSearch ? _searchListView(ref) : _defaultListView(ref),
    );
  }

  Widget _searchTextField(WidgetRef ref) {
    final wordList = ref.watch(dataProvider);
    final searchIndexListNotifier = ref.watch(searchIndexListProvider.notifier);
    return TextField(
      autofocus: true,
      onChanged: (String text) {
        searchIndexListNotifier.state = [];
        for (int i = 0; i < wordList.length; i++) {
          if (wordList[i][0].name.contains(text) || wordList[i][0].artistName.contains(text)) {
            searchIndexListNotifier.state.add(i); // 今回の問題はここ！！！
          }
        }
      },
    );
  }

  Widget _searchListView(WidgetRef ref) {
    final wordList = ref.watch(dataProvider);
    final searchIndexListNotifier = ref.watch(searchIndexListProvider.notifier);
    final searchIndexList = ref.watch(searchIndexListProvider);
    return ListView.builder(
        itemCount: searchIndexList.length,
        itemBuilder: (context, int index) {
          index = searchIndexListNotifier.state[index];
          return Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MySongPage(index: index, preUrl: wordList[index][0].previewUrl)));
              },
              title: Text(wordList[index][0].name),
            ),
          );
        });
  }

  Widget _defaultListView(WidgetRef ref) {
    final wordList = ref.watch(dataProvider);
    return ListView.builder(
      itemCount: wordList.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MySongPage(index: index, preUrl: wordList[index][0].previewUrl)));
            },
            title: Text(wordList[index][0].name),
          ),
        );
      },
    );
  }
}