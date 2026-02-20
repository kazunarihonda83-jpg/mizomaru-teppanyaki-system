#!/bin/bash

# 鉄板焼き居酒屋みぞまる 大量テストデータ登録スクリプト
# 2026-02-20

API_URL="https://mizomaru-backend.onrender.com/api"
TOKEN=$(cat /tmp/mizomaru_token.txt)

echo "=========================================="
echo "鉄板焼き居酒屋みぞまる テストデータ登録"
echo "=========================================="
echo ""

# カウンター
SUCCESS_CUSTOMERS=0
SUCCESS_INVENTORY=0
SUCCESS_ORDERS=0
SUCCESS_DOCUMENTS=0
FAIL_CUSTOMERS=0
FAIL_INVENTORY=0
FAIL_ORDERS=0
FAIL_DOCUMENTS=0

# 1. 顧客登録（50件）
echo "📋 顧客データ登録中..."

# 個人客（45件）
INDIVIDUAL_CUSTOMERS=(
  "田中 太郎:tanaka@example.com:090-1111-1111:神奈川県相模原市中央区:個人事業主:常連客"
  "佐藤 花子:sato@example.com:090-2222-2222:神奈川県相模原市南区:個人事業主:リピーター"
  "鈴木 一郎:suzuki@example.com:090-3333-3333:神奈川県相模原市緑区:個人事業主:近隣住民"
  "高橋 美咲:takahashi@example.com:090-4444-4444:東京都町田市:個人事業主:常連客"
  "伊藤 健:ito@example.com:090-5555-5555:神奈川県相模原市中央区:個人事業主:週末利用"
  "渡辺 真由美:watanabe@example.com:090-6666-6666:神奈川県相模原市南区:個人事業主:家族連れ"
  "山本 大輔:yamamoto@example.com:090-7777-7777:神奈川県座間市:個人事業主:月1回来店"
  "中村 さくら:nakamura@example.com:090-8888-8888:神奈川県相模原市中央区:個人事業主:常連客"
  "小林 正:kobayashi@example.com:090-9999-9999:神奈川県相模原市緑区:個人事業主:接待利用"
  "加藤 愛:kato@example.com:090-1234-5678:東京都八王子市:個人事業主:デート利用"
  "吉田 浩二:yoshida@example.com:090-2345-6789:神奈川県相模原市中央区:個人事業主:一人飲み"
  "山田 京子:yamada@example.com:090-3456-7890:神奈川県相模原市南区:個人事業主:女子会"
  "佐々木 孝:sasaki@example.com:090-4567-8901:神奈川県相模原市中央区:個人事業主:常連客"
  "松本 麗子:matsumoto@example.com:090-5678-9012:神奈川県厚木市:個人事業主:月2回来店"
  "井上 翔太:inoue@example.com:090-6789-0123:神奈川県相模原市緑区:個人事業主:カウンター常連"
  "木村 美穂:kimura@example.com:090-7890-1234:神奈川県相模原市中央区:個人事業主:ランチ利用"
  "林 雄介:hayashi@example.com:090-8901-2345:神奈川県相模原市南区:個人事業主:宴会利用"
  "斎藤 奈々:saito@example.com:090-9012-3456:東京都町田市:個人事業主:記念日利用"
  "清水 誠:shimizu@example.com:090-0123-4567:神奈川県相模原市中央区:個人事業主:常連客"
  "森 優子:mori@example.com:090-1357-2468:神奈川県座間市:個人事業主:家族連れ"
  "池田 健一:ikeda@example.com:090-2468-1357:神奈川県相模原市緑区:個人事業主:週末利用"
  "橋本 恵美:hashimoto@example.com:090-3579-2468:神奈川県相模原市中央区:個人事業主:女子会"
  "山口 隆:yamaguchi@example.com:090-4680-1357:神奈川県相模原市南区:個人事業主:接待利用"
  "石川 舞:ishikawa@example.com:090-5791-2468:東京都八王子市:個人事業主:デート利用"
  "藤田 修:fujita@example.com:090-6802-3579:神奈川県相模原市中央区:個人事業主:一人飲み"
  "坂本 香織:sakamoto@example.com:090-7913-4680:神奈川県厚木市:個人事業主:常連客"
  "西村 直樹:nishimura@example.com:090-8024-5791:神奈川県相模原市緑区:個人事業主:カウンター常連"
  "前田 彩:maeda@example.com:090-9135-6802:神奈川県相模原市中央区:個人事業主:ランチ利用"
  "岡田 勇気:okada@example.com:090-0246-7913:神奈川県相模原市南区:個人事業主:週末利用"
  "長谷川 美里:hasegawa@example.com:090-1478-9024:東京都町田市:個人事業主:家族連れ"
  "村上 光男:murakami@example.com:090-2589-0135:神奈川県相模原市中央区:個人事業主:常連客"
  "近藤 綾:kondo@example.com:090-3690-1246:神奈川県座間市:個人事業主:女子会"
  "遠藤 龍也:endo@example.com:090-4701-2357:神奈川県相模原市緑区:個人事業主:接待利用"
  "青木 千春:aoki@example.com:090-5812-3468:神奈川県相模原市中央区:個人事業主:デート利用"
  "福田 祐介:fukuda@example.com:090-6923-4579:神奈川県相模原市南区:個人事業主:一人飲み"
  "太田 明美:ota@example.com:090-7034-5680:東京都八王子市:個人事業主:常連客"
  "岩崎 拓也:iwasaki@example.com:090-8145-6791:神奈川県相模原市中央区:個人事業主:カウンター常連"
  "上田 真理子:ueda@example.com:090-9256-7802:神奈川県厚木市:個人事業主:ランチ利用"
  "原田 晃:harada@example.com:090-0367-8913:神奈川県相模原市緑区:個人事業主:週末利用"
  "柴田 恵:shibata@example.com:090-1478-9024:神奈川県相模原市中央区:個人事業主:家族連れ"
  "酒井 慎一:sakai@example.com:090-2589-0135:神奈川県相模原市南区:個人事業主:常連客"
  "宮崎 幸子:miyazaki@example.com:090-3690-1246:東京都町田市:個人事業主:女子会"
  "古川 健太郎:furukawa@example.com:090-4701-2357:神奈川県座間市:個人事業主:接待利用"
  "三浦 愛子:miura@example.com:090-5812-3468:神奈川県相模原市中央区:個人事業主:デート利用"
  "藤井 秀樹:fujii@example.com:090-6923-4579:神奈川県相模原市緑区:個人事業主:一人飲み"
)

