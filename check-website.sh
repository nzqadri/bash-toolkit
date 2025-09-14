#!/bin/bash

# Author: Nabeel Qadri
# Description: Checks if a website is up or down. If down, it checks if it's down for everyone or just you.
#
# Usage:
# ./check-website.sh <URL>
#
# Example:
# ./check-website.sh https://github.com

set -eo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Functions ---
usage() {
    echo -e "Usage: $0 <URL>"
    echo
    echo -e "Checks if a website is reachable. If it appears down, it uses an external"
    echo -e "service (isitup.org) to determine if it's down for everyone or just you."
    echo
    echo -e "${YELLOW}Arguments:${NC}"
    echo -e "  URL         The full URL of the website to check (e.g., https://www.google.com)."
    echo
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -h, --help  Display this help message."
    exit 1
}

# --- Argument Parsing ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

if [ "$#" -ne 1 ]; then
    echo -e "${RED}Error: You must provide exactly one URL to check.${NC}"
    usage
fi

URL_TO_CHECK="$1"

# --- Script Logic ---

# 1. Check for prerequisites
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: 'curl' is not installed. Please install it to use this script.${NC}" >&2
    exit 1
fi

echo -e "${YELLOW}Performing local check for: ${CYAN}$URL_TO_CHECK${NC}..."

# 2. Perform a local check first.
if curl --output /dev/null --silent --head --fail --connect-timeout 5 "$URL_TO_CHECK"; then
    echo -e "Status: ${GREEN}UP${NC} (Reachable from your location)"
    exit 0
else
    echo -e "Status: ${RED}DOWN${NC} (Not reachable from your location)"
    echo -e "${YELLOW}Performing external check to see if it's down for everyone...${NC}"

    # 3. If local check fails, use an external service.
    # Extract domain from the URL
    DOMAIN=$(echo "$URL_TO_CHECK" | sed -e 's|https\?://||' -e 's|/.*$||')

    # Query the isitup.org API
    EXTERNAL_STATUS_CODE=$(curl --silent "https://isitup.org/$DOMAIN.json" | grep -o '"status_code":[0-9]*' | cut -d':' -f2)

    case "$EXTERNAL_STATUS_CODE" in
        1)
            echo -e "External Status: ${RED}DOWN (Just for you)${NC}"
            ;;
        2)
            echo -e "External Status: ${RED}DOWN (For everyone)${NC}"
            ;;
        3)
            echo -e "External Status: ${YELLOW}Invalid Domain${NC}. Could not perform external check."
            ;;
        *)
            echo -e "External Status: ${YELLOW}Unknown${NC}. Could not determine external status."
            ;;
    esac
    exit 1
fi