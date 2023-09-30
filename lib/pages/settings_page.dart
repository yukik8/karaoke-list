import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import '../assets/constants/privacy_policy.dart';
import '../assets/constants/terms_of_service.dart';
import '../assets/ui_components/settings_item.dart';
import '../assets/ui_components/settings_modal.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool hasError = false;
  String version = '';

  @override
  void initState() {
    Future(() async {
      await getVersion();
    });
    super.initState();
  }

  Future<void> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text("Settings",
        style: TextStyle(color: Color(0xffC57E14)),)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 0.5),
          SizedBox(
            height: 32,
            child: Container(
              color: const Color(0xffFAFAFA),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SettingsItem(
              title: 'プライバシーポリシー',
              data: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return SettingsModal(
                          title: 'プライバシーポリシー',
                          sentence: PrivacyPolicy().privacyText);
                    });
              }),
          SettingsItem(
              title: '利用規約',
              data: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return SettingsModal(
                          title: '利用規約', sentence: TermsOfService().termsText);
                    });
              }),
          SettingsItem(
            title: 'アプリバージョン',
            data: Text('v$version'),
          ),
          const SizedBox(
            height: 36,
          ),
            // const Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text(
            //       '　その他',
            //       style: TextStyle(
            //         fontSize: 12,
            //         fontWeight: FontWeight.w500,
            //         color: Color(0xff828282),
            //       ),
            //     ),
            //     SizedBox(
            //       height: 8,
            //     ),
            //   ],
            // ),
        ],
      ),
    );
  }
}