# 法人客（5件）
CORPORATE_CUSTOMERS=(
  "相模原商事株式会社:sagamihara@corp.com:042-111-1111:神奈川県相模原市中央区:法人:宴会担当"
  "中央技研工業:chuo-giken@corp.com:042-222-2222:神奈川県相模原市南区:法人:接待利用"
  "橋本建設:hashimoto-const@corp.com:042-333-3333:神奈川県相模原市緑区:法人:忘年会"
  "相模原IT株式会社:sagami-it@corp.com:042-444-4444:神奈川県相模原市中央区:法人:歓送迎会"
  "みなみ不動産:minami-estate@corp.com:042-555-5555:神奈川県相模原市南区:法人:定期利用"
)

for customer in "${INDIVIDUAL_CUSTOMERS[@]}"; do
  IFS=':' read -r name email phone address type notes <<< "$customer"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/customers" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"$name\",
      \"email\": \"$email\",
      \"phone\": \"$phone\",
      \"address\": \"$address\",
      \"type\": \"$type\",
      \"notes\": \"$notes\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    ((SUCCESS_CUSTOMERS++))
  else
    ((FAIL_CUSTOMERS++))
  fi
  sleep 0.1
done

for customer in "${CORPORATE_CUSTOMERS[@]}"; do
  IFS=':' read -r name email phone address type notes <<< "$customer"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/customers" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"$name\",
      \"email\": \"$email\",
      \"phone\": \"$phone\",
      \"address\": \"$address\",
      \"type\": \"$type\",
      \"notes\": \"$notes\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    ((SUCCESS_CUSTOMERS++))
  else
    ((FAIL_CUSTOMERS++))
  fi
  sleep 0.1
