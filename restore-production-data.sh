#!/bin/bash

# 鉄板焼き居酒屋みぞまる 本番環境データ再登録スクリプト
# 2026-02-20

API_URL="https://mizomaru-backend.onrender.com/api"
TOKEN=$(cat /tmp/mizomaru_token_new.txt)

echo "=========================================="
echo "鉄板焼き居酒屋みぞまる データ再登録"
echo "=========================================="
echo ""

# カウンター
SUCCESS_CUSTOMERS=0
SUCCESS_INVENTORY=0
FAIL_CUSTOMERS=0
FAIL_INVENTORY=0

# 顧客登録関数
register_customer() {
  local customer_type=$1
  local name=$2
  local email=$3
  local phone=$4
  local address=$5
  local notes=$6
  
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/customers" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"customer_type\": \"$customer_type\",
      \"name\": \"$name\",
      \"email\": \"$email\",
      \"phone\": \"$phone\",
      \"address\": \"$address\",
      \"notes\": \"$notes\"
    }")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    ((SUCCESS_CUSTOMERS++))
  else
    ((FAIL_CUSTOMERS++))
  fi
  sleep 0.15
}

# 在庫登録関数
register_inventory() {
  local name=$1
  local supplier_id=$2
  local unit=$3
  local price=$4
  local quantity=$5
  local threshold=$6
  local notes=$7
  
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
  sleep 0.15
}

echo "📋 顧客データ登録中（50件）..."

