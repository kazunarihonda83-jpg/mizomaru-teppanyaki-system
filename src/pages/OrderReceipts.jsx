import { useState, useEffect } from 'react';
import { Plus, Search, FileText, Trash2, Edit, Eye, DollarSign, Calendar } from 'lucide-react';
import api from '../utils/api';

export default function OrderReceipts() {
  const [receipts, setReceipts] = useState([]);
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingReceipt, setEditingReceipt] = useState(null);
  const [formData, setFormData] = useState({
    receipt_number: '',
    customer_id: '',
    order_date: new Date().toISOString().split('T')[0],
    delivery_date: '',
    status: 'pending',
    payment_status: 'unpaid',
    payment_date: '',
    notes: '',
    items: [{ item_name: '', description: '', quantity: 1, unit_price: 0 }]
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [receiptsRes, customersRes] = await Promise.all([
        api.get('/order-receipts'),
        api.get('/customers')
      ]);
      setReceipts(receiptsRes.data.data || receiptsRes.data || []);
      setCustomers(customersRes.data || []);
    } catch (err) {
      console.error('Error loading data:', err);
      setError('データの読み込みに失敗しました');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editingReceipt) {
        await api.put(`/order-receipts/${editingReceipt.id}`, formData);
      } else {
        await api.post('/order-receipts', formData);
      }
      setShowModal(false);
      resetForm();
      loadData();
    } catch (err) {
      console.error('Error saving receipt:', err);
      setError(err.response?.data?.error || '保存に失敗しました');
    }
  };

  const handleDelete = async (id) => {
    if (!confirm('本当に削除しますか？')) return;
    try {
      await api.delete(`/order-receipts/${id}`);
      loadData();
    } catch (err) {
      console.error('Error deleting receipt:', err);
      setError('削除に失敗しました');
    }
  };

  const resetForm = () => {
    setFormData({
      receipt_number: '',
      customer_id: '',
      order_date: new Date().toISOString().split('T')[0],
      delivery_date: '',
      status: 'pending',
      payment_status: 'unpaid',
      payment_date: '',
      notes: '',
      items: [{ item_name: '', description: '', quantity: 1, unit_price: 0 }]
    });
    setEditingReceipt(null);
  };

  const handleEdit = (receipt) => {
    setEditingReceipt(receipt);
    setFormData({
      receipt_number: receipt.receipt_number,
      customer_id: receipt.customer_id,
      order_date: receipt.order_date,
      delivery_date: receipt.delivery_date || '',
      status: receipt.status,
      payment_status: receipt.payment_status,
      payment_date: receipt.payment_date || '',
      notes: receipt.notes || '',
      items: receipt.items || [{ item_name: '', description: '', quantity: 1, unit_price: 0 }]
    });
    setShowModal(true);
  };

  const addItem = () => {
    setFormData({
      ...formData,
      items: [...formData.items, { item_name: '', description: '', quantity: 1, unit_price: 0 }]
    });
  };

  const removeItem = (index) => {
    const newItems = formData.items.filter((_, i) => i !== index);
    setFormData({ ...formData, items: newItems });
  };

  const updateItem = (index, field, value) => {
    const newItems = [...formData.items];
    newItems[index][field] = value;
    setFormData({ ...formData, items: newItems });
  };

  const filteredReceipts = receipts.filter(receipt =>
    receipt.receipt_number?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    receipt.customer_name?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getStatusBadge = (status) => {
    const statusConfig = {
      pending: { label: '受注済み', color: 'bg-blue-100 text-blue-800' },
      processing: { label: '処理中', color: 'bg-yellow-100 text-yellow-800' },
      shipped: { label: '出荷済み', color: 'bg-purple-100 text-purple-800' },
      delivered: { label: '納品完了', color: 'bg-green-100 text-green-800' },
      cancelled: { label: 'キャンセル', color: 'bg-red-100 text-red-800' }
    };
    const config = statusConfig[status] || statusConfig.pending;
    return <span className={`px-2 py-1 rounded text-xs ${config.color}`}>{config.label}</span>;
  };

  const getPaymentBadge = (status) => {
    const statusConfig = {
      unpaid: { label: '未払い', color: 'bg-red-100 text-red-800' },
      partial: { label: '一部払い', color: 'bg-yellow-100 text-yellow-800' },
      paid: { label: '支払済み', color: 'bg-green-100 text-green-800' }
    };
    const config = statusConfig[status] || statusConfig.unpaid;
    return <span className={`px-2 py-1 rounded text-xs ${config.color}`}>{config.label}</span>;
  };

  if (loading) return <div style={{ padding: '20px' }}>読み込み中...</div>;

  return (
    <div style={{ padding: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <FileText size={24} />
          <h1 style={{ fontSize: '24px', fontWeight: 'bold', margin: 0 }}>受注取引一覧</h1>
        </div>
        <button
          onClick={() => {
            resetForm();
            setShowModal(true);
          }}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '5px',
            padding: '10px 20px',
            backgroundColor: '#3b82f6',
            color: 'white',
            border: 'none',
            borderRadius: '5px',
            cursor: 'pointer'
          }}
        >
          <Plus size={20} />
          新規受注
        </button>
      </div>

      {error && (
        <div style={{
          padding: '10px',
          backgroundColor: '#fee',
          border: '1px solid #fcc',
          borderRadius: '5px',
          marginBottom: '20px',
          color: '#c33'
        }}>
          {error}
        </div>
      )}

      <div style={{ marginBottom: '20px' }}>
        <div style={{ position: 'relative' }}>
          <Search size={20} style={{ position: 'absolute', left: '10px', top: '10px', color: '#999' }} />
          <input
            type="text"
            placeholder="受注番号、顧客名で検索..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            style={{
              width: '100%',
              padding: '10px 10px 10px 40px',
              border: '1px solid #ddd',
              borderRadius: '5px'
            }}
          />
        </div>
      </div>

      <div style={{ backgroundColor: 'white', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr style={{ backgroundColor: '#f9fafb', borderBottom: '1px solid #e5e7eb' }}>
              <th style={{ padding: '12px', textAlign: 'left', fontWeight: '600' }}>受注番号</th>
              <th style={{ padding: '12px', textAlign: 'left', fontWeight: '600' }}>顧客名</th>
              <th style={{ padding: '12px', textAlign: 'left', fontWeight: '600' }}>受注日</th>
              <th style={{ padding: '12px', textAlign: 'left', fontWeight: '600' }}>納品予定日</th>
              <th style={{ padding: '12px', textAlign: 'right', fontWeight: '600' }}>金額</th>
              <th style={{ padding: '12px', textAlign: 'center', fontWeight: '600' }}>ステータス</th>
              <th style={{ padding: '12px', textAlign: 'center', fontWeight: '600' }}>支払状況</th>
              <th style={{ padding: '12px', textAlign: 'center', fontWeight: '600' }}>操作</th>
            </tr>
          </thead>
          <tbody>
            {filteredReceipts.length === 0 ? (
              <tr>
                <td colSpan="8" style={{ padding: '40px', textAlign: 'center', color: '#999' }}>
                  受注データがありません
                </td>
              </tr>
            ) : (
              filteredReceipts.map((receipt) => (
                <tr key={receipt.id} style={{ borderBottom: '1px solid #e5e7eb' }}>
                  <td style={{ padding: '12px' }}>{receipt.receipt_number}</td>
                  <td style={{ padding: '12px' }}>{receipt.customer_name}</td>
                  <td style={{ padding: '12px' }}>{receipt.order_date}</td>
                  <td style={{ padding: '12px' }}>{receipt.delivery_date || '-'}</td>
                  <td style={{ padding: '12px', textAlign: 'right' }}>
                    ¥{receipt.total_amount?.toLocaleString()}
                  </td>
                  <td style={{ padding: '12px', textAlign: 'center' }}>
                    {getStatusBadge(receipt.status)}
                  </td>
                  <td style={{ padding: '12px', textAlign: 'center' }}>
                    {getPaymentBadge(receipt.payment_status)}
                  </td>
                  <td style={{ padding: '12px' }}>
                    <div style={{ display: 'flex', gap: '8px', justifyContent: 'center' }}>
                      <button
                        onClick={() => handleEdit(receipt)}
                        style={{
                          padding: '5px 10px',
                          backgroundColor: '#3b82f6',
                          color: 'white',
                          border: 'none',
                          borderRadius: '4px',
                          cursor: 'pointer'
                        }}
                      >
                        <Edit size={16} />
                      </button>
                      <button
                        onClick={() => handleDelete(receipt.id)}
                        style={{
                          padding: '5px 10px',
                          backgroundColor: '#ef4444',
                          color: 'white',
                          border: 'none',
                          borderRadius: '4px',
                          cursor: 'pointer'
                        }}
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'rgba(0,0,0,0.5)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1000
        }}>
          <div style={{
            backgroundColor: 'white',
            borderRadius: '8px',
            padding: '20px',
            width: '90%',
            maxWidth: '800px',
            maxHeight: '90vh',
            overflow: 'auto'
          }}>
            <h2 style={{ marginBottom: '20px' }}>
              {editingReceipt ? '受注取引編集' : '新規受注取引'}
            </h2>
            <form onSubmit={handleSubmit}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '20px' }}>
                <div>
                  <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>受注番号 *</label>
                  <input
                    type="text"
                    value={formData.receipt_number}
                    onChange={(e) => setFormData({ ...formData, receipt_number: e.target.value })}
                    required
                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                  />
                </div>
                <div>
                  <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>顧客 *</label>
                  <select
                    value={formData.customer_id}
                    onChange={(e) => setFormData({ ...formData, customer_id: e.target.value })}
                    required
                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                  >
                    <option value="">選択してください</option>
                    {customers.map(c => (
                      <option key={c.id} value={c.id}>{c.name}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>受注日 *</label>
                  <input
                    type="date"
                    value={formData.order_date}
                    onChange={(e) => setFormData({ ...formData, order_date: e.target.value })}
                    required
                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                  />
                </div>
                <div>
                  <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>納品予定日</label>
                  <input
                    type="date"
                    value={formData.delivery_date}
                    onChange={(e) => setFormData({ ...formData, delivery_date: e.target.value })}
                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                  />
                </div>
                <div>
                  <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>ステータス</label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                  >
                    <option value="pending">受注済み</option>
                    <option value="processing">処理中</option>
                    <option value="shipped">出荷済み</option>
                    <option value="delivered">納品完了</option>
                    <option value="cancelled">キャンセル</option>
                  </select>
                </div>
                <div>
                  <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>支払状況</label>
                  <select
                    value={formData.payment_status}
                    onChange={(e) => setFormData({ ...formData, payment_status: e.target.value })}
                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                  >
                    <option value="unpaid">未払い</option>
                    <option value="partial">一部払い</option>
                    <option value="paid">支払済み</option>
                  </select>
                </div>
              </div>

              {formData.payment_status === 'paid' && (
                <div style={{ marginBottom: '20px' }}>
                  <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>支払日</label>
                  <input
                    type="date"
                    value={formData.payment_date}
                    onChange={(e) => setFormData({ ...formData, payment_date: e.target.value })}
                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                  />
                </div>
              )}

              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>備考</label>
                <textarea
                  value={formData.notes}
                  onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                  rows="3"
                  style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                />
              </div>

              <div style={{ marginBottom: '20px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                  <label style={{ fontWeight: '500' }}>商品明細 *</label>
                  <button
                    type="button"
                    onClick={addItem}
                    style={{
                      padding: '5px 15px',
                      backgroundColor: '#10b981',
                      color: 'white',
                      border: 'none',
                      borderRadius: '4px',
                      cursor: 'pointer'
                    }}
                  >
                    明細を追加
                  </button>
                </div>
                {formData.items.map((item, index) => (
                  <div key={index} style={{
                    display: 'grid',
                    gridTemplateColumns: '2fr 2fr 1fr 1fr auto',
                    gap: '10px',
                    marginBottom: '10px',
                    padding: '10px',
                    backgroundColor: '#f9fafb',
                    borderRadius: '4px'
                  }}>
                    <input
                      type="text"
                      placeholder="商品名"
                      value={item.item_name}
                      onChange={(e) => updateItem(index, 'item_name', e.target.value)}
                      required
                      style={{ padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                    <input
                      type="text"
                      placeholder="説明"
                      value={item.description}
                      onChange={(e) => updateItem(index, 'description', e.target.value)}
                      style={{ padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                    <input
                      type="number"
                      placeholder="数量"
                      value={item.quantity}
                      onChange={(e) => updateItem(index, 'quantity', parseFloat(e.target.value) || 0)}
                      required
                      min="0"
                      step="0.01"
                      style={{ padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                    <input
                      type="number"
                      placeholder="単価"
                      value={item.unit_price}
                      onChange={(e) => updateItem(index, 'unit_price', parseFloat(e.target.value) || 0)}
                      required
                      min="0"
                      step="0.01"
                      style={{ padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                    <button
                      type="button"
                      onClick={() => removeItem(index)}
                      disabled={formData.items.length === 1}
                      style={{
                        padding: '8px',
                        backgroundColor: '#ef4444',
                        color: 'white',
                        border: 'none',
                        borderRadius: '4px',
                        cursor: formData.items.length === 1 ? 'not-allowed' : 'pointer',
                        opacity: formData.items.length === 1 ? 0.5 : 1
                      }}
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                ))}
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false);
                    resetForm();
                  }}
                  style={{
                    padding: '10px 20px',
                    backgroundColor: '#6b7280',
                    color: 'white',
                    border: 'none',
                    borderRadius: '5px',
                    cursor: 'pointer'
                  }}
                >
                  キャンセル
                </button>
                <button
                  type="submit"
                  style={{
                    padding: '10px 20px',
                    backgroundColor: '#3b82f6',
                    color: 'white',
                    border: 'none',
                    borderRadius: '5px',
                    cursor: 'pointer'
                  }}
                >
                  {editingReceipt ? '更新' : '登録'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
