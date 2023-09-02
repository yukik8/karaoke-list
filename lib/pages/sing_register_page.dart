
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/register_notifier.dart';


class SingRegisterPage extends ConsumerStatefulWidget {
  const SingRegisterPage({super.key, required this.index});
  final int index;

  @override
  SingRegisterPageState createState() => SingRegisterPageState();
}

class SingRegisterPageState extends ConsumerState<SingRegisterPage> {
  String? onChangedText = '';
  String? onFieldSubmittedText = '';
  final textController = TextEditingController();
  String? onChangedScore = '';
  String? onFieldSubmittedScore = '';
  final scoreController = TextEditingController();


  Widget _scoreField() {
    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.4,
      child: TextFormField(
        keyboardType: TextInputType.number,
        autocorrect: true,
        controller: scoreController,
        decoration: InputDecoration(
          hintText: 'Search',
          suffixIcon: IconButton(
            onPressed: () => scoreController.clear(), //リセット処理
            icon: const Icon(Icons.clear),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
          counterText: "点",
          // counterStyle: TextStyle(),
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
            onChangedScore = value;
          });
        },
        // ユーザーがフィールドのテキストの編集が完了したことを示したときに呼び出される
        onFieldSubmitted: (value) async {
          setState(() {
            onFieldSubmittedScore = value;
          });
        },
      ),
    );
  }
  Widget _textField() {
    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.8,
      child: TextFormField(
        autocorrect: true,
        controller: textController,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () => textController.clear(), //リセット処理
            icon: const Icon(Icons.clear),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(100, 100, 100, 10),
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
            "歌う記録",
            style: TextStyle(
                color: Color(0xffC57E14)
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: GestureDetector(
          onTap: () => WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10,),
                      Image.network(
                          data[widget.index][0].artworkUrl(50)),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data[widget.index][0].artistName,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF828282)),
                              ),
                              Text(
                                data[widget.index][0].name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),),
                            ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  const Text("得点"),
                  _scoreField(),
                  const Text("メモ"),
                  _textField(),
                  const SizedBox(height: 10,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[200],
                    ),
                    onPressed: () {
                      // int num = ref.watch(dataProvider.notifier).state[widget.index][4];
                      ref.read(dataProvider.notifier).state[widget.index][3].add([onChangedScore,onChangedText,DateTime.now()]);
                      print(ref.watch(dataProvider.notifier).state[widget.index][3]);
                      // ref.read(dataProvider.notifier).state[widget.index][4]++;
                      // print(ref.watch(dataProvider.notifier).state[widget.index][4]);

                    }, child: const Text("歌った！",
                    style: TextStyle(fontSize: 22,
                      color: Colors.black,),),)
                ],
              ),
            ),
          ),
        )
    );
  }
}
