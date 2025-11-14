# Supply Chain Security Lab

Hands-on lab for learning modern supply chain security practices with Sigstore, SLSA, and GitHub Actions.

## Lab Phases

1. **Phase 1**: Fix vulnerabilities across source code, container images, IaC, and Kubernetes
2. **Phase 2**: Generate provenance, SBOM, and vulnerability attestations
3. **Phase 3**: Sign artifacts with keyless authentication (Sigstore)
4. **Phase 4**: Automate everything in GitHub Actions (SLSA-aligned practices)

## Materials

- **Slides**: `CONCEPTS-SLIDES.md` - Theory and concepts
- **Labs**: `LAB-phase[1-4].md` - Hands-on exercises for each phase
- **Code**: `src/` - Sample application with intentional vulnerabilities

## Rendering Slides

### Install Marp CLI
```bash
npm install -g @marp-team/marp-cli
```

### Option 1: Generate HTML Files
```bash
# Concepts slides
marp CONCEPTS-SLIDES.md -o concepts.html --html

# Lab slides (any phase)
marp LAB-phase1.md -o lab-phase1.html --html
```

Open generated HTML files in your browser. Press `f` for fullscreen mode.

### Option 2: Live Server (Auto-reload)
```bash
# Serve with live preview on http://localhost:8080
marp -s .
```

Navigate to any `.md` file in your browser. Changes auto-reload.

## Quick Start

1. Read `CONCEPTS.md` for background theory
2. Start with `LAB-phase1.md` and work through each phase
3. Use `scripts/` for automation and validation helpers