# 個人客45件
register_customer "個人事業主" "田中 太郎" "tanaka@example.com" "090-1111-1111" "神奈川県相模原市中央区中央1-1-1" "常連客"
register_customer "個人事業主" "佐藤 花子" "sato@example.com" "090-2222-2222" "神奈川県相模原市南区相南1-1-1" "リピーター"
register_customer "個人事業主" "鈴木 一郎" "suzuki@example.com" "090-3333-3333" "神奈川県相模原市緑区橋本1-1-1" "近隣住民"
register_customer "個人事業主" "高橋 美咲" "takahashi@example.com" "090-4444-4444" "東京都町田市原町田1-1-1" "常連客"
register_customer "個人事業主" "伊藤 健" "ito@example.com" "090-5555-5555" "神奈川県相模原市中央区富士見1-1-1" "週末利用"
register_customer "個人事業主" "渡辺 真由美" "watanabe@example.com" "090-6666-6666" "神奈川県相模原市南区東林間1-1-1" "家族連れ"
register_customer "個人事業主" "山本 大輔" "yamamoto@example.com" "090-7777-7777" "神奈川県座間市相模が丘1-1-1" "月1回来店"
register_customer "個人事業主" "中村 さくら" "nakamura@example.com" "090-8888-8888" "神奈川県相模原市中央区矢部1-1-1" "常連客"
register_customer "個人事業主" "小林 正" "kobayashi@example.com" "090-9999-9999" "神奈川県相模原市緑区大山町1-1-1" "接待利用"
register_customer "個人事業主" "加藤 愛" "kato@example.com" "090-1234-5678" "東京都八王子市八王子1-1-1" "デート利用"
register_customer "個人事業主" "吉田 浩二" "yoshida@example.com" "090-2345-6789" "神奈川県相模原市中央区上溝1-1-1" "一人飲み"
register_customer "個人事業主" "山田 京子" "yamada@example.com" "090-3456-7890" "神奈川県相模原市南区相模大野1-1-1" "女子会"
register_customer "個人事業主" "佐々木 孝" "sasaki@example.com" "090-4567-8901" "神奈川県相模原市中央区淵野辺1-1-1" "常連客"
register_customer "個人事業主" "松本 麗子" "matsumoto@example.com" "090-5678-9012" "神奈川県厚木市中町1-1-1" "月2回"
register_customer "個人事業主" "井上 翔太" "inoue@example.com" "090-6789-0123" "神奈川県相模原市緑区相原1-1-1" "カウンター常連"
register_customer "個人事業主" "木村 美穂" "kimura@example.com" "090-7890-1234" "神奈川県相模原市中央区小山1-1-1" "ランチ利用"
register_customer "個人事業主" "林 雄介" "hayashi@example.com" "090-8901-2345" "神奈川県相模原市南区麻溝台1-1-1" "宴会幹事"
register_customer "個人事業主" "斎藤 奈々" "saito@example.com" "090-9012-3456" "東京都町田市成瀬1-1-1" "記念日利用"
register_customer "個人事業主" "清水 誠" "shimizu@example.com" "090-0123-4567" "神奈川県相模原市中央区田名1-1-1" "常連客"
register_customer "個人事業主" "森 優子" "mori@example.com" "090-1357-2468" "神奈川県座間市入谷1-1-1" "家族4人"
register_customer "個人事業主" "池田 健一" "ikeda@example.com" "090-2468-1357" "神奈川県相模原市緑区二本松1-1-1" "週末利用"
register_customer "個人事業主" "橋本 恵美" "hashimoto@example.com" "090-3579-2468" "神奈川県相模原市中央区星が丘1-1-1" "女子会"
register_customer "個人事業主" "山口 隆" "yamaguchi@example.com" "090-4680-1357" "神奈川県相模原市南区新磯野1-1-1" "接待利用"
register_customer "個人事業主" "石川 舞" "ishikawa@example.com" "090-5791-2468" "東京都八王子市みなみ野1-1-1" "デート"
register_customer "個人事業主" "藤田 修" "fujita@example.com" "090-6802-3579" "神奈川県相模原市中央区横山1-1-1" "一人飲み"
register_customer "個人事業主" "坂本 香織" "sakamoto@example.com" "090-7913-4680" "神奈川県厚木市飯山1-1-1" "常連客"
register_customer "個人事業主" "西村 直樹" "nishimura@example.com" "090-8024-5791" "神奈川県相模原市緑区城山1-1-1" "カウンター"
register_customer "個人事業主" "前田 彩" "maeda@example.com" "090-9135-6802" "神奈川県相模原市中央区光が丘1-1-1" "ランチ"
register_customer "個人事業主" "岡田 勇気" "okada@example.com" "090-0246-7913" "神奈川県相模原市南区上鶴間1-1-1" "週末"
register_customer "個人事業主" "長谷川 美里" "hasegawa@example.com" "090-1478-9024" "東京都町田市金森1-1-1" "子連れ"
register_customer "個人事業主" "村上 光男" "murakami@example.com" "090-2589-0135" "神奈川県相模原市中央区清新1-1-1" "常連客"
register_customer "個人事業主" "近藤 綾" "kondo@example.com" "090-3690-1246" "神奈川県座間市ひばりが丘1-1-1" "女子会"
register_customer "個人事業主" "遠藤 龍也" "endo@example.com" "090-4701-2357" "神奈川県相模原市緑区若柳1-1-1" "接待"
register_customer "個人事業主" "青木 千春" "aoki@example.com" "090-5812-3468" "神奈川県相模原市中央区陽光台1-1-1" "デート"
register_customer "個人事業主" "福田 祐介" "fukuda@example.com" "090-6923-4579" "神奈川県相模原市南区御園1-1-1" "一人飲み"
register_customer "個人事業主" "太田 明美" "ota@example.com" "090-7034-5680" "東京都八王子市長房1-1-1" "常連客"
register_customer "個人事業主" "岩崎 拓也" "iwasaki@example.com" "090-8145-6791" "神奈川県相模原市中央区宮下1-1-1" "カウンター"
register_customer "個人事業主" "上田 真理子" "ueda@example.com" "090-9256-7802" "神奈川県厚木市恩名1-1-1" "ランチ"
register_customer "個人事業主" "原田 晃" "harada@example.com" "090-0367-8913" "神奈川県相模原市緑区久保沢1-1-1" "週末"
register_customer "個人事業主" "柴田 恵" "shibata@example.com" "090-1478-9025" "神奈川県相模原市中央区共和1-1-1" "家族"
register_customer "個人事業主" "酒井 慎一" "sakai@example.com" "090-2589-0136" "神奈川県相模原市南区双葉1-1-1" "常連客"
register_customer "個人事業主" "宮崎 幸子" "miyazaki@example.com" "090-3690-1247" "東京都町田市南大谷1-1-1" "女子会"
register_customer "個人事業主" "古川 健太郎" "furukawa@example.com" "090-4701-2358" "神奈川県座間市広野台1-1-1" "接待"
register_customer "個人事業主" "三浦 愛子" "miura@example.com" "090-5812-3469" "神奈川県相模原市中央区鹿沼台1-1-1" "デート"
register_customer "個人事業主" "藤井 秀樹" "fujii@example.com" "090-6923-4580" "神奈川県相模原市緑区三井1-1-1" "一人飲み"

