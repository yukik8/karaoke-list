import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/assets/ui_components/tunes_selection.dart';
import 'package:untitled/data/season_notifier.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

import '../assets/ui_components/radio_button.dart';
import '../data/history_notifier.dart';
import '../data/one_song_tune.dart';
import '../data/register_notifier.dart';
import '../root.dart';


class EditPage extends ConsumerStatefulWidget {
  const EditPage({super.key, required this.index, required this.preUrl});
  final int index;
  final String preUrl;

  @override
  MySongPageState createState() => MySongPageState();
}

class MySongPageState extends ConsumerState<EditPage> {
  late VideoPlayerController _controller;
  List<String> tunes = [];
  var selectedTunes = <String>[];
  String? onChangedText = '';
  String? onFieldSubmittedText = '';
  final textController = TextEditingController();



  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.preUrl))..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    }).catchError((error) {
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget editButton(){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange[200],
      ),
      onPressed: () async {
        if (!mounted) return;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const Root(page: 0)));

        final List<String> tunes = await ref.watch(oneTuneProvider);
        final data = await ref.watch(dataProvider);
        data[widget.index][2] = tunes;
        data[widget.index][4] = onChangedText;
        data[widget.index][5] = ref.watch(seasonProvider);
        // print(ref.watch(dataProvider.notifier).state[0][3]);
      }, child: const Text("この内容で編集する",
      style: TextStyle(fontSize: 20,
        color: Colors.black,),),);
  }

  Widget _textField() {
    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.4,
      child: TextFormField(
        autocorrect: true,
        controller: textController,
        decoration: InputDecoration(
          hintText: 'key',
          suffixIcon: IconButton(
            onPressed: () => textController.clear(), //リセット処理
            icon: const Icon(Icons.clear),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
          hintStyle: const TextStyle(
            color: Color(0x993C3C43),
            fontSize: 17,
          ),
          filled: true,
          fillColor: const Color(0x1F767680),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0x1F767680), width: 3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0x1F767680), width: 0),
          ),
        ),
        // フィールドのテキストが変更される度に呼び出される
        onChanged: (value) {
          setState(() {
            onChangedText = value;
          });
        },
        // ユーザーがフィールドのテキストの編集が完了したことを示したときに呼び出される
        onFieldSubmitted: (value) async {
          setState(() {
            onFieldSubmittedText = value;
          });
        },
      ),
    );
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20,0,8,8),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.network(
                            data[widget.index][0].artworkUrl(50)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data[widget.index][0].artistName,
                                  style: const TextStyle(
                                      fontSize: 10, color: Color(0xFF828282)),
                                ),
                                Text(
                                  data[widget.index][0].name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),


                 const TunesSelectionPage(),
                  const SizedBox(height: 20,),
                  const Text("歌いやすいキー"),
                  _textField(),
                  const SizedBox(height: 30,),
                  const CustomRadioButton(),
                  const SizedBox(height:20,),
                  editButton(),
                    const SizedBox(height: 40,),
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete,size: 20,),
                              Text("マイリストから削除する")
                            ],
                          ),

                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false, // user must tap button!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('削除しますか？'),
                                  content: const SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text('マイリストからこの曲を削除すると、'),
                                        Text('この曲の歌った履歴も消去されます。'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('削除しない'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('削除する'),
                                      onPressed: () {
                                        Future.delayed(const Duration(seconds: 1),(){
                                          ref.read(dataProvider.notifier).deleteData(
                                              data[widget.index]
                                          );
                                          var history = ref.watch(historyProvider);
                                          for(int i=0;i<history.length;i++){
                                            if(history[i][1]==widget.index){
                                              ref.read(historyProvider.notifier).deleteHistory(
                                                history[i]
                                              );
                                            }
                                          }
                                        });
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const Root(page: 0)));                                  },
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
                    ),
                ]

            ),
          ),
        )
    );
  }
}