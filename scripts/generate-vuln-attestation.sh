#!/bin/bash
set -euo pipefail

# Generate vulnerability predicate for cosign attest
# Usage: generate-vuln-attestation.sh <scan-type> <target>
#
# Scan types:
#   fs      - Filesystem scan (source code + dependencies)
#   config  - Configuration scan (IaC misconfigurations)
#   image   - Container image scan
#
# Generates Trivy vulnerability predicate (for use with cosign attest --predicate)
# Note: cosign attest wraps the predicate in the in-toto Statement envelope
#
# Examples:
#   generate-vuln-attestation.sh fs src/app/
#   generate-vuln-attestation.sh config src/iac/
#   generate-vuln-attestation.sh image supply-chain-app:latest

if [ $# -ne 2 ]; then
    echo "Usage: $0 <scan-type> <target>" >&2
    echo "" >&2
    echo "Scan types:" >&2
    echo "  fs      - Filesystem scan (source code + dependencies)" >&2
    echo "  config  - Configuration scan (IaC misconfigurations)" >&2
    echo "  image   - Container image scan" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 fs src/app/" >&2
    echo "  $0 config src/iac/" >&2
    echo "  $0 image supply-chain-app:latest" >&2
    exit 1
fi

SCAN_TYPE="$1"
TARGET="$2"

# Validate scan type
case "$SCAN_TYPE" in
    fs|config|image)
        ;;
    *)
        echo "Error: Invalid scan type: $SCAN_TYPE" >&2
        echo "Valid types: fs, config, image" >&2
        exit 1
        ;;
esac

# Run trivy with cosign-vuln format (outputs predicate only)
trivy "$SCAN_TYPE" --format cosign-vuln "$TARGET" 2>/dev/null
