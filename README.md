# Bash Toolkit

**Author:** Nabeel Qadri

A collection of helpful command-line scripts to make managing your computer easier.

---

## Scripts

### 1. Docker Cleanup Script (`docker-cleanup.sh`)

A simple script to clean up old Docker items and free up hard drive space.

#### When This Script Can Help

Use this script when:

-   Your computer is running out of storage, and you think Docker might be using too much space.
-   You want to start fresh with Docker, removing everything you've built or downloaded.
-   You've been testing a lot with Docker and have many old, unused items left over.

#### Features

-   **Interactive Mode:** Asks for your permission before deleting anything, so you don't lose work by accident.
-   **Non-Interactive Mode:** A `-y` or `--yes` flag lets the script run automatically, which is great for scheduled tasks.
-   **Aggressive Cleanup:** Capable of stopping and removing *all* Docker containers and images for a complete reset.

#### How to Use

1.  **Give the script permission to run:**
    Before you can run the script, you need to make it "executable." This is a one-time step.
    ```bash
    chmod +x docker-cleanup.sh
    ```

2.  **Run in Interactive Mode (Recommended for most users):**
    The script will ask "yes" or "no" before it deletes anything.
    ```bash
    ./docker-cleanup.sh
    ```

3.  **Run in Automatic Mode (For advanced users):**
    This will delete everything without asking. **Use with caution!**
    ```bash
    ./docker-cleanup.sh -y
    ```

---

### 2. S3 Backup Script (`backup-to-s3.sh`)

A script to back up a folder from your computer to an Amazon S3 storage bucket.

#### Prerequisites

-   **AWS Command Line Interface (CLI):** You must have the AWS CLI tool installed and configured. This means you have already run `aws configure` and entered your AWS Access Key and Secret Key.
    -   Official AWS CLI Installation Guide

#### Features

-   **Easy to Use:** Just tell it which folder to back up and where to put it.
-   **Timestamped Backups:** Creates a unique, dated file for each backup (e.g., `my-folder_2023-10-27_10-30-00.tar.gz`), so you never overwrite old backups.
-   **Supports Multiple AWS Accounts:** Use the `-p` flag if you have more than one AWS account configured.
-   **Automatic Cleanup:** Deletes the temporary backup file from your computer after it's safely uploaded.

#### How to Use

1.  **Give the script permission to run:**
    Just like the other script, you need to make this one executable first.
    ```bash
    chmod +x backup-to-s3.sh
    ```

2.  **Run the backup:**
    The script needs two pieces of information: the folder you want to back up and the name of your S3 bucket.

    **Basic Example:**
    This command backs up the `/home/user/my-documents` folder to an S3 bucket named `my-secure-backup-bucket`.
    ```bash
    ./backup-to-s3.sh /home/user/my-documents my-secure-backup-bucket
    ```

    **Example with a specific AWS Profile:**
    If you have a special profile for work, you can specify it like this.
    ```bash
    ./backup-to-s3.sh -p work-profile /home/user/work-projects my-work-backups
    ```

3.  **Get Help:**
    If you forget how to use it, just ask for help.
    ```bash
    ./backup-to-s3.sh --help
    ```

---

## Hire Me

Looking for a skilled developer for your project? I'm available for freelance work on Upwork.

[![Hire Me on Upwork](https://img.shields.io/badge/Hire%20Me-Upwork-green.svg)](https://www.upwork.com/freelancers/~01315c3a41f60b61e7)