import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/register_notifier.dart';

class SingRegisterPage extends ConsumerStatefulWidget {
  const SingRegisterPage({super.key, required this.index});
  final int index;

  @override
  SingRegisterPageState createState() => SingRegisterPageState();
}

class SingRegisterPageState extends ConsumerState<SingRegisterPage> {
  final _scoreController = TextEditingController();
  final _memoController = TextEditingController();
  DateTime _sungAt = DateTime.now();
  TimeOfDay? _sungTime; // null = 時間未設定
  bool _isLoading = false;

  static const _gold = Color(0xFFC57E14);
  static const _cardBg = Color(0xFFF7F7F7);

  @override
  void dispose() {
    _scoreController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  double get _scoreValue => double.tryParse(_scoreController.text) ?? 0.0;

  void _changeScore(double delta) {
    final next = (_scoreValue + delta).clamp(0.0, double.infinity);
    final text = next == next.roundToDouble()
        ? next.toInt().toString()
        : next.toStringAsFixed(1);
    _scoreController.text = text;
    _scoreController.selection =
        TextSelection.collapsed(offset: text.length);
    setState(() {});
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _sungTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFC57E14)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _sungTime = picked);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _sungAt,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFC57E14)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _sungAt = picked);
  }

  Future<void> _submit(song) async {
    setState(() => _isLoading = true);
    try {
      final memo = _memoController.text.trim().isEmpty
          ? null
          : _memoController.text.trim();
      final isToday = DateUtils.isSameDay(_sungAt, DateTime.now()) && _sungTime == null;
      final sungAt = isToday ? null : DateTime(
        _sungAt.year, _sungAt.month, _sungAt.day,
        _sungTime?.hour ?? 0,
        _sungTime?.minute ?? 0,
      );
      await ref
          .read(dataProvider.notifier)
          .addHistory(song.id, _scoreValue, memo, sungAt: sungAt);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('記録に失敗しました: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider).value ?? [];
    if (widget.index >= data.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _gold)),
      );
    }
    final song = data[widget.index];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        title: const Text(
          '歌う記録',
          style: TextStyle(color: _gold, fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SongCard(song: song),
              const SizedBox(height: 24),
              _ScorePanel(
                scoreController: _scoreController,
                scoreValue: _scoreValue,
                onDecrement: () => _changeScore(-1),
                onIncrement: () => _changeScore(1),
                onLongDecrement: () => _changeScore(-5),
                onLongIncrement: () => _changeScore(5),
                onScoreChanged: () => setState(() {}),
              ),
              const SizedBox(height: 16),
              _DateField(date: _sungAt, onTap: _pickDate),
              const SizedBox(height: 8),
              _TimeField(
                time: _sungTime,
                onTap: _pickTime,
                onClear: () => setState(() => _sungTime = null),
              ),
              const SizedBox(height: 16),
              _MemoPanel(controller: _memoController),
              const SizedBox(height: 28),
              _SubmitButton(
                isLoading: _isLoading,
                onTap: () => _submit(song),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Song Card ----

class _SongCard extends StatelessWidget {
  const _SongCard({required this.song});
  final dynamic song;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              song.song.artworkUrl(80),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.song.artistName,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  song.song.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Score Panel ----

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({
    required this.scoreController,
    required this.scoreValue,
    required this.onDecrement,
    required this.onIncrement,
    required this.onLongDecrement,
    required this.onLongIncrement,
    required this.onScoreChanged,
  });

  final TextEditingController scoreController;
  final double scoreValue;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onLongDecrement;
  final VoidCallback onLongIncrement;
  final VoidCallback onScoreChanged;

  static const _gold = Color(0xFFC57E14);

  Color _scoreColor(double score) {
    if (score >= 90) return const Color(0xFFB8860B);
    if (score >= 70) return _gold;
    return const Color(0xFF888888);
  }

  @override
  Widget build(BuildContext context) {
    final barValue = (scoreValue / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          const Text(
            'SCORE',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 4,
              color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _StepButton(
                icon: Icons.remove,
                onTap: onDecrement,
                onLongPress: onLongDecrement,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: scoreController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: _scoreColor(scoreValue),
                          height: 1,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: '0',
                          hintStyle: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFCCCCCC),
                            height: 1,
                          ),
                        ),
                        onChanged: (_) => onScoreChanged(),
                      ),
                    ),
                    const Text(
                      '点',
                      style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA), letterSpacing: 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _StepButton(
                icon: Icons.add,
                onTap: onIncrement,
                onLongPress: onLongIncrement,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barValue,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(scoreValue)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'タップして直接入力 / ボタンで ±1（長押しで ±5）',
            style: TextStyle(fontSize: 10, color: Color(0xFFBBBBBB)),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.onLongPress,
  });

  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFC57E14).withValues(alpha: 0.4),
            width: 1.5,
          ),
          color: const Color(0xFFFFF8EE),
        ),
        child: Icon(icon, color: const Color(0xFFC57E14), size: 22),
      ),
    );
  }
}

// ---- Memo Panel ----

class _MemoPanel extends StatelessWidget {
  const _MemoPanel({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              'MEMO',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 4,
                color: Color(0xFFAAAAAA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextField(
            controller: controller,
            maxLines: 5,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A), height: 1.6),
            decoration: const InputDecoration(
              hintText: '今日の感想など',
              hintStyle: TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Submit Button ----

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC57E14),
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Text(
                '歌った！',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }
}

// ---- Time Field ----

class _TimeField extends StatelessWidget {
  const _TimeField({required this.time, required this.onTap, required this.onClear});
  final TimeOfDay? time;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasTime = time != null;
    final label = hasTime
        ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
        : '設定しない';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule_outlined, size: 16, color: Color(0xFFAAAAAA)),
            const SizedBox(width: 10),
            const Text('時間', style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA))),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: hasTime ? FontWeight.w600 : FontWeight.normal,
                color: hasTime ? const Color(0xFFC57E14) : const Color(0xFFCCCCCC),
              ),
            ),
            if (hasTime) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: const Icon(Icons.close, size: 16, color: Color(0xFFCCCCCC)),
              ),
            ] else ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCCCCCC)),
            ],
          ],
        ),
      ),
    );
  }
}

// ---- Date Field ----

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final label = isToday
        ? '今日'
        : DateFormat('yyyy年M月d日').format(date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Color(0xFFAAAAAA)),
            const SizedBox(width: 10),
            const Text(
              '歌った日',
              style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? const Color(0xFFAAAAAA)
                    : const Color(0xFFC57E14),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 18, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}
