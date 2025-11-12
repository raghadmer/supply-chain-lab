from flask import Flask, request
import sqlite3
import os

app = Flask(__name__)

# Fixed: Use environment variable for secret (vulnerability #1 - FIXED)
API_KEY = os.environ.get('API_KEY', 'default-key-for-testing')

@app.route('/user/<user_id>')
def get_user(user_id):
    # Fixed: Use parameterized query (vulnerability #2 - FIXED)
    conn = sqlite3.connect('app.db')
    query = "SELECT * FROM users WHERE id = ?"
    result = conn.execute(query, (user_id,)).fetchone()
    return str(result)

@app.route('/health')
def health_check():
    return {"status": "ok"}

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')
