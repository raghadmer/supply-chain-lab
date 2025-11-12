# Helper Scripts Directory

This directory contains helper scripts for the Supply Chain Security Lab.

## Purpose

Helper scripts handle complex or boilerplate operations that students shouldn't need to implement from scratch, allowing them to focus on learning security concepts rather than bash syntax.

## Script Categories

### Infrastructure Scripts (Pre-built)
Scripts that handle low-level operations with minimal learning value:
- JSON formatting and validation
- OCI artifact manipulation
- Complex tool invocations with many flags
- Test/validation framework helpers

### Student-Focused Scripts (With TODOs)
Scripts where students complete missing logic to learn key concepts:
- Attestation generation (provenance, SBOM wrapping, vulnerability reports)
- Signing command construction
- Verification workflows

## Usage in Lab

Scripts are called from Taskfile.yml tasks or used directly in LAB.md exercises. Each script should:
- Have clear purpose documented in header comments
- Include usage examples
- Provide helpful error messages
- Be idempotent where possible

## Development Guidelines

When adding new helper scripts:
1. Document the script's purpose and usage at the top
2. Use clear, descriptive names
3. Make scripts executable (`chmod +x`)
4. Test thoroughly before integrating into lab
5. Consider if it's pre-built infrastructure or student work

## Available Scripts

### Phase 2: Attestation Generation & Validation

**Generation Scripts** (Pre-built, no TODOs - students run and inspect output):
- `generate-provenance.sh <image-name>` - Generate SLSA provenance attestation
- `generate-sbom-attestation.sh <image-name>` - Generate SBOM attestation (wraps syft output in in-toto Statement)
- `generate-vuln-attestation.sh <scan-type> <target>` - Generate vulnerability attestation (wraps Trivy output)
  - Scan types: `fs` (source), `config` (IaC), `image` (container)

**Validation Scripts** (Pre-built - detailed error messages):
- `validate-provenance.sh` - Validate SLSA provenance structure
- `validate-sbom.sh` - Validate SBOM attestation structure
- `validate-vuln.sh <type>` - Validate vulnerability attestations (type: source, iac, image)

## Future Scripts (Planned)

### Phase 3: Signing
- `sign-with-oidc.sh` - Keyless signing helper (with TODOs for flags)

### Phase 4: Verification
- `decode-cert.sh` - Extract identity from Fulcio certificate (pre-built)
- `pretty-print-attestation.sh` - Human-readable attestation display (pre-built)

### Phase 5: CI/CD
- No additional scripts needed (GitHub Actions uses Taskfile)

## Notes

- All scripts assume execution from repository root
- Scripts use tools from the supply-chain-tools Docker container
- Error messages should guide students to relevant LAB.md sections
- Pre-built scripts are fully implemented
- Student scripts contain TODO markers with hints

---

**Last Updated**: 2025-11-12  
**Status**: Phase 2 generation & validation scripts complete
