import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/data/season_notifier.dart';

import '../../data/songs_season.dart';

class CustomRadioButton extends ConsumerStatefulWidget {
  const CustomRadioButton({Key? key}) : super(key: key);

  @override
  CustomRadioButtonState createState() => CustomRadioButtonState();
}

class CustomRadioButtonState extends ConsumerState<CustomRadioButton> {
  int? _selectedValueIndex;
  List<String> buttonText = ['春', '夏', '秋', '冬'];

  Widget button({required String text, required int index}) {
    return InkWell(
      splashColor: const Color(0xffC57E14),
      onTap: () {
        ref.read(songSeasonProvider.notifier).state[0] = index;
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        color: index == _selectedValueIndex ? Colors.blue : Colors.white,
        child: Text(
          text,
          style: TextStyle(
            color: index == _selectedValueIndex ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(
          buttonText.length,
              (index) => button(
            index: index,
            text: buttonText[index],
          ),
        ),
      ],
    );
  }
}
