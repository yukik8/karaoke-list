import 'package:flutter/material.dart';
import 'package:untitled/pages/random_page.dart';
import 'package:untitled/pages/my_list_page.dart';

class Root extends StatefulWidget {
  const Root({super.key, required this.page});
  final int page;

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  static const _screens = [
    MyListPage(),
    RandomPage(),
    Scaffold(body: Center(child: Text("settings",style: TextStyle(fontSize: 20),),
    )),
    Scaffold(body: Center(child: Text("settings",style: TextStyle(fontSize: 20),),
    )),  ];
  int? _selectedIndex;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _screens[_selectedIndex ?? widget.page],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex ?? widget.page,
          onTap: _onItemTapped,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.queue_music,size: 40,),
              label: 'マイリスト',
            ),
             BottomNavigationBarItem(
              icon:
                 SizedBox(height:40,
                    child: Padding(
                     padding: const EdgeInsets.all(2),
                     child: _selectedIndex == 1 ?Image.asset('lib/assets/images/roulette_selected.png')
                           : Image.asset('lib/assets/images/roulette.png')
                    )
                 ),
              label: 'ランダム',
            ),

             const BottomNavigationBarItem(
              icon: Icon(Icons.history,size: 40,),
              label: '履歴',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 40,),
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
