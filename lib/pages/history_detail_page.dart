import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../data/register_notifier.dart';
import '../models/singing_history_item.dart';
import '../models/user_song.dart';

String _formatScore(double score) =>
    score % 1 == 0 ? score.toInt().toString() : score.toStringAsFixed(1);

class HistoryDetail extends ConsumerStatefulWidget {
  const HistoryDetail({
    super.key,
    required this.userSong,
    required this.history,
  });
  final UserSong userSong;
  final SingingHistoryItem history;

  @override
  HistoryDetailState createState() => HistoryDetailState();
}

class HistoryDetailState extends ConsumerState<HistoryDetail> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  static const _gold = Color(0xffC57E14);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.userSong.song.previewUrl))
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('記録を削除'),
        content: const Text('この記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(dataProvider.notifier).deleteHistory(
            widget.userSong.id,
            widget.history.id,
          );
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('削除に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _showEditSheet(BuildContext context) async {
    final scoreController = TextEditingController(
      text: widget.history.score % 1 == 0
          ? widget.history.score.toInt().toString()
          : widget.history.score.toStringAsFixed(1),
    );
    final memoController = TextEditingController(text: widget.history.memo ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('記録を編集',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text('スコア', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
            const SizedBox(height: 6),
            TextField(
              controller: scoreController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),
            const Text('メモ', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
            const SizedBox(height: 6),
            TextField(
              controller: memoController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                hintText: 'メモを入力',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final score = double.tryParse(scoreController.text);
                  if (score == null) return;
                  Navigator.pop(ctx);
                  try {
                    await ref.read(dataProvider.notifier).updateHistory(
                          widget.userSong.id,
                          widget.history.id,
                          score: score,
                          memo: memoController.text.isEmpty ? null : memoController.text,
                        );
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('更新に失敗しました: $e')),
                      );
                    }
                  }
                },
                child: const Text('保存',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 90) return const Color(0xFFB8860B);
    if (score >= 70) return _gold;
    return const Color(0xFF888888);
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.userSong.song;
    final history = widget.history;
    final score = history.score;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        title: const Text(
          '歌った記録',
          style: TextStyle(color: _gold, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFFAAAAAA)),
            onPressed: () => _showEditSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Song header — same layout as my_song_page
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    song.artworkUrl(80),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.artistName,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        song.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: _gold,
                  bufferedColor: Color(0xFFFFE0B2),
                  backgroundColor: Color(0xFFEEEEEE),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Player controls — replay left, play/pause center
            SizedBox(
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => _controller
                          .seekTo(Duration.zero)
                          .then((_) => _controller.play()),
                      icon: const Icon(Icons.replay, size: 24, color: Color(0xFFAAAAAA)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        _isPlaying ? _controller.pause() : _controller.play(),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 20),

            // Score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('yyyy年M月d日 HH:mm').format(history.sungAt),
                    style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SCORE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 4,
                      color: Color(0xFFAAAAAA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatScore(score),
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: _scoreColor(score),
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 4),
                        child: Text(
                          '点',
                          style: TextStyle(
                            fontSize: 16,
                            color: _scoreColor(score).withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (score / 100).clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFFE0E0E0),
                      valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(score)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            // Memo
            if (history.memo != null && history.memo!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MEMO',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 4,
                        color: Color(0xFFAAAAAA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      history.memo!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
