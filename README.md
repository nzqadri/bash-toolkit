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

### 3. Git Multi-Push Script (`git-multi-push.sh`)

A script to push your current code to multiple Git repositories (remotes) at the same time.

#### When This Script Can Help

Use this script when:

-   You need to keep a project synchronized across different services (e.g., GitHub and GitLab).
-   You maintain a private backup repository and want to push to it at the same time as your main repository.
-   You want to save time by not having to type `git push` for each remote individually.

#### Features

-   **Smart Default:** Pushes to *all* your configured remotes if you don't specify any.
-   **Targeted Pushing:** You can easily specify which remotes to push to.
-   **User-Friendly Output:** Uses colors to clearly show which pushes were successful and which failed.
-   **Supports Common Options:** Works with flags like `--force` and `--tags`.

#### How to Use

1.  **Give the script permission to run:**
    This is a one-time step for this script.
    ```bash
    chmod +x git-multi-push.sh
    ```

2.  **Push to ALL remotes:**
    This is the simplest way to use it.
    ```bash
    ./git-multi-push.sh
    ```

3.  **Push to specific remotes:**
    If you only want to push to `origin` and `gitlab`, for example.
    ```bash
    ./git-multi-push.sh origin gitlab
    ```

4.  **Push with options:**
    You can include other Git options, like forcing a push.
    ```bash
    ./git-multi-push.sh --force
    ```

---

### 4. Website Status Checker (`check-website.sh`)

A smart script to check if a website is online. If it seems down, it also checks if the problem is just on your end or if it's down for everyone.

#### When This Script Can Help

Use this script when:

-   You want to quickly see if a website is down, or if the problem is on your end.

#### Features

-   **Smart Check:** First checks locally, then uses an external service if the site appears down.
-   **Informative Status:** Tells you if a site is `UP`, `DOWN (Just for you)`, or `DOWN (For everyone)`.
-   **Fast & Efficient:** Uses a lightweight request that doesn't download the whole page.

#### How to Use

1.  **Give the script permission to run:**
    This is a one-time step for this script.
    ```bash
    chmod +x check-website.sh
    ```

2.  **Check a website:**
    Just provide the full URL of the site you want to check.
    ```bash
    ./check-website.sh https://www.github.com
    ```

---

### 5. SSL Expiry Check Script (`ssl-expiry-check.sh`)

A script to check when a website's SSL certificate will expire. This helps you renew it on time and avoid security warnings for your visitors.

#### When This Script Can Help

Use this script when:

-   You want to proactively check your website's SSL certificate status.
-   You need to monitor multiple domains and ensure none of them expire unexpectedly.

#### Features

-   **Clear Expiry Info:** Tells you exactly how many days are left until the certificate expires.
-   **Color-Coded Status:** Uses colors to show if the status is OK (green), a warning (yellow), or critical/expired (red).
-   **Custom Port Support:** Can check domains that use non-standard ports for HTTPS (e.g., `mydomain.com:8443`).

#### How to Use

1.  **Give the script permission to run:**
    This is a one-time step for this script.
    ```bash
    chmod +x ssl-expiry-check.sh
    ```

2.  **Check a domain's SSL certificate:**
    Just provide the domain name.
    ```bash
    ./ssl-expiry-check.sh google.com
    ```
    It will tell you the status and how many days are left.

---

## Hire Me

Looking for a skilled developer for your project? I'm available for freelance work on Upwork.

[![Hire Me on Upwork](https://img.shields.io/badge/Hire%20Me-Upwork-green.svg)](https://www.upwork.com/freelancers/~01315c3a41f60b61e7)