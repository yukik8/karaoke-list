# iOS 26 対応 Flutter アップグレード 学び

> 2026-05-20 / Flutter 3.13.3 → 3.44.0

---

## 根本原因

**Flutter 3.13.3（2023年9月）はiOS 26（2025年）に対応していなかった。**

それだけ。でも辿り着くまでに多くの迷い道があった。

---

## ループした原因

### 1. SIGABRT の場所を誤読した

Xcodeのデバッガはクラッシュ位置を「最も近いユーザーコードの行」に表示する。  
`@objc class AppDelegate: FlutterAppDelegate {` が赤くなっても、**そこでクラッシュしているわけではない**。  
実際は Flutter.framework のバイナリがiOS 26のランタイムで起動できていなかった。

### 2. コンパイルが通る ≠ 動く

`flutter build ios --no-codesign` が成功していたのに実機クラッシュが続いた。  
**ビルド（Xcode）はiOS 26 SDKでコンパイルできる。でも Flutter 3.13 のバイナリは iOS 26 のランタイムで実行できない。**  
→ コンパイル成功は「動く」の証明ではない。

### 3. 症状ベースで直そうとした

- `SIGABRT` → SceneManifest疑い → 消す → また同じ症状
- `非モジュールヘッダーエラー` → xcconfig をいじる → ビルド壊れる → 戻す

**症状の裏にある「なぜ」を確認せずに直し始めるとループする。**

### 4. 環境バージョンを最初に確認しなかった

```
device_osBuild = "26.4"   ← iOS 26（2025年新OS）
flutter --version → 3.13.3（2023年9月）
```

これを最初に見ていれば全体の1/10の時間で解決できた。

---

## 正しい診断フロー

```
クラッシュ発生
  ↓
① flutter --version と device iOS バージョンを確認
  ↓
② 対応表を確認（Flutter何年製？デバイスOS何年製？）
  ↓
③ flutter run の生ログを見る（"Unexpected debug results" が出ていた）
  ↓
④ 原因確定 → flutter upgrade
```

---

## 技術的な覚え書き

| 事象 | 実際の意味 |
|---|---|
| Xcodeで `@UIApplicationMain` 行が赤い | その行じゃなく、フレームワーク読み込み失敗の可能性 |
| `flutter build` 成功 | コンパイルOK。ランタイム互換性は別問題 |
| `Unexpected debug results` | Flutter tooling がそのiOSバージョンを知らない = バージョン不一致のサイン |
| CocoaPodsに全部入らない | Flutter 3.44以降はSPM（Swift Package Manager）がデフォルト |
| `firebase_auth 非モジュールヘッダーエラー` | Firebase 4.x + Xcode 16+ の既知の非互換。6.xに上げれば消える |

---

## 今回の対応内容

| 変更 | 詳細 |
|---|---|
| Flutter 3.13.3 → 3.44.0 | `flutter upgrade` |
| iOS最低バージョン 13.0 → 15.0 | Firebase 6.x (SPM) が iOS 15 以上を要求 |
| firebase_core `^2` → `^4.9.0` | SPM対応版、Xcode 26互換 |
| firebase_auth `^4` → `^6.5.1` | 同上、非モジュールヘッダー問題も解消 |
| google_mobile_ads `^3` → `^8.0.0` | SPM対応版 |
| riverpod/flutter_riverpod `^2` → `^3` | `StateNotifier` 等が `legacy.dart` に移動 |
| google_sign_in `^6` → `^7.2.0` | `GoogleSignIn()` → `GoogleSignIn.instance`、`signIn()` → `authenticate()` |
| package_info_plus `^4` → `^10.1.0` | win32 6.x との互換性 |

### Riverpod 3.x で変わったこと

```dart
// StateNotifier / StateNotifierProvider / StateProvider を使っているファイルに追加
import 'package:flutter_riverpod/legacy.dart';

// valueOrNull は .value に変わった
state.valueOrNull  →  state.value
```

### GoogleSignIn 7.x で変わったこと

```dart
// 起動時に一度だけ初期化が必要
await GoogleSignIn.instance.initialize();

// サインイン
// 旧: final user = await GoogleSignIn().signIn();
final user = await GoogleSignIn.instance.authenticate();

// authentication は非同期ではなくなった
// 旧: final auth = await user.authentication;
final auth = user.authentication;

// accessToken は取れなくなった。idToken だけで Firebase 認証は可能
final credential = GoogleAuthProvider.credential(
  idToken: auth.idToken,
);

// サインアウト
// 旧: await GoogleSignIn().signOut();
await GoogleSignIn.instance.signOut();
```

---

## 今後のチェックリスト（新しいiOSデバイスで動かないとき）

1. `flutter --version` → Flutter は何年製か？
2. デバイスのiOSは何年リリースか？
3. Flutter のリリースノートでそのiOSバージョンのサポートが入っているか確認
4. 古ければ `flutter upgrade` 一択