# 法人5件
register_customer "法人" "相模原商事株式会社" "sagamihara@corp.com" "042-111-1111" "神奈川県相模原市中央区中央3-10-5" "宴会年4回"
register_customer "法人" "中央技研工業株式会社" "chuo-giken@corp.com" "042-222-2222" "神奈川県相模原市南区古淵2-15-8" "接待利用"
register_customer "法人" "橋本建設株式会社" "hashimoto-const@corp.com" "042-333-3333" "神奈川県相模原市緑区橋本6-5-3" "忘年会"
register_customer "法人" "相模原IT株式会社" "sagami-it@corp.com" "042-444-4444" "神奈川県相模原市中央区淵野辺4-8-12" "歓送迎会"
register_customer "法人" "みなみ不動産株式会社" "minami-estate@corp.com" "042-555-5555" "神奈川県相模原市南区相模大野3-12-1" "定期利用"

echo "✅ 顧客登録完了: $SUCCESS_CUSTOMERS 件成功、$FAIL_CUSTOMERS 件失敗"
echo ""

echo "📦 在庫データ登録中（100件）..."

# 肉類30件
register_inventory "黒毛和牛A5サーロイン" 1 "kg" 12000 10 5 "特選A5"
register_inventory "黒毛和牛A5リブロース" 1 "kg" 11500 8 5 "霜降り"
register_inventory "黒毛和牛A5ヒレ" 1 "kg" 15000 5 3 "最高級"
register_inventory "黒毛和牛A5カルビ" 1 "kg" 9500 15 8 "焼肉用"
register_inventory "黒毛和牛A5ハラミ" 1 "kg" 8500 12 6 "柔らか"
register_inventory "黒毛和牛A4サーロイン" 1 "kg" 9000 12 5 "A4ランク"
register_inventory "黒毛和牛A4ロース" 1 "kg" 8500 10 5 "食べやすい"
register_inventory "神戸ビーフサーロイン" 1 "kg" 18000 3 2 "ブランド牛"
register_inventory "松阪牛リブロース" 1 "kg" 16000 4 2 "三重県産"
register_inventory "国産和牛モモ" 1 "kg" 5500 20 10 "赤身"
register_inventory "国産豚バラ" 2 "kg" 1800 30 15 "定番"
register_inventory "国産豚ロース" 2 "kg" 2200 25 12 "厚切り"
register_inventory "国産豚肩ロース" 2 "kg" 2000 20 10 "鉄板焼き用"
register_inventory "国産豚トントロ" 2 "kg" 2500 15 8 "希少部位"
register_inventory "国産豚ホルモンミックス" 2 "kg" 1500 18 10 "ホルモン焼き"
register_inventory "鶏もも肉" 2 "kg" 1200 35 20 "国産鶏"
register_inventory "鶏むね肉" 2 "kg" 800 30 15 "ヘルシー"
register_inventory "鶏手羽先" 2 "kg" 900 25 12 "唐揚げ用"
register_inventory "鶏レバー" 2 "kg" 600 15 8 "新鮮"
register_inventory "鶏せせり" 2 "kg" 1100 20 10 "希少"
register_inventory "国産牛タン" 1 "kg" 6500 10 5 "厚切り"
register_inventory "国産牛ハラミ" 1 "kg" 5800 12 6 "柔らか"
register_inventory "国産牛ホルモン" 1 "kg" 3500 15 8 "ミックス"
register_inventory "ラム肉ショルダー" 1 "kg" 3200 10 5 "ジンギスカン"
register_inventory "ラム肉ロース" 1 "kg" 4500 8 4 "高級"
register_inventory "粗挽きソーセージ" 2 "kg" 2800 20 10 "鉄板焼き用"
register_inventory "フランクフルト" 2 "kg" 2400 15 8 "ビールに合う"
register_inventory "ベーコンスライス" 2 "kg" 3200 18 10 "厚切り"
register_inventory "鴨ロース" 1 "kg" 5500 5 3 "希少"
register_inventory "牛サガリ" 1 "kg" 4200 12 6 "ハラミに似た"

