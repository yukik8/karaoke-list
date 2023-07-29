import 'package:flutter/material.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  static const _screens = [
    Text("myList"),
    Text("random"),
    Text("history"),
    Text("setting"),
  ];
  int? _selectedIndex;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print("aaaa");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _screens[_selectedIndex ?? 0],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex ?? 0,
          onTap: _onItemTapped,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.queue_music),
              label: 'マイリスト',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('lib/assets/images/roulette.png'),
              label: 'ランダム',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: '履歴',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xffC57E14),
          unselectedFontSize: 10,
          selectedFontSize: 10,
        ),
      ),
    );
  }
}
