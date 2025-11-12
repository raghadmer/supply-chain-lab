def test_no_hardcoded_secrets():
    """Test fails due to hardcoded API key in source code"""
    with open('main.py', 'r') as f:
        content = f.read()
    assert 'sk-' not in content, "Hardcoded API key found - move to environment variable"

def test_no_sql_injection():
    """Test fails due to SQL injection vulnerability"""
    with open('main.py', 'r') as f:
        content = f.read()
    assert 'f"SELECT' not in content, "SQL injection vulnerability found - use parameterized queries"