# 魚介類20件
register_inventory "真イカ" 3 "kg" 2500 15 8 "新鮮"
register_inventory "ホタテ貝柱" 3 "kg" 4500 10 5 "北海道産"
register_inventory "ブラックタイガーエビ" 3 "kg" 3800 12 6 "大ぶり"
register_inventory "バナメイエビ" 3 "kg" 2800 15 8 "中サイズ"
register_inventory "あさり" 3 "kg" 1800 10 5 "酒蒸し用"
register_inventory "はまぐり" 3 "kg" 3500 8 4 "高級貝"
register_inventory "ムール貝" 3 "kg" 1500 12 6 "ワイン蒸し"
register_inventory "タコ" 3 "kg" 3200 10 5 "茹でタコ"
register_inventory "するめいか" 3 "kg" 2200 15 8 "焼きイカ"
register_inventory "サーモン切り身" 3 "kg" 2800 20 10 "脂のり良好"
register_inventory "ブリ切り身" 3 "kg" 2500 15 8 "照り焼き"
register_inventory "カツオたたき" 3 "kg" 3000 10 5 "土佐風"
register_inventory "マグロ赤身" 3 "kg" 4500 8 4 "刺身用"
register_inventory "ホッケ開き" 3 "枚" 800 20 10 "北海道産"
register_inventory "サンマ" 3 "kg" 1200 15 8 "塩焼き"
register_inventory "イワシ" 3 "kg" 900 18 10 "新鮮"
register_inventory "アジ" 3 "kg" 1500 15 8 "塩焼き"
register_inventory "カキ" 3 "kg" 3800 12 6 "生食用"
register_inventory "シシャモ" 3 "kg" 1800 15 8 "卵たっぷり"
register_inventory "ししゃも子持ち" 3 "kg" 2500 10 5 "高級"

# 野菜類20件
register_inventory "キャベツ" 4 "個" 180 50 25 "お好み焼き用"
register_inventory "もやし" 4 "袋" 80 100 50 "炒め物用"
register_inventory "玉ねぎ" 4 "kg" 200 40 20 "焼き野菜"
register_inventory "長ネギ" 4 "kg" 350 30 15 "薬味・焼き用"
register_inventory "ピーマン" 4 "kg" 280 25 12 "炒め物用"
register_inventory "赤ピーマン" 4 "kg" 450 15 8 "彩り用"
register_inventory "にんにく" 4 "kg" 1200 10 5 "国産"
register_inventory "生姜" 4 "kg" 800 8 4 "薬味用"
register_inventory "にんじん" 4 "kg" 180 30 15 "付け合わせ"
register_inventory "じゃがいも" 4 "kg" 200 40 20 "バター焼き"
register_inventory "かぼちゃ" 4 "kg" 250 20 10 "甘み強い"
register_inventory "なす" 4 "kg" 280 25 12 "焼きナス"
register_inventory "トマト" 4 "kg" 400 20 10 "新鮮"
register_inventory "ミニトマト" 4 "パック" 250 30 15 "サラダ用"
register_inventory "アスパラガス" 4 "kg" 1200 10 5 "高級野菜"
register_inventory "ブロッコリー" 4 "個" 200 20 10 "栄養豊富"
register_inventory "紅生姜" 4 "kg" 1800 5 3 "お好み焼き用"
register_inventory "エリンギ" 4 "パック" 180 30 15 "きのこ類"
register_inventory "しいたけ" 4 "パック" 280 25 12 "肉厚"
register_inventory "えのき" 4 "袋" 120 40 20 "鉄板焼き用"

