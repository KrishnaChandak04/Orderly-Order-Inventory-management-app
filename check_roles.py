import sqlite3

db_path = 'C:/Users/LENOVO/OneDrive/Desktop/ritika/site.db'

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT id, name FROM roles")
    roles = cursor.fetchall()
    if roles:
        print("Roles found:")
        for role_id, role_name in roles:
            print(f"ID: {role_id}, Name: {role_name}")
    else:
        print("No roles found in the database.")
except sqlite3.Error as e:
    print(f"Database error: {e}")
finally:
    if conn:
        conn.close()