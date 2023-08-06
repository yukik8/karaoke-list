import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/data/song_notifier.dart';
import 'package:untitled/data/songs_tune_notifier.dart';
import 'package:untitled/pages/my_song_page.dart';
import 'package:untitled/pages/search_page.dart';
import 'package:untitled/pages/sing_register_page.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../data/season_notifier.dart';
import '../data/songs_season.dart';
import '../data/tune_notifier.dart';
import '../models/song.dart';
import 'package:untitled/main.dart';



class MyListPage extends ConsumerStatefulWidget {
  const MyListPage({super.key});

  @override
  MyListPageState createState() => MyListPageState();
}

class MyListPageState extends ConsumerState<MyListPage> {
  var showIndex = [];
  List<String> tunesList = [];
  List<List<String>> songsTunesList = [];


  @override
  void initState() {
    super.initState();
  }

  Widget _loadingView() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.grey,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(songProvider);
    tunesList = ref.watch(tuneProvider);
    songsTunesList = ref.watch(songsTuneProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.add_circle_outline,
          size: 30,color: Color(0xff6F6565)),
          onPressed: (){
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SearchPage()));
                }
        ),
        backgroundColor: Colors.white,
        title: const Text("My List",
          style: TextStyle(color: Color(0xffC57E14)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search,
                size: 30,color: Color(0xff6F6565)),
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle,
            size: 30,
                color: Color(0xff6F6565)),
            onPressed: (){

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
              child: ListView.builder(
                shrinkWrap: true,
                  itemCount: songs.length,
                itemBuilder: (context, index) {
                  if (index == songs.length) {
                    return _loadingView();
                  }
                  if (index > songs.length) {
                    return const SizedBox.shrink(); // 何も表示しない場合は空のSizedBoxを返す
                  }

                  return VisibilityDetector(
                  key: ValueKey(index),
                  onVisibilityChanged: (info) {
                    if (info.visibleFraction == 1) {
                      setState(() {
                        showIndex.add(index); //表示されたインデックスの追加
                      });
                    } else if (info.visibleFraction == 0) {
                      setState(() {
                        showIndex.remove(index); //非表示になったインデックスを削除
                      });
                    }
                  },
                    child: SizedBox(
                      height: 68,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.white),
                          elevation: MaterialStateProperty.all(0),
                        ),
                        onPressed: () {
                          showModalBottomSheet<void>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      )),
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.9,
                                  child: MySongPage(preUrl: songs[index].previewUrl, name: songs[index].name, id: songs[index].id, imgUrl: songs[index].artworkImgUrl, artistName: songs[index].artistName),
                                );
                              });
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.network(
                                    Song(id: songs[index].id,
                                        name: songs[index].name,
                                        previewUrl: songs[index].previewUrl,
                                        artworkImgUrl: songs[index].artworkImgUrl,
                                        artistName: songs[index].artistName)
                                        .artworkUrl(
                                        40)),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(songs[index].artistName,
                                        style: const TextStyle(
                                            fontSize: 12, color: Color(0xFF828282)),
                                      ),
                                      Text(
                                        songs[index].name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: Wrap(
                                    verticalDirection: VerticalDirection.down, //折り返した際、前後表示の順番
                                    alignment: WrapAlignment.end, // 折り返した要素の配置位置を決める
                                    runSpacing: 5,
                                    spacing: 5,
                                    children: songsTunesList[index+1].map((tune) {
                                      // selectedTags の中に自分がいるかを確かめる
                                      return InkWell(
                                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(32)),
                                            border: Border.all(
                                              width: 2,
                                              color: Colors.pink,
                                            ),
                                            color: Colors.pink,
                                          ),
                                          child: Text(
                                            tune,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 7,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                // SizedBox(
                                //   width: 20,
                                //   child: InkWell(
                                //         borderRadius: const BorderRadius.all(Radius.circular(20)),
                                //         child: AnimatedContainer(
                                //           duration: const Duration(milliseconds: 200),
                                //           padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                //           decoration: BoxDecoration(
                                //             borderRadius: const BorderRadius.all(Radius.circular(32)),
                                //             border: Border.all(
                                //               width: 2,
                                //               color: Colors.pink,
                                //             ),
                                //             color: Colors.pink,
                                //           ),
                                //           child: Text(
                                //             ref.watch(seasonProvider.notifier).state[index] == 0
                                //             ?'春'
                                //             : ref.watch(seasonProvider.notifier).state[index] == 1
                                //             ?'夏'
                                //             : ref.watch(seasonProvider.notifier).state[index] == 2
                                //                 ?'秋'
                                //                 : '冬',
                                //
                                //             style: TextStyle(
                                //               color: Colors.white,
                                //               fontWeight: FontWeight.bold,
                                //               fontSize: 7,
                                //             ),))
                                //     ),
                                //   ),

                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      ref.read(songProvider.notifier).deleteSong(
                                        songs[index].id,
                                        songs[index].name,
                                        songs[index].previewUrl,
                                        songs[index].artworkImgUrl,
                                        songs[index].artistName,
                                      );}),
                              ],
                            ),
                            const Divider(height: 10,thickness: 2,),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                ),
            ),
        ],
      ),
    );
  }
}
