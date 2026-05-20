import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/data/one_song_tune.dart';
import '../../data/tune_name.dart';

class TunesSelectionPage extends ConsumerWidget {
  const TunesSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTunes = ref.watch(oneTuneProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('タグ',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF555555))),
            const Spacer(),
            GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const _TagSheet(),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, size: 15, color: Color(0xffC57E14)),
                  SizedBox(width: 2),
                  Text('選択・追加',
                      style: TextStyle(fontSize: 13, color: Color(0xffC57E14), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (selectedTunes.isEmpty)
          const Text('タグ未選択', style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)))
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedTunes.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xffC57E14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(t,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
      ],
    );
  }
}

class _TagSheet extends ConsumerStatefulWidget {
  const _TagSheet();

  @override
  _TagSheetState createState() => _TagSheetState();
}

class _TagSheetState extends ConsumerState<_TagSheet> {
  final textController = TextEditingController();
  String _input = '';

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _submitTag(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final exists = ref.read(tuneProvider).contains(trimmed);
    if (!exists) {
      ref.read(tuneProvider.notifier).addTune(trimmed);
    }
    if (!ref.read(oneTuneProvider).contains(trimmed)) {
      ref.read(oneTuneProvider.notifier).addSongsTune(trimmed);
    }
    textController.clear();
    setState(() => _input = '');
  }

  @override
  Widget build(BuildContext context) {
    final allTunes = ref.watch(tuneProvider);
    final selected = ref.watch(oneTuneProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('タグを選択',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff1A1A1A))),
          ),
          const SizedBox(height: 16),
          // All tags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allTunes.map((tune) {
                final isSelected = selected.contains(tune);
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      ref.read(oneTuneProvider.notifier).deleteSongsTune(tune);
                    } else {
                      ref.read(oneTuneProvider.notifier).addSongsTune(tune);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected ? const Color(0xffC57E14) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? const Color(0xffC57E14) : const Color(0xFFD0D0D0),
                      ),
                    ),
                    child: Text(
                      tune,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF888888),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Add new tag row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextFormField(
                      controller: textController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '新しいタグを追加',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBBBBBB)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) => setState(() => _input = v),
                      onFieldSubmitted: _submitTag,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _submitTag(_input),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xffC57E14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Done button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1A1A1A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('完了',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
