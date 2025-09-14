#!/bin/bash

# Author: Nabeel Qadri
# Description: Checks SSL certificate expiration. Can optionally attempt to renew
#              certificates using certbot if they are close to expiring.
#
# Usage:
# ./ssl-expiry-check.sh [OPTIONS] <domain_or_file>
#
# Examples:
# ./ssl-expiry-check.sh --renew domains.txt

set -eo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Thresholds ---
WARN_DAYS=30
CRIT_DAYS=14

# --- Functions ---
usage() {
    echo -e "Usage: $0 [OPTIONS] <domain_or_file>"
    echo
    echo -e "Checks the expiration date of SSL certificates. If a certificate is near expiry,"
    echo -e "it can attempt to renew it using 'certbot'."
    echo
    echo -e "${YELLOW}Arguments:${NC}"
    echo -e "  domain_or_file   A single domain (e.g., google.com:443) or a path to a file"
    echo -e "                   containing one domain per line."
    echo
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  --renew          If a certificate is in the critical range, attempt to renew it"
    echo -e "                   using 'certbot renew'. This may require running the script with 'sudo'."
    echo -e "  -h, --help       Display this help message."
    exit 1
}

check_domain() {
    local TARGET="$1"
    local RENEW_ATTEMPTED="$2" # Recursion guard
    local DOMAIN=$(echo "$TARGET" | cut -d: -f1)
    local PORT=$(echo "$TARGET" | cut -d: -f2)
    if [ "$DOMAIN" == "$PORT" ]; then
        PORT=443
    fi

    echo -e "${YELLOW}Checking SSL certificate for: ${CYAN}$DOMAIN:$PORT${NC}..."

    # Get the certificate's expiration date string
    # Use a timeout to prevent the script from hanging
    local EXPIRY_DATE_STR=$(echo | timeout 5 openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:$PORT" 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)

    if [ -z "$EXPIRY_DATE_STR" ]; then
        echo -e "Status: ${RED}ERROR${NC}. Could not retrieve certificate from ${CYAN}$DOMAIN:$PORT${NC}."
        return
    fi

    # Convert the date string to seconds since epoch (handles Linux vs macOS date command)
    local EXPIRY_SECONDS
    if [[ "$(uname)" == "Darwin" ]]; then # macOS
        EXPIRY_SECONDS=$(date -j -f "%b %d %T %Y %Z" "$EXPIRY_DATE_STR" "+%s")
    else # Linux
        EXPIRY_SECONDS=$(date -d "$EXPIRY_DATE_STR" "+%s")
    fi

    local CURRENT_SECONDS=$(date "+%s")
    local DAYS_LEFT=$(((EXPIRY_SECONDS - CURRENT_SECONDS) / 86400))

    # Display the result with appropriate colors
    if [ "$DAYS_LEFT" -lt 0 ]; then
        echo -e "Status: ${RED}EXPIRED${NC}. The certificate for ${CYAN}$DOMAIN${NC} expired ${DAYS_LEFT#-} days ago on ${EXPIRY_DATE_STR}."
    elif [ "$DAYS_LEFT" -lt "$CRIT_DAYS" ]; then
        echo -e "Status: ${RED}CRITICAL${NC}. Expires in ${DAYS_LEFT} days on ${EXPIRY_DATE_STR}."
    elif [ "$DAYS_LEFT" -lt "$WARN_DAYS" ]; then
        echo -e "Status: ${YELLOW}WARNING${NC}. Expires in ${DAYS_LEFT} days on ${EXPIRY_DATE_STR}."
    else
        echo -e "Status: ${GREEN}OK${NC}. Expires in ${DAYS_LEFT} days on ${EXPIRY_DATE_STR}."
    fi
}

# --- Argument Parsing ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

if [ "$#" -ne 1 ]; then
    echo -e "${RED}Error: You must provide a domain or a file path to check.${NC}"
    usage
fi

INPUT="$1"

# --- Script Logic ---

if ! command -v openssl &> /dev/null; then
    echo -e "${RED}Error: 'openssl' is not installed. Please install it to use this script.${NC}" >&2
    exit 1
fi

if [ -f "$INPUT" ]; then
    echo -e "Reading domains from file: ${CYAN}$INPUT${NC}\n"
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Ignore empty lines and comments
        [[ -z "$line" ]] || [[ "$line" =~ ^#.* ]] && continue
        check_domain "$line" "false"
        echo
    done < "$INPUT"
else
    check_domain "$INPUT" "false"
fi