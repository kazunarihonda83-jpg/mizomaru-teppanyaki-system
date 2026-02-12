#!/bin/bash

# 仮環境のバックエンドをテスト
API_URL="https://5003-iwz00ie3gdkhvxpx2ni1z-5c13a017.sandbox.novita.ai/api"

echo "=== 受注番号自動採番テスト ==="

# ログイン
echo "1. ログイン..."
TOKEN=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"麺家弍色","password":"admin123"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ ログイン失敗"
  exit 1
fi

echo "✅ ログイン成功"

# 受注取引を作成（受注番号なし）
echo ""
echo "2. 受注取引作成（受注番号は自動採番）..."
RESPONSE=$(curl -s -X POST "$API_URL/order-receipts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "customer_id": 1,
    "order_date": "2026-02-12",
    "delivery_date": "2026-02-15",
    "status": "pending",
    "payment_status": "unpaid",
    "notes": "テスト受注（自動採番）",
    "items": [
      {
        "item_name": "テスト商品A",
        "description": "自動採番テスト",
        "quantity": 2,
        "unit_price": 1000
      }
    ]
  }')

echo "$RESPONSE" | jq '.'

# 受注番号を確認
RECEIPT_NUMBER=$(echo "$RESPONSE" | jq -r '.data.receipt_number')
echo ""
echo "✅ 自動生成された受注番号: $RECEIPT_NUMBER"

# 2件目を作成
echo ""
echo "3. 2件目の受注取引作成..."
RESPONSE2=$(curl -s -X POST "$API_URL/order-receipts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "customer_id": 1,
    "order_date": "2026-02-12",
    "delivery_date": "2026-02-16",
    "status": "pending",
    "payment_status": "unpaid",
    "notes": "テスト受注2（自動採番）",
    "items": [
      {
        "item_name": "テスト商品B",
        "description": "自動採番テスト2",
        "quantity": 1,
        "unit_price": 2000
      }
    ]
  }')

RECEIPT_NUMBER2=$(echo "$RESPONSE2" | jq -r '.data.receipt_number')
echo "✅ 自動生成された受注番号: $RECEIPT_NUMBER2"

echo ""
echo "=== テスト完了 ==="
echo "採番形式: OR-YYYYMMDD-XXXX"
echo "1件目: $RECEIPT_NUMBER"
echo "2件目: $RECEIPT_NUMBER2"
