import 'package:untitled/assets/ui_components/tunes_selection.dart';
import 'package:untitled/data/one_song_tune.dart';
import 'package:untitled/data/season_notifier.dart';
import 'package:untitled/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:untitled/data/song_notifier.dart';
import '../assets/ui_components/radio_button.dart';
import '../data/register_notifier.dart';
import '../data/songs_season.dart';
import '../models/song.dart';
import 'package:intl/intl.dart';

import '../root.dart';


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
 }

  Widget registerButton(){
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

  final List<String> tunes = await ref.watch(oneTuneProvider.notifier).state;



    // if(i==400){
      // ref.read(songProvider.notifier).addSong(
      //     widget.id,
      //     widget.name,
      //     widget.preUrl,
      //     widget.imgUrl,
      //     widget.artistName);
      print("b");
      // final List<String> tunes = ref.watch(oneTuneProvider.notifier).state;
      // ref.read(songsTuneProvider.notifier).addSongsTune(tunes);
      DateTime now = DateTime.now();
      print(now);
      print(tunes);
      ref.read(dataProvider.notifier).addData([
        Song(id: widget.id,
          name: widget.name,
          previewUrl: widget.preUrl,
          artworkImgUrl: widget.imgUrl,
          artistName: widget.artistName), now, tunes,[[]],0]);
      print(ref.watch(dataProvider.notifier).state[0][3]);
    // }
  // }

  }, child: Text("登録",
  style: TextStyle(fontSize: 30,
  color: Colors.black,),),);
}

  @override
  Widget build(BuildContext context) {
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
                          Expanded(
                            child: Column(
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
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    const TunesSelectionPage(),
                    const SizedBox(height: 60,),
                    const CustomRadioButton(),
                    const SizedBox(height: 60,),
                    registerButton(),
                    // 登録した曲一覧を表示するウィジェット
                    const SizedBox(height: 30,),
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