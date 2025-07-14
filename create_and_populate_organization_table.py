
import sqlite3
from datetime import datetime, timezone

db_path = 'C:/Users/LENOVO/OneDrive/Desktop/ritika/instance/site.db'

create_table_sql = """
CREATE TABLE IF NOT EXISTS organizations (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME
);
"""

insert_dummy_org_sql = """
INSERT OR IGNORE INTO organizations (name, created_at) VALUES (?, ?);
"""

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Create table
    cursor.execute(create_table_sql)
    print("'organizations' table created successfully (if it didn't exist).")

    # Insert dummy organization
    dummy_org_name = "Default Organization"
    current_utc_time = datetime.now(timezone.utc).isoformat()
    cursor.execute(insert_dummy_org_sql, (dummy_org_name, current_utc_time))
    conn.commit()
    print(f"Inserted/Ignored dummy organization: {dummy_org_name}")

    # Verify insertion
    cursor.execute("SELECT id, name FROM organizations")
    organizations = cursor.fetchall()
    if organizations:
        print("Organizations found after insertion:")
        for org_id, org_name in organizations:
            print(f"ID: {org_id}, Name: {org_name}")
    else:
        print("No organizations found after insertion.")

except sqlite3.Error as e:
    print(f"Database error: {e}")
finally:
    if conn:
        conn.close()
