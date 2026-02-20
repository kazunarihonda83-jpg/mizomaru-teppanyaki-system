# GitHubへのプッシュ手順

## ✅ 準備完了
- ローカルコードのコミット完了
- リモートURL設定完了: `https://github.com/kazunarihonda83-jpg/mizomaru-teppanyaki-system.git`

## 📋 次のステップ

### 1. GitHubでリポジトリを作成
1. ブラウザで以下のページにアクセス（すでに開いているはず）:
   https://github.com/new

2. 以下の設定で **「Create repository」** ボタンをクリック:
   - Owner: `kazunarihonda83-jpg`
   - Repository name: `mizomaru-teppanyaki-system` ✅
   - Visibility: **Public** （推奨）
   - **README、.gitignore、license は追加しない**（既にコードがあるため）

### 2. リポジトリ作成後、以下のコマンドを実行

```bash
cd /home/user/webapp/mizomaru-teppanyaki-system
git push -u origin main
```

## 🎯 プッシュ後の確認

プッシュが成功したら、以下のURLでリポジトリを確認:
https://github.com/kazunarihonda83-jpg/mizomaru-teppanyaki-system

---

## 📦 次のステップ: デプロイ

### A. Render（バックエンド）デプロイ
1. https://dashboard.render.com にアクセス
2. 「New」→「Web Service」を選択
3. GitHub リポジトリ `mizomaru-teppanyaki-system` を接続
4. 設定:
   - **Name**: `mizomaru-backend`
   - **Environment**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `node server/index.js`
   - **Instance Type**: Starter ($7/month)
5. **Environment Variables** を追加:
   ```
   NODE_ENV=production
   JWT_SECRET=YOUR_RANDOM_64_CHAR_SECRET_HERE
   ENABLE_PERSISTENT_DB=true
   ```
6. **Disk** を追加:
   - Name: `data`
   - Mount Path: `/data`
   - Size: 1GB
7. 「Create Web Service」をクリック
8. デプロイ完了後、URLをメモ（例: `https://mizomaru-backend.onrender.com`）

### B. Vercel（フロントエンド）デプロイ
1. https://vercel.com/dashboard にアクセス
2. 「Add New...」→「Project」を選択
3. GitHub リポジトリ `mizomaru-teppanyaki-system` をインポート
4. 設定:
   - **Framework Preset**: Vite
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
5. **Environment Variables** を追加:
   ```
   VITE_API_URL=https://mizomaru-backend.onrender.com/api
   ```
   ⚠️ **注意**: RenderのバックエンドURL（ステップA-8でメモしたURL）を使用
6. 「Deploy」をクリック
7. デプロイ完了後、本番URLを確認（例: `https://mizomaru-teppanyaki-system.vercel.app`）

---

## 🎉 完了後
1. 本番URLにアクセス
2. ログイン情報でログイン:
   - ユーザー名: `鉄板焼き居酒屋みぞまる`
   - パスワード: `admin123`
3. ダッシュボードで動作確認
4. **重要**: 初回ログイン後、パスワードを変更してください

---

## 📞 サポート
問題が発生した場合は、以下を確認:
- Renderのログ（バックエンドエラー確認用）
- Vercelのデプロイログ（フロントエンドエラー確認用）
- `MIZOMARU_SYSTEM_COMPLETE.md` の詳細ドキュメント
