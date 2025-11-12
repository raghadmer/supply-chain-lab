# Supply Chain Security Concepts

## Overview

This document provides the theoretical foundation for understanding supply chain security in software development. It covers the complete lifecycle from secure source code management to verified artifact distribution.

**Purpose**: Learn the concepts and standards behind modern supply chain security before implementing them in the hands-on lab.

**Related Documents**:
- [LAB.md](LAB.md) - Hands-on exercises and implementation guide
- [INSTRUCTIONS.md](INSTRUCTIONS.md) - Quick start and overview
- [CNCF Security Whitepaper](cncf_security_whitepaper.md) - Industry reference

---

## 1. End-to-End Supply Chain Security Framework

### The Supply Chain Security Model

Modern software supply chains consist of multiple stages, each requiring specific security controls:

```
┌─────────────┐    ┌──────────┐    ┌─────────┐    ┌─────────┐    ┌──────────────┐
│  Developer  │───▶│  Source  │───▶│  Build  │───▶│  CI/CD  │───▶│ Distribution │
│   Identity  │    │  Control │    │ Process │    │ Pipeline│    │  & Delivery  │
└─────────────┘    └──────────┘    └─────────┘    └─────────┘    └──────────────┘
      │                  │              │               │                 │
      ▼                  ▼              ▼               ▼                 ▼
   MFA + SSH       Scans + SBOM   SLSA Provenance  Secure Runners  Signed Artifacts
   Signed Commits  Code Review    Attestations     OIDC Identity   Verification
```

### What is Supply Chain Security?

Supply chain security ensures that software artifacts can be **trusted** throughout their lifecycle. This involves:

- **Authenticity**: Verifying who created the software
- **Integrity**: Ensuring the software wasn't tampered with
- **Traceability**: Tracking the complete build process
- **Transparency**: Making security evidence publicly auditable

### Why Supply Chain Security Matters

Modern software development involves numerous stages and dependencies, each presenting potential attack vectors:

- **Source Code Attacks**: Malicious commits, compromised developer accounts
- **Build Process Attacks**: Tampering during compilation, malicious build scripts
- **Dependency Attacks**: Compromised libraries, typosquatting
- **Distribution Attacks**: Registry compromises, artifact substitution

**Real-World Example**: The SolarWinds breach (2020) compromised the build pipeline, affecting 18,000+ organizations. Supply chain security practices could have detected and prevented this attack.

### Defense in Depth

Supply chain security applies multiple security layers:

1. **Developer Phase**: Authentication, signed commits, code review
2. **Source Phase**: Vulnerability scanning, dependency analysis
3. **Build Phase**: Provenance generation, isolated build environments
4. **Distribution Phase**: Artifact signing, transparency logging
5. **Verification Phase**: Signature validation, policy enforcement

### CNCF Security Model Reference

The Cloud Native Computing Foundation (CNCF) Security Whitepaper defines this lifecycle in detail:

- **Develop Phase**: Security checks, code review, testing ([cncf_security_whitepaper.md](cncf_security_whitepaper.md))
- **Distribute Phase**: Build pipeline security, image scanning, signing
- **Deploy Phase**: Runtime security, admission control, policy enforcement
- **Runtime Phase**: Container security, network policies, monitoring

**This lab focuses on the Develop and Distribute phases**.

---

## 2. Secure Source: Developer Phase

### SSH Authentication vs HTTPS

**SSH (Secure Shell)** uses public-key cryptography for authentication:

- **Key-based Authentication**: No passwords transmitted over the network
- **Public Key Infrastructure (PKI)**: Cryptographic identity verification
- **Forward Secrecy**: Each session uses unique encryption keys
- **Tamper Protection**: Cryptographic integrity checks

**HTTPS with Tokens**:
- **Token-based**: Personal access tokens or OAuth tokens
- **Simpler Setup**: No key generation required
- **Time-Limited**: Tokens can expire
- **Revocable**: Can be revoked without changing passwords

**Recommendation**: Use SSH for stronger cryptographic authentication and non-repudiation.

### Signed Commits

Signed commits cryptographically prove **who** created each change and **when**:

**Traditional Approaches**:
- **GPG (GNU Privacy Guard)**: Long-lived keypairs, manual key management
- **S/MIME**: Certificate-based, requires PKI infrastructure
- **SSH Keys**: Reuses SSH authentication keys for signing

