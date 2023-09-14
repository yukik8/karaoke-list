import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:untitled/pages/history_detail_page.dart';
import '../data/history_notifier.dart';
import '../data/tune_name.dart';




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
    tunesList = ref.watch(tuneProvider);
    var history = ref.watch(historyProvider);
    history.sort((a, b) => a[0][2].compareTo(b[0][2]));



    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text("History",
          style: TextStyle(color: Color(0xffC57E14)),
        ),
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
                // reverse: true,
                shrinkWrap: true,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  if (index == history.length) {
                    return _loadingView();
                  }
                  if (index > history.length) {
                    return const SizedBox.shrink(); // 何も表示しない場合は空のSizedBoxを返す
                  }
                  // ref.read(dataProvider.notifier).state = ref.watch(productsProvider);
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
                                child: HistoryDetail(index: history[index][1]),
                              );
                            });
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Image.network(
                                    history[index][1].artworkUrl(40)),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(history[index][1].artistName,
                                        style: const TextStyle(
                                            fontSize: 10, color: Color(0xFF828282)),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        history[index][1].name,
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
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text("得点：",
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text("${history[index][0][0]}",
                                      style: const TextStyle(
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8,),
                                SizedBox(
                                  width: 150,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("メモ：${history[index][0][1]}",
                                        maxLines: 2,
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),),
                                      Text("日付：${DateFormat('yyyy年M月d日').format(history[index][0][2])}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),),
                                    ],
                                  ),
                                ),
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