done

echo "✅ 顧客登録完了: 成功 $SUCCESS_CUSTOMERS 件、失敗 $FAIL_CUSTOMERS 件"
echo ""

# 2. 在庫商品登録（100件）
echo "📦 在庫商品データ登録中..."

# 肉類（30件）
MEAT_ITEMS=(
  "黒毛和牛A5サーロイン:1:kg:12000:10:5:高級肉類卸売:特選黒毛和牛A5ランク"
  "黒毛和牛A5リブロース:1:kg:11500:8:5:高級肉類卸売:霜降りリブロース"
  "黒毛和牛A5ヒレ:1:kg:15000:5:3:高級肉類卸売:最高級部位"
  "黒毛和牛A5カルビ:1:kg:9500:15:8:高級肉類卸売:焼肉用カルビ"
  "黒毛和牛A5ハラミ:1:kg:8500:12:6:高級肉類卸売:柔らかいハラミ"
  "黒毛和牛A4サーロイン:1:kg:9000:12:5:高級肉類卸売:A4ランク"
  "黒毛和牛A4ロース:1:kg:8500:10:5:高級肉類卸売:食べやすいロース"
  "神戸ビーフサーロイン:1:kg:18000:3:2:高級肉類卸売:神戸ビーフブランド"
  "松阪牛リブロース:1:kg:16000:4:2:高級肉類卸売:三重県産松阪牛"
  "国産和牛モモ:1:kg:5500:20:10:国産豚肉・鶏肉専門:赤身肉"
  "国産豚バラ:2:kg:1800:30:15:国産豚肉・鶏肉専門:定番豚バラ"
  "国産豚ロース:2:kg:2200:25:12:国産豚肉・鶏肉専門:厚切りロース"
  "国産豚肩ロース:2:kg:2000:20:10:国産豚肉・鶏肉専門:鉄板焼き用"
  "国産豚トントロ:2:kg:2500:15:8:国産豚肉・鶏肉専門:希少部位"
  "国産豚ホルモンミックス:2:kg:1500:18:10:国産豚肉・鶏肉専門:ホルモン焼き用"
  "鶏もも肉:2:kg:1200:35:20:国産豚肉・鶏肉専門:国産鶏"
  "鶏むね肉:2:kg:800:30:15:国産豚肉・鶏肉専門:ヘルシー"
  "鶏手羽先:2:kg:900:25:12:国産豚肉・鶏肉専門:手羽先唐揚げ用"
  "鶏レバー:2:kg:600:15:8:国産豚肉・鶏肉専門:新鮮レバー"
  "鶏せせり:2:kg:1100:20:10:国産豚肉・鶏肉専門:希少部位"
  "国産牛タン:1:kg:6500:10:5:高級肉類卸売:厚切り牛タン"
  "国産牛ハラミ:1:kg:5800:12:6:高級肉類卸売:柔らかハラミ"
  "国産牛ホルモン:1:kg:3500:15:8:高級肉類卸売:ホルモンミックス"
  "ラム肉ショルダー:1:kg:3200:10:5:高級肉類卸売:ジンギスカン用"
  "ラム肉ロース:1:kg:4500:8:4:高級肉類卸売:高級ラム"
  "粗挽きソーセージ:2:kg:2800:20:10:国産豚肉・鶏肉専門:鉄板焼き用"
  "フランクフルト:2:kg:2400:15:8:国産豚肉・鶏肉専門:ビールに合う"
  "ベーコンスライス:2:kg:3200:18:10:国産豚肉・鶏肉専門:厚切りベーコン"
  "鴨ロース:1:kg:5500:5:3:高級肉類卸売:希少鴨肉"
  "牛サガリ:1:kg:4200:12:6:高級肉類卸売:ハラミに似た部位"
)

