#!/bin/bash

# 鉄板焼き居酒屋みぞまる 大量テストデータ登録スクリプト v2
# 2026-02-20

API_URL="https://mizomaru-backend.onrender.com/api"
TOKEN=$(cat /tmp/mizomaru_token.txt)

echo "=========================================="
echo "鉄板焼き居酒屋みぞまる テストデータ登録 v2"
echo "=========================================="
echo ""

# カウンター
SUCCESS_CUSTOMERS=0
FAIL_CUSTOMERS=0

# 1. 顧客登録（50件）
echo "📋 顧客データ登録中..."

# 個人客と法人客のデータ
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
    echo "  ✓ $name"
  else
    ((FAIL_CUSTOMERS++))
    echo "  ✗ $name (HTTP $HTTP_CODE)"
  fi
  sleep 0.2
}

# 個人事業主客（45件）
register_customer "個人事業主" "田中 太郎" "tanaka@example.com" "090-1111-1111" "神奈川県相模原市中央区中央1-1-1" "常連客・カウンター好き"
register_customer "個人事業主" "佐藤 花子" "sato@example.com" "090-2222-2222" "神奈川県相模原市南区相南1-1-1" "リピーター・女子会"
register_customer "個人事業主" "鈴木 一郎" "suzuki@example.com" "090-3333-3333" "神奈川県相模原市緑区橋本1-1-1" "近隣住民・週末利用"
register_customer "個人事業主" "高橋 美咲" "takahashi@example.com" "090-4444-4444" "東京都町田市原町田1-1-1" "常連客・デート利用"
register_customer "個人事業主" "伊藤 健" "ito@example.com" "090-5555-5555" "神奈川県相模原市中央区富士見1-1-1" "週末来店"
register_customer "個人事業主" "渡辺 真由美" "watanabe@example.com" "090-6666-6666" "神奈川県相模原市南区東林間1-1-1" "家族連れ"
register_customer "個人事業主" "山本 大輔" "yamamoto@example.com" "090-7777-7777" "神奈川県座間市相模が丘1-1-1" "月1回来店"
register_customer "個人事業主" "中村 さくら" "nakamura@example.com" "090-8888-8888" "神奈川県相模原市中央区矢部1-1-1" "常連客・ランチ"
register_customer "個人事業主" "小林 正" "kobayashi@example.com" "090-9999-9999" "神奈川県相模原市緑区大山町1-1-1" "接待利用"
register_customer "個人事業主" "加藤 愛" "kato@example.com" "090-1234-5678" "東京都八王子市八王子1-1-1" "デート利用・記念日"
register_customer "個人事業主" "吉田 浩二" "yoshida@example.com" "090-2345-6789" "神奈川県相模原市中央区上溝1-1-1" "一人飲み・カウンター"
register_customer "個人事業主" "山田 京子" "yamada@example.com" "090-3456-7890" "神奈川県相模原市南区相模大野1-1-1" "女子会利用"
register_customer "個人事業主" "佐々木 孝" "sasaki@example.com" "090-4567-8901" "神奈川県相模原市中央区淵野辺1-1-1" "常連客・仕事帰り"
register_customer "個人事業主" "松本 麗子" "matsumoto@example.com" "090-5678-9012" "神奈川県厚木市中町1-1-1" "月2回来店"
register_customer "個人事業主" "井上 翔太" "inoue@example.com" "090-6789-0123" "神奈川県相模原市緑区相原1-1-1" "カウンター常連"
register_customer "個人事業主" "木村 美穂" "kimura@example.com" "090-7890-1234" "神奈川県相模原市中央区小山1-1-1" "ランチ利用・OL"
register_customer "個人事業主" "林 雄介" "hayashi@example.com" "090-8901-2345" "神奈川県相模原市南区麻溝台1-1-1" "宴会幹事"
register_customer "個人事業主" "斎藤 奈々" "saito@example.com" "090-9012-3456" "東京都町田市成瀬1-1-1" "記念日・特別日"
register_customer "個人事業主" "清水 誠" "shimizu@example.com" "090-0123-4567" "神奈川県相模原市中央区田名1-1-1" "常連・昼夜利用"
register_customer "個人事業主" "森 優子" "mori@example.com" "090-1357-2468" "神奈川県座間市入谷1-1-1" "家族4人"
register_customer "個人事業主" "池田 健一" "ikeda@example.com" "090-2468-1357" "神奈川県相模原市緑区二本松1-1-1" "週末・友人"
register_customer "個人事業主" "橋本 恵美" "hashimoto@example.com" "090-3579-2468" "神奈川県相模原市中央区星が丘1-1-1" "女子会・誕生日"
register_customer "個人事業主" "山口 隆" "yamaguchi@example.com" "090-4680-1357" "神奈川県相模原市南区新磯野1-1-1" "接待・取引先"
register_customer "個人事業主" "石川 舞" "ishikawa@example.com" "090-5791-2468" "東京都八王子市みなみ野1-1-1" "デート・カップル"
register_customer "個人事業主" "藤田 修" "fujita@example.com" "090-6802-3579" "神奈川県相模原市中央区横山1-1-1" "一人飲み・夜"
register_customer "個人事業主" "坂本 香織" "sakamoto@example.com" "090-7913-4680" "神奈川県厚木市飯山1-1-1" "常連・夫婦"
register_customer "個人事業主" "西村 直樹" "nishimura@example.com" "090-8024-5791" "神奈川県相模原市緑区城山1-1-1" "カウンター・おひとりさま"
register_customer "個人事業主" "前田 彩" "maeda@example.com" "090-9135-6802" "神奈川県相模原市中央区光が丘1-1-1" "ランチ・友人"
register_customer "個人事業主" "岡田 勇気" "okada@example.com" "090-0246-7913" "神奈川県相模原市南区上鶴間1-1-1" "週末・家族"
register_customer "個人事業主" "長谷川 美里" "hasegawa@example.com" "090-1478-9024" "東京都町田市金森1-1-1" "子連れ・ファミリー"
register_customer "個人事業主" "村上 光男" "murakami@example.com" "090-2589-0135" "神奈川県相模原市中央区清新1-1-1" "常連・朝からビール"
register_customer "個人事業主" "近藤 綾" "kondo@example.com" "090-3690-1246" "神奈川県座間市ひばりが丘1-1-1" "女子会・ママ友"
register_customer "個人事業主" "遠藤 龍也" "endo@example.com" "090-4701-2357" "神奈川県相模原市緑区若柳1-1-1" "接待・ビジネス"
register_customer "個人事業主" "青木 千春" "aoki@example.com" "090-5812-3468" "神奈川県相模原市中央区陽光台1-1-1" "デート・若いカップル"
register_customer "個人事業主" "福田 祐介" "fukuda@example.com" "090-6923-4579" "神奈川県相模原市南区御園1-1-1" "一人飲み・仕事終わり"
register_customer "個人事業主" "太田 明美" "ota@example.com" "090-7034-5680" "東京都八王子市長房1-1-1" "常連・お好み焼き好き"
register_customer "個人事業主" "岩崎 拓也" "iwasaki@example.com" "090-8145-6791" "神奈川県相模原市中央区宮下1-1-1" "カウンター・一人"
register_customer "個人事業主" "上田 真理子" "ueda@example.com" "090-9256-7802" "神奈川県厚木市恩名1-1-1" "ランチ・OL友達"
register_customer "個人事業主" "原田 晃" "harada@example.com" "090-0367-8913" "神奈川県相模原市緑区久保沢1-1-1" "週末・BBQ好き"
register_customer "個人事業主" "柴田 恵" "shibata@example.com" "090-1478-9024" "神奈川県相模原市中央区共和1-1-1" "家族・子供3人"
register_customer "個人事業主" "酒井 慎一" "sakai@example.com" "090-2589-0135" "神奈川県相模原市南区双葉1-1-1" "常連・昼夜どちらも"
register_customer "個人事業主" "宮崎 幸子" "miyazaki@example.com" "090-3690-1246" "東京都町田市南大谷1-1-1" "女子会・ワイワイ"
register_customer "個人事業主" "古川 健太郎" "furukawa@example.com" "090-4701-2357" "神奈川県座間市広野台1-1-1" "接待・丁寧な対応"
register_customer "個人事業主" "三浦 愛子" "miura@example.com" "090-5812-3468" "神奈川県相模原市中央区鹿沼台1-1-1" "デート・夜景"
register_customer "個人事業主" "藤井 秀樹" "fujii@example.com" "090-6923-4579" "神奈川県相模原市緑区三井1-1-1" "一人飲み・黙々"

