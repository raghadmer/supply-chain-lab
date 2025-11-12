---
marp: true
theme: default
paginate: true
header: 'Supply Chain Security Lab'
footer: 'Phase 2: Attestations & Provenance'
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

# Phase 2: Attestations & Provenance

**Learning Goals:**
- Generate SLSA provenance attestations
- Create SBOM attestations in in-toto format
- Generate vulnerability attestations
- Understand attestation structure

**Prerequisites:**
- Phase 1 completed
- All vulnerabilities fixed
- Docker image built

**📖 Theory Reference:** See CONCEPTS.md - Sections 4 (SLSA) & 5 (in-toto Attestations)

---

# Exercise 2.1: Generate SLSA Provenance

**Generate Provenance:**
```bash
./scripts/generate-provenance.sh supply-chain-app:latest > attestations/provenance.json
```

**What It Captures:** Builder identity, Git commit SHA, build timestamps, materials

---

# Exercise 2.1: Review Provenance

**Inspect the Generated Attestation:**
```bash
# View the full attestation
cat attestations/provenance.json | jq

# Check builder identity
jq '.predicate.builder.id' attestations/provenance.json

# Check git commit
jq '.predicate.materials[0].uri' attestations/provenance.json
jq '.predicate.materials[0].digest.sha1' attestations/provenance.json
```

---

# Exercise 2.1: Review Provenance (Continued)

```bash
# Check timestamps
jq '.predicate.metadata.buildStartedOn' attestations/provenance.json
jq '.predicate.metadata.buildFinishedOn' attestations/provenance.json
```

**Expected:** You should see your VM hostname, git commit SHA, and build timestamps

---

# Exercise 2.1: Validate Provenance

**Run Validation:**
```bash
task validate:provenance
```

**What It Checks:**
- ✅ Valid JSON syntax
- ✅ Correct in-toto Statement structure
- ✅ PredicateType = `https://slsa.dev/provenance/v0.2`

---

# Exercise 2.1: Validate (Continued)

- ✅ Required fields: builder.id, timestamps, materials
- ✅ Subject contains image name and digest

**Expected Output:**
```
✅ SLSA provenance attestation is valid
   Builder: student@vm-hostname
   Materials: 1
   Subject: supply-chain-app:latest
```

---

# Exercise 2.2: Generate SBOM Attestation

**Generate SBOM Attestation:**
```bash
./scripts/generate-sbom-attestation.sh supply-chain-app:latest > attestations/sbom.json
```

**Note:** Large file (~2MB) with all package details. Syft generates SPDX format, wrapped in in-toto Statement.

---

# Exercise 2.2: Review SBOM

**Inspect the SBOM Attestation:**
```bash
# View SBOM structure (too large to view entirely)
jq 'keys' attestations/sbom.json

# Check SPDX version
jq '.predicate.spdxVersion' attestations/sbom.json

# Count packages
jq '.predicate.packages | length' attestations/sbom.json
```

---

# Exercise 2.2: Review SBOM (Continued)

```bash
# View first 3 packages
jq '.predicate.packages[0:3] | .[] | {name, versionInfo}' attestations/sbom.json
```

**Expected:** ~100+ packages (Python, system libs, dependencies)

---

# Exercise 2.2: Validate SBOM

**Run Validation:**
```bash
task validate:sbom
```

**What It Checks:**
- ✅ Valid JSON syntax
- ✅ Correct in-toto Statement structure
- ✅ PredicateType = `https://spdx.dev/Document`

---

# Exercise 2.2: Validate (Continued)

- ✅ Valid SPDX document with packages
- ✅ Subject matches image name

**Expected Output:**
```
✅ SBOM attestation is valid
   SPDX Version: SPDX-2.3
   Packages: 124
   Subject: supply-chain-app:latest
```

---

# Exercise 2.3: Generate Vulnerability Attestations

**Three Scan Targets:**
- **Source code & dependencies** - Python vulns
- **IaC (Terraform)** - Misconfigurations
- **Container image** - OS & app vulns

**Tool:** Trivy with `--format cosign-vuln` (outputs in-toto Statement format)

