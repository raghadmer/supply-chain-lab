---
marp: true
theme: default
paginate: true
header: 'Supply Chain Security Concepts'
footer: 'Theoretical Foundation for Hands-On Lab'
style: |
  section {
    font-size: 18px;
  }
  h1 {
    font-size: 36px;
  }
  h2 {
    font-size: 28px;
  }
  code {
    font-size: 12px;
  }
  pre {
    font-size: 12px;
  }
  .lab-ref {
    background: #e3f2fd;
    padding: 8px;
    border-left: 4px solid #2196f3;
    margin: 10px 0;
  }
---

# Supply Chain Security Concepts

**Theoretical Foundation**

Learn the concepts and standards behind modern supply chain security before implementing them in the hands-on lab.

---

## Lab Overview

**Three Practical Phases**:
1. **Phase 1**: Security Scanning - Detect & fix vulnerabilities
2. **Phase 2**: Attestations & Provenance - Generate security evidence
3. **Phase 3**: Keyless Signing & Transparency - Sign and verify artifacts

**This Presentation**: Explains the "why" and "how" behind each phase

---

# Part 1: Introduction

## What is Supply Chain Security?

---

## Supply Chain Security Model

```
┌─────────────┐   ┌──────────┐   ┌─────────┐   ┌──────────────┐
│  Developer  │──▶│  Source  │──▶│  Build  │──▶│ Distribution │
│   Identity  │   │  Control │   │ Process │   │  & Delivery  │
└─────────────┘   └──────────┘   └─────────┘   └──────────────┘
      │                │              │                │
      ▼                ▼              ▼                ▼
   MFA + SSH      Scans + SBOM   SLSA Provenance  Signed Artifacts
   Signed Commits Code Review    Attestations     Verification
```

**Goal**: Trust software artifacts throughout their lifecycle

---

## Four Pillars of Supply Chain Security

**Authenticity**
Verify who created the software

**Integrity**
Ensure software wasn't tampered with

**Traceability**
Track the complete build process

**Transparency**
Make security evidence publicly auditable

---

## Why Supply Chain Security Matters

**Attack Vectors**:
- Source Code Attacks (malicious commits)
- Build Process Attacks (tampering during compilation)
- Dependency Attacks (compromised libraries)
- Distribution Attacks (registry compromises)

**Real-World Example**:
SolarWinds breach (2020) - build pipeline compromised, affecting 18,000+ organizations

---

## Defense in Depth

Multiple security layers protect each phase:

1. **Developer Phase**: Authentication, signed commits
2. **Source Phase**: Vulnerability scanning, dependency analysis
3. **Build Phase**: Provenance generation, isolated builds
4. **Distribution Phase**: Artifact signing, transparency logs
5. **Verification Phase**: Signature validation, policy enforcement

**No single layer is sufficient - all are necessary**

---

# Part 2: Phase 1 Foundation
## Security Scanning

---

## What is Security Scanning?

**Purpose**: Identify vulnerabilities **before** they reach production

**Key Insight**: Scanning is necessary but not sufficient
- Finds known vulnerabilities
- Does not verify integrity
- Does not prove secure build process
- Must be combined with attestations and signing

---

## Five Vulnerability Categories

**1. Source Code (SAST)**
- Static Application Security Testing
- Hardcoded secrets, SQL injection, XSS

**2. Dependencies (SCA)**
- Software Composition Analysis
- Known CVEs in libraries (e.g., Flask CVE-2023-30861)

**3. Dockerfile**
- Container build configuration
- Running as root, missing healthchecks

---

## Five Vulnerability Categories (cont.)

**4. Infrastructure as Code (IaC)**
- Cloud misconfigurations
- Public S3 buckets, open security groups

**5. Container Image**
- OS packages + application dependencies
- Example: python:3.8 → 907 HIGH/CRITICAL vulnerabilities

**🔬 Lab Phase 1**: You'll scan all 5 categories and fix findings

---

## Vulnerability Severity Levels

