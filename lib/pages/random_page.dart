import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/data/register_notifier.dart';
import 'package:untitled/pages/flying_page.dart';
import 'package:untitled/pages/my_song_page.dart';



class RandomPage extends ConsumerStatefulWidget {
  const RandomPage({super.key});

  @override
  MyListPageState createState() => MyListPageState();
}

class MyListPageState extends ConsumerState<RandomPage> {
  var showIndex = [];
  var random = Random();
  late List<dynamic> randomElem;



  @override
  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    if(data.isNotEmpty) {
      randomElem = data[random.nextInt(data.length)];
    }

    return Scaffold(
       appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Random",
          style: TextStyle(color: Color(0xffC57E14)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Container(
          //   alignment: Alignment.center,
          //   decoration: const BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage('lib/assets/images/random_back.jpg'),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          // Container(
          //   alignment: Alignment.center,
          //   decoration: const BoxDecoration(
          //     color: Color(0x33000000),
          //   ),
          // ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("今歌う１曲を決める",
                style: TextStyle(
                    fontSize: 25,
                  fontFamily: 'Noto_Sans_JP',
                  color: Color(0xff333333),
                ),),
              const SizedBox(height: 30),
              SizedBox(
                          height: 80,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              elevation: MaterialStateProperty.all(10),
                            ),
                            onPressed: () {
                              try {
                                if(data.isEmpty) {
                                  showDialog(context: context,
                                      builder: (_) {
                                        return AlertDialog(
                                          title: const Text('マイリストページ左上部から\n歌いたい曲を追加しましょう。'),
                                          actions: <Widget>[
                                            GestureDetector(
                                              child: const Padding(
                                                padding: EdgeInsets.fromLTRB(0,0,30,20),
                                                child: Text('戻る'),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                }
                                else {
                                  int ran = random.nextInt(data.length);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          MySongPage(index: ran, preUrl: data[ran][0].previewUrl,),));
                                }
                                } catch (e, s) {
                                print(s);
                              }
                            },
                            child: const Text("クリック", style: TextStyle(fontSize: 25,color: Color(0xff333333)),)
                          ),
                        ),
              SplashPage(),
            ]),
        ],
      ),
            );
  }
}






