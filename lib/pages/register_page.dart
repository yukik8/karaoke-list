import 'package:untitled/data/season_notifier.dart';
import 'package:untitled/pages/final_register_page.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/one_song_tune.dart';
import '../data/register_notifier.dart';
import '../models/song.dart';


class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, required this.preUrl, required this.name, required this.id, required this.imgUrl,required this.artistName,});
  final String preUrl;
  final String name;
  final String id;
  final String imgUrl;
  final String artistName;

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends ConsumerState<RegisterPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.preUrl))..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Scaffold(
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
                          artistName: widget.artistName).artworkUrl(250)),
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
                              fontSize: 24,
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[200],
                    ),
                    onPressed: (){
                      _controller.pause();
                      ref.read(oneTuneProvider.notifier).deleteSongsAllTunes();
                      ref.read(seasonProvider.notifier).deleteSeason();
                      final songState = ref.watch(dataProvider);
                      int i;
                      for(i=0; i<songState.length; i++) {
                        if (Song(id: widget.id,
                            name: widget.name,
                            previewUrl: widget.preUrl,
                            artworkImgUrl: widget.imgUrl,
                            artistName: widget.artistName).id == songState[i][0].id) {
                          showDialog(context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text('この曲はすでに追加されています'),
                                  actions: <Widget>[
                                    GestureDetector(
                                      child: const Text('戻る'),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              });
                          break;
                        }
                      }
                      if(i==songState.length) {
                        try {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  FinalRegisterPage(preUrl: widget.preUrl,
                                      name: widget.name,
                                      id: widget.id,
                                      imgUrl: widget.imgUrl,
                                      artistName: widget.artistName)));
                        } catch (e, s) {
                          print(s);
                        }
                      }
                  }, child: const Text(
                    "登録に進む",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  )
                ],
              ),
            ),
          )
      ),
    );
  }
}