**CRITICAL**
Immediate action required (RCE, privilege escalation)

**HIGH**
Serious security risk (data exposure, auth bypass)

**MEDIUM**
Moderate risk (info disclosure, DoS)

**LOW**
Minor issues (missing best practices)

---

## Scanning Tools

**Trivy**
Container and filesystem vulnerability scanner

**Semgrep**
Static analysis for code patterns

**Checkov**
Infrastructure as Code security scanner

**Syft**
Software Bill of Materials (SBOM) generation

---

## Limitations of Scanning

**What Scanning Cannot Do**:
- Detect zero-day vulnerabilities
- Verify artifact integrity
- Prove secure build process
- Prevent supply chain attacks

**Solution**: Combine scanning with attestations and signing

---

# Part 3: Phase 2 Foundation
## SLSA & Attestations

---

## What is SLSA?

**SLSA**: Supply-chain Levels for Software Artifacts

**Pronunciation**: "salsa" (like the dance)

**Purpose**: Common vocabulary and framework for supply chain security maturity

**Developed by**: Google & OpenSSF (Open Source Security Foundation)

**Website**: https://slsa.dev

---

## SLSA Levels Overview

**Four levels** of supply chain maturity (0-3):

- **Level 0**: No guarantees
- **Level 1**: Build process documented
- **Level 2**: Tamper-resistant provenance (🎯 **Inspired by this lab**)
- **Level 3**: Hardened builds

Each level builds on the previous, closing specific attack vectors

---

## SLSA Level 0: No Guarantees

**Characteristics**:
- No supply chain security measures
- Vulnerable to all attack vectors
- Manual builds, no documentation

**Risk**: High - anyone can tamper at any stage

---

## SLSA Level 1: Build Documentation

**Requirements**:
- Build process is documented
- Provenance is generated

**Protection**: Basic build transparency

**Example**: Automated builds with basic metadata

---

## SLSA Level 2: Tamper Resistance

**Requirements**:
- Builds are automated
- Provenance is signed and non-falsifiable
- Build service generates provenance (not build script)

**Protection**: Provenance can't be forged

**Example**: CI/CD pipeline with signed attestations

**🎯 This lab demonstrates Level 2 principles**

---

## SLSA Level 3: Hardened Builds

**Requirements**:
- All Level 2 requirements
- Source and build platform auditable
- Complete dependency information

**Protection**: Prevents attacks on build platform

**Example**: Isolated build environments, hermetic builds

---

## What is SLSA Provenance?

**Provenance**: Attestation metadata describing how an artifact was built

**Answers Key Questions**:
- Who built it?
- When was it built?
- What inputs were used?
- How was it built?
- Where did the source come from?

---

## SLSA Provenance Structure

**Key Information Captured**:
- **Builder Identity**: Who/what performed the build
- **Source Repository**: Git URL and commit SHA
- **Build Invocation**: Commands and parameters
- **Build Materials**: Dependencies and base images
- **Timestamps**: Build start and finish times
- **Environment**: Build platform details

**🔬 Lab Phase 2**: You'll generate provenance with Docker BuildKit

---

## Provenance Example

```json
{
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [{"name": "myapp", "digest": {"sha256": "abc123..."}}],
  "predicate": {
    "builder": {"id": "docker-buildkit"},
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
    }
  }
}
```

---

## What is an Attestation?

**Signature**: Cryptographic proof someone signed something
- Limited information: only "who signed"

**Attestation**: Signed statement with rich metadata
- Signature + structured evidence
- Describes what was attested and why
- Multiple types for different evidence

**Analogy**: Signature on blank paper vs. notarized document with details

---

## The in-toto Framework

**in-toto**: Framework for securing software supply chains

**Key Concepts**:
- **Layout**: Defines expected supply chain steps
- **Links**: Records what happened in each step
- **Attestations**: Signed statements about artifacts
- **Verification**: Validates complete supply chain

**Website**: https://in-toto.io

---

