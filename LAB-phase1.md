---
marp: true
theme: default
paginate: true
header: 'Supply Chain Security Lab'
footer: 'Phase 1: Security Scanning'
style: |
  section {
    font-size: 20px;
  }
  h1 {
    font-size: 40px;
  }
  h2 {
    font-size: 30px;
  }
  code {
    font-size: 14px;
  }
  pre {
    font-size: 14px;
  }
---

# Supply Chain Security Lab
## Hands-On Exercises

**Learn by Building**
Secure your software supply chain from source to deployment

---

## Prerequisites

**Install Required Tools:**
```bash
# Install task runner
sudo snap install task --classic 2>&1 && task --version

# Verify all tools
task --version  # Should show v3.x.x
docker --version
git --version
```

---

# Phase 1: Security Scanning

**Learning Goals:**
- Detect vulnerabilities across 5 categories
- Practice remediation techniques
- Build foundation for SLSA Level 1

**📖 Theory Reference:** See CONCEPTS.md - Section 3: Security Scanning

---

# Exercise 1.1: Run Security Scans

**Your Task:** Run all security scans to discover intentional vulnerabilities

**Commands:**
```bash
task scan-all > logs/1.1-scan-all.log
```

---

# Exercise 1.1: Individual Scans

Run scans separately:
```bash
task scan-source > logs/1.1-source.log
task scan-deps > logs/1.1-deps.log
task scan-containers > logs/1.1-containers.log
task scan-iac > logs/1.1-iac.log
task scan-manifests > logs/1.1-manifests.log
```

---

# Exercise 1.1: Expected Results

**What you should see:**
- ❌ Source code: Hardcoded secrets, SQL injection
- ❌ Containers: Outdated base image, running as root
- ❌ IaC: Public S3 bucket, SSH from 0.0.0.0/0
- ❌ K8s: Privileged mode, running as root

**Questions to Consider:**
- Which vulnerabilities are most critical?
- What's the attack surface for each issue?
- How do these scans complement each other?

---

# Exercise 1.2: Fix Source Code Vulnerabilities
## Part 1/5

**File:** `src/app/main.py`

**Vulnerabilities Found:**
- Line 7: Hardcoded API key `sk-1234567890abcdef`
- Line 13: SQL injection via string formatting
- Line 19: API key exposed in health endpoint

---

# Exercise 1.2: Hints

**Fix #1 - Hardcoded Secret:**
- Use environment variable: `os.environ.get('API_KEY', 'default')`
- Remove secret from health endpoint response

**Fix #2 - SQL Injection:**
- Use parameterized query: `query = "SELECT * FROM users WHERE id = ?"`
- Pass parameters: `conn.execute(query, (user_id,))`

**Verify:** `task test`

---

# Exercise 1.2: Solution

**See full solution:** `lab-files/1.2-solution-main.py`

**Key changes:**
```python
# Use environment variable
API_KEY = os.environ.get('API_KEY', 'default-key-for-testing')

# Parameterized query
query = "SELECT * FROM users WHERE id = ?"
result = conn.execute(query, (user_id,)).fetchone()

# Don't expose secret
return {"status": "ok"}
```

---

# Exercise 1.3: Fix Container Vulnerabilities
## Part 2/5

**File:** `src/docker/Dockerfile`

**Vulnerabilities Found:**
- Line 2: Outdated base image `python:3.8`
- Line 7: Running as root (no USER directive)

---

# Exercise 1.3: Hints

**Fix #1 - Base Image:**
- Use recent slim image: `FROM python:3.12-slim`

**Fix #2 - Root User:**
- Create non-root user: `useradd -m -u 1000 appuser`
- Change ownership: `chown -R appuser:appuser /app`
- Switch user: `USER appuser`

**Verify:** `task scan-containers`

---

# Exercise 1.3: Solution

**See full solution:** `lab-files/1.3-solution-Dockerfile`

**Key changes:**
```dockerfile
FROM python:3.12-slim
# ... install commands ...
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser
```

---

# Exercise 1.4: Fix IaC Vulnerabilities
## Part 3/5

**File:** `src/iac/main.tf`

**Vulnerabilities Found:**
- Lines 8-11: Public S3 bucket (all 4 settings = false)
- Line 21: SSH accessible from anywhere (0.0.0.0/0)

---

# Exercise 1.4: Hints

**Fix #1 - S3 Bucket:**
- Set all 4 public access blocks to `true`

**Fix #2 - SSH Access:**
- Restrict CIDR block to specific IP range
- Example: `["203.0.113.0/24"]` or your organization's range

**Verify:** `task scan-iac`

---

# Exercise 1.4: Solution

**See full solution:** `lab-files/1.4-solution-main.tf`

**Key changes:**
```hcl
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

cidr_blocks = ["203.0.113.0/24"]  # Specific range
```

---

# Exercise 1.5: Fix K8s Vulnerabilities
## Part 4/5

**File:** `src/k8s/deployment.yaml`

**Vulnerabilities Found:**
- Line 21: `privileged: true` (dangerous!)
- Line 22: `runAsUser: 0` (running as root)

---

# Exercise 1.5: Hints

**Security Settings:**
- Set `privileged: false` 
- Add `runAsNonRoot: true` and `runAsUser: 1000`

**Additional:** Drop capabilities and prevent privilege escalation

**Verify:** `task scan-manifests`

---

# Exercise 1.5: Solution

**Full solution:** `lab-files/1.5-solution-deployment.yaml`

```yaml
securityContext:
  privileged: false
  runAsNonRoot: true
  runAsUser: 1000
```

---

# Exercise 1.6: Build Secure Application
## Part 5/5

**Your Task:** Build the now-secure application and container

**Commands:**
```bash
task build > logs/1.6-build.log
task build-image > logs/1.6-build-image.log
```

**Expected Output:**
- ✅ Application built successfully
- ✅ Container image created
- ✅ All security fixes applied

---

# Phase 1 Summary

**What You Accomplished:**
✅ Scanned 5 vulnerability categories  
✅ Fixed source code (secrets, injection)  
✅ Secured container (base image, user)  
✅ Hardened infrastructure (S3, SSH)  
✅ Locked down Kubernetes (privileges)

**Next: Phase 2 - Attestations & Provenance**

*📖 For defense-in-depth and SLSA concepts, see CONCEPTS.md Sections 1 & 4*

---

# Next: Phase 2
## Attestations & Provenance

**Coming Up:**
- Generate SLSA provenance
- Create SBOM attestations
- Wrap vulnerability reports
- Learn in-toto format

**Why This Matters:**
Scanning finds problems, but attestations **prove** you fixed them and **document** your secure build process.

---

# Checkpoint

**Before proceeding, verify:**
- [ ] All scans pass after your fixes
- [ ] `task test` passes
- [ ] Application builds successfully
- [ ] Container image builds successfully

**Questions?** Review the solution files in `lab-files/`

**Ready?** Move to Phase 2 when checkpoint complete
