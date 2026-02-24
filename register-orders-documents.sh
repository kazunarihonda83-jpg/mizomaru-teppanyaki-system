#!/bin/bash

API_URL="https://mizomaru-backend.onrender.com/api"
TOKEN_FILE="/tmp/mizomaru_token_new.txt"
TOKEN=$(cat $TOKEN_FILE)

PURCHASE_SUCCESS=0
PURCHASE_FAIL=0
DOCUMENT_SUCCESS=0
DOCUMENT_FAIL=0

echo "=== 発注データ登録開始（20件） ==="

# 在庫商品IDリストを取得
INVENTORY=$(curl -s "$API_URL/inventory" -H "Authorization: Bearer $TOKEN")
INVENTORY_IDS=($(echo $INVENTORY | jq -r '.[].id'))
INVENTORY_NAMES=($(echo $INVENTORY | jq -r '.[].item_name' | head -20))

if [ ${#INVENTORY_IDS[@]} -eq 0 ]; then
  echo "✗ 在庫データが見つかりません。"
  exit 1
fi

for i in {1..20}; do
  # ランダムな仕入先（1-4）
  SUPPLIER_ID=$((1 + RANDOM % 4))
  
  # ランダムな日付（過去2ヶ月）
  DAYS_AGO=$((RANDOM % 60))
  ORDER_DATE=$(date -d "$DAYS_AGO days ago" +%Y-%m-%d)
  
  # ランダムに2-5個の商品を選択
  NUM_ITEMS=$((2 + RANDOM % 4))
  
  # items配列を作成
  ITEMS_JSON="["
  for j in $(seq 1 $NUM_ITEMS); do
    RANDOM_IDX=$((RANDOM % ${#INVENTORY_NAMES[@]}))
    PRODUCT_NAME="${INVENTORY_NAMES[$RANDOM_IDX]}"
    QUANTITY=$((1 + RANDOM % 10))
    UNIT_PRICE=$((1000 + RANDOM % 9000))
    
    if [ $j -gt 1 ]; then
      ITEMS_JSON+=","
    fi
    ITEMS_JSON+="{\"product_name\":\"$PRODUCT_NAME\",\"quantity\":$QUANTITY,\"unit_price\":$UNIT_PRICE}"
  done
  ITEMS_JSON+="]"
  
  # ステータス
  STATUS_ARRAY=("delivered" "pending" "cancelled")
  STATUS="${STATUS_ARRAY[$((RANDOM % 3))]}"
  
  PAYMENT_STATUS_ARRAY=("paid" "unpaid")
  PAYMENT_STATUS="${PAYMENT_STATUS_ARRAY[$((RANDOM % 2))]}"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/purchases/orders" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"supplier_id\": $SUPPLIER_ID,
      \"order_date\": \"$ORDER_DATE\",
      \"items\": $ITEMS_JSON,
      \"status\": \"$STATUS\",
      \"payment_status\": \"$PAYMENT_STATUS\",
      \"notes\": \"テスト発注データ No.$i\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((PURCHASE_SUCCESS++))
    echo "✓ 発注登録 No.$i ($STATUS)"
  else
    ((PURCHASE_FAIL++))
    echo "✗ 発注登録失敗 No.$i (HTTP: $HTTP_CODE)"
  fi
done

echo ""
echo "発注登録完了: 成功 $PURCHASE_SUCCESS 件 / 失敗 $PURCHASE_FAIL 件"
echo ""

# 書類データ登録
echo "=== 書類データ登録開始（20件） ==="

# 顧客IDリストを取得
CUSTOMERS=$(curl -s "$API_URL/customers" -H "Authorization: Bearer $TOKEN")
CUSTOMER_IDS=($(echo $CUSTOMERS | jq -r '.[].id'))

if [ ${#CUSTOMER_IDS[@]} -eq 0 ]; then
  echo "✗ 顧客データが見つかりません。"
  exit 1
fi

# 見積書（5件）
for i in {1..5}; do
  CUSTOMER_ID="${CUSTOMER_IDS[$((RANDOM % ${#CUSTOMER_IDS[@]}))]}"
  DAYS_AGO=$((RANDOM % 30))
  ISSUE_DATE=$(date -d "$DAYS_AGO days ago" +%Y-%m-%d)
  
  # ランダムに2-4個の商品
  NUM_ITEMS=$((2 + RANDOM % 3))
  ITEMS_JSON="["
  SUBTOTAL=0
  
  for j in $(seq 1 $NUM_ITEMS); do
    RANDOM_IDX=$((RANDOM % ${#INVENTORY_NAMES[@]}))
    ITEM_NAME="${INVENTORY_NAMES[$RANDOM_IDX]}"
    QUANTITY=$((1 + RANDOM % 5))
    UNIT_PRICE=$((2000 + RANDOM % 8000))
    AMOUNT=$((QUANTITY * UNIT_PRICE))
    SUBTOTAL=$((SUBTOTAL + AMOUNT))
    
    if [ $j -gt 1 ]; then
      ITEMS_JSON+=","
    fi
    ITEMS_JSON+="{\"product_name\":\"$ITEM_NAME\",\"quantity\":$QUANTITY,\"unit_price\":$UNIT_PRICE,\"amount\":$AMOUNT}"
  done
  ITEMS_JSON+="]"
  
  TAX_AMOUNT=$((SUBTOTAL * 10 / 100))
  TOTAL_AMOUNT=$((SUBTOTAL + TAX_AMOUNT))
  DOC_NUMBER="Q$(date +%y%m)$(printf "%04d" $i)"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/documents" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"document_number\": \"$DOC_NUMBER\",
      \"document_type\": \"quote\",
      \"customer_id\": $CUSTOMER_ID,
      \"issue_date\": \"$ISSUE_DATE\",
      \"tax_type\": \"exclusive\",
      \"tax_rate\": 10,
      \"subtotal\": $SUBTOTAL,
      \"tax_amount\": $TAX_AMOUNT,
      \"total_amount\": $TOTAL_AMOUNT,
      \"items\": $ITEMS_JSON,
      \"status\": \"issued\",
      \"notes\": \"テスト見積書 No.$i\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((DOCUMENT_SUCCESS++))
    echo "✓ 見積書登録 No.$i: ¥$TOTAL_AMOUNT"
  else
    ((DOCUMENT_FAIL++))
    echo "✗ 見積書登録失敗 No.$i (HTTP: $HTTP_CODE)"
  fi
done

# 発注書（5件）
for i in {1..5}; do
  CUSTOMER_ID="${CUSTOMER_IDS[$((RANDOM % ${#CUSTOMER_IDS[@]}))]}"
  DAYS_AGO=$((RANDOM % 25))
  ISSUE_DATE=$(date -d "$DAYS_AGO days ago" +%Y-%m-%d)
  
  NUM_ITEMS=$((2 + RANDOM % 3))
  ITEMS_JSON="["
  SUBTOTAL=0
  
  for j in $(seq 1 $NUM_ITEMS); do
    RANDOM_IDX=$((RANDOM % ${#INVENTORY_NAMES[@]}))
    ITEM_NAME="${INVENTORY_NAMES[$RANDOM_IDX]}"
    QUANTITY=$((2 + RANDOM % 8))
    UNIT_PRICE=$((1500 + RANDOM % 6500))
    AMOUNT=$((QUANTITY * UNIT_PRICE))
    SUBTOTAL=$((SUBTOTAL + AMOUNT))
    
    if [ $j -gt 1 ]; then
      ITEMS_JSON+=","
    fi
    ITEMS_JSON+="{\"product_name\":\"$ITEM_NAME\",\"quantity\":$QUANTITY,\"unit_price\":$UNIT_PRICE,\"amount\":$AMOUNT}"
  done
  ITEMS_JSON+="]"
  
  TAX_AMOUNT=$((SUBTOTAL * 10 / 100))
  TOTAL_AMOUNT=$((SUBTOTAL + TAX_AMOUNT))
  DOC_NUMBER="O$(date +%y%m)$(printf "%04d" $i)"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/documents" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"document_number\": \"$DOC_NUMBER\",
      \"document_type\": \"order\",
      \"customer_id\": $CUSTOMER_ID,
      \"issue_date\": \"$ISSUE_DATE\",
      \"tax_type\": \"exclusive\",
      \"tax_rate\": 10,
      \"subtotal\": $SUBTOTAL,
      \"tax_amount\": $TAX_AMOUNT,
      \"total_amount\": $TOTAL_AMOUNT,
      \"items\": $ITEMS_JSON,
      \"status\": \"issued\",
      \"notes\": \"テスト発注書 No.$i\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((DOCUMENT_SUCCESS++))
    echo "✓ 発注書登録 No.$i: ¥$TOTAL_AMOUNT"
  else
    ((DOCUMENT_FAIL++))
    echo "✗ 発注書登録失敗 No.$i (HTTP: $HTTP_CODE)"
  fi
done

# 納品書（5件）
for i in {1..5}; do
  CUSTOMER_ID="${CUSTOMER_IDS[$((RANDOM % ${#CUSTOMER_IDS[@]}))]}"
  DAYS_AGO=$((RANDOM % 20))
  ISSUE_DATE=$(date -d "$DAYS_AGO days ago" +%Y-%m-%d)
  
  NUM_ITEMS=$((2 + RANDOM % 3))
  ITEMS_JSON="["
  SUBTOTAL=0
  
  for j in $(seq 1 $NUM_ITEMS); do
    RANDOM_IDX=$((RANDOM % ${#INVENTORY_NAMES[@]}))
    ITEM_NAME="${INVENTORY_NAMES[$RANDOM_IDX]}"
    QUANTITY=$((1 + RANDOM % 6))
    UNIT_PRICE=$((2500 + RANDOM % 7500))
    AMOUNT=$((QUANTITY * UNIT_PRICE))
    SUBTOTAL=$((SUBTOTAL + AMOUNT))
    
    if [ $j -gt 1 ]; then
      ITEMS_JSON+=","
    fi
    ITEMS_JSON+="{\"product_name\":\"$ITEM_NAME\",\"quantity\":$QUANTITY,\"unit_price\":$UNIT_PRICE,\"amount\":$AMOUNT}"
  done
  ITEMS_JSON+="]"
  
  TAX_AMOUNT=$((SUBTOTAL * 10 / 100))
  TOTAL_AMOUNT=$((SUBTOTAL + TAX_AMOUNT))
  DOC_NUMBER="D$(date +%y%m)$(printf "%04d" $i)"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/documents" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"document_number\": \"$DOC_NUMBER\",
      \"document_type\": \"delivery\",
      \"customer_id\": $CUSTOMER_ID,
      \"issue_date\": \"$ISSUE_DATE\",
      \"tax_type\": \"exclusive\",
      \"tax_rate\": 10,
      \"subtotal\": $SUBTOTAL,
      \"tax_amount\": $TAX_AMOUNT,
      \"total_amount\": $TOTAL_AMOUNT,
      \"items\": $ITEMS_JSON,
      \"status\": \"delivered\",
      \"notes\": \"テスト納品書 No.$i\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((DOCUMENT_SUCCESS++))
    echo "✓ 納品書登録 No.$i: ¥$TOTAL_AMOUNT"
  else
    ((DOCUMENT_FAIL++))
    echo "✗ 納品書登録失敗 No.$i (HTTP: $HTTP_CODE)"
  fi
done

# 請求書（5件）
for i in {1..5}; do
  CUSTOMER_ID="${CUSTOMER_IDS[$((RANDOM % ${#CUSTOMER_IDS[@]}))]}"
  DAYS_AGO=$((RANDOM % 15))
  ISSUE_DATE=$(date -d "$DAYS_AGO days ago" +%Y-%m-%d)
  DUE_DATE=$(date -d "$((DAYS_AGO - 30)) days ago" +%Y-%m-%d)
  
  NUM_ITEMS=$((2 + RANDOM % 4))
  ITEMS_JSON="["
  SUBTOTAL=0
  
  for j in $(seq 1 $NUM_ITEMS); do
    RANDOM_IDX=$((RANDOM % ${#INVENTORY_NAMES[@]}))
    ITEM_NAME="${INVENTORY_NAMES[$RANDOM_IDX]}"
    QUANTITY=$((1 + RANDOM % 7))
    UNIT_PRICE=$((3000 + RANDOM % 9000))
    AMOUNT=$((QUANTITY * UNIT_PRICE))
    SUBTOTAL=$((SUBTOTAL + AMOUNT))
    
    if [ $j -gt 1 ]; then
      ITEMS_JSON+=","
    fi
    ITEMS_JSON+="{\"product_name\":\"$ITEM_NAME\",\"quantity\":$QUANTITY,\"unit_price\":$UNIT_PRICE,\"amount\":$AMOUNT}"
  done
  ITEMS_JSON+="]"
  
  TAX_AMOUNT=$((SUBTOTAL * 10 / 100))
  TOTAL_AMOUNT=$((SUBTOTAL + TAX_AMOUNT))
  DOC_NUMBER="I$(date +%y%m)$(printf "%04d" $i)"
  
  PAYMENT_STATUS_ARRAY=("paid" "unpaid" "overdue")
  PAYMENT_STATUS="${PAYMENT_STATUS_ARRAY[$((RANDOM % 3))]}"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/documents" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"document_number\": \"$DOC_NUMBER\",
      \"document_type\": \"invoice\",
      \"customer_id\": $CUSTOMER_ID,
      \"issue_date\": \"$ISSUE_DATE\",
      \"due_date\": \"$DUE_DATE\",
      \"tax_type\": \"exclusive\",
      \"tax_rate\": 10,
      \"subtotal\": $SUBTOTAL,
      \"tax_amount\": $TAX_AMOUNT,
      \"total_amount\": $TOTAL_AMOUNT,
      \"items\": $ITEMS_JSON,
      \"status\": \"$PAYMENT_STATUS\",
      \"notes\": \"テスト請求書 No.$i\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((DOCUMENT_SUCCESS++))
    echo "✓ 請求書登録 No.$i: ¥$TOTAL_AMOUNT ($PAYMENT_STATUS)"
  else
    ((DOCUMENT_FAIL++))
    echo "✗ 請求書登録失敗 No.$i (HTTP: $HTTP_CODE)"
  fi
done

echo ""
echo "書類登録完了: 成功 $DOCUMENT_SUCCESS 件 / 失敗 $DOCUMENT_FAIL 件"
echo ""

echo "======================================"
echo "  発注・書類データ登録完了"
echo "======================================"
echo ""
echo "発注データ:   成功 $PURCHASE_SUCCESS 件 / 失敗 $PURCHASE_FAIL 件"
echo "書類データ:   成功 $DOCUMENT_SUCCESS 件 / 失敗 $DOCUMENT_FAIL 件"
echo ""
echo "合計登録数:   $((PURCHASE_SUCCESS + DOCUMENT_SUCCESS)) 件"
echo ""

