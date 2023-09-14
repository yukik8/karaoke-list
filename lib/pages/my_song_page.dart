import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:untitled/pages/sing_register_page.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

import '../data/register_notifier.dart';


class MySongPage extends ConsumerStatefulWidget {
  const MySongPage({super.key, required this.index, required this.preUrl});
  final int index;
  final String preUrl;

  @override
  MySongPageState createState() => MySongPageState();
}

class MySongPageState extends ConsumerState<MySongPage> {
  late VideoPlayerController _controller;


  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.preUrl))..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Song",
            style: TextStyle(
                color: Color(0xffC57E14)
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body:SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                  data[widget.index][0].artworkUrl(250)),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20,20,40,10),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data[widget.index][0].artistName,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF828282)),
                              ),
                              Text(
                                data[widget.index][0].name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xff333333),
                                ),),
                            ],
                          ),
                          Spacer(),
                          data[widget.index][5] !=null?
                          Row(
                            children: [
                              Icon(
                                data[widget.index][5] == 0
                                    ?Icons.emoji_nature
                                    : data[widget.index][5] == 1
                                    ?Icons.surfing
                                    : data[widget.index][5] == 2
                                    ?Icons.forest_outlined
                                    : Icons.ac_unit,
                                  color: data[widget.index][5] == 0
                                      ?const Color(0xfff19ec2)
                                      : data[widget.index][5] == 1
                                      ?const Color(0xff00a0e9)
                                        : data[widget.index][5] == 2
                                      ?const Color(0xfff39800)
                                      :const Color(0xff84ccc9)
                              ),
                              Text(data[widget.index][5] == 0
                                  ?"春"
                                  : data[widget.index][5] == 1
                                  ?"夏"
                                  : data[widget.index][5] == 2
                                  ?"秋"
                                  : "冬",
                                  style: TextStyle(
                                      color: data[widget.index][5] == 0
                                          ?const Color(0xfff19ec2)
                                          : data[widget.index][5] == 1
                                          ?const Color(0xff00a0e9)
                                          : data[widget.index][5] == 2
                                          ?const Color(0xfff39800)
                                          :const Color(0xff84ccc9),
                                    fontSize: 15
                                  ),
                                  )
                            ],
                          )
                              : const SizedBox.shrink()
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Wrap(
                  verticalDirection: VerticalDirection.down, //折り返した際、前後表示の順番
                  alignment: WrapAlignment.end, // 折り返した要素の配置位置を決める
                  runSpacing: 5,
                  spacing: 5,
                  children: data[widget.index][2].map<Widget>((tune) {
                    // selectedTags の中に自分がいるかを確かめる
                    return InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(32)),
                          border: Border.all(
                            width: 2,
                            color: Colors.pink,
                          ),
                          color: Colors.white,
                        ),
                        child: Text(
                          tune,
                          style: const TextStyle(
                            color: Color(0xff333333),
                            // fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
              ),
              const SizedBox(height: 20,),
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      _controller
                          .seekTo(Duration.zero)
                          .then((_) => _controller.play());
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    onPressed: () {
                      _controller.play();
                    },
                    icon: const Icon(Icons.play_arrow),
                  ),
                  IconButton(
                    onPressed: () {
                      _controller.pause();
                    },
                    icon: const Icon(Icons.pause),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[200],
                ),
                onPressed: (){
                  try {
                    _controller.pause();
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SingRegisterPage(index: widget.index)));
                  } catch (e, s) {
                    print(s);
                  }
                }, child: const Text("歌う！",
                style: TextStyle(fontSize: 22,
                  color: Colors.black,),),),
              // const Divider(height: 30,thickness: 2,),
              const Padding(
                padding: EdgeInsets.fromLTRB(30,0,0,8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("履歴"),
                  ],
                ),
              ),
              // const Divider(height: 15,thickness: 2,),
              data[widget.index][3].isNotEmpty ?
              SizedBox(
                height: 86,
                child: ListView.builder(
                  // reverse: true,
                    itemCount: data[widget.index][3].length,
                    itemBuilder: (context, index) {
                      if (index > data[widget.index][3].length || data[widget.index][3][index].isEmpty) {
                        return const SizedBox.shrink(); // 何も表示しない場合は空のSizedBoxを返す
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8,0,8,0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20,),
                            Text("得点：${data[widget.index][3][index][0]}"),
                            Text("メモ：${data[widget.index][3][index][1]}"),
                            Text("日付：${DateFormat('yyyy年M月d日').format(data[widget.index][3][index][2])}"),
                            const Divider(height: 2,thickness: 2,)
                          ],
                        ),
                      );
                  }
                  ,),
              )
                  : const Text("まだ歌った履歴がありません")
            ]

          ),
        )
    );
  }
}