**Challenges**:
- Key generation and secure storage
- Key distribution and verification
- Key rotation and expiration management
- Lost keys mean lost ability to sign

### Keyless Signing with gitsign

**gitsign** uses the Sigstore ecosystem for keyless commit signing:

**How it Works**:
1. **OIDC Authentication**: Log in with existing identity provider (GitHub, Google, Microsoft)
2. **Certificate Issuance**: Fulcio issues a short-lived X.509 certificate (10 minutes)
3. **Commit Signing**: Certificate signs the commit
4. **Transparency Logging**: Rekor records the signing event
5. **Verification**: Certificate is verified via transparency log

**Benefits**:
- **No Key Management**: No keys to generate, store, or rotate
- **Real Identity**: Uses authenticated email addresses
- **Transparency**: All signatures publicly auditable
- **Short-Lived Credentials**: Certificates expire automatically

**Important Note**: GitHub's UI shows gitsign signatures as "Unverified" because Fulcio's CA is not in GitHub's trust store. However, GitHub branch protection **does accept** gitsign signatures. Verification is performed using `gitsign verify` or in CI/CD pipelines.

### Why Signed Commits Matter

- **Non-repudiation**: Cryptographic proof of authorship
- **Tamper Detection**: Any modification breaks the signature
- **Audit Trail**: Complete history of who changed what
- **Compliance**: Meets regulatory requirements for code provenance

---

## 3. Security Scanning: Source Phase

### Purpose of Security Scanning

Security scanning identifies vulnerabilities **before** they reach production:

- **Source Code Scanning (SAST)**: Static Application Security Testing (SAST) analyzes code for security issues
- **Dependency Scanning (SCA)**: Software Composition Analysis (SCA) checks libraries for known vulnerabilities
- **Container Image Scanning**: Examines base image, OS packages and application dependencies
- **Configuration Scanning**: Validates security settings

### Defense in Depth Approach

Scanning alone is **not sufficient**. It must be combined with:

1. **Secure Development**: Following secure coding practices
2. **Code Review**: Human verification of changes
3. **Testing**: Security test cases and penetration testing
4. **Build Security**: Secure build environments and provenance
5. **Runtime Protection**: Continuous monitoring and policies

### Scanning Tools in This Lab

- **Trivy**: Container and filesystem vulnerability scanner
- **Semgrep**: Static analysis for code patterns
- **Syft**: Software Bill of Materials (SBOM) generation

### Limitations of Scanning

- **Zero-Day Vulnerabilities**: Unknown vulnerabilities aren't detected
- **False Positives**: Not all findings are exploitable
- **Configuration Context**: Scanners don't understand deployment context
- **Supply Chain Attacks**: Scanning doesn't verify artifact integrity

**This is why attestations and signing are critical**.

---

## 4. SLSA Framework: Build Phase

### What is SLSA?

**SLSA (Supply-chain Levels for Software Artifacts)** is a security framework developed by Google and the OpenSSF (Open Source Security Foundation).

**Pronunciation**: "salsa" (like the dance or condiment)

**Purpose**: Provide a common vocabulary and checklist for supply chain security, with increasing levels of maturity.

**Official Specification**: https://slsa.dev

### SLSA Levels (0-4)

SLSA defines **five levels** of supply chain maturity:

#### Level 0: No Guarantees
- **Status**: No supply chain security measures
- **Risk**: Vulnerable to all attack vectors
- **Example**: Manual builds, no documentation

#### Level 1: Build Process Documentation
- **Requirements**:
  - Build process is documented
  - Provenance is generated (even if not verified)
- **Protection**: Basic build transparency
- **Example**: Automated builds with basic metadata

#### Level 2: Tamper Resistance
- **Requirements**:
  - Builds are automated
  - Provenance is signed and non-falsifiable
  - Build service generates provenance (not the build script)
- **Protection**: Provenance can't be forged or tampered with
- **Example**: CI/CD pipeline with signed attestations
- **🎯 This lab achieves Level 2**

#### Level 3: Hardened Builds
- **Requirements**:
  - All Level 2 requirements
  - Source and build platform are auditable
  - Provenance includes complete dependency information
- **Protection**: Prevents attacks on the build platform
- **Example**: Isolated build environments, hermetic builds

