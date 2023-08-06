import 'package:untitled/pages/final_register_page.dart';
import 'package:untitled/pages/sing_register_page.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

import '../models/song.dart';


class MySongPage extends StatefulWidget {
  const MySongPage({super.key, required this.preUrl, required this.name, required this.id, required this.imgUrl,required this.artistName,});
  final String preUrl;
  final String name;
  final String id;
  final String imgUrl;
  final String artistName;

  @override
  MySongPageState createState() => MySongPageState();
}

class MySongPageState extends State<MySongPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.preUrl))..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    }).catchError((error) {
      // エラーログを出力して、エラーを確認できるようにする
      print('Error while initializing VideoPlayerController: $error');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
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
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
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
                  width: MediaQuery.of(context).size.width,
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SingRegisterPage(preUrl: widget.preUrl, name: widget.name, id: widget.id, imgUrl: widget.imgUrl, artistName: widget.artistName)));
                    } catch (e, s) {
                      print(s);
                    }
                  }, child: const Text("歌う！",
                  style: TextStyle(fontSize: 22,
                    color: Colors.black,),),)
              ],
            ),
          ),
        )
    );
  }
}