for item in "${MEAT_ITEMS[@]}"; do
  IFS=':' read -r name supplier_id unit price quantity threshold supplier notes <<< "$item"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/inventory" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"item_name\": \"$name\",
      \"category\": \"食材\",
      \"supplier_id\": $supplier_id,
      \"unit\": \"$unit\",
      \"unit_cost\": $price,
      \"current_stock\": $quantity,
      \"reorder_point\": $threshold,
      \"optimal_stock\": $((quantity * 2)),
      \"notes\": \"$notes\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    ((SUCCESS_INVENTORY++))
  else
    ((FAIL_INVENTORY++))
  fi
  sleep 0.1
done

# 魚介類（20件）
SEAFOOD_ITEMS=(
  "真イカ:3:kg:2500:15:8:鮮魚仲卸:新鮮イカ"
  "ホタテ貝柱:3:kg:4500:10:5:鮮魚仲卸:北海道産"
  "ブラックタイガーエビ:3:kg:3800:12:6:鮮魚仲卸:大ぶりエビ"
  "バナメイエビ:3:kg:2800:15:8:鮮魚仲卸:中サイズエビ"
  "あさり:3:kg:1800:10:5:鮮魚仲卸:酒蒸し用"
  "はまぐり:3:kg:3500:8:4:鮮魚仲卸:高級貝"
  "ムール貝:3:kg:1500:12:6:鮮魚仲卸:ワイン蒸し用"
  "タコ:3:kg:3200:10:5:鮮魚仲卸:茹でタコ"
  "するめいか:3:kg:2200:15:8:鮮魚仲卸:焼きイカ用"
  "サーモン切り身:3:kg:2800:20:10:鮮魚仲卸:脂のり良好"
  "ブリ切り身:3:kg:2500:15:8:鮮魚仲卸:照り焼き用"
  "カツオたたき:3:kg:3000:10:5:鮮魚仲卸:土佐風"
  "マグロ赤身:3:kg:4500:8:4:鮮魚仲卸:刺身用"
  "ホッケ開き:3:枚:800:20:10:鮮魚仲卸:北海道産"
  "サンマ:3:kg:1200:15:8:鮮魚仲卸:秋刀魚塩焼き"
  "イワシ:3:kg:900:18:10:鮮魚仲卸:新鮮いわし"
  "アジ:3:kg:1500:15:8:鮮魚仲卸:塩焼き用"
  "カキ:3:kg:3800:12:6:鮮魚仲卸:生食用"
  "シシャモ:3:kg:1800:15:8:鮮魚仲卸:卵たっぷり"
  "ししゃも子持ち:3:kg:2500:10:5:鮮魚仲卸:高級ししゃも"
)

for item in "${SEAFOOD_ITEMS[@]}"; do
  IFS=':' read -r name supplier_id unit price quantity threshold supplier notes <<< "$item"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/inventory" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"item_name\": \"$name\",
      \"category\": \"食材\",
      \"supplier_id\": $supplier_id,
      \"unit\": \"$unit\",
      \"unit_cost\": $price,
      \"current_stock\": $quantity,
      \"reorder_point\": $threshold,
      \"optimal_stock\": $((quantity * 2)),
      \"notes\": \"$notes\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    ((SUCCESS_INVENTORY++))
  else
    ((FAIL_INVENTORY++))
  fi
  sleep 0.1
done

