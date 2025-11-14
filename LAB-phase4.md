---
marp: true
theme: default
paginate: true
header: 'Supply Chain Security Lab'
footer: 'Phase 4: CI/CD Automation & SLSA Principles'
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
---

# Phase 4: CI/CD Automation (SLSA Build L2 Principles)

**Learning Goals:**
- Automate the entire supply chain pipeline in GitHub Actions
- Implement key SLSA Build L2 concepts (hosted builds, signed provenance)
- Use GitHub's OIDC tokens for keyless authentication
- Publish signed images with attestations to a permanent registry

> **Note:** This lab demonstrates SLSA L2 principles. Full compliance requires SLSA-certified build platforms.

**Prerequisites:** Phases 1-3 completed, GitHub repository with your lab code

---

# Exercise 4.1: Pipeline Requirements

**Create:** `.github/workflows/supply-chain.yml` that runs on every push to `main`

**Must Include:**

1. **Security Scanning** - All 5 scans, zero HIGH/CRITICAL vulnerabilities (fails if found)
2. **Build with Attestations** - Generate provenance, SBOM, 3x vulnerability attestations
3. **Sign Everything** - Image + 5 attestations using GitHub OIDC (no manual auth)
4. **Publish** - Push to `ghcr.io/<your-username>/supply-chain-app` with all artifacts
5. **Verify** - Confirm signatures, attestations, and 6 Rekor entries at end of pipeline

---

# Implementation: Authentication

**OIDC Permissions Required:**
```yaml
permissions:
  id-token: write    # Sigstore keyless signing
  contents: read     # Checkout code
  packages: write    # Push to ghcr.io
```

**Registry Setup:**
- Use `ghcr.io` (GitHub Container Registry)
- Authenticate with `GITHUB_TOKEN` (automatic)
- Image name: `ghcr.io/${{ github.repository_owner }}/supply-chain-app:${{ github.sha }}`

**GitHub OIDC for Cosign:**
- Token provided automatically when `id-token: write` set
- No device flow needed in CI

---

# Implementation: Build & Attestations

**BuildKit for Attestations:**
- Use `docker/build-push-action@v5`
- Enable with `--provenance=true --sbom=true`
- Capture digest for signing

---

# Pipeline Verification

Add verification at end of pipeline before marking success:

1. **Verify Image Signature** - Use `cosign verify` with certificate identity/issuer regexes
2. **Verify Attestations** - Use `cosign verify-attestation` for each type (provenance, sbom, vuln)
3. **Check Rekor** - Use `rekor-cli search` with digest, confirm 6 entries exist

---

# Demo Requirements

**Part 1: Show Failure (Required)**

1. Introduce vulnerability: downgrade Flask to `2.0.1`, OR use `python:3.8` base image, OR add `privileged: true` to K8s
2. Commit and push - pipeline must fail at security scanning
3. Purpose: proves pipeline catches issues

**Part 2: Show Success (Required)**

1. Fix the vulnerability
2. Commit and push - pipeline must succeed with all green checks
3. Image published to ghcr.io with signatures and attestations

**Deliverable:** Both commits visible in GitHub Actions history (one failed, one succeeded)

---

# Success Criteria

**Your Pipeline Must:**
- Trigger on every push to `main`
- Pass all security scans (zero HIGH/CRITICAL)
- Generate 5 attestations (provenance, SBOM, 3x vuln)
- Sign image + attestations with GitHub OIDC
- Push to ghcr.io with OCI 1.1 artifacts
- Verify signatures/attestations/Rekor at end
- Show all green checks in GitHub Actions UI

**Manual Check After Success:**
- GitHub Actions UI shows green workflow run
- Repository Packages shows supply-chain-app image
- Image pullable from `ghcr.io/<your-username>/supply-chain-app`

---

# Lab Complete!

**Journey:**
- **Phase 1:** Fixed vulnerabilities across 5 categories
- **Phase 2:** Generated provenance, SBOM, vulnerability attestations
- **Phase 3:** Signed everything with keyless authentication
- **Phase 4:** Automated entire pipeline in GitHub Actions

**You Achieved:**
- SLSA-aligned practices (hosted builds, signed provenance, attestations)
- Full CI/CD automation with security scanning, signing, and publishing
- GitHub OIDC for machine identity
- Demonstrated L2 principles without formal certification

**Key Takeaways:**
- Defense-in-depth catches different issues at each layer
- Attestations provide verifiable evidence
- Keyless signing eliminates key management
- Automation ensures security on every commit

---

# Resources

**Documentation:**
- GitHub Actions OIDC: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
- Cosign GitHub Actions: https://docs.sigstore.dev/cosign/signing/signing_with_containers/
- SLSA Framework: https://slsa.dev
- GitHub Container Registry: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry

**Troubleshooting:**
- Check GitHub Actions logs for errors
- Verify OIDC permissions are set
- Ensure BuildKit driver configured
- Review Phases 1-3 for command reference
