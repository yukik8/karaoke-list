import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:untitled/pages/list_edit_page.dart';
import 'package:untitled/pages/sing_register_page.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

import '../data/register_notifier.dart';

String _formatScore(double score) =>
    score % 1 == 0 ? score.toInt().toString() : score.toStringAsFixed(1);

class MySongPage extends ConsumerStatefulWidget {
  const MySongPage({super.key, required this.index, required this.preUrl});
  final int index;
  final String preUrl;

  @override
  MySongPageState createState() => MySongPageState();
}

class MySongPageState extends ConsumerState<MySongPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  static const _seasonEmojis = ['🌸', '🌻', '🍁', '⛄️'];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.preUrl))
      ..initialize().then((_) => setState(() {}));
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
    final data = ref.watch(dataProvider).valueOrNull ?? [];
    if (widget.index >= data.length) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final song = data[widget.index];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Song', style: TextStyle(color: Color(0xffC57E14))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFFAAAAAA)),
            onPressed: () {
              _controller.pause();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPage(userSong: song),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Song header card
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          song.song.artworkUrl(80),
                          width: 72, height: 72, fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(song.song.artistName,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text(song.song.name,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xff1A1A1A)),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      if (song.season != null) ...[
                        const SizedBox(width: 8),
                        Text(_seasonEmojis[song.season!.clamp(0, 3)],
                            style: const TextStyle(fontSize: 22)),
                      ],
                    ],
                  ),
                  // Key + Tags row
                  if (song.key != null || song.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (song.key != null && song.key!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xffC57E14).withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('key ', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
                                Text(song.key!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xffC57E14))),
                              ],
                            ),
                          ),
                        ...song.tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(t, style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
                        )),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Progress bar
                  ClipRRect(
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
                  const SizedBox(height: 12),
                  // Player controls
                  SizedBox(
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => _controller.seekTo(Duration.zero).then((_) => _controller.play()),
                            icon: const Icon(Icons.replay, size: 24, color: Color(0xFFAAAAAA)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _isPlaying ? _controller.pause() : _controller.play(),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xffC57E14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),
                  // History
                  const Text('履歴', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
                  const SizedBox(height: 8),
                  if (song.history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('まだ歌った履歴がありません', style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA))),
                    )
                  else
                    ...song.history.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('yyyy年M月d日').format(h.sungAt),
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                                  if (h.memo != null && h.memo!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(h.memo!, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
                                  ],
                                ],
                              ),
                            ),
                            if (h.score != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xffC57E14),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(_formatScore(h.score),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                          ],
                        ),
                      ),
                    )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Sing button pinned at bottom
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SingRegisterPage(index: widget.index),
                    ));
                  },
                  child: const Text('歌う！',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
