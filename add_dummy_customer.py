
import sqlite3
from datetime import datetime, timezone

db_path = 'C:/Users/LENOVO/OneDrive/Desktop/ritika/instance/site.db'

insert_customer_sql = """
INSERT OR IGNORE INTO customers (name, business_name, contact, email, address, credit_limit, tax_id, sales_rep_id, notes, organization_id, created_at)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
"""

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Get a sales_rep_id and organization_id from existing data or use defaults
    # Assuming 'Default Organization' has ID 1 and there's at least one user
    # You might need to adjust these IDs based on your actual database content
    organization_id = 1
    sales_rep_id = None # Assuming no sales rep initially, or fetch one if available

    # Try to find an existing user to be a sales rep
    cursor.execute("SELECT id FROM users LIMIT 1")
    user_row = cursor.fetchone()
    if user_row:
        sales_rep_id = user_row[0]

    dummy_customer_name = "Test Customer"
    dummy_business_name = "Test Business Inc."
    dummy_contact = "123-456-7890"
    dummy_email = "test@example.com"
    dummy_address = "123 Test St, Test City"
    dummy_credit_limit = 1000.00
    dummy_tax_id = "TAX123"
    dummy_notes = "Dummy customer for testing."
    current_utc_time = datetime.now(timezone.utc).isoformat()

    cursor.execute(insert_customer_sql, (
        dummy_customer_name, dummy_business_name, dummy_contact, dummy_email, dummy_address,
        dummy_credit_limit, dummy_tax_id, sales_rep_id, dummy_notes, organization_id, current_utc_time
    ))
    conn.commit()
    print(f"Inserted/Ignored dummy customer: {dummy_customer_name}")

except sqlite3.Error as e:
    print(f"Database error: {e}")
finally:
    if conn:
        conn.close()
