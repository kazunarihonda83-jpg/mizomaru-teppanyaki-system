import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import db from './database.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Import routes
import authRoutes from './routes/auth.js';
import customersRoutes from './routes/customers.js';
import documentsRoutes from './routes/documents.js';
import suppliersRoutes from './routes/suppliers.js';
import purchasesRoutes from './routes/purchases.js';
import accountingRoutes from './routes/accounting.js';
import inventoryRoutes from './routes/inventory.js';
import expensesRoutes from './routes/expenses.js';
import orderReceiptsRoutes from './routes/order-receipts.js';
import accountingLedgersRoutes from './routes/accounting-ledgers.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5003;

app.use(cors());
app.use(express.json({ limit: '50mb' })); // 画像データ用にリミットを拡大
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// キャッシュ無効化ミドルウェア（全APIリクエストに適用）
app.use('/api', (req, res, next) => {
  res.set({
    'Cache-Control': 'no-store, no-cache, must-revalidate, proxy-revalidate',
    'Pragma': 'no-cache',
    'Expires': '0',
    'Surrogate-Control': 'no-store'
  });
  next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/customers', customersRoutes);
app.use('/api/documents', documentsRoutes);
app.use('/api/suppliers', suppliersRoutes);
app.use('/api/purchases', purchasesRoutes);
app.use('/api/accounting', accountingRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/expenses', expensesRoutes);
app.use('/api/order-receipts', orderReceiptsRoutes);
app.use('/api/accounting-ledgers', accountingLedgersRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Debug endpoint - check admin users (TEMPORARY)
app.get('/api/debug/users', (req, res) => {
  try {
    const users = db.prepare('SELECT id, username, email, is_active FROM administrators').all();
    res.json({ 
      count: users.length,
      users: users 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Serve static files in production (only if SERVE_FRONTEND is enabled)
// This is disabled on Render backend deployment
if (process.env.NODE_ENV === 'production' && process.env.SERVE_FRONTEND === 'true') {
  const distPath = path.join(__dirname, '../dist');
  app.use(express.static(distPath));
  
  // Handle SPA routing - send all non-API requests to index.html
  app.get('*', (req, res) => {
    res.sendFile(path.join(distPath, 'index.html'));
  });
  console.log('Serving frontend from dist directory');
} else if (process.env.NODE_ENV === 'production') {
  console.log('Backend API only mode - frontend serving disabled');
}

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
