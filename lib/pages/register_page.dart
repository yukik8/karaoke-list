import 'package:untitled/data/season_notifier.dart';
import 'package:untitled/pages/final_register_page.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/one_song_tune.dart';
import '../data/register_notifier.dart';
import '../models/song.dart';


class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, required this.preUrl, required this.name, required this.id, required this.imgUrl, required this.artistName});
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
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.preUrl))
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.addListener(() {
      if (_controller.value.isPlaying != _isPlaying) {
        setState(() => _isPlaying = _controller.value.isPlaying);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = Song(
      id: widget.id,
      name: widget.name,
      previewUrl: widget.preUrl,
      artworkImgUrl: widget.imgUrl,
      artistName: widget.artistName,
    );

    return ProviderScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Register",
            style: TextStyle(color: Color(0xffC57E14)),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Builder(
                    builder: (context) {
                      final size = MediaQuery.of(context).size.width * 0.62;
                      return SizedBox(
                        width: size,
                        height: size,
                        child: Image.network(song.artworkUrl(400), fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Song info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.artistName,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Color(0xffC57E14),
                    bufferedColor: Color(0xFFFFE0B2),
                    backgroundColor: Color(0xFFEEEEEE),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          _controller.seekTo(Duration.zero).then((_) => _controller.play());
                        },
                        icon: const Icon(Icons.replay, size: 26, color: Color(0xFFAAAAAA)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _isPlaying ? _controller.pause() : _controller.play(),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xffC57E14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Register button pinned at bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffC57E14),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _controller.pause();
                    ref.read(oneTuneProvider.notifier).deleteSongsAllTunes();
                    ref.read(seasonProvider.notifier).deleteSeason();
                    final songState = ref.read(dataProvider).valueOrNull ?? [];
                    final alreadyExists = songState.any((us) => us.song.id == widget.id);
                    if (alreadyExists) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('この曲はすでに追加されています'),
                          actions: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('戻る'),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinalRegisterPage(
                            preUrl: widget.preUrl,
                            name: widget.name,
                            id: widget.id,
                            imgUrl: widget.imgUrl,
                            artistName: widget.artistName,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    '登録に進む',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
