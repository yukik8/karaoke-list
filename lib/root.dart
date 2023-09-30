import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:untitled/pages/flying_page.dart';
import 'package:untitled/pages/history_page.dart';
import 'package:untitled/pages/random_page.dart';
import 'package:untitled/pages/my_list_page.dart';
import 'package:untitled/pages/settings_page.dart';

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
    HistoryPage(),
    SettingPage() ];
  int? _selectedIndex;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final AdManagerBannerAd myBanner = AdManagerBannerAd(
    adUnitId: Platform.isIOS ?
    'ca-app-pub-4699704811538614/2488229900'
    :'ca-app-pub-4699704811538614/9071472631',
    sizes: [AdSize.banner],
    request: const AdManagerAdRequest(),
    listener: AdManagerBannerAdListener(), // BannerAdListener()は間違い？
  );

  @override
  Widget build(BuildContext context) {
    myBanner.load();
    final AdWidget adWidget = AdWidget(ad: myBanner);

    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            body: _screens[_selectedIndex ?? widget.page],
            bottomNavigationBar:
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //   Container(
            //   alignment: Alignment.center,
            //   width: 300,
            //   height: 50,
            //   child: adWidget,
            // ),
                BottomNavigationBar(
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
            //   ],
            // ),
          ),
        ),
      ],
    );
  }
}
