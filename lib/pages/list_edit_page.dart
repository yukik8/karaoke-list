import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../assets/ui_components/radio_button.dart';
import '../assets/ui_components/tunes_selection.dart';
import '../data/one_song_tune.dart';
import '../data/register_notifier.dart';
import '../data/season_notifier.dart';
import '../models/user_song.dart';
import '../root.dart';

class EditPage extends ConsumerStatefulWidget {
  const EditPage({super.key, required this.userSong});
  final UserSong userSong;

  @override
  EditPageState createState() => EditPageState();
}

class EditPageState extends ConsumerState<EditPage> {
  late FixedExtentScrollController _keyScrollController;
  bool _isLoading = false;
  int _keyValue = 0;

  static const _gold = Color(0xffC57E14);

  @override
  void initState() {
    super.initState();

    // Parse existing key (e.g. "+3", "-2", "0", null) → int
    final rawKey = widget.userSong.key;
    _keyValue = rawKey == null || rawKey.isEmpty ? 0 : int.tryParse(rawKey) ?? 0;
    _keyScrollController =
        FixedExtentScrollController(initialItem: _keyValue + 12);

    // プロバイダーに既存値をセット（フレーム後に実行）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(oneTuneProvider.notifier).deleteSongsAllTunes();
      for (final tag in widget.userSong.tags) {
        ref.read(oneTuneProvider.notifier).addSongsTune(tag);
      }
      ref.read(seasonProvider.notifier).changeSeason(widget.userSong.season);
    });
  }

  @override
  void dispose() {
    _keyScrollController.dispose();
    super.dispose();
  }

  Widget _keyPicker() {
    final values = List.generate(25, (i) => i - 12);
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _keyScrollController,
            itemExtent: 40,
            perspective: 0.002,
            diameterRatio: 2.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() => _keyValue = values[index]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: values.length,
              builder: (context, index) {
                final val = values[index];
                final isSelected = val == _keyValue;
                return Center(
                  child: Text(
                    val == 0 ? '0' : (val > 0 ? '+$val' : '$val'),
                    style: TextStyle(
                      fontSize: isSelected ? 22 : 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? _gold : const Color(0xFFCCCCCC),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final tunes = ref.read(oneTuneProvider);
      final season = ref.read(seasonProvider);
      await ref.read(dataProvider.notifier).updateData(
            widget.userSong.id,
            key: _keyValue == 0
                ? null
                : (_keyValue > 0 ? '+$_keyValue' : '$_keyValue'),
            season: season,
            tags: tunes,
          );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Root(page: 0)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('編集に失敗しました: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('削除しますか？'),
        content: const Text('マイリストからこの曲を削除すると、歌った履歴も消去されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除する', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(dataProvider.notifier).deleteData(widget.userSong.id);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Root(page: 0)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除に失敗しました: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.userSong.song;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '編集',
          style: TextStyle(color: _gold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Song header — same as my_song_page
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
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
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF999999)),
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
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
                  // Form fields
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TunesSelectionPage(),
                        const SizedBox(height: 20),
                        const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: const [
                            Text('歌いやすいキー',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF555555))),
                            SizedBox(width: 8),
                            Text('0 = オリジナルキー',
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFFAAAAAA))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _keyPicker(),
                        const SizedBox(height: 16),
                        const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 16),
                        const Text('季節',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF555555))),
                        const SizedBox(height: 8),
                        const CustomRadioButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Buttons pinned at bottom
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('この内容で保存する',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _isLoading ? null : _delete,
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Color(0xFFAAAAAA)),
                    label: const Text('マイリストから削除する',
                        style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
