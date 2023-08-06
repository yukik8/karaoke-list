import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/data/one_song_tune.dart';
import 'package:untitled/data/song_notifier.dart';

import '../../data/tune_notifier.dart';

class TunesSelectionPage extends ConsumerStatefulWidget {
  const TunesSelectionPage({Key? key}) : super(key: key);

  @override
  TunesSelectionPageState createState() => TunesSelectionPageState();
}

class TunesSelectionPageState extends ConsumerState<TunesSelectionPage> {
  /// 検索したいお酒の種類を選ぶことを想定
  List<String > tunesList = [];
  List<String > tunes = [];

  final textController = TextEditingController();
  String onChangedText = '';
  String onFieldSubmittedText = '';
  var selectedTunes = <String>[];

  @override
  void initState() {
    super.initState();
    //  `ref` は StatefulWidget のすべてのライフサイクルメソッド内で使用可能です。
    // ref.read(tuneProvider);
  }



  @override
  Widget build(BuildContext context) {
    tunesList = ref.watch(tuneProvider);
    return Column(
      children: [
        Text("タグ                          　",
        style: TextStyle(fontSize: 30),),
        SizedBox(height: 15,),
        Wrap(
          runSpacing: 16,
          spacing: 16,
          children: tunesList.map((tune) {
            // selectedTags の中に自分がいるかを確かめる
            final isSelected = selectedTunes.contains(tune);
            return InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              onTap: () {
                if (isSelected) {
                  // すでに選択されていれば取り除く
                  selectedTunes.remove(tune);
                  ref.read(oneTuneProvider.notifier).deleteTune(tune);
                } else {
                  // 選択されていなければ追加する
                  selectedTunes.add(tune);
                  ref.read(oneTuneProvider.notifier).addTune(tune);
                }
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  border: Border.all(
                    width: 2,
                    color: Colors.pink,
                  ),
                  color: isSelected ? Colors.pink : null,
                ),
                child: Text(
                  tune,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20,),
        TextFormField(
            autocorrect: true,
            controller: textController,
            decoration: InputDecoration(
              hintText: 'タグを追加',
              prefixIcon: const Icon(Icons.add),
              suffixIcon: IconButton(
                onPressed: () => textController.clear(), //リセット処理
                icon: const Icon(Icons.clear),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(10, 12, 12, 10),
              hintStyle: const TextStyle(
                color: Color(0x993C3C43),
                fontSize: 17,
              ),
              filled: true,
              fillColor: const Color(0x1F767680),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0x1F767680), width: 0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0x1F767680), width: 0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
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
            onFieldSubmitted: (value)  {
              setState(() {
                onFieldSubmittedText = value;
                ref.read(tuneProvider.notifier).addTune(onFieldSubmittedText);
                print(onFieldSubmittedText);
              });
            },
          ),
      ],
    );
  }
}