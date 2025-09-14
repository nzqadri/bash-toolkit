#!/bin/bash

# Author: Nabeel Qadri
# Description: Pushes the current branch to multiple Git remotes.
#
# Usage:
# ./git-multi-push.sh [OPTIONS] [REMOTE_NAME_1] [REMOTE_NAME_2] ...
#
# If no remote names are provided, it pushes to all configured remotes.
#
# Options:
#   --tags             Push all tags as well.
#   -f, --force        Force the push (use with caution).
#   -h, --help         Display this help message.

set -eo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Functions ---
usage() {
    # Using -e to enable color interpretation
    echo -e "Usage: $0 [OPTIONS] [REMOTE_NAME_1] [REMOTE_NAME_2] ..."
    echo
    echo -e "Pushes the current Git branch to one or more remotes."
    echo -e "If no remotes are specified, it pushes to all configured remotes."
    echo
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  --tags             Push all tags as well."
    echo -e "  -f, --force        ${RED}Force the push (use with caution).${NC}"
    echo -e "  -h, --help         Display this help message."
    exit 1
}

# --- Argument Parsing ---
PUSH_OPTIONS=""
REMOTES=()
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --tags) PUSH_OPTIONS="$PUSH_OPTIONS --tags";;
        -f|--force) PUSH_OPTIONS="$PUSH_OPTIONS --force";;
        -h|--help) usage ;;
        -*) echo -e "${RED}Unknown option: $1${NC}"; usage ;;
        *) REMOTES+=("$1") ;; # Add to remotes array
    esac
    shift
done

# --- Script Logic ---

# 1. Check if inside a Git repository.
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo -e "${RED}Error: Not a Git repository. Please run this script from within a Git repository.${NC}" >&2
    exit 1
fi

# 2. Determine the current branch.
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" == "HEAD" ]; then
    echo -e "${RED}Error: You are in a detached HEAD state. Please check out a branch to push.${NC}" >&2
    exit 1
fi
echo -e "${YELLOW}Current branch is '${CYAN}$CURRENT_BRANCH${YELLOW}'.${NC}"

# 3. If no remotes were passed as arguments, get all configured remotes.
if [ ${#REMOTES[@]} -eq 0 ]; then
    echo -e "${YELLOW}No remotes specified. Detecting all configured remotes...${NC}"
    mapfile -t REMOTES < <(git remote)
fi

# 4. Check if any remotes exist.
if [ ${#REMOTES[@]} -eq 0 ]; then
    echo -e "${RED}Error: No Git remotes found or specified.${NC}" >&2
    exit 1
fi

# 5. Loop through the remotes and push.
echo -e "${YELLOW}Preparing to push branch '${CYAN}$CURRENT_BRANCH${YELLOW}' to remotes: ${CYAN}${REMOTES[*]}${NC}"
echo

for remote in "${REMOTES[@]}"; do
    echo -e "--- Pushing to '${CYAN}$remote${NC}' ---"
    # Use "git push <options>" and handle potential failures gracefully.
    if git push $PUSH_OPTIONS "$remote" "$CURRENT_BRANCH"; then
        echo -e "${GREEN}--- Successfully pushed to '$remote' ---${NC}"
    else
        echo -e "${RED}--- FAILED to push to '$remote' ---${NC}"
    fi
    echo
done

echo -e "${GREEN}Multi-push complete.${NC}"