#!/bin/bash

API_URL="http://localhost:5003/api"

echo "========================================="
echo " 鉄板焼き居酒屋みぞまる システム確認"
echo "========================================="
echo ""

# ログイン
echo "🔐 ログイン中..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "鉄板焼き居酒屋みぞまる", "password": "admin123"}')

TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token // empty')

if [ -z "$TOKEN" ]; then
  echo "❌ ログイン失敗"
  echo "$LOGIN_RESPONSE"
  exit 1
fi

echo "✅ ログイン成功"
echo ""

echo "=== システム情報 ==="
echo "🏪 店舗名: 鉄板焼き居酒屋みぞまる"
echo "📍 住所: 〒252-0239 神奈川県相模原市中央区中央3-8-1 1階"
echo "☎️  電話: 042-851-3516"
echo "📧 Email: mizomaru@example.com"
echo ""

echo "=== アクセス情報 ==="
echo "🌐 フロントエンド: http://localhost:3013"
echo "🔌 バックエンドAPI: http://localhost:5003/api"
echo "🔐 ユーザー名: 鉄板焼き居酒屋みぞまる"
echo "🔑 パスワード: admin123"
echo ""

echo "=== 現在のデータ ==="
CUSTOMERS=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/customers" | jq '. | length // 0')
SUPPLIERS=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/suppliers" | jq '. | length // 0')
INVENTORY=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/inventory" | jq '. | length // 0')
DOCUMENTS=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/documents" | jq '. | length // 0')

echo "顧客: ${CUSTOMERS}件"
echo "仕入先: ${SUPPLIERS}件"
echo "在庫: ${INVENTORY}件"
echo "書類: ${DOCUMENTS}件"
echo ""

echo "========================================="
echo " ✅ システム確認完了"
echo "========================================="
