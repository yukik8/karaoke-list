import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/data/season_notifier.dart';

class CustomRadioButton extends ConsumerWidget {
  const CustomRadioButton({Key? key}) : super(key: key);

  static const _labels = ['春', '夏', '秋', '冬'];
  static const _seasonColors = [
    Color(0xfff19ec2),
    Color(0xff00a0e9),
    Color(0xfff39800),
    Color(0xff84ccc9),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(seasonProvider);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final isSelected = current == index;
          final color = _seasonColors[index];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(seasonProvider.notifier).changeSeason(
                  isSelected ? null : index,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _labels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? Colors.white : const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