#### Level 4: Two-Party Review
- **Requirements**:
  - All Level 3 requirements
  - All changes require two-person approval
  - Changes to dependencies are reviewed
- **Protection**: Prevents single compromised developer from backdooring code
- **Example**: Branch protection with required reviews, signed commits enforced

### SLSA Provenance

**Provenance** is attestation metadata that describes how an artifact was built:

**Key Information**:
- **Builder Identity**: Who/what performed the build
- **Source Repository**: Where the code came from
- **Build Invocation**: Commands and parameters used
- **Build Materials**: Dependencies and base images
- **Timestamps**: When the build occurred
- **Environment**: Build platform details

**Predicate Type**: `https://slsa.dev/provenance/v0.2` or `v1.0`

**Example Structure**:
```json
{
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [{"name": "myapp", "digest": {"sha256": "abc123..."}}],
  "predicate": {
    "builder": {"id": "github-actions"},
    "buildType": "docker",
    "invocation": {
      "configSource": {
        "uri": "git+https://github.com/user/repo",
        "digest": {"sha1": "def456..."}
      }
    },
    "metadata": {
      "buildStartedOn": "2025-11-12T10:00:00Z",
      "buildFinishedOn": "2025-11-12T10:05:00Z"
    },
    "materials": [...]
  }
}
```

### Why SLSA Matters

- **Industry Standard**: Adopted by Google, GitHub, Linux Foundation
- **Measurable Security**: Clear progression from Level 0 to Level 4
- **Supply Chain Transparency**: Build process becomes auditable
- **Attack Prevention**: Each level closes specific attack vectors

---

## 5. in-toto Attestations

### Attestation vs Signature

**Signature**: Cryptographic proof that someone signed something
- **What**: Verifies integrity and authenticity
- **Limited Information**: Only proves "who signed"

**Attestation**: Signed statement about an artifact with metadata
- **What**: Signature + structured evidence
- **Rich Information**: Describes **what** was attested to and **why**
- **Multiple Types**: Different attestation formats for different evidence

**Analogy**: A signature on a blank paper vs. a notarized document with complete details.

### The in-toto Framework

**in-toto** is a framework for securing the integrity of software supply chains:

**Official Specification**: https://in-toto.io

**Key Concepts**:
- **Layout**: Defines the expected supply chain steps
- **Links**: Records what happened in each step
- **Attestations**: Signed statements about artifacts
- **Verification**: Validates the complete supply chain

### in-toto Attestation Format

**Standard Structure**:
```json
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "subject": [
    {
      "name": "artifact-name",
      "digest": {"sha256": "abc123..."}
    }
  ],
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "predicate": {
    ...predicate-specific content...
  }
}
```

**Components**:
- **Statement**: Wrapper format (always the same)
- **Subject**: What artifact this attestation describes
- **Predicate Type**: What kind of attestation this is
- **Predicate**: The actual attestation content

### Predicate Types

Different predicate types capture different kinds of evidence:

1. **SLSA Provenance** (`https://slsa.dev/provenance/v0.2`)
   - Build metadata and dependencies
   - Builder identity and environment

2. **SPDX SBOM** (`https://spdx.dev/Document`)
   - Complete software bill of materials
   - License and dependency information

3. **Vulnerability Report** (`https://cosign.sigstore.dev/attestation/vuln/v1`)
   - Security scan results
   - Known vulnerabilities and severity

4. **Test Results**, **Code Review**, **Custom Attestations**
   - Additional evidence types as needed

### Why Multiple Attestations?

Each attestation type provides **different security evidence**:

- **Provenance**: Answers "How was this built?"
- **SBOM**: Answers "What's inside this artifact?"
- **Vulnerability Report**: Answers "Is this artifact safe?"

**Together**, they provide comprehensive supply chain security evidence.

### Attestation Signing

Attestations must be signed to be trustworthy:

- **Unsigned**: Just metadata (can be forged)
- **Signed**: Cryptographic proof of authenticity

**Signing Methods**:
- Traditional keypairs (GPG, RSA)
- Keyless signing (Sigstore/Fulcio)

---

## 6. Sigstore Toolchain

### What is Sigstore?

**Sigstore** is an open-source project providing keyless signing infrastructure for software artifacts.

