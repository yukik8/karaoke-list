# Karalis

カラオケのマイリストを管理するiOS / Androidアプリ。

## 機能

- **マイリスト** — 歌いたい曲を登録・管理。キー・シーズン・タグで整理できる
- **おまかせ** — マイリストからランダムに曲を提案
- **記録** — 歌った履歴とスコアを管理
- **設定** — アカウント情報、ログアウト、アカウント削除

## 技術スタック

### アプリ (Flutter)

| カテゴリ | 使用技術 |
|---|---|
| フレームワーク | Flutter / Dart |
| 状態管理 | Riverpod |
| 認証 | Firebase Auth（Google / Apple Sign-In） |
| API通信 | http |
| フォント | Noto Sans JP |

### バックエンド

| カテゴリ | 使用技術 |
|---|---|
| API | FastAPI（Python） |
| ホスティング | Google Cloud Run |
| データベース | Supabase（PostgreSQL） |
| 認証検証 | Firebase Admin SDK |

## セットアップ

### 必要なファイル（git管理外）

以下のファイルはリポジトリに含まれていないため、別途用意が必要です。

```
ios/Runner/GoogleService-Info.plist   # Firebase iOS設定
android/app/google-services.json     # Firebase Android設定
```

### Flutter

```bash
flutter pub get
flutter run
```

### API（ローカル開発）

```bash
cd ../karaoke-api
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

環境変数は `.env` に記載。

## 環境

- Flutter 3.x
- Dart 3.x
- Python 3.11
