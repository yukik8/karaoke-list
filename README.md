*日本語は下に記載しています。*

# Karalis

> Your personal karaoke manager — track songs you want to sing, log scores, and let the app pick what's next.

Never forget which songs you wanted to sing, or spend time deciding. Karalis keeps your karaoke list organized by key, season, and tags — and picks a song for you when you can't decide.

**App Store**: [apps.apple.com/jp/app/karalis/id6466579915](https://apps.apple.com/jp/app/karalis/id6466579915)  
**Backend**: [karaoke-api](https://github.com/yukik8/karaoke-api)

---

## Features

- **My List** — Search Apple Music and add songs with key (pitch adjustment), season, and custom tags
- **Random Pick** — Slot-machine animation picks one song at random; filter by season and tags before the draw
- **History** — Log scores (0–100) and memos for each performance; grouped by month with color-coded score badges (gold: 90+, orange: 70–89)
- **Settings** — Account management, logout, account deletion with full data cleanup

---

## Tech Stack

### App

| | |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| State | Riverpod (AsyncNotifier) |
| Auth | Firebase Auth (Apple Sign-In / Google) |
| External API | Apple Music API (custom JWT / ES256 signing) |
| Font | Noto Sans JP |
| Build | iOS / Android |

### Backend ([karaoke-api](https://github.com/yukik8/karaoke-api))

| | |
|---|---|
| Framework | FastAPI (Python 3.11) |
| Hosting | Google Cloud Run |
| DB | Supabase / PostgreSQL |
| Auth | Firebase Admin SDK (ID token verification) |
| ORM | SQLAlchemy 2.0 + Alembic |
| External API | Apple Music API |

---

## Setup

### Required files (not in repo)

```
ios/Runner/GoogleService-Info.plist   # Firebase iOS config
android/app/google-services.json     # Firebase Android config
```

### Install and run

```bash
flutter pub get
flutter run
```

### Backend (local dev)

```bash
cd ../karaoke-api
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Set environment variables in `.env`.

---

---
---

# Karalis（日本語）

> カラオケに行くたびに「あの曲なんだっけ」「何歌おう」となる問題を解決する、自分専用のカラオケ管理アプリ。

歌いたい曲をリスト化して、スコアや履歴を記録。「おまかせ」機能でその場でランダムに1曲ピックアップ — シーズンやタグで絞り込んで迷わない。

---

## 機能

- **マイリスト** — Apple Musicから曲を検索して追加。キー（音程）・シーズン・カスタムタグで整理
- **おまかせ** — スロットマシン風アニメーションで1曲をランダムピック。シーズン・タグで事前フィルタ可能
- **記録** — 歌唱履歴とスコア（0〜100）を管理。月別表示、スコアに応じてバッジカラーが変わる（90+: 金、70-89: オレンジ）
- **設定** — アカウント情報、ログアウト、アカウント削除（全データ連動削除）

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
