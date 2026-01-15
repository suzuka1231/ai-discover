# AI Discover - Claude Code 自動セットアップスクリプト (Windows版)

$ErrorActionPreference = "Stop"

Write-Host "🤖 AI Discover - 自動セットアップを開始" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# リポジトリ名（変更可能）
$REPO_NAME = "ai-discover"
$REPO_DESCRIPTION = "生成AI情報の自動キュレーションサイト"

# ステップ1: GitHub CLI のインストール確認
Write-Host "`n[1/7] GitHub CLI の確認..." -ForegroundColor Yellow
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI (gh) がインストールされていません" -ForegroundColor Red
    Write-Host "以下のコマンドでインストールしてください："
    Write-Host ""
    Write-Host "  winget install --id GitHub.cli" -ForegroundColor White
    Write-Host ""
    Write-Host "または https://cli.github.com/ からダウンロード"
    exit 1
}
Write-Host "✓ GitHub CLI が利用可能です" -ForegroundColor Green

# ステップ2: GitHub認証の確認
Write-Host "`n[2/7] GitHub認証の確認..." -ForegroundColor Yellow
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub認証が必要です" -ForegroundColor Yellow
    Write-Host "以下のコマンドを実行して認証してください：" -ForegroundColor White
    Write-Host ""
    Write-Host "  gh auth login" -ForegroundColor White
    Write-Host ""
    Read-Host "認証が完了したら Enter を押してください"
}

gh auth status
Write-Host "✓ GitHub認証が完了しています" -ForegroundColor Green

# ステップ3: リポジトリの作成
Write-Host "`n[3/7] GitHubリポジトリの作成..." -ForegroundColor Yellow

# 既存のリポジトリをチェック
$repoExists = gh repo view $REPO_NAME 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "リポジトリ '$REPO_NAME' は既に存在します" -ForegroundColor Yellow
    $useExisting = Read-Host "既存のリポジトリを使用しますか？ (y/n)"
    if ($useExisting -ne "y") {
        $REPO_NAME = Read-Host "別のリポジトリ名を入力してください"
    }
} else {
    Write-Host "リポジトリ '$REPO_NAME' を作成します..."
    gh repo create $REPO_NAME `
        --public `
        --description $REPO_DESCRIPTION `
        --clone=false
    Write-Host "✓ リポジトリが作成されました" -ForegroundColor Green
}

# ステップ4: ローカルリポジトリの準備
Write-Host "`n[4/7] ローカルリポジトリの準備..." -ForegroundColor Yellow

$username = gh api user -q .login

# 既にクローンされているかチェック
if (Test-Path $REPO_NAME) {
    Write-Host "ディレクトリ '$REPO_NAME' が既に存在します" -ForegroundColor Yellow
    $recreate = Read-Host "削除して再作成しますか？ (y/n)"
    if ($recreate -eq "y") {
        Remove-Item -Recurse -Force $REPO_NAME
        git clone "https://github.com/$username/$REPO_NAME.git"
    } else {
        Set-Location $REPO_NAME
    }
} else {
    git clone "https://github.com/$username/$REPO_NAME.git"
    Set-Location $REPO_NAME
}

Write-Host "✓ ローカルリポジトリの準備完了" -ForegroundColor Green

# ステップ5: プロジェクトファイルのコピー
Write-Host "`n[5/7] プロジェクトファイルのコピー..." -ForegroundColor Yellow

# ai-discover-autoフォルダからファイルをコピー
if (Test-Path "..\ai-discover-auto") {
    Copy-Item -Path "..\ai-discover-auto\*" -Destination . -Recurse -Force
    Copy-Item -Path "..\ai-discover-auto\.github" -Destination . -Recurse -Force
    Copy-Item -Path "..\ai-discover-auto\.gitignore" -Destination . -Force
    Write-Host "✓ ファイルのコピー完了" -ForegroundColor Green
} else {
    Write-Host "ai-discover-auto フォルダが見つかりません" -ForegroundColor Red
    Write-Host "ZIPファイルを解凍してから再実行してください"
    exit 1
}

# ステップ6: Git コミット & プッシュ
Write-Host "`n[6/7] ファイルをコミット & プッシュ..." -ForegroundColor Yellow

git add .
git commit -m "🚀 Initial commit - AI Discover setup"
git push -u origin main

Write-Host "✓ ファイルのプッシュ完了" -ForegroundColor Green

# ステップ7: GitHub Pages の有効化
Write-Host "`n[7/7] GitHub Pages の設定..." -ForegroundColor Yellow

try {
    gh api `
        --method POST `
        -H "Accept: application/vnd.github+json" `
        "/repos/$username/$REPO_NAME/pages" `
        -f source[branch]=main `
        -f source[path]=/ | Out-Null
    Write-Host "✓ GitHub Pages が有効化されました" -ForegroundColor Green
} catch {
    Write-Host "! GitHub Pages の設定に失敗しました（手動で設定してください）" -ForegroundColor Yellow
}

# ステップ8: GitHub Actions の手動実行
Write-Host "`n[8/8] 初回の記事収集を実行..." -ForegroundColor Yellow
Start-Sleep -Seconds 5  # Pagesの設定が反映されるまで待機

gh workflow run update.yml

Write-Host "✓ ワークフローが開始されました" -ForegroundColor Green

# 完了メッセージ
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "✨ セットアップ完了！" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 サイトURL: https://$username.github.io/$REPO_NAME/" -ForegroundColor White
Write-Host "📊 GitHub: https://github.com/$username/$REPO_NAME" -ForegroundColor White
Write-Host ""
Write-Host "⏰ 5-10分後にサイトが公開されます" -ForegroundColor Yellow
Write-Host ""
Write-Host "次のステップ："
Write-Host "1. Actions タブでワークフローの進行状況を確認"
Write-Host "2. data/articles.json が生成されたことを確認"
Write-Host "3. サイトにアクセスして動作確認"
Write-Host ""
Write-Host "🎨 カスタマイズ:"
Write-Host "  - config.json でキーワードや収集対象を変更"
Write-Host "  - manual_articles に手動で記事を追加"
Write-Host ""
Write-Host "詳細は README.md をご覧ください"
Write-Host ""
