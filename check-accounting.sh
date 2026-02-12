#!/bin/bash
API_URL="https://5003-iwz00ie3gdkhvxpx2ni1z-5c13a017.sandbox.novita.ai/api"

TOKEN=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"麺家弍色","password":"admin123"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "=== 仕訳帳 ==="
curl -s -X GET "$API_URL/accounting/journal" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.entries | length'

echo ""
echo "=== 現金出納帳 ==="
curl -s -X GET "$API_URL/accounting-ledgers/cash-book?start_date=2026-02-01&end_date=2026-02-28" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.data | length'

echo ""
echo "=== 損益計算書 ==="
curl -s -X GET "$API_URL/accounting/profit-loss" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '{revenue, expenses}'
