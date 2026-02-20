# ✅ 鉄板焼き居酒屋みぞまる システム構築完了

## 🎉 納品概要

**作成日**: 2026年02月20日  
**ベースシステム**: 麺家弍色システム  
**ステータス**: ✅ 完了・稼働中

---

## 🏪 会社情報

- **店舗名**: 鉄板焼き居酒屋みぞまる
- **住所**: 〒252-0239 神奈川県相模原市中央区中央3-8-1 1階
- **電話番号**: 042-851-3516
- **メールアドレス**: mizomaru@example.com
- **業種**: 飲食業

---

## 🌐 アクセス情報

### ローカル環境（現在稼働中）

#### フロントエンド
```
http://localhost:3013
```

#### バックエンドAPI
```
http://localhost:5003/api
```

#### ログイン情報
- **ユーザー名**: `鉄板焼き居酒屋みぞまる`
- **パスワード**: `admin123`

---

## 📦 システム構成

### ディレクトリ
```
/home/user/webapp/mizomaru-teppanyaki-system/
```

### データベース
```
/home/user/webapp/mizomaru-teppanyaki-system/mizomaru-order.db
```

### 技術スタック
- **フロントエンド**: React 18 + Vite
- **バックエンド**: Node.js + Express
- **データベース**: SQLite3 (better-sqlite3)
- **認証**: JWT + bcryptjs

---

## 🎯 実装済み機能

### 1. 受注取引管理 ✅
- 受注データの登録・編集・削除
- ステータス管理（受注済み、処理中、出荷済み、納品完了、キャンセル）
- 支払状況管理（未払い、一部払い、支払済み）
- CSV一括登録
- 検索・フィルター機能

### 2. 会計帳簿 ✅
- **税額控除帳**: 消費税控除対象取引の管理
- **現金出納帳**: 現金収支の記録と残高管理
- **請求判明書**: 請求書の発行・入金管理
- **キャッシュフロー計算書**: 営業・投資・財務活動のキャッシュフロー

### 3. 在庫管理 ✅
- 在庫数量のリアルタイム追跡
- 在庫アラート（閾値設定）
- 在庫取引履歴
- カテゴリー別管理

### 4. 書類管理 ✅
- 見積書作成・発行
- 発注書作成・発行
- 納品書作成・発行
- 請求書作成・発行
- PDF出力機能

### 5. 顧客管理 ✅
- 顧客情報・連絡先管理
- 顧客タイプ別管理（法人、個人事業主、一般消費者）
- 取引履歴追跡

### 6. 仕入先管理 ✅
- 仕入先情報・支払条件管理
- 発注履歴管理
- 仕入先別取引分析

### 7. ダッシュボード ✅
- 売上・支出の可視化
- 最近の取引表示
- 在庫アラート表示
- 重要指標の一覧表示

---

## 📊 初期データ

### 登録済み
- **仕入先**: 4件（デフォルト）

### 未登録（今後追加可能）
- 顧客: 0件
- 在庫: 0件
- 書類: 0件
- 受注: 0件

---

## 🔧 サーバー管理

### 起動確認
```bash
# システム確認スクリプト
cd /home/user/webapp/mizomaru-teppanyaki-system
bash verify-mizomaru-system.sh

# バックエンド確認
curl http://localhost:5003/api/health

# ポート確認
lsof -i :3013  # フロントエンド
lsof -i :5003  # バックエンド
```

### 再起動（必要な場合）
```bash
# バックエンド再起動
cd /home/user/webapp/mizomaru-teppanyaki-system
pkill -f "node server/index.js"
node server/index.js &

# フロントエンド再起動
pkill -f "vite.*mizomaru"
npm run dev &
```

---

## 🚀 本番環境デプロイ手順

### 1. GitHubリポジトリ作成

```bash
cd /home/user/webapp/mizomaru-teppanyaki-system

# Gitを初期化（既存の.gitを削除して新規作成）
rm -rf .git
git init
git add .
git commit -m "Initial commit: 鉄板焼き居酒屋みぞまる システム"

# GitHubリポジトリを作成後
git remote add origin https://github.com/kazunarihonda83-jpg/mizomaru-teppanyaki-system.git
git branch -M main
git push -u origin main
```