## in-toto Statement Format

**Standard Structure**:

```json
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "subject": [
    {"name": "artifact-name", "digest": {"sha256": "abc123..."}}
  ],
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "predicate": {
    ...predicate-specific content...
  }
}
```

**Components**: Statement wrapper + Subject + Predicate Type + Predicate

---

## DSSE Envelope (Signed Format)

When attestations are signed, wrapped in **DSSE** (Dead Simple Signing Envelope):

```json
{
  "payloadType": "application/vnd.in-toto+json",
  "payload": "<base64-encoded-statement>",
  "signatures": [
    {"sig": "<base64-signature>", "keyid": "..."}
  ]
}
```

**🔬 Lab Phase 2**: See both formats
- `out/provenance.json` → Full DSSE envelope
- `attestations/provenance.json` → Extracted predicate

---

## Predicate Types

Different predicate types capture different evidence:

**1. SLSA Provenance** (`https://slsa.dev/provenance/v0.2`)
- Build metadata and dependencies

**2. SPDX SBOM** (`https://spdx.dev/Document`)
- Complete software bill of materials

**3. Vulnerability Report** (`https://cosign.sigstore.dev/attestation/vuln/v1`)
- Security scan results

**4. Custom Attestations**
- Test results, code review, etc.

---

## Why Multiple Attestations?

Each attestation answers different questions:

**Provenance**: "How was this built?"
- Build process, inputs, environment

**SBOM**: "What's inside this artifact?"
- All components, licenses, dependencies

**Vulnerability Report**: "Is this artifact safe?"
- Known vulnerabilities, scan results

**Together**: Comprehensive supply chain security evidence

---

## What is an SBOM?

**SBOM**: Software Bill of Materials

**Purpose**: Complete inventory of software components
- All dependencies (direct and transitive)
- Versions and licenses
- Relationships between components

**Format**: SPDX (Software Package Data Exchange)
- ISO/IEC 5962:2021 standard
- Machine-readable JSON format

**🔬 Lab Phase 2**: Generate SBOM with ~100+ packages

---

# Part 4: Phase 3 Foundation
## Sigstore & Keyless Signing

---

## The Key Management Problem

**Traditional Signing** (GPG, X.509):
- Generate cryptographic keypairs
- Securely store private keys
- Distribute and verify public keys
- Rotate keys periodically
- Handle key compromise and revocation

**Challenge**: Key management is complex, error-prone, and risky

---

## What is Keyless Signing?

**Solution**: Use existing identity providers instead of managing keys

**How It Works**:
1. Authenticate with existing identity (GitHub, Google)
2. Get short-lived certificate binding identity to ephemeral key
3. Sign artifact with ephemeral key
4. Log signing event in transparency log
5. Discard ephemeral key

**Result**: No keys to manage, but still cryptographically verifiable

---

## What is Sigstore?

**Sigstore**: Open-source keyless signing infrastructure

**Mission**: Make signing and verification easy and accessible

**Components**:
- **Cosign**: Sign and verify artifacts
- **Fulcio**: Issue short-lived certificates
- **Rekor**: Transparency log for signatures
- **gitsign**: Keyless commit signing

**Website**: https://sigstore.dev

---

## Sigstore Architecture

```
1. Developer (cosign)
   ↓
2. OIDC Provider (GitHub) → ID Token
   ↓
3. Fulcio CA → Short-lived Certificate
   ↓
4. Sign Artifact → Registry
   ↓
5. Rekor Log (Transparency)
```

---

## Cosign: Signing Tool

**Cosign**: CLI tool for signing and verifying container images

**Key Features**:
- Sign container images
- Attach attestations to artifacts
- Verify signatures and attestations
- Supports keyless, KMS, and local keys

**Common Commands**:
```bash
cosign sign <image>
cosign verify <image>
cosign attest --predicate <file> <image>
cosign verify-attestation --type <type> <image>
```

---

## Fulcio: Certificate Authority

**Fulcio**: Issues short-lived certificates based on OIDC identity

