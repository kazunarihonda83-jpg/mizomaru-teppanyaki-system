#!/bin/bash

API_URL="https://mizomaru-backend.onrender.com/api"
TOKEN_FILE="/tmp/mizomaru_token_new.txt"

# トークン取得
echo "=== トークン取得中 ==="
LOGIN_RESPONSE=$(curl -s "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"鉄板焼き居酒屋みぞまる","password":"admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')
echo $TOKEN > $TOKEN_FILE
echo "✓ トークン取得完了"
echo ""

# カウンター初期化
CUSTOMER_SUCCESS=0
CUSTOMER_FAIL=0
INVENTORY_SUCCESS=0
INVENTORY_FAIL=0
PURCHASE_SUCCESS=0
PURCHASE_FAIL=0
DOCUMENT_SUCCESS=0
DOCUMENT_FAIL=0

# 1. 顧客データ登録（50件）
echo "=== 顧客データ登録開始（50件） ==="

# 個人事業主（45件）
declare -a CUSTOMER_NAMES=(
  "田中太郎" "佐藤花子" "鈴木一郎" "高橋美咲" "伊藤健太"
  "渡辺由美" "山本大輔" "中村麻衣" "小林翔太" "加藤愛子"
  "吉田直樹" "山田優子" "佐々木拓也" "松本さくら" "井上陽介"
  "木村結衣" "林勇気" "清水真由美" "山崎健" "森美咲"
  "池田大地" "橋本彩" "石川智也" "前田夏希" "藤田康平"
  "岡田詩織" "長谷川涼" "村上咲希" "近藤達也" "斎藤美穂"
  "遠藤悠太" "坂本陽菜" "青木健吾" "西村優花" "藤原隆史"
  "太田真理" "金子賢一" "増田愛美" "平野大輔" "島田桜子"
  "原田純一" "三浦美咲" "谷口拓海" "千葉結衣" "久保健太"
)

for i in "${!CUSTOMER_NAMES[@]}"; do
  NAME="${CUSTOMER_NAMES[$i]}"
  EMAIL=$(echo "$NAME" | sed 's/[^ ]*$//')$(printf "%02d" $((i+1)))"@example.com"
  PHONE="090-$(printf "%04d" $((1000+i)))-$(printf "%04d" $((i*13 % 10000)))"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/customers" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"customer_type\": \"個人事業主\",
      \"name\": \"$NAME\",
      \"email\": \"$EMAIL\",
      \"phone\": \"$PHONE\",
      \"address\": \"神奈川県相模原市中央区\",
      \"notes\": \"テスト顧客データ\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((CUSTOMER_SUCCESS++))
    echo "✓ 顧客登録: $NAME"
  else
    ((CUSTOMER_FAIL++))
    echo "✗ 顧客登録失敗: $NAME (HTTP: $HTTP_CODE)"
  fi
done

# 法人顧客（5件）
declare -a COMPANY_NAMES=(
  "相模原商事株式会社"
  "みなと食品卸売株式会社"
  "横浜貿易株式会社"
  "東京フードサービス株式会社"
  "神奈川レストラン協会"
)

for i in "${!COMPANY_NAMES[@]}"; do
  NAME="${COMPANY_NAMES[$i]}"
  EMAIL="contact@company$(printf "%02d" $((i+1))).co.jp"
  PHONE="042-$(printf "%03d" $((700+i)))-$(printf "%04d" $((i*17 % 10000)))"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/customers" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"customer_type\": \"法人\",
      \"name\": \"$NAME\",
      \"email\": \"$EMAIL\",
      \"phone\": \"$PHONE\",
      \"address\": \"神奈川県相模原市\",
      \"notes\": \"法人顧客・定期取引先\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((CUSTOMER_SUCCESS++))
    echo "✓ 法人顧客登録: $NAME"
  else
    ((CUSTOMER_FAIL++))
    echo "✗ 法人顧客登録失敗: $NAME (HTTP: $HTTP_CODE)"
  fi
done

echo ""
echo "顧客登録完了: 成功 $CUSTOMER_SUCCESS 件 / 失敗 $CUSTOMER_FAIL 件"
echo ""

# 2. 在庫データ登録（100件）
echo "=== 在庫データ登録開始（100件） ==="

# 肉類（30件）
declare -a MEAT_ITEMS=(
  "黒毛和牛A5サーロイン" "黒毛和牛A5リブロース" "黒毛和牛A4ヒレ" "黒毛和牛A4ロース"
  "神戸ビーフサーロイン" "松阪牛リブロース" "近江牛ロース" "飛騨牛カルビ"
  "国産牛バラ" "国産牛モモ" "国産牛肩ロース" "国産牛タン"
  "輸入牛サーロイン" "輸入牛リブアイ" "輸入牛ヒレ"
  "豚バラ" "豚ロース" "豚肩ロース" "豚トロ" "豚タン"
  "鶏もも肉" "鶏むね肉" "鶏手羽先" "鶏レバー"
  "ラム肉" "ラムチョップ" "ベーコン" "ソーセージ" "ハム" "鴨肉"
)

for i in "${!MEAT_ITEMS[@]}"; do
  ITEM="${MEAT_ITEMS[$i]}"
  COST=$((3000 + RANDOM % 10000))
  STOCK=$((5 + RANDOM % 30))
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/inventory" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"item_name\": \"$ITEM\",
      \"category\": \"肉類\",
      \"supplier_id\": 1,
      \"unit\": \"kg\",
      \"current_stock\": $STOCK,
      \"reorder_point\": 5,
      \"optimal_stock\": 20,
      \"unit_cost\": $COST,
      \"storage_location\": \"冷蔵庫A\",
      \"notes\": \"テスト在庫データ\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((INVENTORY_SUCCESS++))
    echo "✓ 在庫登録: $ITEM"
  else
    ((INVENTORY_FAIL++))
  fi
done

# 魚介類（20件）
declare -a SEAFOOD_ITEMS=(
  "真イカ" "ヤリイカ" "ホタルイカ" "スルメイカ"
  "大エビ" "車エビ" "甘エビ" "ブラックタイガー"
  "ホタテ" "大アサリ" "ハマグリ" "あさり"
  "タコ" "真ダコ" "サーモン" "真鯛" "ブリ" "カツオ" "マグロ" "イワシ"
)

for i in "${!SEAFOOD_ITEMS[@]}"; do
  ITEM="${SEAFOOD_ITEMS[$i]}"
  COST=$((800 + RANDOM % 4000))
  STOCK=$((3 + RANDOM % 20))
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/inventory" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"item_name\": \"$ITEM\",
      \"category\": \"魚介類\",
      \"supplier_id\": 2,
      \"unit\": \"kg\",
      \"current_stock\": $STOCK,
      \"reorder_point\": 3,
      \"optimal_stock\": 15,
      \"unit_cost\": $COST,
      \"storage_location\": \"冷蔵庫B\",
      \"notes\": \"鮮魚・鮮度管理重要\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((INVENTORY_SUCCESS++))
    echo "✓ 在庫登録: $ITEM"
  else
    ((INVENTORY_FAIL++))
  fi
done

# 野菜類（20件）
declare -a VEGETABLE_ITEMS=(
  "キャベツ" "もやし" "玉ねぎ" "ピーマン" "にんにく"
  "長ねぎ" "紅生姜" "しいたけ" "えのき" "しめじ"
  "トマト" "レタス" "きゅうり" "なす" "アスパラガス"
  "ブロッコリー" "かぼちゃ" "じゃがいも" "にんじん" "大根"
)

for i in "${!VEGETABLE_ITEMS[@]}"; do
  ITEM="${VEGETABLE_ITEMS[$i]}"
  COST=$((100 + RANDOM % 800))
  STOCK=$((10 + RANDOM % 40))
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/inventory" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"item_name\": \"$ITEM\",
      \"category\": \"野菜\",
      \"supplier_id\": 3,
      \"unit\": \"kg\",
      \"current_stock\": $STOCK,
      \"reorder_point\": 5,
      \"optimal_stock\": 30,
      \"unit_cost\": $COST,
      \"storage_location\": \"野菜庫\",
      \"notes\": \"鮮度管理\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((INVENTORY_SUCCESS++))
    echo "✓ 在庫登録: $ITEM"
  else
    ((INVENTORY_FAIL++))
  fi
done

# 粉物・麺類（10件）
declare -a FLOUR_ITEMS=(
  "お好み焼き粉" "たこ焼き粉" "天ぷら粉" "小麦粉"
  "焼きそば麺" "うどん" "そば" "中華麺" "パスタ" "春巻きの皮"
)

for i in "${!FLOUR_ITEMS[@]}"; do
  ITEM="${FLOUR_ITEMS[$i]}"
  COST=$((200 + RANDOM % 800))
  STOCK=$((20 + RANDOM % 50))
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/inventory" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"item_name\": \"$ITEM\",
      \"category\": \"粉物・麺類\",
      \"supplier_id\": 4,
      \"unit\": \"kg\",
      \"current_stock\": $STOCK,
      \"reorder_point\": 10,
      \"optimal_stock\": 40,
      \"unit_cost\": $COST,
      \"storage_location\": \"乾物庫\",
      \"notes\": \"常温保存可\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((INVENTORY_SUCCESS++))
    echo "✓ 在庫登録: $ITEM"
  else
    ((INVENTORY_FAIL++))
  fi
done

# 調味料・ソース（15件）
declare -a SEASONING_ITEMS=(
  "お好み焼きソース" "たこ焼きソース" "焼肉のタレ" "焼きそばソース"
  "マヨネーズ" "醤油" "みりん" "料理酒" "塩" "胡椒"
  "七味唐辛子" "青のり" "かつお節" "紅生姜" "ごま油"
)

for i in "${!SEASONING_ITEMS[@]}"; do
  ITEM="${SEASONING_ITEMS[$i]}"
  COST=$((300 + RANDOM % 1500))
  STOCK=$((5 + RANDOM % 20))
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/inventory" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"item_name\": \"$ITEM\",
      \"category\": \"調味料\",
      \"supplier_id\": 4,
      \"unit\": \"L\",
      \"current_stock\": $STOCK,
      \"reorder_point\": 3,
      \"optimal_stock\": 15,
      \"unit_cost\": $COST,
      \"storage_location\": \"調味料棚\",
      \"notes\": \"定番調味料\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((INVENTORY_SUCCESS++))
    echo "✓ 在庫登録: $ITEM"
  else
    ((INVENTORY_FAIL++))
  fi
done

# 飲料（5件）
declare -a DRINK_ITEMS=(
  "生ビール" "瓶ビール" "チューハイ" "焼酎" "日本酒"
)

for i in "${!DRINK_ITEMS[@]}"; do
  ITEM="${DRINK_ITEMS[$i]}"
  COST=$((500 + RANDOM % 2000))
  STOCK=$((10 + RANDOM % 50))
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/inventory" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"item_name\": \"$ITEM\",
      \"category\": \"飲料\",
      \"supplier_id\": 4,
      \"unit\": \"L\",
      \"current_stock\": $STOCK,
      \"reorder_point\": 10,
      \"optimal_stock\": 40,
      \"unit_cost\": $COST,
      \"storage_location\": \"冷蔵庫C\",
      \"notes\": \"アルコール飲料\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((INVENTORY_SUCCESS++))
    echo "✓ 在庫登録: $ITEM"
  else
    ((INVENTORY_FAIL++))
  fi
done

echo ""
echo "在庫登録完了: 成功 $INVENTORY_SUCCESS 件 / 失敗 $INVENTORY_FAIL 件"
echo ""

# 3. 発注データ登録（20件）
echo "=== 発注データ登録開始（20件） ==="

for i in {1..20}; do
  # ランダムな仕入先（1-4）
  SUPPLIER_ID=$((1 + RANDOM % 4))
  
  # ランダムな日付（過去2ヶ月）
  DAYS_AGO=$((RANDOM % 60))
  ORDER_DATE=$(date -d "$DAYS_AGO days ago" +%Y-%m-%d)
  
  # ランダムな金額
  TOTAL_AMOUNT=$((10000 + RANDOM % 100000))
  
  # ステータス（完了、処理中、未払い）
  STATUS_ARRAY=("完了" "処理中" "未払い")
  STATUS="${STATUS_ARRAY[$((RANDOM % 3))]}"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/purchases/orders" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      \"supplier_id\": $SUPPLIER_ID,
      \"order_date\": \"$ORDER_DATE\",
      \"delivery_date\": \"$ORDER_DATE\",
      \"total_amount\": $TOTAL_AMOUNT,
      \"status\": \"$STATUS\",
      \"notes\": \"テスト発注データ No.$i\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    ((PURCHASE_SUCCESS++))
    echo "✓ 発注登録 No.$i: ¥$TOTAL_AMOUNT ($STATUS)"
  else
    ((PURCHASE_FAIL++))
    echo "✗ 発注登録失敗 No.$i (HTTP: $HTTP_CODE)"
  fi
done

echo ""
echo "発注登録完了: 成功 $PURCHASE_SUCCESS 件 / 失敗 $PURCHASE_FAIL 件"
echo ""

# 4. 書類データ登録（20件）
echo "=== 書類データ登録開始（20件） ==="

# 顧客IDリストを取得
CUSTOMERS=$(curl -s "$API_URL/customers" -H "Authorization: Bearer $TOKEN")
CUSTOMER_IDS=($(echo $CUSTOMERS | jq -r '.[].id'))

if [ ${#CUSTOMER_IDS[@]} -eq 0 ]; then
  echo "✗ 顧客データが見つかりません。書類登録をスキップします。"
else
  # 見積書（5件）
  for i in {1..5}; do
    CUSTOMER_ID="${CUSTOMER_IDS[$((RANDOM % ${#CUSTOMER_IDS[@]}))]}"
    DAYS_AGO=$((RANDOM % 30))
    ISSUE_DATE=$(date -d "$DAYS_AGO days ago" +%Y-%m-%d)
    TOTAL_AMOUNT=$((50000 + RANDOM % 150000))
    
    RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/documents" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"document_type\": \"見積書\",
        \"customer_id\": $CUSTOMER_ID,
        \"issue_date\": \"$ISSUE_DATE\",
        \"total_amount\": $TOTAL_AMOUNT,
        \"status\": \"発行済み\",
        \"notes\": \"テスト見積書 No.$i\"
      }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
      ((DOCUMENT_SUCCESS++))
      echo "✓ 見積書登録 No.$i: ¥$TOTAL_AMOUNT"
    else
      ((DOCUMENT_FAIL++))
    fi
  done
  
  # 発注書（5件）
  for i in {1..5}; do
    SUPPLIER_ID=$((1 + RANDOM % 4))
    DAYS_AGO=$((RANDOM % 30))
    ISSUE_DATE=$(date -d "$DAYS_AGO days ago" +%Y-%m-%d)
    TOTAL_AMOUNT=$((30000 + RANDOM % 120000))
    
    RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/documents" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"document_type\": \"発注書\",
        \"customer_id\": $SUPPLIER_ID,
        \"issue_date\": \"$ISSUE_DATE\",
        \"total_amount\": $TOTAL_AMOUNT,
        \"status\": \"発行済み\",
        \"notes\": \"テスト発注書 No.$i\"
      }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
      ((DOCUMENT_SUCCESS++))
      echo "✓ 発注書登録 No.$i: ¥$TOTAL_AMOUNT"
    else
      ((DOCUMENT_FAIL++))
    fi
  done
  
  # 納品書（5件）
  for i in {1..5}; do
    CUSTOMER_ID="${CUSTOMER_IDS[$((RANDOM % ${#CUSTOMER_IDS[@]}))]}"
    DAYS_AGO=$((RANDOM % 20))
    ISSUE_DATE=$(date -d "$DAYS_AGO days ago" +%Y-%m-%d)
    TOTAL_AMOUNT=$((60000 + RANDOM % 140000))
    
    RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/documents" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"document_type\": \"納品書\",
        \"customer_id\": $CUSTOMER_ID,
        \"issue_date\": \"$ISSUE_DATE\",
        \"total_amount\": $TOTAL_AMOUNT,
        \"status\": \"配送済み\",
        \"notes\": \"テスト納品書 No.$i\"
      }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
      ((DOCUMENT_SUCCESS++))
      echo "✓ 納品書登録 No.$i: ¥$TOTAL_AMOUNT"
    else
      ((DOCUMENT_FAIL++))
    fi
  done
  
  # 請求書（5件）
  for i in {1..5}; do
    CUSTOMER_ID="${CUSTOMER_IDS[$((RANDOM % ${#CUSTOMER_IDS[@]}))]}"
    DAYS_AGO=$((RANDOM % 15))
    ISSUE_DATE=$(date -d "$DAYS_AGO days ago" +%Y-%m-%d)
    TOTAL_AMOUNT=$((70000 + RANDOM % 180000))
    
    RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/documents" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"document_type\": \"請求書\",
        \"customer_id\": $CUSTOMER_ID,
        \"issue_date\": \"$ISSUE_DATE\",
        \"total_amount\": $TOTAL_AMOUNT,
        \"status\": \"請求済み\",
        \"notes\": \"テスト請求書 No.$i\"
      }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
      ((DOCUMENT_SUCCESS++))
      echo "✓ 請求書登録 No.$i: ¥$TOTAL_AMOUNT"
    else
      ((DOCUMENT_FAIL++))
    fi
  done
