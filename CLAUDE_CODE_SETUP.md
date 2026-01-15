# 🤖 Claude Code でセットアップする方法

Claude Codeを使えば、**たった3コマンド**で完全自動セットアップできます！

## 📋 事前準備（1回だけ）

### 1. GitHub CLI のインストール

**macOS:**
```bash
brew install gh
```

**Windows:**
```powershell
winget install --id GitHub.cli
```

**Linux:**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo apt update && sudo apt install gh
```

### 2. GitHub認証（初回のみ）

```bash
gh auth login
```

以下を選択：
- GitHub.com
- HTTPS
- Yes (認証情報を保存)
- Login with a web browser

→ ブラウザで認証コードを入力して完了

---

## 🚀 Claude Codeでのセットアップ手順

### ステップ1: ZIPファイルを解凍

ダウンロードした `ai-discover-auto.zip` を解凍してください。

### ステップ2: Claude Codeを起動

```bash
# 解凍したフォルダに移動
cd ai-discover-auto

# Claude Codeを起動
claude
```

### ステップ3: セットアップスクリプトを実行

**macOS / Linux の場合:**

Claude Codeのプロンプトで以下を入力：

```
chmod +x setup.sh && ./setup.sh を実行して、GitHub にリポジトリを作成してセットアップしてください
```

**Windows の場合:**

```
PowerShell で setup.ps1 を実行して、GitHub にリポジトリを作成してセットアップしてください
```

### ステップ4: 完了を待つ

Claude Codeが自動で以下を実行します：

1. ✅ GitHub CLI の確認
2. ✅ GitHub認証の確認
3. ✅ GitHubリポジトリの作成
4. ✅ ローカルリポジトリの準備
5. ✅ ファイルのコピー
6. ✅ Git コミット & プッシュ
7. ✅ GitHub Pages の有効化
8. ✅ 初回記事収集の実行

**5〜10分後にサイトが公開されます！** 🎉

---

## 🌐 サイトにアクセス

```
https://あなたのユーザー名.github.io/ai-discover/
```

---

## 📝 セットアップ後のカスタマイズ

### 記事を手動追加

Claude Codeで：

```
config.json を開いて、manual_articles にYouTube記事を追加してください。
タイトルは「○○○」、URLは「https://...」です。
その後、git commit & push してください。
```

### 不要な記事を削除

```
config.json の blacklist に「https://note.com/spam/n/xxxxx」を追加して、
git commit & push してください。
```

### キーワードを変更

```
config.json の keywords_filter を編集して、
「機械学習」「ディープラーニング」を追加キーワードに設定してください。
その後、git commit & push してください。
```

### 記事を再収集

```
gh workflow run update.yml を実行して、記事を再収集してください
```

---

## 💡 Claude Code の便利な使い方

### 記事の状況を確認

```
data/articles.json の中身を確認して、現在何件の記事が収集されているか教えてください
```

### GitHub Actionsのログを確認

```
gh run list --workflow=update.yml で最新の実行状況を確認してください
```

### サイトのプレビュー（ローカル）

```
python -m http.server 8000 でローカルサーバーを起動して、
ブラウザで http://localhost:8000 を開いてプレビューしてください
```

---

## 🔧 トラブルシューティング

### GitHub CLI がインストールされていない

```
brew install gh (macOS) または winget install --id GitHub.cli (Windows) を実行してください
```

### 認証エラーが出る

```
gh auth login を実行して、再度認証してください
```

### リポジトリが既に存在する

```
既存のリポジトリ名を確認して、別の名前で作成するか、既存のリポジトリを削除してください
```

### GitHub Pages が有効化されない

手動で設定：
1. GitHub リポジトリの Settings → Pages
2. Source: `Deploy from a branch`
3. Branch: `main` / `/ (root)`
4. Save

---

## 🎯 おすすめの使い方

### 毎日の運用

Claude Codeを開いて：

```
今日のAI記事を確認して、面白そうなものを3つ教えてください。
その中から1つ選んで、manual_articlesに追加してください。
```

### 週次メンテナンス

```
data/articles.json を確認して、質の低い記事をブラックリストに追加してください。
config.json も更新して、git commit & push してください。
```

---

**Claude Code を使えば、すべての操作が自然言語で完結します！** 🚀
