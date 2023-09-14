import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    Key? key,
    this.customPaintSize = 200.0,
  }) : super(key: key);

  final double customPaintSize;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
        child: Center(
          child: Lottie.asset(
            'lib/assets/lottie.json',
            width: 250,
            height: 250,
            frameRate: FrameRate(60),
            repeat: true,
            controller: _controller,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration
                ..forward();
            },
          ),
        )
    );
  }
}