**Process**:
1. User authenticates with OIDC provider
2. Fulcio validates OIDC ID token
3. Fulcio issues X.509 certificate binding identity to public key
4. Certificate expires in ~10 minutes
5. Certificate contains email and OIDC issuer

**Why Short-Lived?**
- No revocation lists needed
- Reduces impact of compromised credentials
- Encourages just-in-time authentication

---

## Certificate Properties

**Standard X.509 Certificate with Extensions**:

**Subject Alternative Name (SAN)**
Contains email address (e.g., `user@example.com`)

**Custom OID (1.3.6.1.4.1.57264.1.1)**
Contains OIDC issuer URL (e.g., `https://github.com/login/oauth`)

**Extended Key Usage**
Set to code signing

**Public Key**
ECDSA P-256 from ephemeral keypair

---

## Rekor: Transparency Log

**Rekor**: Immutable, append-only transparency log

**Purpose**: Non-repudiable evidence of signing events

**How It Works**:
1. Signing event occurs
2. Certificate and signature uploaded to Rekor
3. Rekor creates cryptographically verifiable entry
4. Entry is globally searchable and auditable

**🔬 Lab Phase 3**: Search Rekor for your signatures

---

## Why Transparency Logs?

**Public Auditability**
Anyone can search Rekor for an artifact

**Offline Verification**
Rekor provides certificate after Fulcio cert expires

**Non-Repudiation**
Cannot deny signing an artifact

**Tamper Evidence**
Any modification to log is detectable

---

## Complete Keyless Signing Flow

**Step 1**: Developer runs `cosign sign --yes <image>`

**Step 2**: OIDC Authentication
- Browser opens to OAuth provider
- User authenticates
- OIDC token issued with verified identity

**Step 3**: Certificate Request
- Cosign generates ephemeral ECDSA keypair
- Sends public key + OIDC token to Fulcio
- Fulcio issues certificate

---

## Complete Keyless Signing Flow (cont.)

**Step 4**: Artifact Signing
- Cosign signs artifact with private key
- Signature and certificate uploaded to registry

**Step 5**: Transparency Logging
- Rekor records signing event
- Creates searchable, immutable entry

**Step 6**: Verification
- Retrieve signature and certificate
- Validate certificate chain to Fulcio root
- Verify signature matches artifact

---

## OCI 1.1 and Referrers API

**OCI 1.1**: Native support for artifact attachments

**Key Features**:
- **Referrers API**: Query artifacts linked to an image
- **Native Storage**: No tag-based workarounds
- **Clean Tree Structure**: Artifacts form tree

**Cosign v3 Behavior**:
- Writing: OCI 1.1 by default
- Reading: Requires `--experimental-oci11` flag
- Future: Flag becomes default in Cosign v4

---

## OCI 1.1 in Practice

**🔬 Lab Phase 3 Commands**:
```bash
cosign tree --experimental-oci11 $IMAGE
cosign verify --experimental-oci11 $IMAGE
cosign verify-attestation --experimental-oci11 $IMAGE
```

**Why It Matters**:
- Better garbage collection
- Standardized across registries
- Improved performance

---

## ttl.sh: Ephemeral Registry

**ttl.sh**: Free, ephemeral container registry

**Features**:
- No authentication required
- Time-to-live based deletion (`:3h` = 3 hours)
- OCI 1.1 support
- Perfect for testing

**🔬 Lab Phase 3 Usage**:
```bash
docker tag app:latest ttl.sh/app-$(hostname):3h
docker push ttl.sh/app-$(hostname):3h
```

**Benefits**: No account needed, automatic cleanup

---

# Part 5: Verification & Trust

---

## Two Approaches to Verification

**Manual Exploration** (Transparency)
- Human-readable investigation
- Search Rekor for signing events
- Extract and inspect certificates
- View attestation contents

**Automated Verification** (Cryptographic)
- Programmatic validation
- Verify signatures cryptographically
- Enforce identity policies
- Integrate into CI/CD

