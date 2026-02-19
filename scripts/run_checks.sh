#!/usr/bin/env bash
#
# Run all code quality checks.
# Adjust the check commands below to match your project's tools.
#
# Exit codes:
#   0 - All checks passed
#   1 - One or more checks failed

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║          Code Quality Checks             ║"
echo "╚══════════════════════════════════════════╝"
echo ""

FAILED_CHECKS=()
PASSED_CHECKS=()

run_check() {
    local name=$1
    local command=$2

    echo -e "${BLUE}▶ Running: $name${NC}"
    echo "──────────────────────────────────────────"

    if eval "$command"; then
        echo -e "${GREEN}✓ $name passed${NC}"
        PASSED_CHECKS+=("$name")
    else
        echo -e "${RED}✗ $name failed${NC}"
        FAILED_CHECKS+=("$name")
    fi
    echo ""
}

# ── Checks ────────────────────────────────────────────────
# Adjust these to match your project's tools and source paths.

run_check "Security Scan"          "$SCRIPT_DIR/security_scan.sh"            || true
run_check "Black (Formatting)"     "black --check --diff src/ tests/"        || true
run_check "Ruff (Linting)"         "ruff check src/ tests/"                  || true
run_check "MyPy (Type Checking)"   "mypy src/"                               || true
run_check "Pytest (Unit Tests)"    "pytest -v --tb=short"                    || true

# ── Summary ───────────────────────────────────────────────
echo "══════════════════════════════════════════"
echo "                 SUMMARY"
echo "══════════════════════════════════════════"
echo ""

if [ ${#PASSED_CHECKS[@]} -gt 0 ]; then
    echo -e "${GREEN}Passed (${#PASSED_CHECKS[@]}):${NC}"
    for check in "${PASSED_CHECKS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $check"
    done
    echo ""
fi

if [ ${#FAILED_CHECKS[@]} -gt 0 ]; then
    echo -e "${RED}Failed (${#FAILED_CHECKS[@]}):${NC}"
    for check in "${FAILED_CHECKS[@]}"; do
        echo -e "  ${RED}✗${NC} $check"
    done
    echo ""
    echo -e "${RED}Some checks failed. Please fix the issues above.${NC}"
    exit 1
else
    echo -e "${GREEN}All checks passed! 🎉${NC}"
    exit 0
fi
