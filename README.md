# 🤖 AI Discover - 自動記事収集サイト

生成AI関連の最新情報を自動収集して表示するキュレーションサイトです。

## ✨ 機能

- ✅ **自動収集**: note、Zenn、個人ブログからRSSで自動収集
- ✅ **毎日更新**: GitHub Actionsで1日1回自動更新
- ✅ **キーワードフィルタリング**: AI関連記事のみを収集
- ✅ **手動追加**: YouTube、X（Twitter）など手動で記事追加可能
- ✅ **ブラックリスト**: 不要な記事を除外
- ✅ **レスポンシブデザイン**: スマホでも快適に閲覧

## 📁 ファイル構成

```
ai-discover-auto/
├── .github/
│   └── workflows/
│       └── update.yml           # 自動更新設定
├── scripts/
│   └── fetch_articles.py        # 記事収集スクリプト
├── data/
│   └── articles.json            # 収集した記事データ
├── config.json                  # 設定ファイル
├── index.html                   # サイト本体
└── README.md                    # このファイル
```

## 🚀 セットアップ手順

### 1. GitHubリポジトリを作成

1. GitHubにログイン
2. 新しいリポジトリを作成（パブリック）
3. リポジトリ名: `ai-discover`（任意）

### 2. ファイルをアップロード

このフォルダの全ファイルをGitHubリポジトリにアップロード：

```bash
# ローカルでの操作
git clone https://github.com/あなたのユーザー名/ai-discover.git
cd ai-discover

# ファイルをコピー
# （ダウンロードしたファイルを全てコピー）

git add .
git commit -m "Initial commit"
git push origin main
```

### 3. GitHub Pagesを有効化

1. リポジトリの `Settings` → `Pages`
2. Source: `Deploy from a branch`
3. Branch: `main` / `/ (root)`
4. Save

5分ほど待つと、サイトが公開されます！  
URL: `https://あなたのユーザー名.github.io/ai-discover/`

### 4. 初回の記事収集を実行

1. リポジトリの `Actions` タブ
2. `Update Articles` ワークフロー
3. `Run workflow` → `Run workflow`

数分後、`data/articles.json` が自動生成されます。

## ⚙️ カスタマイズ

### 収集対象を追加

`config.json` を編集：

```json
{
  "sources": [
    {
      "name": "あなたのサイト名",
      "type": "rss",
      "url": "https://example.com/feed.xml",
      "keywords": ["AI", "ChatGPT"],
      "platform": "blog"
    }
  ]
}
```

### キーワードを変更

`config.json` の `keywords_filter` を編集：

```json
{
  "keywords_filter": {
    "required_any": ["AI", "機械学習", "ディープラーニング"],
    "exclude": ["求人", "セミナー"]
  }
}
```

### 手動で記事を追加（YouTube、Xなど）

`config.json` の `manual_articles` に追加：

```json
{
  "manual_articles": [
    {
      "title": "すごいAI動画",
      "description": "Soraで作った動画の解説",
      "url": "https://youtube.com/watch?v=xxxxx",
      "platform": "youtube",
      "author": "YouTuber名",
      "time": "1日前",
      "thumbnail": "https://i.ytimg.com/vi/xxxxx/maxresdefault.jpg",
      "tags": ["Sora", "動画生成"],
      "aiTools": ["sora"]
    }
  ]
}
```

### 記事をブラックリストに追加

`config.json` の `blacklist` に追加：

```json
{
  "blacklist": [
    "https://note.com/spam/n/xxxxx",
    "https://zenn.dev/lowquality/articles/yyyyy"
  ]
}
```

## 🔧 メンテナンス

### 手動で更新を実行

1. `Actions` タブ
2. `Update Articles`
3. `Run workflow`

### ローカルでテスト

```bash
# Python環境を準備
pip install feedparser requests beautifulsoup4 lxml

# スクリプトを実行
python scripts/fetch_articles.py

# 結果を確認
cat data/articles.json
```

### エラーが発生した場合

1. `Actions` タブでログを確認
2. エラーメッセージを確認
3. 必要に応じて `config.json` を修正

## 📊 自動更新の仕組み

```
毎日 9:00 JST (0:00 UTC)
    ↓
GitHub Actionsが起動
    ↓
fetch_articles.py 実行
    ↓
RSS フィードから記事取得
    ↓
キーワードでフィルタリング
    ↓
articles.json に保存
    ↓
自動コミット & プッシュ
    ↓
GitHub Pagesが自動デプロイ
    ↓
サイトが更新される！
```

## 🎨 デザインのカスタマイズ

`index.html` の `:root` セクションで色を変更：

```css
:root {
    --color-bg: #0a0e27;          /* 背景色 */
    --color-accent: #f59e0b;      /* アクセントカラー */
    --color-text-primary: #e8eaed; /* テキスト色 */
}
```

## 📝 よくある質問

### Q: 記事が収集されない
A: `config.json` のキーワードが厳しすぎる可能性があります。`required_any` を減らしてみてください。

### Q: 古い記事も含まれる
A: `config.json` の `days_to_keep` を調整してください（デフォルト: 30日）

### Q: 自動更新の時間を変更したい
A: `.github/workflows/update.yml` の `cron` を編集してください
   - 例: `'0 9 * * *'` = 日本時間 18:00 (9:00 UTC)

### Q: 費用はかかる？
A: **完全無料**です！GitHub Actions の無料枠（月2,000分）で十分です。

## 🤝 貢献

改善案やバグ報告は Issue でお知らせください！

## 📄 ライセンス

MIT License

---

**作成者**: Claude  
**最終更新**: 2025年1月
