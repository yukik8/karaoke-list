import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../data/register_notifier.dart';
import '../services/api_service.dart';

import '../assets/constants/privacy_policy.dart';
import '../assets/constants/terms_of_service.dart';
import '../assets/ui_components/settings_item.dart';
import '../assets/ui_components/settings_modal.dart';

class _AccountItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? '';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 24, 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              backgroundColor: const Color(0xffEEEEEE),
              child: photoUrl == null
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  Text(name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                Text(email,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xff828282))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({Key? key}) : super(key: key);
  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
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
          _AccountItem(),
          const SizedBox(height: 36),
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
          const SizedBox(height: 36),
          SettingsItem(
            title: 'ログアウト',
            data: const Icon(Icons.logout, size: 16, color: Colors.red),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('ログアウト'),
                  content: const Text('ログアウトしますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('ログアウト',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.invalidate(dataProvider);
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
              }
            },
          ),
          SettingsItem(
            title: 'アカウントを削除',
            data: const Icon(Icons.delete_forever, size: 16, color: Colors.red),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('アカウントを削除'),
                  content: const Text('全てのデータが削除されます。この操作は取り消せません。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('削除',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
              try {
                await KaraokeApiService.instance.deleteAccount();
                ref.invalidate(dataProvider);
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.currentUser?.delete();
              } on FirebaseAuthException catch (e) {
                if (e.code == 'requires-recent-login') {
                  if (!context.mounted) return;
                  // 再認証が必要な理由をユーザーに説明してから進む
                  final proceed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('本人確認が必要です'),
                      content: const Text(
                          'セキュリティのため、もう一度Googleアカウントでサインインしてください。\n完了するとアカウントが削除されます。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('サインインして削除',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (proceed != true) return;
                  try {
                    final providers = FirebaseAuth.instance.currentUser
                            ?.providerData
                            .map((p) => p.providerId)
                            .toList() ??
                        [];
                    final AuthCredential credential;
                    if (providers.contains('apple.com')) {
                      final appleCredential =
                          await SignInWithApple.getAppleIDCredential(
                        scopes: [
                          AppleIDAuthorizationScopes.email,
                          AppleIDAuthorizationScopes.fullName,
                        ],
                      );
                      credential = OAuthProvider('apple.com').credential(
                        idToken: appleCredential.identityToken,
                        accessToken: appleCredential.authorizationCode,
                      );
                    } else {
                      final googleUser = await GoogleSignIn().signIn();
                      if (googleUser == null) return;
                      final googleAuth = await googleUser.authentication;
                      credential = GoogleAuthProvider.credential(
                        accessToken: googleAuth.accessToken,
                        idToken: googleAuth.idToken,
                      );
                    }
                    await FirebaseAuth.instance.currentUser
                        ?.reauthenticateWithCredential(credential);
                    await FirebaseAuth.instance.currentUser?.delete();
                    // delete() 後も Google セッションが残るので明示的にサインアウト
                    await GoogleSignIn().signOut();
                  } catch (_) {
                    // 再認証も失敗した場合は強制サインアウト（データは既に削除済み）
                    await GoogleSignIn().signOut();
                    await FirebaseAuth.instance.signOut();
                  }
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('削除に失敗しました: ${e.message}')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('削除に失敗しました: $e')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 36),
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
