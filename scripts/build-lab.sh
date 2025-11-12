#!/bin/bash
set -e

echo "📖 Building full lab presentation..."

# Start with Phase 1 (includes YAML frontmatter)
cat LAB-phase1.md > LAB-full.md

# Append Phase 2, but skip its YAML frontmatter (first 23 lines)
# This prevents duplicate configuration from appearing as slide content
tail -n +24 LAB-phase2.md >> LAB-full.md

echo "✅ Generated LAB-full.md"
echo ""
echo "Available phases:"
ls -1 LAB-phase*.md | sed 's/^/  - /'
echo ""
echo "Full presentation: LAB-full.md"
echo ""
echo "To generate HTML presentation:"
echo "  marp LAB-full.md -o lab-presentation.html"
