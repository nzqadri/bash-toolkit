#!/bin/bash

# Author: Nabeel Qadri
# Description: This script creates a compressed tarball of a specified directory
#              and uploads it to an AWS S3 bucket.
#
# Usage:
# ./backup-to-s3.sh [OPTIONS] <SOURCE_DIRECTORY> <S3_BUCKET_NAME>
#
# Arguments:
#   SOURCE_DIRECTORY   The local directory to back up.
#   S3_BUCKET_NAME     The name of the S3 bucket to upload the backup to.
#
# Options:
#   -p, --profile      The AWS CLI profile to use (optional).
#   -h, --help         Display this help message.
#
# Prerequisites:
# - AWS CLI must be installed and configured.
#   (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

set -eo pipefail

# --- Functions ---
usage() {
    echo "Usage: $0 [OPTIONS] <SOURCE_DIRECTORY> <S3_BUCKET_NAME>"
    echo
    echo "Creates a compressed tarball of a directory and uploads it to an AWS S3 bucket."
    echo
    echo "Arguments:"
    echo "  SOURCE_DIRECTORY   The local directory to back up."
    echo "  S3_BUCKET_NAME     The name of the S3 bucket to upload the backup to."
    echo
    echo "Options:"
    echo "  -p, --profile      The AWS CLI profile to use (optional)."
    echo "  -h, --help         Display this help message."
    exit 1
}

# --- Argument Parsing ---
AWS_CLI_PROFILE=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--profile) AWS_CLI_PROFILE="$2"; shift ;;
        -h|--help) usage ;;
        -*) echo "Unknown option: $1"; usage ;;
        *) break ;; # Stop parsing options, the rest are positional arguments
    esac
    shift
done

if [ "$#" -ne 2 ]; then
    echo "Error: Missing required arguments."
    usage
fi

SOURCE_DIR="$1"
S3_BUCKET="$2"

# --- Script Logic ---

# 1. Check for prerequisites.
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it to continue." >&2
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist." >&2
    exit 1
fi

echo "Starting backup of '$SOURCE_DIR' to S3 bucket '$S3_BUCKET'..."

# 2. Create a timestamped filename for the backup.
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BASENAME=$(basename "$SOURCE_DIR")
BACKUP_FILENAME="${BASENAME}_${TIMESTAMP}.tar.gz"
LOCAL_BACKUP_PATH="/tmp/${BACKUP_FILENAME}"

# 3. Create the compressed backup archive.
echo "Creating backup archive: $LOCAL_BACKUP_PATH"
# The -C flag changes the directory so the tarball doesn't contain the full path.
tar -C "$(dirname "$SOURCE_DIR")" -czf "$LOCAL_BACKUP_PATH" "$BASENAME"

# 4. Construct the AWS CLI command with an optional profile.
AWS_CMD="aws s3 cp"
if [ -n "$AWS_CLI_PROFILE" ]; then
    AWS_CMD="$AWS_CMD --profile $AWS_CLI_PROFILE"
fi

# 5. Upload the backup to S3.
echo "Uploading backup to s3://$S3_BUCKET/$BACKUP_FILENAME..."
$AWS_CMD "$LOCAL_BACKUP_PATH" "s3://$S3_BUCKET/$BACKUP_FILENAME"

# 6. Clean up the local backup file.
echo "Cleaning up local archive..."
rm "$LOCAL_BACKUP_PATH"

echo "Backup complete!"
echo "File '$BACKUP_FILENAME' has been successfully uploaded to S3 bucket '$S3_BUCKET'."