**Official Website**: https://sigstore.dev

**Purpose**: Make signing and verification **easy** and **accessible** without managing cryptographic keys.

### Sigstore Architecture

```
┌──────────────┐
│   Developer  │
│  (cosign)    │
└──────┬───────┘
       │ 1. Sign Request
       ▼
┌──────────────┐     ┌──────────────┐
│ OIDC Provider│◀────│  Browser     │
│ (GitHub)     │     │  Auth Flow   │
└──────┬───────┘     └──────────────┘
       │ 2. ID Token
       ▼
┌──────────────┐
│   Fulcio CA  │
│ (Certificate)│
└──────┬───────┘
       │ 3. Short-lived Certificate
       ▼
┌──────────────┐
│   Developer  │───── 4. Sign Artifact ────▶ ┌──────────────┐
│  (cosign)    │                              │   Registry   │
└──────┬───────┘                              └──────────────┘
       │ 5. Upload Signature + Certificate
       ▼
┌──────────────┐
│  Rekor Log   │
│ (Transparency)│
└──────────────┘
```

### Cosign: Signing and Verification Tool

**Cosign** is the CLI tool for signing and verifying container images and other artifacts.

**Key Features**:
- Sign container images
- Attach attestations to artifacts
- Verify signatures and attestations
- Supports multiple key types (keyless, KMS, local keys)

**Common Commands**:
```bash
cosign sign <image>
cosign verify <image>
cosign attest --predicate <file> <image>
cosign verify-attestation --type <type> <image>
```

**OCI Artifact Storage**: Signatures and attestations are stored as OCI artifacts alongside the container image in the registry.

### Fulcio: Keyless Certificate Authority

**Fulcio** issues short-lived code-signing certificates based on OIDC identity.

**How It Works**:
1. **Authentication**: User authenticates with OIDC provider (GitHub, Google, etc.)
2. **Token Validation**: Fulcio validates the OIDC ID token
3. **Certificate Issuance**: Fulcio issues X.509 certificate binding identity to public key
4. **Short-Lived**: Certificates expire in ~10 minutes
5. **Identity Binding**: Certificate contains email and OIDC issuer

**Certificate Properties**:
- **Subject Alternative Name (SAN)**: Contains email address
- **Custom OID**: Contains OIDC issuer URL
- **Code Signing**: Extended key usage set to code signing
- **Public Key**: ECDSA P-256 key from ephemeral keypair

**Why Short-Lived?**
- No need for revocation lists
- Reduces impact of compromised credentials
- Encourages just-in-time authentication

### Rekor: Transparency Log

**Rekor** is an immutable, append-only transparency log for signed artifacts.

**Purpose**: Provide non-repudiable evidence of signing events.

**How It Works**:
1. Signing event occurs (image signed, attestation attached)
2. Certificate and signature uploaded to Rekor
3. Rekor creates cryptographically verifiable log entry
4. Entry is globally searchable and auditable

**Entry Types**:
- **Public Key Entries**: Just the public key
- **Certificate Entries**: Full X.509 certificate with identity
- **Multiple Entries**: Same signing event may have multiple entry types

**Searching Rekor**:
```bash
rekor-cli search --sha <image-digest>
rekor-cli get --uuid <entry-uuid>
```

**Why Transparency Logs?**
- **Audit Trail**: Complete history of signing events
- **Offline Verification**: Can verify signatures without CA online
- **Tamper Evidence**: Any modification to log is detectable
- **Non-Repudiation**: Cannot deny signing event occurred

### The Keyless Signing Workflow

**Complete Flow**:

1. **Developer initiates signing**
   ```bash
   cosign sign --yes <image>
   ```

2. **OIDC Authentication**
   - Browser opens to OAuth provider
   - User authenticates with GitHub/Google/etc.
   - OIDC token issued with verified identity

3. **Certificate Request**
   - Cosign generates ephemeral ECDSA keypair
   - Sends public key + OIDC token to Fulcio
   - Fulcio validates token and issues certificate

4. **Artifact Signing**
   - Cosign signs artifact with private key
   - Signature and certificate uploaded to registry
   - Signature also logged in Rekor

5. **Transparency Logging**
   - Rekor records signing event
   - Creates searchable, immutable entry
   - Entry includes full certificate with identity

