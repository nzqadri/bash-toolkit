#!/bin/bash

# Author: Nabeel Qadri
# This script interactively cleans up Docker resources.
# It will ask for confirmation before removing containers, images, networks, and volumes.
# Use the -y or --yes flag to skip all confirmations.
#
# How to use:
# 1. Save this script as docker-cleanup.sh
#
# 2. Make it executable:
#    chmod +x docker-cleanup.sh
#
# 3. Run in interactive mode (will ask for confirmation at each step):
#    ./docker-cleanup.sh
#
# 4. Run in non-interactive mode (will automatically approve all actions):
#    ./docker-cleanup.sh -y
#    or
#    ./docker-cleanup.sh --yes
#

set -eo pipefail

# Check for a non-interactive flag
FORCE_DELETE=false
if [[ "$1" == "-y" || "$1" == "--yes" ]]; then
    FORCE_DELETE=true
fi

# Function to ask for confirmation
confirm() {
    # If the force flag is set, automatically return true (exit code 0)
    if [ "$FORCE_DELETE" = true ]; then
        return 0
    fi
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

if [ "$FORCE_DELETE" = true ]; then
    echo "Starting non-interactive Docker cleanup (-y flag detected)..."
else
    echo "Starting interactive Docker cleanup..."
fi
echo

# 1. Stop and remove ALL containers.
if confirm "Do you want to stop and remove ALL containers (running and stopped)?"; then
    echo "Stopping and removing all containers..."
    ALL_CONTAINERS=$(docker ps -aq)
    if [ -n "$ALL_CONTAINERS" ]; then
        docker rm -f $ALL_CONTAINERS
    else
        echo "No containers to remove."
    fi
    echo
fi

# 2. Remove ALL images.
# This is intentionally placed after container removal.
if confirm "Do you want to remove ALL images (this is very destructive)?"; then
    echo "Removing all images..."
    ALL_IMAGES=$(docker images -q)
    if [ -n "$ALL_IMAGES" ]; then
        docker rmi -f $ALL_IMAGES
    else
        echo "No images to remove."
    fi
    echo
fi

# 3. Remove all unused networks.
if confirm "Do you want to remove all unused networks?"; then
    echo "Removing unused networks..."
    docker network prune -f
    echo
fi

# 4. Remove all unused volumes (dangling volumes).
if confirm "Do you want to remove all unused volumes (dangling volumes)?"; then
    echo "Removing unused volumes..."
    docker volume prune -f
    echo
fi

echo "Docker cleanup complete."