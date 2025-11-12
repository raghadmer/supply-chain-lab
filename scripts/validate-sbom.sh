#!/bin/bash
set -e

FILE="attestations/sbom.json"

echo "🔍 Validating SBOM predicate..."

# Check file exists
if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  echo "💡 Generate it with: ./scripts/generate-sbom-attestation.sh supply-chain-app:latest"
  exit 1
fi

# Validate JSON syntax
if ! jq empty "$FILE" 2>/dev/null; then
  echo "❌ Invalid JSON syntax in $FILE"
  exit 1
fi

# Check SPDX predicate structure (this is an SPDX document, not a full in-toto statement)
SPDX_VERSION=$(jq -r '.spdxVersion // empty' "$FILE")
if [ -z "$SPDX_VERSION" ]; then
  echo "❌ Missing spdxVersion"
  exit 1
fi

# Check packages exist
PKG_COUNT=$(jq '.packages | length' "$FILE")
if [ "$PKG_COUNT" -eq 0 ]; then
  echo "❌ No packages found in SBOM"
  exit 1
fi

echo "✅ SBOM predicate is valid"
echo "   SPDX Version: $SPDX_VERSION"
echo "   Packages: $PKG_COUNT"
