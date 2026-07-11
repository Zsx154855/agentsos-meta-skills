#!/usr/bin/env bash
# agentsos-think — 5-Perspective Strategic Analysis
# Uses: Karpathy × tonny × Naval × Security Gate × Workbench
# Usage: agentsos-think "your question or decision"

set -euo pipefail

QUESTION="${1:-}"
if [ -z "$QUESTION" ]; then
  echo "Usage: agentsos-think \"your question or decision\""
  echo ""
  echo "5 Perspectives applied:"
  echo "  Karpathy  — how to build it correctly, minimal implementation"
  echo "  tonny     — what to build, how to monetize, 4-hour MVP"
  echo "  Naval     — leverage, specific knowledge, long-term game check"
  echo "  SecGate   — what could go wrong, security risks, hardening needed"
  echo "  Workbench — can this be productized into a reusable skill?"
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║        AGENTSOS THINK — 5-Perspective           ║"
echo "╚══════════════════════════════════════════════════╝"
echo "  Question: $QUESTION"
echo ""

# Perspective 1: Karpathy — Minimal Implementation
echo "━━━ Karpathy (How to Build) ━━━"
echo "  → First principles: What is the core problem?"
echo "  → Minimal MVP: What's the simplest thing that could work?"
echo "  → Build from scratch or use existing blocks?"
echo ""

# Perspective 2: tonny — Builder & Monetization
echo "━━━ tonny (What to Build & Monetize) ━━━"
echo "  → 4-hour MVP: Can this ship tonight?"
echo "  → Revenue layer: Who pays? How much?"
echo "  → Internet leverage: Does it scale without you?"
echo ""

# Perspective 3: Naval — Leverage & Long Game
echo "━━━ Naval (Leverage & Decisions) ━━━"
echo "  → Specific knowledge: Is this YOUR unique advantage?"
echo "  → Permissionless leverage: Code/media or permissioned?"
echo "  → Long game: Will this compound over 10 years?"
echo ""

# Perspective 4: Security Gate — Risk Assessment
echo "━━━ Security Gate (Risk & Hardening) ━━━"
echo "  → Secrets risk: Any credentials exposed?"
echo "  → Attack surface: What's the blast radius?"
echo "  → Audit trail: Can every action be traced?"
echo ""

# Perspective 5: Workbench — Productization
echo "━━━ Workbench (Productization) ━━━"
echo "  → Distillable: Can the method be turned into a skill?"
echo "  → Pipeline: Can this be automated end-to-end?"
echo "  → Distributable: npm/pip/skills.sh/GitHub?"
echo ""

echo "══════════════════════════════════════════════════"
echo "  Run with: agentsos-think \"your question\""
echo "  For deep analysis: invoke individual skill perspectives"
echo "══════════════════════════════════════════════════"
