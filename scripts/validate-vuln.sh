#!/bin/bash
set -e

# Usage: validate-vuln.sh <type>
# type: source, iac, or image

TYPE=$1

if [ -z "$TYPE" ]; then
  echo "Usage: $0 <source|iac|image>"
  exit 1
fi

FILE="attestations/vuln-${TYPE}.json"

echo "🔍 Validating ${TYPE} vulnerability predicate..."

# Check file exists
if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  case "$TYPE" in
    source)
      echo "💡 Generate it with: ./scripts/generate-vuln-attestation.sh fs src/"
      ;;
    iac)
      echo "💡 Generate it with: ./scripts/generate-vuln-attestation.sh config src/iac/"
      ;;
    image)
      echo "💡 Generate it with: ./scripts/generate-vuln-attestation.sh image supply-chain-app:latest"
      ;;
  esac
  exit 1
fi

# Validate JSON syntax
if ! jq empty "$FILE" 2>/dev/null; then
  echo "❌ Invalid JSON syntax in $FILE"
  exit 1
fi

# Check scanner info (this is a vulnerability predicate, not a full in-toto statement)
SCANNER=$(jq -r '.scanner.uri // empty' "$FILE")
if [ -z "$SCANNER" ]; then
  echo "❌ Missing scanner.uri"
  exit 1
fi

echo "✅ $(echo $TYPE | tr '[:lower:]' '[:upper:]' | cut -c1)$(echo $TYPE | cut -c2-) vulnerability predicate is valid"
echo "   Scanner: $SCANNER"
