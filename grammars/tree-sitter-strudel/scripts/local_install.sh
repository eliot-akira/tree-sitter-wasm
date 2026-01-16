#!/bin/bash

set -e  # Exit on any error

echo "🔨 Installing Strudel Tree Sitter"
echo "================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}
success() {
    echo -e "${GREEN}✅ $1${NC}"
}
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}
error() {
    echo -e "${RED}❌ $1${NC}"
}

STRUDEL_LOCAL_DIR="$HOME/.local/share/nvim/lazy/nvim-treesitter/queries/strudel"

echo 'Installing tree-sitter-strudel locally'
if [ ! -d "${STRUDEL_LOCAL_DIR}" ]; then
	mkdir -p ${STRUDEL_LOCAL_DIR}
	success "Created ${STRUDEL_LOCAL_DIR}"
else
	info "${STRUDEL_LOCAL_DIR} exists"
fi

info "Copying queries/*scm to ${STRUDEL_LOCAL_DIR}"
cp queries/*scm ${STRUDEL_LOCAL_DIR}

# Added ls command to show files in the directory
info "Printing files in ${STRUDEL_LOCAL_DIR}"
ls -la "${STRUDEL_LOCAL_DIR}"
