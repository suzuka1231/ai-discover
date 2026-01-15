# 🚀 クイックスタートガイド

## 最短5ステップで公開！

### ステップ1: GitHubリポジトリ作成
1. https://github.com/new にアクセス
2. Repository name: `ai-discover`
3. Public を選択
4. Create repository

### ステップ2: ファイルをアップロード
1. 作成したリポジトリページで `uploading an existing file` をクリック
2. このフォルダの全ファイルをドラッグ&ドロップ
3. Commit changes

### ステップ3: GitHub Pages有効化
1. Settings → Pages
2. Source: `Deploy from a branch`
3. Branch: `main` / `/ (root)`
4. Save

### ステップ4: 初回の記事収集
1. Actions タブ
2. `I understand my workflows, go ahead and enable them` をクリック
3. `Update Articles` → `Run workflow` → `Run workflow`

### ステップ5: サイトを確認
https://あなたのユーザー名.github.io/ai-discover/

**完成！** 🎉

---

## 💡 次にやること

### 記事を手動追加（YouTube、Xなど）

1. `config.json` を開く
2. `manual_articles` セクションに追加：

```json
{
  "title": "記事タイトル",
  "description": "説明文",
  "url": "https://youtube.com/watch?v=xxxxx",
  "platform": "youtube",
  "author": "作成者名",
  "time": "1日前",
  "thumbnail": "画像URL",
  "tags": ["ChatGPT", "プロンプト"],
  "aiTools": ["chatgpt"]
}
```

3. Commit changes

### 不要な記事を削除

サイト上の「🗑️ 削除」ボタンをクリック  
→ 表示される指示に従って `config.json` の `blacklist` に追加

### 収集対象を変更

`config.json` の `keywords_filter` を編集：

```json
{
  "required_any": ["追加したいキーワード"],
  "exclude": ["除外したいキーワード"]
}
```

---

## ❓ トラブルシューティング

### サイトが表示されない
- GitHub Pages の設定を確認
- 5〜10分待ってから再度アクセス

### 記事が表示されない
- Actions タブで `Update Articles` を手動実行
- エラーログを確認

### もっと詳しく知りたい
README.md を読んでください！

---

**何か問題があれば、GitHub の Issues で質問してください！**
