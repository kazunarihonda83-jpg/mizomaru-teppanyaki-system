import Database from 'better-sqlite3';
import path from 'path';

const dbPath = path.join(process.cwd(), 'menya-nishiki-order.db');
console.log('Database path:', dbPath);

try {
  const db = new Database(dbPath);
  console.log('\n=== 顧客一覧 ===');
  const customers = db.prepare('SELECT id, name, customer_type FROM customers ORDER BY id').all();
  console.log(customers);
  db.close();
} catch (error) {
  console.error('Error:', error.message);
}
