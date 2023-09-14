import 'package:untitled/assets/ui_components/tunes_selection.dart';
import 'package:untitled/data/one_song_tune.dart';
import 'package:untitled/data/season_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../assets/ui_components/radio_button.dart';
import '../data/register_notifier.dart';
import '../models/song.dart';

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
  String? onChangedText = '';
  String? onFieldSubmittedText = '';
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
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

  final List<String> tunes = await ref.watch(oneTuneProvider);
      DateTime now = DateTime.now();
    final int? season = await ref.watch(seasonProvider);
    ref.read(dataProvider.notifier).addData([
        Song(id: widget.id,
          name: widget.name,
          previewUrl: widget.preUrl,
          artworkImgUrl: widget.imgUrl,
          artistName: widget.artistName), now, tunes,[[]],onChangedText,season]);
    // print(ref.watch(dataProvider.notifier).state[0][3]);
  }, child: const Text("登録",
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
        body:SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25,0,25,0),
            child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Text("歌いやすいキー"),
                        _textField(),
                        const SizedBox(height: 30,),
                        Stack(
                          alignment: const Alignment(0, 0),
                          children: [
                            SizedBox(width:200,
                                child: ref.watch(seasonProvider.notifier).state==0? Image.asset('lib/assets/images/spring.webp')
                                    : ref.watch(seasonProvider.notifier).state==1? Image.asset('lib/assets/images/summer2.webp')
                                    : ref.watch(seasonProvider.notifier).state==2? Image.asset('lib/assets/images/fall.webp')
                                    : ref.watch(seasonProvider.notifier).state==3? Image.asset('lib/assets/images/winter.webp')
                                    :SizedBox.shrink()
                            ),
                            const CustomRadioButton(),
                          ],
                        ),
                        const SizedBox(height: 60,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            registerButton(),
                          ],
                        ),
                        const SizedBox(height: 30,),
                      ],
                    ),
          ),
        ),
    );
  }
}