*📖 For vulnerability scanning concepts, see CONCEPTS.md Section 3*

---

# Exercise 2.3a: Source Vulnerability Attestation

**Scan Source Code & Dependencies:**
```bash
# Generate source vulnerability attestation
./scripts/generate-vuln-attestation.sh fs src/ > attestations/vuln-source.json

# Validate
task validate:vuln-source
```

**Expected Result:** Zero vulnerabilities (Phase 1 fixes applied!)

---

# Exercise 2.3b: IaC Vulnerability Attestation

**Scan Infrastructure as Code:**
```bash
# Generate IaC vulnerability attestation
./scripts/generate-vuln-attestation.sh config src/iac/ > attestations/vuln-iac.json

# Validate
task validate:vuln-iac
```

**Expected Result:** Zero misconfigurations (Phase 1 fixes applied)

---

# Exercise 2.3c: Container Image Attestation

**Scan Container Image:**
```bash
./scripts/generate-vuln-attestation.sh image supply-chain-app:latest > attestations/vuln-image.json

task validate:vuln-image
```

**Expected Result:** Zero vulnerabilities (Phase 1 fixes applied)

---

# Exercise 2.3: Review All Vulnerability Attestations

**List All Attestations:**
```bash
ls -lh attestations/vuln-*.json
```

**Inspect One Attestation Structure:**
```bash
# View scanner information
jq '.predicate.scanner' attestations/vuln-source.json

# View scan metadata
jq '.predicate.metadata' attestations/vuln-source.json
```

---

# Exercise 2.3: Review (Continued)

```bash
# Check vulnerability count (should be empty arrays)
jq '.predicate.scanner.result.Results[].Vulnerabilities // []' attestations/vuln-source.json
```

**Key Observation:** All scans show zero issues because you fixed them in Phase 1!

*📖 Note: Trivy's `--format cosign-vuln` outputs standard in-toto Statement + CosignVulnerabilityReport predicate, compatible with Sigstore/Cosign toolchain.*

---

# Exercise 2.4: Review All Attestations

**List Everything You've Generated:**
```bash
ls -lh attestations/
```

**You Should Have:**
- `provenance.json` - Build provenance (SLSA)
- `sbom.json` - Software Bill of Materials (SPDX)
- `vuln-source.json` - Source code scan results
- `vuln-iac.json` - Infrastructure scan results
- `vuln-image.json` - Container image scan results

---

# Exercise 2.4: Review (Continued)

**Total:** 5 attestations documenting your secure build process

---

# Exercise 2.4: Validate All Attestations

**Run Complete Validation:**
```bash
task validate:all-attestations
```

---

# Exercise 2.4: Validation Output

**Expected Output:**
```
✅ SLSA provenance attestation is valid
✅ SBOM attestation is valid
✅ Source vulnerability attestation is valid
✅ Iac vulnerability attestation is valid
✅ Image vulnerability attestation is valid
All attestations validated successfully!
```

*📖 For attestation structure details, see CONCEPTS.md Section 5: in-toto Attestations*

---

# Phase 2 Summary

**What You Accomplished:**
- Generated SLSA provenance (build metadata)
- Created SBOM attestation (component inventory)
- Generated 3 vulnerability attestations (scan results)
- Validated all attestation structures
- Understood in-toto Statement format

---

# Phase 2 Summary (Continued)

**Current State:**
- Phase 1: Vulnerabilities fixed ✅
- Phase 2: Attestations generated ✅
- Next: Sign these attestations (Phase 3)

**Why This Matters:** Attestations provide verifiable proof for CI/CD gates, compliance, supply chain attack detection, and license compliance.

*📖 See CONCEPTS.md Sections 4 & 5*

---

# Checkpoint

**Before proceeding to Phase 3, verify:**
- [ ] All 5 attestations generated in `attestations/`
- [ ] `task validate:all-attestations` passes
- [ ] You understand in-toto Statement structure
- [ ] You can explain what each attestation type contains

**Questions?** Review example files in `lab-files/2.*`

**Ready?** Move to Phase 3: Signing with Keyless Authentication