# 法人客（5件）
register_customer "法人" "相模原商事株式会社" "sagamihara@corp.com" "042-111-1111" "神奈川県相模原市中央区中央3-10-5" "宴会担当・年4回"
register_customer "法人" "中央技研工業株式会社" "chuo-giken@corp.com" "042-222-2222" "神奈川県相模原市南区古淵2-15-8" "接待利用・高級志向"
register_customer "法人" "橋本建設株式会社" "hashimoto-const@corp.com" "042-333-3333" "神奈川県相模原市緑区橋本6-5-3" "忘年会・新年会"
register_customer "法人" "相模原IT株式会社" "sagami-it@corp.com" "042-444-4444" "神奈川県相模原市中央区淵野辺4-8-12" "歓送迎会・定期"
register_customer "法人" "みなみ不動産株式会社" "minami-estate@corp.com" "042-555-5555" "神奈川県相模原市南区相模大野3-12-1" "定期利用・月1"

echo ""
echo "✅ 顧客登録完了: 成功 $SUCCESS_CUSTOMERS 件、失敗 $FAIL_CUSTOMERS 件"
echo ""
echo "=========================================="
echo "📊 登録結果サマリー"
echo "=========================================="
echo "顧客: 成功 $SUCCESS_CUSTOMERS 件 / 失敗 $FAIL_CUSTOMERS 件"
echo "在庫: 100件（前回登録済み）"
echo "=========================================="
echo "✅ テストデータ登録完了！"
echo ""
echo "🌐 システムURL: https://mizomaru-teppanyaki-system.vercel.app"
echo "🔐 ログイン情報:"
echo "   ユーザー名: 鉄板焼き居酒屋みぞまる"
echo "   パスワード: admin123"
echo "=========================================="
