# 🔧 Vercel環境変数修正手順

## 問題
ログインできない原因: Vercelの環境変数が設定されていないため、フロントエンドがlocalhostを参照している

```
期待: https://mizomaru-backend.onrender.com/api
実際: http://localhost:5003/api
```

## 解決方法

### 方法1: Vercelダッシュボード（推奨）

1. https://vercel.com/dashboard にアクセス

2. `mizomaru-teppanyaki-system` プロジェクトを選択

3. **Settings** タブをクリック

4. 左メニューから **Environment Variables** を選択

5. **Add New** をクリック

6. 以下を入力:
   ```
   Name: VITE_API_URL
   Value: https://mizomaru-backend.onrender.com/api
   Environment: ✅ Production ✅ Preview ✅ Development
   ```

7. **Save** をクリック

8. **Deployments** タブに移動

9. 最新のデプロイの右側 **[...]** メニューをクリック

10. **Redeploy** を選択

11. **Redeploy** を確認

12. デプロイ完了を待つ（2-3分）

13. https://mizomaru-teppanyaki-system.vercel.app/login でログイン確認

---

### 方法2: Vercel CLI（コマンドライン）

```bash
cd /home/user/webapp/mizomaru-teppanyaki-system

# 環境変数を設定
vercel env add VITE_API_URL production

# プロンプトで入力:
# https://mizomaru-backend.onrender.com/api

# 再デプロイ
vercel --prod
```

---

## 確認

デプロイ完了後:

1. ブラウザで https://mizomaru-teppanyaki-system.vercel.app/login にアクセス

2. ブラウザの開発者ツール（F12）でコンソールを確認:
   ```
   期待される出力:
   [API Config] Using baseURL: https://mizomaru-backend.onrender.com/api
   ```

3. ログイン情報を入力:
   - ユーザー名: `鉄板焼き居酒屋みぞまる`
   - パスワード: `admin123`

4. ログイン成功を確認

---

## トラブルシューティング

### まだlocalhostを参照している場合

1. Vercelでキャッシュをクリア:
   - Deployments → 最新デプロイ → [...] → Redeploy → ✅ Clear cache

2. ブラウザのキャッシュをクリア:
   - Ctrl + Shift + Delete → キャッシュクリア

3. シークレットモードで確認

---

## コード変更内容

✅ `index.html`: タイトルを「鉄板焼き居酒屋みぞまる」に変更  
✅ `.env.production.example`: 正しいAPI URLを設定  
✅ GitHubにプッシュ済み  

あとはVercelで環境変数を設定して再デプロイするだけです！