### 2. Render（バックエンド）デプロイ

1. Renderダッシュボードにアクセス: https://dashboard.render.com
2. 「New +」→「Web Service」を選択
3. GitHubリポジトリを接続: `mizomaru-teppanyaki-system`
4. 設定:
   - **Name**: `mizomaru-backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `node server/index.js`
   - **Instance Type**: Starter ($7/月)
   - **Persistent Disk**: 1GB, Mount Path: `/data`

5. 環境変数を設定:
   ```
   NODE_ENV=production
   JWT_SECRET=<ランダム文字列64文字>
   ENABLE_PERSISTENT_DB=true
   ```

6. 「Create Web Service」をクリック

### 3. Vercel（フロントエンド）デプロイ

```bash
cd /home/user/webapp/mizomaru-teppanyaki-system

# Vercelにログイン
vercel login

# デプロイ
vercel --prod

# または Vercel Dashboard経由で:
# 1. https://vercel.com/dashboard
# 2. New Project
# 3. Import Git Repository: mizomaru-teppanyaki-system
# 4. Framework: Vite
# 5. Environment Variables:
#    VITE_API_URL=https://mizomaru-backend.onrender.com/api
# 6. Deploy
```

---

## 📝 重要ファイル

| ファイル | 説明 |
|----------|------|
| `README.md` | プロジェクト概要 |
| `MIZOMARU_SYSTEM_COMPLETE.md` | このファイル（システム完成報告書） |
| `verify-mizomaru-system.sh` | システム確認スクリプト |
| `server/database-init.js` | データベース初期化（みぞまる用にカスタマイズ済み） |
| `package.json` | プロジェクト設定（mizomaru用に更新済み） |
| `.env.development` | 開発環境設定 |

---

## 🔄 麺家弍色システムとの違い

### 変更点
1. **会社情報**:
   - 店舗名: 麺家弍色 → 鉄板焼き居酒屋みぞまる
   - 住所: 北海道音更町 → 神奈川県相模原市
   - 電話番号: 070-2184-0992 → 042-851-3516
   - Email: 0hp2c84c787541j@ezweb.ne.jp → mizomaru@example.com

2. **データベース名**:
   - menya-nishiki-order.db → mizomaru-order.db

3. **プロジェクト名**:
   - menya-nishiki-order-management-system → mizomaru-teppanyaki-order-management-system

4. **ログインユーザー名**:
   - 麺家弍色 → 鉄板焼き居酒屋みぞまる

### 共通機能（そのまま使用可能）
- すべての機能とUI
- データベース構造
- API エンドポイント
- 会計帳簿機能
- 書類作成機能

---

## ⚡ 次のステップ

1. ✅ **システム確認**: http://localhost:3013 にアクセス
2. ✅ **ログイン**: ユーザー名とパスワードでログイン
3. ✅ **データ登録**: 顧客・在庫・書類を登録
4. 🔜 **GitHubリポジトリ作成**: 上記手順に従って作成
5. 🔜 **本番デプロイ**: Render & Vercel にデプロイ
6. 🔐 **パスワード変更**: 初回ログイン後に変更

---

## 📞 サポート

### 参考システム
- **麺家弍色（本番環境）**:
  - フロントエンド: https://menya-nishiki-prod-final.vercel.app
  - バックエンド: https://menya-nishiki-prod-final.onrender.com/api
  - ※ このシステムと同じ機能を持っています

### ドキュメント
- `DEPLOYMENT.md` - デプロイ詳細手順
- `README.md` - プロジェクト概要
- 麺家弍色システムのドキュメント（機能は同じ）

---

## 🎊 完了

鉄板焼き居酒屋みぞまる様専用の統合受発注管理システムが完成しました！

**麺家弍色システムと同じ全機能が使用可能です。**

今すぐ **http://localhost:3013** にアクセスしてご確認ください！

---

**Built with ❤️ for 鉄板焼き居酒屋みぞまる**  
**Based on 麺家弍色 System**
