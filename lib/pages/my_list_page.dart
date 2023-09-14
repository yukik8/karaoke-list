import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/pages/list_edit_page.dart';
import 'package:untitled/pages/list_search_page.dart';
import 'package:untitled/pages/my_song_page.dart';
import 'package:untitled/pages/search_page.dart';
import '../data/one_song_tune.dart';
import '../data/register_notifier.dart';




class MyListPage extends ConsumerStatefulWidget {
  const MyListPage({super.key});

  @override
  MyListPageState createState() => MyListPageState();
}

enum SortType {
  name,
  artistName,
  time
}



class MyListPageState extends ConsumerState<MyListPage> {

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
    var data = ref.watch(dataProvider);
    final sortTypeProvider = StateProvider<SortType>(
      // ソートの種類 name を返します。これがデフォルトのステートとなります。
          (ref) => SortType.name,
    );


    final productsProvider = Provider<List<List<dynamic>>>((ref) {
      final type = ref.watch(sortTypeProvider);
      switch (type) {
        case SortType.name:
          data.sort((a, b) => a[0].name.compareTo(b[0].name));
          return data;
        case SortType.artistName:
          data.sort((a, b) => a[0].artistName.compareTo(b[0].artistName));
          return data;
        case SortType.time:
          data.sort((a, b) => a[1].compareTo(b[1]));
          return data;
      }
    });

    // final listSong = ref.watch(productsProvider);



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
          DropdownButton<SortType>(
            value: ref.watch(sortTypeProvider),
            onChanged: (value) {
             ref.read(sortTypeProvider.notifier).state = value!;
            },
            items: const [
              DropdownMenuItem(
                value: SortType.name,
                child: Row(
                  children: [
                    Icon(Icons.library_music_outlined),
                    Text(" 曲名順")
                  ],
                ),
              ),
              DropdownMenuItem(
                value: SortType.artistName,
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded),
                    Text(" アーティスト名順")
                  ],
                ),
              ),
              DropdownMenuItem(
                value: SortType.time,
                child: Row(
                  children: [
                    Icon(Icons.schedule),
                    Text(" 登録した日付順")
                  ],
                ),
              ),
            ],
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
              child: ListView.builder(
                shrinkWrap: true,
                  itemCount: data.length,
                itemBuilder: (context, index) {
                  if (index == data.length) {
                    return _loadingView();
                  }
                  if (index > data.length) {
                    return const SizedBox.shrink(); // 何も表示しない場合は空のSizedBoxを返す
                  }
                  // ref.read(dataProvider.notifier).state = ref.watch(productsProvider);
                  data = ref.watch(productsProvider);
                  return SizedBox(
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
                                child: MySongPage(index: index,preUrl: data[index][0].previewUrl,),
                              );
                            });
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Image.network(
                                    data[index][0].artworkUrl(40)),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(data[index][0].artistName,
                                        style: const TextStyle(
                                            fontSize: 11, color: Color(0xFF828282)),
                                        maxLines: 1,
                                      ),
                                        Text(
                                          data[index][0].name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                          maxLines: 2,
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
                                    children: data[index][2].map<Widget>((tune) {
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
                                            // color: Colors.pink,
                                          ),
                                          child: Text(
                                            tune,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 7,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 5,),
                                SizedBox(
                                  width: 20,
                                  child: data[index][5]!=null ?
                                  InkWell(
                                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(32)),
                                            border: Border.all(
                                              width: 2,
                                              color: data[index][5] == 0
                                                  ?const Color(0xfff19ec2)
                                                  : data[index][5] == 1
                                                  ?const Color(0xff00a0e9)
                                                  : data[index][5] == 2
                                                  ?const Color(0xfff39800)
                                                  :const Color(0xff84ccc9)
                                            ),
                                            color: data[index][5] == 0
                                                ?const Color(0xfff19ec2)
                                                : data[index][5] == 1
                                                ?const Color(0xff00a0e9)
                                                : data[index][5] == 2
                                                ?const Color(0xfff39800)
                                                :const Color(0xff84ccc9)
                                          ),
                                          child: Text(
                                            data[index][5] == 0
                                            ?'春'
                                            : data[index][5] == 1
                                            ?'夏'
                                            : data[index][5] == 2
                                                ?'秋'
                                                : '冬',

                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 7,
                                            ),))
                                    )
                                      :const SizedBox.shrink()
                                  ),
                                const SizedBox(width: 5,),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("key",
                                      style: TextStyle(
                                        fontSize:11,
                                      ),
                                    ),
                                    Text(data[index][4],
                                      style: const TextStyle(
                                        fontSize:18,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) =>
                                              EditPage(index: index, preUrl: data[index][0].previewUrl)));
                                      ref.read(oneTuneProvider.notifier).deleteSongsAllTunes();//   break\;\n
                                    }),
                              ],
                            ),
                          ),
                          const Divider(height: 7,thickness: 2,),
                        ],
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
