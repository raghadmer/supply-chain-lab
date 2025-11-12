#!/bin/bash
set -euo pipefail

# Generate SLSA Provenance predicate for use with cosign attest
# Usage: generate-provenance.sh <image-name>
#
# Generates ONLY the predicate portion (not the full in-toto Statement)
# Cosign will wrap this predicate in an in-toto Statement automatically
# Automatically extracts:
# - Image digest (sha256)
# - Git commit SHA
# - Build timestamps
# - Builder ID (user@hostname)
# - Repository URL

if [ $# -ne 1 ]; then
    echo "Usage: $0 <image-name>" >&2
    echo "Example: $0 supply-chain-app:latest" >&2
    exit 1
fi

IMAGE_NAME="$1"

# Extract image digest
if ! IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE_NAME" 2>/dev/null | cut -d'@' -f2); then
    # If no RepoDigests (local image), use Id
    IMAGE_DIGEST=$(docker inspect --format='{{.Id}}' "$IMAGE_NAME" | sed 's/sha256://')
    if [ -z "$IMAGE_DIGEST" ]; then
        echo "Error: Could not find image: $IMAGE_NAME" >&2
        exit 1
    fi
    IMAGE_DIGEST="sha256:$IMAGE_DIGEST"
fi

# Extract only the sha256 hash
IMAGE_SHA256=$(echo "$IMAGE_DIGEST" | sed 's/sha256://')

# Get git information (if in a git repo)
if git rev-parse --git-dir > /dev/null 2>&1; then
    COMMIT_SHA=$(git rev-parse HEAD)
    REPO_URI=$(git config --get remote.origin.url 2>/dev/null || echo "file://$(git rev-parse --show-toplevel)")
else
    COMMIT_SHA="unknown"
    REPO_URI="unknown"
fi

# Get build timestamps (ISO 8601 format)
BUILD_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Get builder ID
BUILDER_ID="$(whoami)@$(hostname)"

# Get working directory
WORKDIR=$(pwd)

# Generate SLSA provenance predicate (for use with cosign attest)
cat <<EOF
{
  "builder": {
    "id": "$BUILDER_ID"
  },
  "buildType": "https://github.com/slsa-framework/slsa/blob/main/docs/build-types.md#manual",
  "invocation": {
    "configSource": {
      "uri": "$REPO_URI",
      "digest": {
        "sha1": "$COMMIT_SHA"
      },
      "entryPoint": "Dockerfile"
    },
    "parameters": {
      "dockerfile": "src/docker/Dockerfile",
      "context": "src/"
    },
    "environment": {
      "workdir": "$WORKDIR",
      "docker_version": "$(docker --version | cut -d' ' -f3 | tr -d ',')"
    }
  },
  "metadata": {
    "buildStartedOn": "$BUILD_TIMESTAMP",
    "buildFinishedOn": "$BUILD_TIMESTAMP",
    "completeness": {
      "parameters": true,
      "environment": false,
      "materials": false
    },
    "reproducible": false
  },
  "materials": [
    {
      "uri": "$REPO_URI",
      "digest": {
        "sha1": "$COMMIT_SHA"
      }
    }
  ]
}
EOF
