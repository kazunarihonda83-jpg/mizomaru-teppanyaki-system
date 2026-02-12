#!/bin/bash
API="https://menya-nishiki-system-cloud.onrender.com/api"

# ログイン
echo "=== ログインテスト ==="
TOKEN=$(curl -s -X POST "$API/auth/login" -H "Content-Type: application/json" -d '{"username":"麺家弍色","password":"admin123"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")
echo "Token取得: ${TOKEN:0:20}..."
echo ""

# 各APIをテスト
echo "=== 各APIテスト ==="
for endpoint in "customers" "suppliers" "documents" "inventory" "order-receipts" "purchases/orders"; do
  echo -n "$endpoint: "
  RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "$API/$endpoint")
  if echo "$RESPONSE" | grep -q "error"; then
    echo "❌ エラー: $(echo $RESPONSE | python3 -c 'import sys,json; print(json.load(sys.stdin).get("error", "不明"))' 2>/dev/null || echo $RESPONSE)"
  else
    echo "✅ OK"
  fi
done
