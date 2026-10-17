#!/bin/bash

# Environment Setup
DB_USER="fp_dev_user"
DB_HOST="localhost"
export PGPASSWORD="" # Empty due to security risk

AWS_BUCKET="s3://awns-prd-db-backup"
BACKUP_BASE="/tmp/db_backups"
# Accepts date as argument (YYYY-MM-DD), defaults to today
DATE=${1:-$(date +'%Y-%m-%d')}
BACKUP_DIR="$BACKUP_BASE/$DATE"

# Target Microservice Databases
DATABASES=("db_name_1" "db_name_2")

echo "Starting clean restore for date: $DATE"

mkdir -p "$BACKUP_DIR"

for DB in "${DATABASES[@]}"; do
    FILENAME="${DB}-${DATE}.backup"
    FILE="$BACKUP_DIR/$FILENAME"
    S3_PATH="$AWS_BUCKET/$DATE/$FILENAME"

    echo "Processing $DB..."

    # Step 1: Download backup from S3 if not already downloaded
    if [ ! -f "$FILE" ]; then
        aws s3 cp "$S3_PATH" "$FILE" >/dev/null 2>&1
    fi

    # Step 2: Restore database
    if [ -f "$FILE" ]; then
        ERRORS=$(pg_restore -h "$DB_HOST" -U "$DB_USER" \
            -d "$DB" \
            -F c \
            --clean \
            --if-exists \
            --no-owner \
            --no-privileges \
            --no-comments \
            "$FILE" 2>&1 >/dev/null)

        FILTERED=$(echo "$ERRORS" | grep -E "ERROR:" | \
        grep -v -E "transaction_timeout|must be owner of extension")

        if [ -z "$FILTERED" ]; then
            echo "$DB restored successfully"
        else
            echo "REAL ERROR in $DB:"
            echo "$FILTERED"
        fi
    else
        echo "Backup file not found in S3 for $DB"
    fi
done

# Cleanup temporary files after restore (Optional but recommended)
rm -rf "$BACKUP_DIR"

echo "Clean restore completed!"