# 粉物10件
register_inventory "お好み焼き粉" 4 "kg" 800 30 15 "高品質"
register_inventory "たこ焼き粉" 4 "kg" 750 25 12 "専門店向け"
register_inventory "天ぷら粉" 4 "kg" 650 20 10 "サクサク"
register_inventory "焼きそば麺" 4 "玉" 100 80 40 "蒸し麺"
register_inventory "うどん" 4 "玉" 120 60 30 "讃岐うどん"
register_inventory "そば" 4 "玉" 150 40 20 "十割そば"
register_inventory "パン粉" 4 "kg" 450 15 8 "揚げ物用"
register_inventory "片栗粉" 4 "kg" 400 10 5 "とろみ用"
register_inventory "小麦粉" 4 "kg" 350 20 10 "薄力粉"
register_inventory "山芋" 4 "kg" 1500 10 5 "お好み焼き用"

# 調味料15件
register_inventory "お好み焼きソース" 4 "本" 450 30 15 "オタフク"
register_inventory "たこ焼きソース" 4 "本" 420 25 12 "専門店用"
register_inventory "マヨネーズ" 4 "本" 380 40 20 "キューピー"
register_inventory "焼肉のタレ" 4 "本" 550 30 15 "特製甘口"
register_inventory "焼肉のタレ辛口" 4 "本" 550 25 12 "ピリ辛"
register_inventory "醤油" 4 "本" 400 20 10 "濃口醤油"
register_inventory "みりん" 4 "本" 350 15 8 "本みりん"
register_inventory "料理酒" 4 "本" 300 20 10 "清酒"
register_inventory "塩" 4 "kg" 200 10 5 "食塩"
register_inventory "黒胡椒" 4 "kg" 1200 5 3 "粗挽き"
register_inventory "七味唐辛子" 4 "本" 450 8 4 "国産"
register_inventory "ごま油" 4 "本" 600 15 8 "純正"
register_inventory "サラダ油" 4 "本" 400 25 12 "日清オイリオ"
register_inventory "特製鉄板ソース" 4 "本" 850 10 5 "オリジナル"
register_inventory "ポン酢" 4 "本" 380 20 10 "柚子ポン酢"

# 飲料5件
register_inventory "生ビール樽" 4 "樽" 18000 5 3 "スーパードライ"
register_inventory "瓶ビール" 4 "ケース" 4500 10 5 "大瓶20本"
register_inventory "焼酎" 4 "本" 2800 15 8 "芋焼酎"
register_inventory "日本酒" 4 "本" 3500 10 5 "純米酒"
register_inventory "レモンサワー用レモン果汁" 4 "本" 1200 20 10 "業務用"

echo "✅ 在庫登録完了: $SUCCESS_INVENTORY 件成功、$FAIL_INVENTORY 件失敗"
echo ""

echo "=========================================="
echo "📊 登録結果サマリー"
echo "=========================================="
echo "顧客: $SUCCESS_CUSTOMERS 件成功 / $FAIL_CUSTOMERS 件失敗"
echo "在庫: $SUCCESS_INVENTORY 件成功 / $FAIL_INVENTORY 件失敗"
echo "=========================================="
echo "✅ データ再登録完了！"
echo ""
echo "🌐 システムURL: https://mizomaru-teppanyaki-system.vercel.app"
echo "=========================================="