**Both are important for different use cases**

---

## Manual Exploration Tools

**Purpose**: Understand and audit signing events

**Tools**:
```bash
rekor-cli search --sha <digest>
rekor-cli get --uuid <uuid> --format json
cosign verify-attestation <image> | jq .
```

**Benefits**:
- Educational: See how it works
- Debugging: Investigate issues
- Audit: Manual review

**🔬 Lab Phase 3**: Explore your signatures in Rekor

---

## Automated Verification

**Purpose**: Policy enforcement in production

**Tools**:
```bash
cosign verify \
  --certificate-identity=<email> \
  --certificate-oidc-issuer=<issuer> \
  <image>

cosign verify-attestation \
  --type <predicate-type> \
  --certificate-identity=<email> \
  <image>
```

**Benefits**: Fast, automated, integrates with CI/CD

---

## Trust Model

**Root of Trust**:
- Fulcio Root CA (published certificate)
- Rekor Public Key (published transparency log key)
- OIDC Providers (GitHub, Google, Microsoft)

**Trust Chain**:
1. Trust OIDC provider for authentication
2. Trust Fulcio to issue certificates correctly
3. Trust Rekor to log immutably
4. Trust cryptographic verification

---

## Verification Process

**Six Steps**:
1. Retrieve signature and certificate from registry/Rekor
2. Validate certificate chain to Fulcio root
3. Check certificate not expired at signing time
4. Verify signature matches artifact
5. Validate identity matches expected policy
6. Check Rekor for matching entry

**All steps must pass for successful verification**

---

## Transparency Benefits

**Public Auditability**
Complete signing history is public

**Offline Verification**
Don't need Fulcio CA online

**Non-Repudiation**
Cryptographic proof + timestamp

**Tamper Detection**
Any log modification is detectable

---

# Part 6: Lab Connection

---

## Concepts → Lab Mapping

**Phase 1: Security Scanning**
- Apply 5 vulnerability categories
- Use SAST, SCA, IaC, container scanning
- Understand severity levels
- Fix all findings

**Phase 2: Attestations & Provenance**
- Generate SLSA provenance (BuildKit)
- Create SBOM attestation (Syft)
- Generate vulnerability attestations (Trivy)
- Understand in-toto Statement format

---

## Concepts → Lab Mapping (cont.)

**Phase 3: Keyless Signing & Transparency**
- Sign container image with Cosign
- Attach 5 signed attestations
- Explore OCI 1.1 artifact tree
- Search Rekor transparency log
- Inspect certificates and identities
- Verify signatures

---

## Key Takeaways

**Supply Chain Security is Multi-Layered**
- Scanning finds vulnerabilities
- Attestations provide evidence
- Signing proves authenticity
- Transparency enables auditability

**SLSA Provides Framework**
- Graduated levels of maturity
- This lab demonstrates Level 2 principles

**Keyless Signing Simplifies Security**
- No key management burden
- Cryptographically verifiable
- Publicly auditable

---

## Resources

**Standards & Frameworks**:
- SLSA: https://slsa.dev
- in-toto: https://in-toto.io
- SPDX: https://spdx.dev

**Sigstore Ecosystem**:
- Sigstore: https://sigstore.dev
- Cosign: https://docs.sigstore.dev/cosign/overview
- Fulcio: https://docs.sigstore.dev/certificate_authority/overview
- Rekor: https://docs.sigstore.dev/logging/overview

---

## Ready for Hands-On Lab!

**You now understand**:
✅ Why supply chain security matters
✅ How security scanning works
✅ What SLSA and attestations provide
✅ How keyless signing works
✅ Why transparency logs are critical

**Next**: Apply these concepts in the practical lab exercises

**Phase 1** → Scan and fix vulnerabilities
**Phase 2** → Generate attestations
**Phase 3** → Sign and verify

---

# Thank You

**Questions?**

Proceed to the hands-on lab to apply these concepts in practice.