# 野菜類（20件）
VEGETABLE_ITEMS=(
  "キャベツ:4:個:180:50:25:野菜・調味料卸:お好み焼き用"
  "もやし:4:袋:80:100:50:野菜・調味料卸:炒め物用"
  "玉ねぎ:4:kg:200:40:20:野菜・調味料卸:焼き野菜用"
  "長ネギ:4:kg:350:30:15:野菜・調味料卸:薬味・焼き用"
  "ピーマン:4:kg:280:25:12:野菜・調味料卸:炒め物用"
  "赤ピーマン:4:kg:450:15:8:野菜・調味料卸:彩り用"
  "にんにく:4:kg:1200:10:5:野菜・調味料卸:国産にんにく"
  "生姜:4:kg:800:8:4:野菜・調味料卸:薬味用"
  "にんじん:4:kg:180:30:15:野菜・調味料卸:付け合わせ用"
  "じゃがいも:4:kg:200:40:20:野菜・調味料卸:バター焼き用"
  "かぼちゃ:4:kg:250:20:10:野菜・調味料卸:甘み強い"
  "なす:4:kg:280:25:12:野菜・調味料卸:焼きナス用"
  "トマト:4:kg:400:20:10:野菜・調味料卸:新鮮トマト"
  "ミニトマト:4:パック:250:30:15:野菜・調味料卸:サラダ・付け合わせ"
  "アスパラガス:4:kg:1200:10:5:野菜・調味料卸:高級野菜"
  "ブロッコリー:4:個:200:20:10:野菜・調味料卸:栄養豊富"
  "紅生姜:4:kg:1800:5:3:野菜・調味料卸:お好み焼き用"
  "エリンギ:4:パック:180:30:15:野菜・調味料卸:きのこ類"
  "しいたけ:4:パック:280:25:12:野菜・調味料卸:肉厚しいたけ"
  "えのき:4:袋:120:40:20:野菜・調味料卸:鉄板焼き用"
)

for item in "${VEGETABLE_ITEMS[@]}"; do
  IFS=':' read -r name supplier_id unit price quantity threshold supplier notes <<< "$item"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/inventory" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"item_name\": \"$name\",
      \"category\": \"食材\",
      \"supplier_id\": $supplier_id,
      \"unit\": \"$unit\",
      \"unit_cost\": $price,
      \"current_stock\": $quantity,
      \"reorder_point\": $threshold,
      \"optimal_stock\": $((quantity * 2)),
      \"notes\": \"$notes\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    ((SUCCESS_INVENTORY++))
  else
    ((FAIL_INVENTORY++))
  fi
  sleep 0.1
done

# 粉物・麺類（10件）
FLOUR_ITEMS=(
  "お好み焼き粉:4:kg:800:30:15:野菜・調味料卸:高品質"
  "たこ焼き粉:4:kg:750:25:12:野菜・調味料卸:専門店向け"
  "天ぷら粉:4:kg:650:20:10:野菜・調味料卸:サクサク"
  "焼きそば麺:4:玉:100:80:40:野菜・調味料卸:蒸し麺"
  "うどん:4:玉:120:60:30:野菜・調味料卸:讃岐うどん"
  "そば:4:玉:150:40:20:野菜・調味料卸:十割そば"
  "パン粉:4:kg:450:15:8:野菜・調味料卸:揚げ物用"
  "片栗粉:4:kg:400:10:5:野菜・調味料卸:とろみ用"
  "小麦粉:4:kg:350:20:10:野菜・調味料卸:薄力粉"
  "山芋:4:kg:1500:10:5:野菜・調味料卸:お好み焼き用"
)

for item in "${FLOUR_ITEMS[@]}"; do
  IFS=':' read -r name supplier_id unit price quantity threshold supplier notes <<< "$item"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/inventory" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"item_name\": \"$name\",
      \"category\": \"食材\",
      \"supplier_id\": $supplier_id,
      \"unit\": \"$unit\",
      \"unit_cost\": $price,
      \"current_stock\": $quantity,
      \"reorder_point\": $threshold,
      \"optimal_stock\": $((quantity * 2)),
      \"notes\": \"$notes\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    ((SUCCESS_INVENTORY++))
  else
    ((FAIL_INVENTORY++))
  fi
  sleep 0.1
done

