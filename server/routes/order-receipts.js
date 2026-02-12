import express from 'express';
import multer from 'multer';
import { parse } from 'csv-parse/sync';

const router = express.Router();

// Get all order receipts
router.get('/', (req, res) => {
  try {
    const db = req.app.get('db');
    const orderReceipts = db.prepare(`
      SELECT 
        or.*,
        c.name as customer_name,
        c.customer_type
      FROM order_receipts or
      LEFT JOIN customers c ON or.customer_id = c.id
      ORDER BY or.order_date DESC, or.created_at DESC
    `).all();

    // Get items for each receipt
    const receiptsWithItems = orderReceipts.map(receipt => {
      const items = db.prepare(`
        SELECT * FROM order_receipt_items 
        WHERE order_receipt_id = ?
      `).all(receipt.id);
      
      return {
        ...receipt,
        items
      };
    });

    res.json({ data: receiptsWithItems });
  } catch (error) {
    console.error('Error fetching order receipts:', error);
    res.status(500).json({ error: 'Failed to fetch order receipts' });
  }
});

// Get single order receipt
router.get('/:id', (req, res) => {
  try {
    const db = req.app.get('db');
    const receipt = db.prepare(`
      SELECT 
        or.*,
        c.name as customer_name,
        c.customer_type,
        c.address,
        c.phone,
        c.email
      FROM order_receipts or
      LEFT JOIN customers c ON or.customer_id = c.id
      WHERE or.id = ?
    `).get(req.params.id);

    if (!receipt) {
      return res.status(404).json({ error: 'Order receipt not found' });
    }

    const items = db.prepare(`
      SELECT * FROM order_receipt_items 
      WHERE order_receipt_id = ?
    `).all(receipt.id);

    res.json({ data: { ...receipt, items } });
  } catch (error) {
    console.error('Error fetching order receipt:', error);
    res.status(500).json({ error: 'Failed to fetch order receipt' });
  }
});

