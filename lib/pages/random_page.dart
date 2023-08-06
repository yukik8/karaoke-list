import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/data/song_notifier.dart';
import 'package:untitled/data/songs_tune_notifier.dart';
import 'package:untitled/pages/my_song_page.dart';
import 'package:untitled/pages/search_page.dart';
import 'package:untitled/pages/sing_register_page.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../data/season_notifier.dart';
import '../data/songs_season.dart';
import '../data/tune_notifier.dart';
import '../models/song.dart';
import 'package:untitled/main.dart';



class RandomPage extends ConsumerStatefulWidget {
  const RandomPage({super.key});

  @override
  MyListPageState createState() => MyListPageState();
}

class MyListPageState extends ConsumerState<RandomPage> {
  var showIndex = [];
  List<String> tunesList = [];
  List<List<String>> songsTunesList = [];
  var numbers = [1, 2, 3, 4, 5];
  var random = Random();
  var randomElem;




  @override
  void initState() {
    super.initState();
    randomElem = numbers[random.nextInt(numbers.length)];
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
    final songs = ref.watch(songProvider);
    tunesList = ref.watch(tuneProvider);
    songsTunesList = ref.watch(songsTuneProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("My List",
          style: TextStyle(color: Color(0xffC57E14)),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 0.5),
          SizedBox(
                      height: 68,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.white),
                          elevation: MaterialStateProperty.all(0),
                        ),
                        onPressed: () {
                          try {
                            Navigator.push(
                                context,
                                    MaterialPageRoute(builder: (context) => MySongPage(preUrl: songs[randomElem].previewUrl, name: songs[randomElem].name, id: songs[randomElem].id, imgUrl: songs[randomElem].artworkImgUrl, artistName: songs[randomElem].artistName),));
                          } catch (e, s) {
                            print(s);
                          }
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.network(
                                    Song(id: songs[randomElem].id,
                                        name: songs[randomElem].name,
                                        previewUrl: songs[randomElem].previewUrl,
                                        artworkImgUrl: songs[randomElem].artworkImgUrl,
                                        artistName: songs[randomElem].artistName)
                                        .artworkUrl(
                                        40)),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(songs[randomElem].artistName,
                                        style: const TextStyle(
                                            fontSize: 12, color: Color(0xFF828282)),
                                      ),
                                      Text(
                                        songs[randomElem].name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                ),
                              ],
                            ),
                            const Divider(height: 10,thickness: 2,),
                          ],
                        ),
                      ),
                    ),
                  ]),
            );
  }
}