fi

echo ""
echo "書類登録完了: 成功 $DOCUMENT_SUCCESS 件 / 失敗 $DOCUMENT_FAIL 件"
echo ""

# 5. 最終結果サマリー
echo "======================================"
echo "  テストデータ登録完了サマリー"
echo "======================================"
echo ""
echo "顧客データ:   成功 $CUSTOMER_SUCCESS 件 / 失敗 $CUSTOMER_FAIL 件"
echo "在庫データ:   成功 $INVENTORY_SUCCESS 件 / 失敗 $INVENTORY_FAIL 件"
echo "発注データ:   成功 $PURCHASE_SUCCESS 件 / 失敗 $PURCHASE_FAIL 件"
echo "書類データ:   成功 $DOCUMENT_SUCCESS 件 / 失敗 $DOCUMENT_FAIL 件"
echo ""
echo "合計登録数:   $((CUSTOMER_SUCCESS + INVENTORY_SUCCESS + PURCHASE_SUCCESS + DOCUMENT_SUCCESS)) 件"
echo ""
echo "======================================"
echo "  システムアクセス情報"
echo "======================================"
echo ""
echo "URL: https://mizomaru-teppanyaki-system.vercel.app"
echo "ユーザー名: 鉄板焼き居酒屋みぞまる"
echo "パスワード: admin123"
echo ""