6. **Verification**
   - Verifier retrieves signature and certificate
   - Validates certificate chain to Fulcio root
   - Checks Rekor for matching entry
   - Verifies signature matches artifact

**Key Advantage**: No long-lived keys to manage, compromise, or lose.

---

## 7. Verification & Transparency

### Two Approaches to Verification

Modern supply chain security uses **two complementary verification methods**:

#### Manual Exploration (Transparency)

**Purpose**: Human-readable investigation of signing events

**Methods**:
- **Rekor Search**: Find all entries for an artifact
- **Certificate Extraction**: Retrieve and decode X.509 certificates
- **Identity Inspection**: View signer's email and OIDC issuer
- **Attestation Decoding**: Read attestation contents

**Benefits**:
- Educational: Understand what's happening
- Debugging: Investigate signing issues
- Audit: Manual review of signing events

**Tools**:
```bash
rekor-cli search --sha <digest>
rekor-cli get --uuid <entry-uuid> --format json
echo "<base64>" | base64 -d | openssl x509 -text
cosign verify-attestation <image> | jq .
```

#### Automated Verification (Cryptographic)

**Purpose**: Programmatic validation of signatures and policies

**Methods**:
- **Signature Verification**: Validate cryptographic signatures
- **Certificate Validation**: Check certificate chain and expiration
- **Policy Enforcement**: Ensure specific identities signed
- **Attestation Validation**: Verify attestation types present

**Benefits**:
- **Automation**: Can be integrated into CI/CD
- **Policy Enforcement**: Reject artifacts that don't meet requirements
- **Speed**: Fast cryptographic validation

**Tools**:
```bash
cosign verify \
  --certificate-identity=<email> \
  --certificate-oidc-issuer=<issuer> \
  <image>

cosign verify-attestation \
  --type <predicate-type> \
  --certificate-identity=<email> \
  --certificate-oidc-issuer=<issuer> \
  <image>
```

### The Trust Model

**Root of Trust**:
- **Fulcio Root CA**: Published root certificate
- **Rekor Public Key**: Published transparency log key
- **OIDC Providers**: GitHub, Google, Microsoft, etc.

**Trust Chain**:
1. Trust OIDC provider to authenticate users correctly
2. Trust Fulcio to issue certificates only for validated identities
3. Trust Rekor to immutably log all signing events
4. Trust the cryptographic verification process

**Verification Process**:
1. Retrieve signature and certificate from registry/Rekor
2. Validate certificate chain to Fulcio root
3. Check certificate not expired at signing time (via Rekor timestamp)
4. Verify signature matches artifact using public key from certificate
5. Validate identity matches expected policy

### Transparency Benefits

**Public Auditability**:
- Anyone can search Rekor for an artifact
- Complete signing history is public
- Detects unauthorized signing attempts

**Offline Verification**:
- Don't need Fulcio CA online to verify
- Rekor provides the certificate
- Only need Rekor and registry access

**Non-Repudiation**:
- Cannot deny signing an artifact
- Cryptographic proof + timestamp
- Identity bound to signing event

---

## 8. CI/CD Automation

### GitHub OIDC

**GitHub Actions** provides workload identity through OIDC:

**How It Works**:
1. GitHub Actions generates OIDC token for workflow
2. Token contains workflow identity (repo, ref, trigger)
3. Fulcio validates token and issues certificate
4. Certificate contains **<workflow identity**, not human identity

**Configuration**:
```yaml
permissions:
  id-token: write
  contents: read
```

**Identity in Certificate**:
- **Subject**: Workflow path (e.g., `repo:org/repo:ref:refs/heads/main`)
- **OIDC Issuer**: `https://token.actions.githubusercontent.com`

### Workload Identity vs Human Identity

**Human Identity** (keyless signing):
- **Email**: `developer@example.com`
- **OIDC Issuer**: `https://github.com/login/oauth`
- **Certificate Type**: Code signing for individuals

**Workload Identity** (GitHub Actions):
- **Subject**: `repo:org/repo:ref:refs/heads/main`
- **OIDC Issuer**: `https://token.actions.githubusercontent.com`
- **Certificate Type**: Code signing for automation

**Both are visible in Rekor** and can be compared to understand who/what signed an artifact.

### Secure Runners

