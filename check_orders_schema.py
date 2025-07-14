import sqlite3

db_path = 'C:/Users/LENOVO/OneDrive/Desktop/ritika/site.db'

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("PRAGMA table_info(orders)")
    columns = cursor.fetchall()
    if columns:
        print("Columns in 'orders' table:")
        for col in columns:
            print(f"  Name: {col[1]}, Type: {col[2]}, NotNull: {col[3]}, PrimaryKey: {col[5]}")
    else:
        print("'orders' table not found or has no columns.")
except sqlite3.Error as e:
    print(f"Database error: {e}")
finally:
    if conn:
        conn.close()
