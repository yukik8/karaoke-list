import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:untitled/models/song.dart';

class HistoryDetail extends ConsumerStatefulWidget {
  const HistoryDetail({super.key, required this.index});
  final Song index;

  @override
  MySongPageState createState() => MySongPageState();
}

class MySongPageState extends ConsumerState<HistoryDetail> {
  late VideoPlayerController _controller;


  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.index.previewUrl))..initialize().then((_) {
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
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                    widget.index.artworkUrl(340)),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.index.artistName,
                          style: const TextStyle(
                              fontSize: 15, color: Color(0xFF828282)),
                        ),
                        Text(
                          widget.index.name,
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.black,
                          ),),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
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
              ]

          ),
        )
    );
  }
}