
import sqlite3

db_path = 'C:/Users/LENOVO/OneDrive/Desktop/ritika/instance/site.db'

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT id, name FROM organization")
    organizations = cursor.fetchall()
    if organizations:
        print("Organizations found:")
        for org_id, org_name in organizations:
            print(f"ID: {org_id}, Name: {org_name}")
    else:
        print("No organizations found in the database.")
except sqlite3.Error as e:
    print(f"Database error: {e}")
finally:
    if conn:
        conn.close()
