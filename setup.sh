#!/bin/bash
# AI Discover - Claude Code 自動セットアップスクリプト

set -e  # エラーで停止

echo "🤖 AI Discover - 自動セットアップを開始"
echo "=================================================="

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# リポジトリ名（変更可能）
REPO_NAME="ai-discover"
REPO_DESCRIPTION="生成AI情報の自動キュレーションサイト"

# ステップ1: GitHub CLI のインストール確認
echo -e "\n${YELLOW}[1/7] GitHub CLI の確認...${NC}"
if ! command -v gh &> /dev/null; then
    echo -e "${RED}GitHub CLI (gh) がインストールされていません${NC}"
    echo "以下のコマンドでインストールしてください："
    echo ""
    echo "  # macOS"
    echo "  brew install gh"
    echo ""
    echo "  # Windows (winget)"
    echo "  winget install --id GitHub.cli"
    echo ""
    echo "  # Linux"
    echo "  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "  echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    echo "  sudo apt update"
    echo "  sudo apt install gh"
    exit 1
fi
echo -e "${GREEN}✓ GitHub CLI が利用可能です${NC}"

# ステップ2: GitHub認証の確認
echo -e "\n${YELLOW}[2/7] GitHub認証の確認...${NC}"
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}GitHub認証が必要です${NC}"
    echo "以下のコマンドを実行して認証してください："
    echo ""
    echo "  gh auth login"
    echo ""
    read -p "認証が完了したら Enter を押してください..."
fi

gh auth status
echo -e "${GREEN}✓ GitHub認証が完了しています${NC}"

# ステップ3: リポジトリの作成
echo -e "\n${YELLOW}[3/7] GitHubリポジトリの作成...${NC}"

# 既存のリポジトリをチェック
if gh repo view "$REPO_NAME" &> /dev/null; then
    echo -e "${YELLOW}リポジトリ '$REPO_NAME' は既に存在します${NC}"
    read -p "既存のリポジトリを使用しますか？ (y/n): " use_existing
    if [[ $use_existing != "y" ]]; then
        echo "別のリポジトリ名を入力してください："
        read REPO_NAME
    fi
else
    echo "リポジトリ '$REPO_NAME' を作成します..."
    gh repo create "$REPO_NAME" \
        --public \
        --description "$REPO_DESCRIPTION" \
        --clone=false
    echo -e "${GREEN}✓ リポジトリが作成されました${NC}"
fi

# ステップ4: ローカルリポジトリの準備
echo -e "\n${YELLOW}[4/7] ローカルリポジトリの準備...${NC}"

# 既にクローンされているかチェック
if [ -d "$REPO_NAME" ]; then
    echo -e "${YELLOW}ディレクトリ '$REPO_NAME' が既に存在します${NC}"
    read -p "削除して再作成しますか？ (y/n): " recreate
    if [[ $recreate == "y" ]]; then
        rm -rf "$REPO_NAME"
        git clone "https://github.com/$(gh api user -q .login)/$REPO_NAME.git"
    else
        cd "$REPO_NAME"
    fi
else
    git clone "https://github.com/$(gh api user -q .login)/$REPO_NAME.git"
    cd "$REPO_NAME"
fi

echo -e "${GREEN}✓ ローカルリポジトリの準備完了${NC}"

# ステップ5: プロジェクトファイルのコピー
echo -e "\n${YELLOW}[5/7] プロジェクトファイルのコピー...${NC}"

# ai-discover-autoフォルダからファイルをコピー
if [ -d "../ai-discover-auto" ]; then
    cp -r ../ai-discover-auto/* .
    cp -r ../ai-discover-auto/.github .
    cp ../ai-discover-auto/.gitignore .
    echo -e "${GREEN}✓ ファイルのコピー完了${NC}"
else
    echo -e "${RED}ai-discover-auto フォルダが見つかりません${NC}"
    echo "ZIPファイルを解凍してから再実行してください"
    exit 1
fi

# ステップ6: Git コミット & プッシュ
echo -e "\n${YELLOW}[6/7] ファイルをコミット & プッシュ...${NC}"

git add .
git commit -m "🚀 Initial commit - AI Discover setup"
git push -u origin main

echo -e "${GREEN}✓ ファイルのプッシュ完了${NC}"

# ステップ7: GitHub Pages の有効化
echo -e "\n${YELLOW}[7/7] GitHub Pages の設定...${NC}"

# GitHub API経由でPages を有効化
gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    "/repos/$(gh api user -q .login)/$REPO_NAME/pages" \
    -f source[branch]=main \
    -f source[path]=/ \
    2>/dev/null && echo -e "${GREEN}✓ GitHub Pages が有効化されました${NC}" || echo -e "${YELLOW}! GitHub Pages の設定に失敗しました（手動で設定してください）${NC}"

# ステップ8: GitHub Actions の手動実行
echo -e "\n${YELLOW}[8/8] 初回の記事収集を実行...${NC}"
sleep 5  # Pagesの設定が反映されるまで待機

gh workflow run update.yml

echo -e "${GREEN}✓ ワークフローが開始されました${NC}"

# 完了メッセージ
echo ""
echo "=================================================="
echo -e "${GREEN}✨ セットアップ完了！${NC}"
echo "=================================================="
echo ""
echo "🌐 サイトURL: https://$(gh api user -q .login).github.io/$REPO_NAME/"
echo "📊 GitHub: https://github.com/$(gh api user -q .login)/$REPO_NAME"
echo ""
echo "⏰ 5-10分後にサイトが公開されます"
echo ""
echo "次のステップ："
echo "1. Actions タブでワークフローの進行状況を確認"
echo "2. data/articles.json が生成されたことを確認"
echo "3. サイトにアクセスして動作確認"
echo ""
echo "🎨 カスタマイズ:"
echo "  - config.json でキーワードや収集対象を変更"
echo "  - manual_articles に手動で記事を追加"
echo ""
echo "詳細は README.md をご覧ください"
echo ""
