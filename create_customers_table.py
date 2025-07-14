
import sqlite3

db_path = 'C:/Users/LENOVO/OneDrive/Desktop/ritika/instance/site.db'

create_table_sql = """
CREATE TABLE IF NOT EXISTS customers (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    business_name VARCHAR(100),
    contact VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    credit_limit FLOAT DEFAULT 0.0,
    current_balance FLOAT DEFAULT 0.0,
    tax_id VARCHAR(50),
    sales_rep_id INTEGER,
    organization_id INTEGER,
    created_at DATETIME,
    notes TEXT,
    FOREIGN KEY(sales_rep_id) REFERENCES users (id),
    FOREIGN KEY(organization_id) REFERENCES organizations (id)
);
"""

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(create_table_sql)
    conn.commit()
    print("'customers' table created successfully (if it didn't exist).")
except sqlite3.Error as e:
    print(f"Database error: {e}")
finally:
    if conn:
        conn.close()
