#!/bin/bash
set -euo pipefail

# Generate SBOM predicate for cosign attest
# Usage: generate-sbom-attestation.sh <image-name>
#
# Generates SPDX SBOM predicate (for use with cosign attest --predicate)
# Automatically:
# 1. Generates SBOM with syft in SPDX JSON format
# 
# Note: cosign attest wraps the predicate in the in-toto Statement envelope

if [ $# -ne 1 ]; then
    echo "Usage: $0 <image-name>" >&2
    echo "Example: $0 supply-chain-app:latest" >&2
    exit 1
fi

IMAGE_NAME="$1"

# Detect Docker socket from active context if DOCKER_HOST not set
if [ -z "${DOCKER_HOST:-}" ]; then
    # Check if using colima
    if docker context show 2>/dev/null | grep -q colima; then
        COLIMA_SOCKET="$HOME/.colima/default/docker.sock"
        if [ -S "$COLIMA_SOCKET" ]; then
            export DOCKER_HOST="unix://$COLIMA_SOCKET"
        fi
    fi
fi

# If image name doesn't have a scheme prefix, add docker: for local images
if [[ ! "$IMAGE_NAME" =~ ^[a-z]+: ]]; then
    IMAGE_NAME="docker:$IMAGE_NAME"
fi

# Generate SBOM with syft (SPDX JSON format) - outputs predicate only
syft "$IMAGE_NAME" -o spdx-json -q
