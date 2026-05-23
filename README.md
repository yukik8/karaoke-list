# Karalis

> カラオケに行くたびに「あの曲なんだっけ」「何歌おう」となる問題を解決する、自分専用のカラオケ管理アプリ。

歌いたい曲をリスト化して、スコアや履歴を記録。  
「おまかせ」機能でその場でランダムに1曲ピックアップ — シーズンやタグで絞り込んで迷わない。

**App Store**: [apps.apple.com/jp/app/karalis/id6466579915](https://apps.apple.com/jp/app/karalis/id6466579915)  
**バックエンド**: [karaoke-api](https://github.com/yukik8/karaoke-api)

---

## 機能

- **マイリスト** — Apple Musicから曲を検索して追加。キー（音程）・シーズン・カスタムタグで整理
- **おまかせ** — スロットマシン風アニメーションで1曲をランダムピック。シーズン・タグで事前フィルタ可能
- **記録** — 歌唱履歴とスコア（0〜100）を管理。月別表示、スコアに応じてバッジカラーが変わる（90+: 金、70-89: オレンジ）
- **設定** — アカウント情報、ログアウト、アカウント削除（全データ連動削除）

---

## Tech Stack

### アプリ

| | |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| State | Riverpod（AsyncNotifier） |
| Auth | Firebase Auth（Apple Sign-In / Google） |
| External API | Apple Music API（カスタムJWT / ES256署名） |
| Font | Noto Sans JP |
| Build | iOS / Android |

### バックエンド（[karaoke-api](https://github.com/yukik8/karaoke-api)）

| | |
|---|---|
| Framework | FastAPI（Python 3.11） |
| Hosting | Google Cloud Run |
| DB | Supabase / PostgreSQL |
| Auth | Firebase Admin SDK（IDトークン検証） |
| ORM | SQLAlchemy 2.0 + Alembic |
| External API | Apple Music API |

---

## セットアップ

### 必要なファイル（git管理外）

```
ios/Runner/GoogleService-Info.plist   # Firebase iOS設定
android/app/google-services.json     # Firebase Android設定
```

### 依存関係のインストールと起動

```bash
flutter pub get
flutter run
```

### バックエンド（ローカル開発）

```bash
cd ../karaoke-api
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

環境変数は `.env` に記載。

---

## 環境

- Flutter 3.x / Dart 3.x
- Python 3.11
