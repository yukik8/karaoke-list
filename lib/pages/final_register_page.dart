import 'package:untitled/assets/ui_components/tunes_selection.dart';
import 'package:untitled/data/one_song_tune.dart';
import 'package:untitled/data/season_notifier.dart';
import 'package:untitled/data/songs_tune_notifier.dart';
import 'package:untitled/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:untitled/data/song_notifier.dart';
import '../assets/ui_components/radio_button.dart';
import '../data/songs_season.dart';
import '../models/song.dart';
import 'package:untitled/data/tune_notifier.dart';


class FinalRegisterPage extends ConsumerStatefulWidget {
  const FinalRegisterPage({super.key, required this.preUrl, required this.name, required this.id, required this.imgUrl,required this.artistName,});
  final String preUrl;
  final String name;
  final String id;
  final String imgUrl;
  final String artistName;

  @override
  FinalRegisterPageState createState() => FinalRegisterPageState();
}

class FinalRegisterPageState extends ConsumerState<FinalRegisterPage> {
  List<String> tunes = [];
  var selectedTunes = <String>[];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      ref.read(oneTuneProvider.notifier).deleteAllTunes();
    });  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(songProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Register",
            style: TextStyle(
                color: Color(0xffC57E14)
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.network(
                              Song(id: widget.id,
                                  name: widget.name,
                                  previewUrl: widget.preUrl,
                                  artworkImgUrl: widget.imgUrl,
                                  artistName: widget.artistName).artworkUrl(80)),
                        ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.artistName,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF828282)),
                              ),
                              Text(
                                widget.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.black,
                                ),),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    TunesSelectionPage(),
                    SizedBox(height: 60,),
                    CustomRadioButton(),
                    SizedBox(height: 60,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[200],
                      ),
                      onPressed: () async{
                        ref.read(songProvider.notifier).addSong(
                            widget.id,
                            widget.name,
                            widget.preUrl,
                            widget.imgUrl,
                            widget.artistName);
                        final List<String> tunes = await ref.watch(oneTuneProvider.notifier).state;
                         ref.read(songsTuneProvider.notifier).addTune(tunes);
                        final List<int> seasons = await  ref.watch(seasonProvider.notifier).state;
                         ref.read(seasonProvider.notifier).addTune(ref.watch(songSeasonProvider.notifier).state[0]);
                        // for(int i=0; i<1000; i++){
                        //   if(Song(id: widget.id,
                        //       name: widget.name,
                        //       previewUrl: widget.preUrl,
                        //       artworkImgUrl: widget.imgUrl,
                        //       artistName: widget.artistName) == ref.watch(songProvider.notifier).state[i]){
                        //     showDialog(context: context,
                        //         builder: (_) {
                        //         return AlertDialog(
                        //       title: Text('この曲はすでに追加されています'),
                        //       actions: <Widget>[
                        //         GestureDetector(
                        //           child: Text('戻る'),
                        //           onTap: () {
                        //             Navigator.pop(context);
                        //           },
                        //         ),
                        //       ],
                        //     );});
                        //     break;
                        //   }
                        //   if(i==200){
                        //     ref.read(songProvider.notifier).addSong(
                        //         widget.id,
                        //         widget.name,
                        //         widget.preUrl,
                        //         widget.imgUrl,
                        //         widget.artistName);
                        //     final List<String> tunes = ref.watch(oneTuneProvider.notifier).state;
                        //     ref.read(songsTuneProvider.notifier).addTune(tunes);
                        //   }
                        // }

                      }, child: Text("登録",
                      style: TextStyle(fontSize: 30,
                        color: Colors.black,),),),
                    // 登録した曲一覧を表示するウィジェット
                    SizedBox(height: 30,),
                    // Expanded(
                    //   child: Text("登録完了！",style: TextStyle(fontSize: 30),),
                    //   // child: ListView.builder(
                    //   //   itemCount: songs.length,
                    //   //   itemBuilder: (context, index) {
                    //   //     final song = songs.elementAt(index);
                    //   //     return ListTile(
                    //   //       title: Text(song.name),
                    //   //       subtitle: Text(song.artistName),
                    //   //     );
                    //   //   },
                    //   // ),
                    // ),
                  ],
                ),
    );
  }
}