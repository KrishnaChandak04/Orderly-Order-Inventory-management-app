
import sqlite3

db_path = 'C:/Users/LENOVO/OneDrive/Desktop/ritika/instance/site.db'

create_table_sql = """
CREATE TABLE IF NOT EXISTS organizations (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME
);
"""

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(create_table_sql)
    conn.commit()
    print("'organizations' table created successfully (if it didn't exist).")
except sqlite3.Error as e:
    print(f"Database error: {e}")
finally:
    if conn:
        conn.close()
