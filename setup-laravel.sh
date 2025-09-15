#!/bin/bash

# Author: Nabeel Qadri
# Description: Automates the setup of a new Laravel project.
#
# This script will:
# 1. Check for required tools (PHP, Composer, Git, NPM).
# 2. Create a new Laravel project using Composer.
# 3. Set up the .env file and generate an application key.
# 4. Initialize a Git repository with an initial commit.
# 5. Configure and create a local SQLite database.
# 6. Run the initial database migration.
# 7. Install NPM dependencies and build assets.
# 8. Set appropriate directory permissions.
#
# Usage:
# ./setup-laravel.sh <project-name>

set -eo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Functions ---
usage() {
    echo -e "Usage: $0 <project-name>"
    echo
    echo -e "Automates the setup of a new Laravel project."
    echo
    echo -e "${YELLOW}Arguments:${NC}"
    echo -e "  project-name   The name of the directory for the new Laravel project."
    echo
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -h, --help     Display this help message."
    exit 1
}

step() {
    echo -e "\n${YELLOW}==> $1${NC}"
}

confirm() {
    # call with a prompt string
    read -r -p "${1} [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

# --- Argument Parsing ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

if [ "$#" -ne 1 ]; then
    echo -e "${RED}Error: You must provide a project name.${NC}"
    usage
fi

PROJECT_NAME="$1"

if [ -d "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Directory '$PROJECT_NAME' already exists.${NC}"
    exit 1
fi

# --- Script Logic ---

step "1. Checking and installing prerequisites..."

# Determine package manager
PKG_MANAGER=""
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
elif command -v brew &> /dev/null; then
    PKG_MANAGER="brew"
fi

install_package() {
    local package_name="$1"
    echo -e "${YELLOW}Attempting to install '$package_name'...${NC}"
    case "$PKG_MANAGER" in
        apt) sudo apt-get update && sudo apt-get install -y "$package_name" ;;
        yum) sudo yum install -y "$package_name" ;;
        brew) brew install "$package_name" ;;
        *) echo -e "${RED}Unsupported package manager. Please install '$package_name' manually.${NC}"; exit 1 ;;
    esac
}

check_and_install() {
    local cmd="$1"
    local package_name="$2"
    if ! command -v "$cmd" &> /dev/null; then
        if confirm "'$cmd' is not installed. Would you like to attempt to install it?"; then
            install_package "$package_name"
            if ! command -v "$cmd" &> /dev/null; then
                echo -e "${RED}Installation of '$cmd' failed. Please install it manually and re-run the script.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}'$cmd' is required to continue. Aborting.${NC}"
            exit 1
        fi
    fi
}

install_composer() {
    if ! command -v composer &> /dev/null; then
        if confirm "'composer' is not installed. Would you like to download and install it?"; then
            echo -e "${YELLOW}Installing Composer...${NC}"
            EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
            php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
            ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

            if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
                echo >&2 'ERROR: Invalid installer checksum'
                rm composer-setup.php
                exit 1
            fi

            php composer-setup.php --install-dir=/usr/local/bin --filename=composer
            rm composer-setup.php
            echo -e "${GREEN}Composer installed successfully.${NC}"
        else
            echo -e "${RED}'composer' is required to continue. Aborting.${NC}"
            exit 1
        fi
    fi
}

check_and_install "php" "php"
check_and_install "git" "git"
check_and_install "npm" "nodejs" # npm is usually packaged with nodejs
install_composer

echo -e "${GREEN}All prerequisites are installed.${NC}"

step "2. Creating Laravel project '$PROJECT_NAME'..."
composer create-project laravel/laravel "$PROJECT_NAME"

cd "$PROJECT_NAME"

step "3. Setting up environment file..."
php -r "file_exists('.env') || copy('.env.example', '.env');"
php artisan key:generate
echo -e "${GREEN}.env file created and application key generated.${NC}"

step "4. Initializing Git repository..."
git init
git add .
git commit -m "Initial commit: Fresh Laravel installation"
echo -e "${GREEN}Git repository initialized.${NC}"

step "5. Setting up SQLite database..."
# Determine sed in-place edit argument for cross-platform compatibility (Linux vs macOS)
SED_I_ARG=(-i)
if [[ "$(uname)" == "Darwin" ]]; then
    SED_I_ARG=(-i '')
fi
# Comment out the existing MySQL config and set up SQLite
sed "${SED_I_ARG[@]}" 's/DB_CONNECTION=mysql/DB_CONNECTION=sqlite/' .env
sed "${SED_I_ARG[@]}" 's/^DB_HOST=/#DB_HOST=/' .env
sed "${SED_I_ARG[@]}" 's/^DB_PORT=/#DB_PORT=/' .env
sed "${SED_I_ARG[@]}" 's/^DB_DATABASE=/#DB_DATABASE=/' .env
sed "${SED_I_ARG[@]}" 's/^DB_USERNAME=/#DB_USERNAME=/' .env
sed "${SED_I_ARG[@]}" 's/^DB_PASSWORD=/#DB_PASSWORD=/' .env
touch database/database.sqlite
echo -e "${GREEN}SQLite database configured and created.${NC}"

step "6. Running initial database migration..."
php artisan migrate

step "7. Installing NPM dependencies..."
npm install

step "8. Building front-end assets..."
npm run build

step "9. Setting directory permissions..."
chmod -R 775 storage bootstrap/cache
echo -e "${GREEN}Permissions set for storage and cache directories.${NC}"

step "🎉 Laravel setup complete! 🎉"
echo -e "Your new project '${CYAN}$PROJECT_NAME${NC}' is ready."
echo -e "To get started, run the following commands:"
echo -e "  ${CYAN}cd $PROJECT_NAME${NC}"
echo -e "  ${CYAN}php artisan serve${NC}"

exit 0