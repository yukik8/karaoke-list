import 'package:untitled/pages/final_register_page.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

import '../models/song.dart';


class SingRegisterPage extends StatefulWidget {
  const SingRegisterPage({super.key, required this.preUrl, required this.name, required this.id, required this.imgUrl,required this.artistName,});
  final String preUrl;
  final String name;
  final String id;
  final String imgUrl;
  final String artistName;

  @override
  SingRegisterPageState createState() => SingRegisterPageState();
}

class SingRegisterPageState extends State<SingRegisterPage> {


  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                    Song(id: widget.id,
                        name: widget.name,
                        previewUrl: widget.preUrl,
                        artworkImgUrl: widget.imgUrl,
                        artistName: widget.artistName).artworkUrl(340)),
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.artistName,
                          style: const TextStyle(
                              fontSize: 15, color: Color(0xFF828282)),
                        ),
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.black,
                          ),),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100,),
                const SizedBox(height: 10,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[200],
                  ),
                  onPressed: () {

                  }, child: const Text("歌った！",
                  style: TextStyle(fontSize: 22,
                    color: Colors.black,),),)
              ],
            ),
          ),
        )
    );
  }
}
