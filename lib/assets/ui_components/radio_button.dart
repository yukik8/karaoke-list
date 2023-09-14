import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/data/season_notifier.dart';


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
        if(_selectedValueIndex==index){
          setState(() {
            _selectedValueIndex = null;
            ref.read(seasonProvider.notifier).changeSeason(null);
           });
        }
        else {
          setState(() {
            _selectedValueIndex = index;
            ref.read(seasonProvider.notifier).changeSeason(index);

          });
        }
        // ref.read(songSeasonProvider.notifier).state[0] = index;
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        color: index == ref.watch(seasonProvider.notifier).state && ref.watch(seasonProvider.notifier).state==0? Color(0xfff19ec2)
            : index == ref.watch(seasonProvider.notifier).state && ref.watch(seasonProvider.notifier).state==1? Color(0xff00a0e9)
            : index == ref.watch(seasonProvider.notifier).state && ref.watch(seasonProvider.notifier).state==2? Color(0xfff39800)
            : index == ref.watch(seasonProvider.notifier).state && ref.watch(seasonProvider.notifier).state==3? Color(0xff84ccc9)
            : Colors.white,
        child: Text(
          text,
          style: TextStyle(
            color: index == ref.watch(seasonProvider.notifier).state ? Colors.white : Colors.black,
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