**GitHub-Hosted Runners**:
- Ephemeral environments (clean for each job)
- Managed by GitHub
- Limited customization

**Self-Hosted Runners**:
- Your own infrastructure
- Persistent environments (security risk)
- Full customization

**Security Best Practices**:
- Use GitHub-hosted runners when possible
- If self-hosted, ensure ephemeral environments
- Limit runner access to specific repositories

### CI/CD Security Benefits

**Automated Signing**:
- Consistent signing for every build
- No human key management
- Tied to code review and approval

**SLSA Level Achievement**:
- Level 2+ requires automated builds
- Provenance generated by build service (not script)
- Non-falsifiable attestations

**Policy Enforcement**:
- Verify attestations before deployment
- Ensure all builds come from approved CI/CD
- Block artifacts without required signatures

---

## 9. Industry Standards & References

### Organizations & Standards Bodies

**CNCF (Cloud Native Computing Foundation)**:
- **Website**: https://www.cncf.io
- **Security TAG**: Technical Advisory Group for security
- **Whitepaper**: [cncf_security_whitepaper.md](cncf_security_whitepaper.md)

**OpenSSF (Open Source Security Foundation)**:
- **Website**: https://openssf.org
- **Mission**: Improve open source security
- **Projects**: SLSA, Scorecard, Sigstore, and more

**Linux Foundation**:
- **Website**: https://www.linuxfoundation.org
- **Projects**: Sigstore, in-toto, SPDX

### Frameworks & Specifications

**SLSA (Supply-chain Levels for Software Artifacts)**:
- **Website**: https://slsa.dev
- **Specification**: https://slsa.dev/spec/v1.0
- **Purpose**: Graduated framework for supply chain security maturity

**in-toto**:
- **Website**: https://in-toto.io
- **Specification**: https://github.com/in-toto/attestation
- **Purpose**: Framework for securing software supply chains

**SPDX (Software Package Data Exchange)**:
- **Website**: https://spdx.dev
- **Purpose**: Standard format for SBOMs
- **Adoption**: ISO/IEC 5962:2021 standard

### Tools & Projects

**Sigstore**:
- **Website**: https://sigstore.dev
- **GitHub**: https://github.com/sigstore
- **Components**: Cosign, Fulcio, Rekor, gitsign
- **Documentation**: https://docs.sigstore.dev

**Cosign**:
- **Documentation**: https://docs.sigstore.dev/cosign/overview
- **GitHub**: https://github.com/sigstore/cosign

**Fulcio**:
- **Documentation**: https://docs.sigstore.dev/certificate_authority/overview
- **GitHub**: https://github.com/sigstore/fulcio

**Rekor**:
- **Documentation**: https://docs.sigstore.dev/logging/overview
- **Public Instance**: https://rekor.sigstore.dev
- **GitHub**: https://github.com/sigstore/rekor

**gitsign**:
- **GitHub**: https://github.com/sigstore/gitsign
- **Documentation**: https://docs.sigstore.dev/gitsign/overview

**Trivy**:
- **Website**: https://trivy.dev
- **GitHub**: https://github.com/aquasecurity/trivy
- **Documentation**: https://aquasecurity.github.io/trivy

### Additional Resources

**GitHub Documentation**:
- **Commit Signing**: https://docs.github.com/en/authentication/managing-commit-signature-verification
- **OIDC**: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
- **Security Hardening**: https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions

**NIST Standards**:
- **SSDF (Secure Software Development Framework)**: https://csrc.nist.gov/Projects/ssdf
- **Supply Chain Security**: https://www.nist.gov/itl/executive-order-improving-nations-cybersecurity/software-supply-chain-security-guidance

**Industry Incidents**:
- **SolarWinds**: Build pipeline compromise
- **Codecov**: Bash uploader script compromise
- **Log4Shell**: Vulnerable dependency widespread impact

---

## Next Steps

Now that you understand the theoretical foundation, proceed to:

**[LAB.md](LAB.md)** - Hands-on exercises implementing these concepts

**Lab Phases**:
- Phase 0: Secure Source Setup
- Phase 1: Security Scanning
- Phase 2: Attestation Generation
- Phase 3: Keyless Signing
- Phase 4: Verification & Transparency
- Phase 5: CI/CD Automation (Bonus)

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-12  
**Author**: Supply Chain Security Lab Team
