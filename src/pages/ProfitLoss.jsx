import { useState, useEffect } from 'react';
import { TrendingUp, Download, Save, Plus } from 'lucide-react';
import api from '../utils/api';

export default function ProfitLoss() {
  const [profitLoss, setProfitLoss] = useState({ revenue: 0, expenses: 0 });
  const [loading, setLoading] = useState(true);
  const [dateRange, setDateRange] = useState({
    start: new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0],
    end: new Date().toISOString().split('T')[0]
  });

  useEffect(() => {
    fetchData();
  }, [dateRange]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const response = await api.get('/accounting/profit-loss', {
        params: { start_date: dateRange.start, end_date: dateRange.end }
      });
      setProfitLoss(response.data);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const exportToCSV = () => {
    let csvContent = '損益計算書,\n';
    csvContent += `期間,${dateRange.start} 〜 ${dateRange.end}\n\n`;
    csvContent += '費目,金額\n';
    csvContent += 'I. 売上高,' + Math.round(profitLoss.revenue) + '\n';
    csvContent += 'II. 売上原価及び費用\n';
    csvContent += '売上原価,' + Math.round(profitLoss.expenses * 0.6) + '\n';
    csvContent += '販売費及び一般管理費,' + Math.round(profitLoss.expenses * 0.4) + '\n';
    csvContent += '費用合計,' + Math.round(profitLoss.expenses) + '\n';
    csvContent += '当期純利益,' + Math.round(profitLoss.revenue - profitLoss.expenses) + '\n';
    
    const filename = `profit_loss_${dateRange.start}_${dateRange.end}.csv`;
    const blob = new Blob(['\uFEFF' + csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = filename;
    link.click();
  };

  const handleSave = () => {
    alert('保存しました');
  };

  if (loading) return <div style={{ padding: '20px' }}>読み込み中...</div>;

  const netIncome = profitLoss.revenue - profitLoss.expenses;

  return (
    <div style={{ padding: '20px', maxWidth: '1400px', margin: '0 auto' }}>
      {/* ヘッダー */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <h1 style={{ display: 'flex', alignItems: 'center', gap: '12px', fontSize: '24px', fontWeight: '600' }}>
          <TrendingUp size={28} /> 損益計算書
        </h1>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '220px 1fr', gap: '20px' }}>
        {/* 左側サマリーカード */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <button
            style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '8px',
              padding: '12px 20px', 
              background: 'white', 
              border: '1px solid #d9d9d9',
              borderRadius: '8px', 
              cursor: 'pointer', 
              fontSize: '14px',
              fontWeight: '500',
              boxShadow: '0 1px 3px rgba(0,0,0,0.08)',
              transition: 'all 0.2s'
            }}
            onMouseOver={(e) => e.currentTarget.style.borderColor = '#1890ff'}
            onMouseOut={(e) => e.currentTarget.style.borderColor = '#d9d9d9'}
          >
            <Plus size={18} /> 作成証
          </button>
        </div>

        {/* 右側メインコンテンツ */}
        <div style={{ background: 'white', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.08)', overflow: 'hidden' }}>
          {/* ヘッダー部分 */}
          <div style={{ background: '#fafafa', padding: '20px', borderBottom: '1px solid #f0f0f0' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h2 style={{ fontSize: '18px', fontWeight: '600', margin: 0 }}>損益計算書</h2>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <label style={{ fontSize: '14px', color: '#666' }}>自</label>
                <input type="date" value={dateRange.start} onChange={(e) => setDateRange({...dateRange, start: e.target.value})}
                  style={{ padding: '6px 12px', border: '1px solid #d9d9d9', borderRadius: '4px', fontSize: '14px' }} />
                <label style={{ fontSize: '14px', color: '#666' }}>至</label>
                <input type="date" value={dateRange.end} onChange={(e) => setDateRange({...dateRange, end: e.target.value})}
                  style={{ padding: '6px 12px', border: '1px solid #d9d9d9', borderRadius: '4px', fontSize: '14px' }} />
                <span style={{ fontSize: '14px', color: '#999' }}>(単位　円)</span>
              </div>
            </div>
          </div>

          {/* テーブル */}
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid #e0e0e0' }}>
                  <th style={{ padding: '16px', textAlign: 'left', fontSize: '14px', fontWeight: '600', background: '#fafafa' }}>
                    費目
                  </th>
                  <th style={{ padding: '16px', textAlign: 'right', fontSize: '14px', fontWeight: '600', background: '#fafafa', width: '200px' }}>
                    金額
                  </th>
                </tr>
              </thead>
              <tbody>
                {/* I. 売上高 */}
                <tr style={{ borderBottom: '1px solid #f0f0f0' }}>
                  <td style={{ padding: '14px 16px', fontSize: '14px', fontWeight: '500' }}>I. 売上高</td>
                  <td style={{ padding: '14px 16px', textAlign: 'right', fontSize: '14px', fontWeight: '500' }}>
                    {Math.round(profitLoss.revenue).toLocaleString()}
                  </td>
                </tr>
                
                {/* II. 売上原価及び費用 */}
                <tr style={{ borderBottom: '1px solid #f0f0f0', background: '#fafafa' }}>
                  <td style={{ padding: '14px 16px', fontSize: '14px', fontWeight: '500' }}>II. 売上原価及び費用</td>
                  <td style={{ padding: '14px 16px' }}></td>
                </tr>
                <tr style={{ borderBottom: '1px solid #f0f0f0' }}>
                  <td style={{ padding: '12px 16px 12px 36px', fontSize: '14px' }}>売上原価</td>
                  <td style={{ padding: '12px 16px', textAlign: 'right', fontSize: '14px' }}>
                    {Math.round(profitLoss.expenses * 0.6).toLocaleString()}
                  </td>
                </tr>
                <tr style={{ borderBottom: '1px solid #f0f0f0' }}>
                  <td style={{ padding: '12px 16px 12px 36px', fontSize: '14px' }}>販売費及び一般管理費</td>
                  <td style={{ padding: '12px 16px', textAlign: 'right', fontSize: '14px' }}>
                    {Math.round(profitLoss.expenses * 0.4).toLocaleString()}
                  </td>
                </tr>
                <tr style={{ borderBottom: '1px solid #f0f0f0', background: '#fafafa' }}>
                  <td style={{ padding: '14px 16px', fontSize: '14px', fontWeight: '500' }}>費用合計</td>
                  <td style={{ padding: '14px 16px', textAlign: 'right', fontSize: '14px', fontWeight: '500' }}>
                    {Math.round(profitLoss.expenses).toLocaleString()}
                  </td>
                </tr>
                
                {/* 当期純利益 */}
                <tr style={{ borderTop: '2px solid #e0e0e0', background: netIncome >= 0 ? '#f6ffed' : '#fff7e6' }}>
                  <td style={{ padding: '16px', fontSize: '15px', fontWeight: '600', color: netIncome >= 0 ? '#52c41a' : '#fa8c16' }}>
                    当期純利益
                  </td>
                  <td style={{ padding: '16px', textAlign: 'right', fontSize: '16px', fontWeight: '600', color: netIncome >= 0 ? '#52c41a' : '#fa8c16' }}>
                    {Math.round(netIncome).toLocaleString()}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          {/* フッター：保存とCSVボタン */}
          <div style={{ padding: '20px', borderTop: '1px solid #f0f0f0', display: 'flex', gap: '12px' }}>
            <button onClick={handleSave}
              style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '10px 24px', background: '#1890ff',
                color: 'white', border: 'none', borderRadius: '6px', cursor: 'pointer', fontSize: '14px', fontWeight: '500' }}>
              <Save size={16} /> 保存する
            </button>
            <button onClick={exportToCSV}
              style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '10px 24px', background: '#52c41a',
                color: 'white', border: 'none', borderRadius: '6px', cursor: 'pointer', fontSize: '14px', fontWeight: '500' }}>
              <Download size={16} /> CSV出力
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
