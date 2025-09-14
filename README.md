# Docker Cleanup Script

**Author:** Nabeel Qadri

A powerful Bash script to clean up Docker resources and reclaim disk space.

## Overview

This script helps you manage your local Docker environment by removing unused or all Docker resources, including:

-   Containers
-   Images
-   Networks
-   Volumes

It can be run in an **interactive mode**, where it prompts for confirmation before each action, or in a **non-interactive mode** for use in automated scripts.

## When This Script Can Help

You should use this script when:

-   You are running low on disk space and suspect Docker is the culprit.
-   You want to completely reset your local Docker environment to a clean state.
-   Your Docker builds are slow, and you want to clear out old cache layers and images.
-   You frequently build and run containers for testing and need to clean up afterward.
-   You want to set up a scheduled job (e.g., a cron job) to perform regular maintenance on your system.

## Features

-   **Interactive Mode:** Asks for your confirmation before deleting anything, preventing accidental data loss.
-   **Non-Interactive Mode:** A `-y` or `--yes` flag allows the script to run without user input, perfect for automation.
-   **Aggressive Cleanup:** Capable of stopping and removing *all* containers and *all* images.
-   **Safe Pruning:** Safely removes unused networks and volumes.

## How to Use

1.  **Make the script executable:**
    ```bash
    chmod +x docker-cleanup.sh
    ```

2.  **Run in Interactive Mode:**
    The script will ask for confirmation before each major step.
    ```bash
    ./docker-cleanup.sh
    ```

3.  **Run in Non-Interactive (Force) Mode:**
    The script will automatically approve all actions. **Use with caution!**
    ```bash
    ./docker-cleanup.sh -y
    ```

## Hire Me

Looking for a skilled developer for your project? I'm available for freelance work on Upwork.

[![Hire Me on Upwork](https://img.shields.io/badge/Hire%20Me-Upwork-green.svg)](https://www.upwork.com/freelancers/~01315c3a41f60b61e7)