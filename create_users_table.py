
import sqlite3

db_path = 'C:/Users/LENOVO/OneDrive/Desktop/ritika/instance/site.db'

create_table_sql = """
CREATE TABLE IF NOT EXISTS users (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(150) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(200) NOT NULL,
    is_active BOOLEAN DEFAULT 1,
    last_login DATETIME,
    created_at DATETIME,
    phone VARCHAR(20),
    api_token VARCHAR(255) UNIQUE,
    organization_id INTEGER,
    FOREIGN KEY(organization_id) REFERENCES organizations (id)
);
"""

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(create_table_sql)
    conn.commit()
    print("'users' table created successfully (if it didn't exist).")
except sqlite3.Error as e:
    print(f"Database error: {e}")
finally:
    if conn:
        conn.close()
