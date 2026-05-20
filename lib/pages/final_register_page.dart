import 'package:untitled/assets/ui_components/tunes_selection.dart';
import 'package:untitled/data/one_song_tune.dart';
import 'package:untitled/data/season_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../assets/ui_components/radio_button.dart';
import '../data/register_notifier.dart';
import '../models/song.dart';
import '../models/user_song.dart';

import '../root.dart';


class FinalRegisterPage extends ConsumerStatefulWidget {
  const FinalRegisterPage({super.key, required this.preUrl, required this.name, required this.id, required this.imgUrl,required this.artistName,});
  final String preUrl;
  final String name;
  final String id;
  final String imgUrl;
  final String artistName;

  @override
  FinalRegisterPageState createState() => FinalRegisterPageState();
}

class FinalRegisterPageState extends ConsumerState<FinalRegisterPage> {
  List<String> tunes = [];
  int _keyValue = 0;
  final FixedExtentScrollController _keyScrollController = FixedExtentScrollController(initialItem: 12);

  @override
  void initState() {
    super.initState();
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xffC57E14) : const Color(0xFFCCCCCC),
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


  Widget registerButton(){
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xffC57E14),
      padding: const EdgeInsets.symmetric(vertical: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onPressed: () async {
    if (!mounted) return;

    final List<String> tunes = ref.read(oneTuneProvider);
    final int? season = ref.read(seasonProvider);
    final userSong = UserSong(
      id: '',
      song: Song(
        id: widget.id,
        name: widget.name,
        previewUrl: widget.preUrl,
        artworkImgUrl: widget.imgUrl,
        artistName: widget.artistName,
      ),
      key: _keyValue == 0 ? null : (_keyValue > 0 ? '+$_keyValue' : '$_keyValue'),
      season: season,
      tags: tunes,
      createdAt: DateTime.now(),
      history: [],
    );

    try {
      await ref.read(dataProvider.notifier).addData(userSong);
      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const Root(page: 0)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登録に失敗しました: $e')),
      );
    }
  }, child: const Text('登録',
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Register",
            style: TextStyle(
                color: Color(0xffC57E14)
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(
            20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        Song(id: widget.id, name: widget.name, previewUrl: widget.preUrl, artworkImgUrl: widget.imgUrl, artistName: widget.artistName).artworkUrl(80),
                        width: 64, height: 64, fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.artistName,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff1A1A1A)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              const TunesSelectionPage(),
              const Spacer(flex: 2),
              const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
              const Spacer(flex: 1),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: const [
                  Text('歌いやすいキー', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF555555))),
                  SizedBox(width: 8),
                  Text('0 = オリジナルキー', style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
                ],
              ),
              const Spacer(flex: 1),
              _keyPicker(),
              const Spacer(flex: 1),
              const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
              const Spacer(flex: 1),
              const Text('季節', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF555555))),
              const Spacer(flex: 1),
              const CustomRadioButton(),
              const Spacer(flex: 3),
              registerButton(),
            ],
          ),
        ),
    );
  }
}