#!/bin/bash

# Environment Setup
DB_USER="user"
DB_HOST="localhost"
export PGPASSWORD="" # Empty due to security risk

AWS_BUCKET="s3://awns-db-backup"
DATE=$(date +'%Y-%m-%d')
TIMESTAMP=$(date +'%H-%M-%S')
BACKUP_DIR="/tmp/db_backups/$DATE"
LOG_FILE="/tmp/db_backup_${DATE}.log"

# Target Microservice Databases
DATABASES=("db_name_1" "db_name_2")

mkdir -p "$BACKUP_DIR"
echo "--- Backup process started at $(date) ---" >> "$LOG_FILE"

for DB in "${DATABASES[@]}"; do
    FILENAME="${DB}_${DATE}_${TIMESTAMP}.backup"
    FILEPATH="${BACKUP_DIR}/${FILENAME}"

    echo "Backing up $DB..." | tee -a "$LOG_FILE"

    # Create compressed database dump
    pg_dump -h "$DB_HOST" -U "$DB_USER" \
        -F c \
        --no-owner \
        --no-privileges \
        -f "$FILEPATH" "$DB" >> "$LOG_FILE" 2>&1

    if [ $? -ne 0 ]; then
        echo "Dump failed for $DB" | tee -a "$LOG_FILE"
        continue
    fi

    # Upload to AWS S3
    echo "Uploading $FILENAME to S3..." | tee -a "$LOG_FILE"
    aws s3 cp "$FILEPATH" "$AWS_BUCKET/$DATE/$FILENAME" >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
        echo "Success: $DB uploaded" | tee -a "$LOG_FILE"
    else
        echo "S3 Upload failed for $DB" | tee -a "$LOG_FILE"
    fi
done

# Cleanup temporary local backup files
rm -rf "$BACKUP_DIR"
echo "--- Backup process completed at $(date) ---" >> "$LOG_FILE"

# Automation Setup (Cron Job)
# To automate this script, run 'crontab -e' and add this line 
# to run the backup daily at 2:00 AM:

# 0 2 * * * /home/ubuntu/scripts/db_backup.sh >> /var/log/db_backup_cron.log 2>&1