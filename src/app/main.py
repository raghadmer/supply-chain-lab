from flask import Flask, request
import sqlite3

app = Flask(__name__)

# Hardcoded secret (vulnerability #1 - Source Code)
API_KEY = "sk-1234567890abcdef"

@app.route('/user/<user_id>')
def get_user(user_id):
    # SQL Injection (vulnerability #2 - Source Code)
    conn = sqlite3.connect('app.db')
    query = f"SELECT * FROM users WHERE id = {user_id}"
    result = conn.execute(query).fetchone()
    return str(result)

@app.route('/health')
def health_check():
    return {"status": "ok", "api_key": API_KEY}

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')