// Create order receipt
router.post('/', (req, res) => {
  try {
    const db = req.app.get('db');
    const { 
      customer_id,
      order_date,
      delivery_date,
      status = 'pending',
      payment_status = 'unpaid',
      payment_date,
      notes,
      items = []
    } = req.body;

    // Validate required fields
    if (!customer_id || !order_date || items.length === 0) {
      return res.status(400).json({ 
        error: 'Customer, order date, and items are required' 
      });
    }

    // Generate receipt number automatically (OR-YYYYMMDD-XXXX format)
    const today = new Date(order_date);
    const dateStr = today.toISOString().split('T')[0].replace(/-/g, ''); // YYYYMMDD
    
    // Get the count of receipts created today
    const todayCount = db.prepare(`
      SELECT COUNT(*) as count FROM order_receipts 
      WHERE receipt_number LIKE ?
    `).get(`OR-${dateStr}-%`);
    
    const sequence = String(todayCount.count + 1).padStart(4, '0');
    const receipt_number = `OR-${dateStr}-${sequence}`;
    
    console.log('📝 Generated receipt number:', receipt_number);

    // Calculate totals
    let subtotal = 0;
    for (const item of items) {
      subtotal += item.quantity * item.unit_price;
    }
    const tax_amount = Math.round(subtotal * 0.1);
    const total_amount = subtotal + tax_amount;

    // Insert order receipt
    const result = db.prepare(`
      INSERT INTO order_receipts (
        receipt_number, customer_id, order_date, delivery_date, 
        status, subtotal, tax_amount, total_amount,
        payment_status, payment_date, notes, created_by
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      receipt_number,
      customer_id,
      order_date,
      delivery_date || null,
      status,
      subtotal,
      tax_amount,
      total_amount,
      payment_status,
      payment_date || null,
      notes || null,
      req.user?.id || 1
    );

    // Insert items
    const itemStmt = db.prepare(`
      INSERT INTO order_receipt_items (
        order_receipt_id, item_name, description, quantity, unit_price, tax_rate, amount
      )
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `);

    for (const item of items) {
      const amount = item.quantity * item.unit_price;
      itemStmt.run(
        result.lastInsertRowid,
        item.item_name,
        item.description || null,
        item.quantity,
        item.unit_price,
        item.tax_rate || 10.0,
        amount
      );
    }

    // Create journal entry if paid
    if (payment_status === 'paid' && payment_date) {
      const cashAccount = db.prepare("SELECT id FROM accounts WHERE account_code = '1000'").get();
      const revenueAccount = db.prepare("SELECT id FROM accounts WHERE account_code = '4000'").get();
      const customer = db.prepare('SELECT name FROM customers WHERE id = ?').get(customer_id);
      
      if (cashAccount && revenueAccount && customer) {
        db.prepare(`
          INSERT INTO journal_entries (
            entry_date, description, debit_account_id, credit_account_id, 
            amount, reference_type, reference_id, admin_id
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        `).run(
          payment_date,
          `${customer.name} 売上計上 (${receipt_number})`,
          cashAccount.id,
          revenueAccount.id,
          total_amount,
          'order_receipt',
          result.lastInsertRowid,
          req.user?.id || 1
        );
      }

      // Add to cash book
      const currentBalance = db.prepare(
        'SELECT balance FROM cash_book ORDER BY transaction_date DESC, created_at DESC LIMIT 1'
      ).get();
      const newBalance = (currentBalance?.balance || 0) + total_amount;

      db.prepare(`
        INSERT INTO cash_book (
          transaction_date, transaction_type, category, description, 
          amount, balance, reference_type, reference_id, created_by
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      `).run(
        payment_date,
        'income',
        '売上',
        `受注取引: ${receipt_number}`,
        total_amount,
        newBalance,
        'order_receipt',
        result.lastInsertRowid,
        req.user?.id || 1
      );
    }

    res.status(201).json({ 
      message: 'Order receipt created successfully',
      data: { 
        id: result.lastInsertRowid,
        receipt_number: receipt_number
      }
    });
  } catch (error) {
    console.error('Error creating order receipt:', error);
    if (error.message.includes('UNIQUE constraint failed')) {
      return res.status(400).json({ error: 'Receipt number already exists' });
    }
    res.status(500).json({ error: 'Failed to create order receipt' });
  }
});

// Update order receipt
router.put('/:id', (req, res) => {
  try {
    const db = req.app.get('db');
    const { 
      customer_id,
      order_date,
      delivery_date,
      status,
      payment_status,
      payment_date,
      notes,
      items = []
    } = req.body;

    // Check if receipt exists
    const existing = db.prepare('SELECT * FROM order_receipts WHERE id = ?').get(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Order receipt not found' });
    }

    // Calculate new totals
    let subtotal = 0;
    for (const item of items) {
      subtotal += item.quantity * item.unit_price;
    }
    const tax_amount = Math.round(subtotal * 0.1);
    const total_amount = subtotal + tax_amount;

    // Update order receipt
    db.prepare(`
      UPDATE order_receipts SET
        customer_id = ?,
        order_date = ?,
        delivery_date = ?,
        status = ?,
        subtotal = ?,
        tax_amount = ?,
        total_amount = ?,
        payment_status = ?,
        payment_date = ?,
        notes = ?,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `).run(
      customer_id,
      order_date,
      delivery_date || null,
      status,
      subtotal,
      tax_amount,
      total_amount,
      payment_status,
      payment_date || null,
      notes || null,
      req.params.id
    );

    // Delete existing items
    db.prepare('DELETE FROM order_receipt_items WHERE order_receipt_id = ?').run(req.params.id);

    // Insert new items
    const itemStmt = db.prepare(`
      INSERT INTO order_receipt_items (
        order_receipt_id, item_name, description, quantity, unit_price, tax_rate, amount
      )
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `);

    for (const item of items) {
      const amount = item.quantity * item.unit_price;
      itemStmt.run(
        req.params.id,
        item.item_name,
        item.description || null,
        item.quantity,
        item.unit_price,
        item.tax_rate || 10.0,
        amount
      );
    }

    // If payment status changed to paid, create journal entry
    if (payment_status === 'paid' && existing.payment_status !== 'paid' && payment_date) {
      const cashAccount = db.prepare("SELECT id FROM accounts WHERE account_code = '1000'").get();
      const revenueAccount = db.prepare("SELECT id FROM accounts WHERE account_code = '4000'").get();
      const customer = db.prepare('SELECT name FROM customers WHERE id = ?').get(customer_id);
      
      if (cashAccount && revenueAccount && customer) {
        db.prepare(`
          INSERT INTO journal_entries (
            entry_date, description, debit_account_id, credit_account_id, 
            amount, reference_type, reference_id, admin_id
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        `).run(
          payment_date,
          `${customer.name} 売上計上 (${existing.receipt_number})`,
          cashAccount.id,
          revenueAccount.id,
          total_amount,
          'order_receipt',
          req.params.id,
          req.user?.id || 1
        );
      }

      // Add to cash book
      const currentBalance = db.prepare(
        'SELECT balance FROM cash_book ORDER BY transaction_date DESC, created_at DESC LIMIT 1'
      ).get();
      const newBalance = (currentBalance?.balance || 0) + total_amount;

      db.prepare(`
        INSERT INTO cash_book (
          transaction_date, transaction_type, category, description, 
          amount, balance, reference_type, reference_id, created_by
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      `).run(
        payment_date,
        'income',
        '売上',
        `受注取引: ${existing.receipt_number}`,
        total_amount,
        newBalance,
        'order_receipt',
        req.params.id,
        req.user?.id || 1
      );
    }

    res.json({ message: 'Order receipt updated successfully' });
  } catch (error) {
    console.error('Error updating order receipt:', error);
    res.status(500).json({ error: 'Failed to update order receipt' });
  }
});

// Delete order receipt
router.delete('/:id', (req, res) => {
  try {
    const db = req.app.get('db');
    
    const existing = db.prepare('SELECT * FROM order_receipts WHERE id = ?').get(req.params.id);
    if (!existing) {
      return res.status(404).json({ error: 'Order receipt not found' });
    }

    db.prepare('DELETE FROM order_receipts WHERE id = ?').run(req.params.id);
    res.json({ message: 'Order receipt deleted successfully' });
  } catch (error) {
    console.error('Error deleting order receipt:', error);
    res.status(500).json({ error: 'Failed to delete order receipt' });
  }
});

// CSV upload
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

router.post('/upload', upload.single('file'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const db = req.app.get('db');
    const csvContent = req.file.buffer.toString('utf-8');
    
    // Parse CSV
    const records = parse(csvContent, {
      columns: true,
      skip_empty_lines: true,
      bom: true
    });

    let successCount = 0;
    let errorCount = 0;
    const errors = [];

    for (const record of records) {
      try {
        // Find customer by name
        const customer = db.prepare('SELECT id FROM customers WHERE name = ?').get(record.customer_name);
        if (!customer) {
          throw new Error(`Customer not found: ${record.customer_name}`);
        }

        const subtotal = parseFloat(record.subtotal) || 0;
        const tax_amount = Math.round(subtotal * 0.1);
        const total_amount = subtotal + tax_amount;

        // Insert order receipt
        const result = db.prepare(`
          INSERT INTO order_receipts (
            receipt_number, customer_id, order_date, delivery_date,
            status, subtotal, tax_amount, total_amount,
            payment_status, payment_date, notes, created_by
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `).run(
          record.receipt_number,
          customer.id,
          record.order_date,
          record.delivery_date || null,
          record.status || 'pending',
          subtotal,
          tax_amount,
          total_amount,
          record.payment_status || 'unpaid',
          record.payment_date || null,
          record.notes || null,
          req.user?.id || 1
        );

        successCount++;
      } catch (err) {
        errorCount++;
        errors.push({
          row: record.receipt_number || `行${successCount + errorCount}`,
          error: err.message
        });
      }
    }

    res.json({
      message: `Upload completed: ${successCount} success, ${errorCount} errors`,
      successCount,
      errorCount,
      errors: errorCount > 0 ? errors : undefined
    });
  } catch (error) {
    console.error('Error uploading order receipts:', error);
    res.status(500).json({ error: 'Failed to upload order receipts' });
  }
});

export default router;