# 調味料・ソース（15件）
SEASONING_ITEMS=(
  "お好み焼きソース:4:本:450:30:15:野菜・調味料卸:オタフクソース"
  "たこ焼きソース:4:本:420:25:12:野菜・調味料卸:専門店用"
  "マヨネーズ:4:本:380:40:20:野菜・調味料卸:キューピー"
  "焼肉のタレ:4:本:550:30:15:野菜・調味料卸:特製甘口"
  "焼肉のタレ辛口:4:本:550:25:12:野菜・調味料卸:ピリ辛"
  "醤油:4:本:400:20:10:野菜・調味料卸:濃口醤油"
  "みりん:4:本:350:15:8:野菜・調味料卸:本みりん"
  "料理酒:4:本:300:20:10:野菜・調味料卸:清酒"
  "塩:4:kg:200:10:5:野菜・調味料卸:食塩"
  "黒胡椒:4:kg:1200:5:3:野菜・調味料卸:粗挽き"
  "七味唐辛子:4:本:450:8:4:野菜・調味料卸:国産"
  "ごま油:4:本:600:15:8:野菜・調味料卸:純正"
  "サラダ油:4:本:400:25:12:野菜・調味料卸:日清オイリオ"
  "特製鉄板ソース:4:本:850:10:5:野菜・調味料卸:オリジナルソース"
  "ポン酢:4:本:380:20:10:野菜・調味料卸:柚子ポン酢"
)

for item in "${SEASONING_ITEMS[@]}"; do
  IFS=':' read -r name supplier_id unit price quantity threshold supplier notes <<< "$item"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/inventory" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"item_name\": \"$name\",
      \"category\": \"食材\",
      \"supplier_id\": $supplier_id,
      \"unit\": \"$unit\",
      \"unit_cost\": $price,
      \"current_stock\": $quantity,
      \"reorder_point\": $threshold,
      \"optimal_stock\": $((quantity * 2)),
      \"notes\": \"$notes\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    ((SUCCESS_INVENTORY++))
  else
    ((FAIL_INVENTORY++))
  fi
  sleep 0.1
done

# お酒・飲料（5件）
DRINK_ITEMS=(
  "生ビール樽:4:樽:18000:5:3:野菜・調味料卸:アサヒスーパードライ"
  "瓶ビール:4:ケース:4500:10:5:野菜・調味料卸:大瓶20本入"
  "焼酎:4:本:2800:15:8:野菜・調味料卸:芋焼酎"
  "日本酒:4:本:3500:10:5:野菜・調味料卸:純米酒"
  "レモンサワー用レモン果汁:4:本:1200:20:10:野菜・調味料卸:業務用"
)

for item in "${DRINK_ITEMS[@]}"; do
  IFS=':' read -r name supplier_id unit price quantity threshold supplier notes <<< "$item"
  
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/inventory" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"item_name\": \"$name\",
      \"category\": \"食材\",
      \"supplier_id\": $supplier_id,
      \"unit\": \"$unit\",
      \"unit_cost\": $price,
      \"current_stock\": $quantity,
      \"reorder_point\": $threshold,
      \"optimal_stock\": $((quantity * 2)),
      \"notes\": \"$notes\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    ((SUCCESS_INVENTORY++))
  else
    ((FAIL_INVENTORY++))
  fi
  sleep 0.1
done

echo "✅ 在庫商品登録完了: 成功 $SUCCESS_INVENTORY 件、失敗 $FAIL_INVENTORY 件"
echo ""

echo "=========================================="
echo "📊 登録結果サマリー"
echo "=========================================="
echo "顧客: 成功 $SUCCESS_CUSTOMERS 件 / 失敗 $FAIL_CUSTOMERS 件"
echo "在庫: 成功 $SUCCESS_INVENTORY 件 / 失敗 $FAIL_INVENTORY 件"
echo "発注: 成功 $SUCCESS_ORDERS 件 / 失敗 $FAIL_ORDERS 件"
echo "書類: 成功 $SUCCESS_DOCUMENTS 件 / 失敗 $FAIL_DOCUMENTS 件"
echo "=========================================="
echo "✅ テストデータ登録完了！"
echo ""
echo "🌐 システムURL: https://mizomaru-teppanyaki-system.vercel.app"
echo "🔐 ログイン情報:"
echo "   ユーザー名: 鉄板焼き居酒屋みぞまる"
echo "   パスワード: admin123"
echo "=========================================="
