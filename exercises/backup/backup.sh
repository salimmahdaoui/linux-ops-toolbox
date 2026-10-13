#!bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -o pipefail

SOURCE_DIR="exercises/backup/source"
BACKUP_DIR="exercises/backup/backups"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/backup-$TIMESTAMP.tar.gz"

echo -e " ${YELLOW}================================"
echo "       BACKUP SCRIPT"
echo -e "================================${NC} "

# 1. Check the source directory

if [ ! -d "$SOURCE_DIR" ]; then
	echo -e " ${RED} ERROR : Source directory does not exist : $SOURCE_DIR ${NC} "
	exit 1 

fi

# 2. Create the compressed backup

if ! tar -czf "$BACKUP_FILE" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"; then
    echo -e " ${RED}ERROR: Failed to create backup ${NC} "
    exit 1
fi

echo -e " ${GREEN} Backup created: $BACKUP_FILE ${NC}  "

# 3. Verify the backup

	# Verify gzip integrity
if ! gzip -t "$BACKUP_FILE"; then
	echo -e " ${RED}ERROR Backup file is corrupted ${NC} "
	rm -f "$BACKUP_FILE"
	exit 1 
fi 

	# Generate SHA-256 checksum
CHECKSUM_FILE="$BACKUP_FILE.sha256"

if ! sha256sum "$BACKUP_FILE" > "$CHECKSUM_FILE"; then
	echo -e " ${RED}ERROR: FAILED to generate CHECKSUM ${NC} "
	rm -f "$BACKUP_FILE" "$CHECKSUM_FILE"
	exit 1
fi 

	# Verify checksum
if ! sha256sum -c "$CHECKSUM_FILE"; then
	echo -e " ${RED}ERROR: CHECKSUM  VERIFICATION FAILED ${NC} "
	rm -f "$BACKUP_FILE" "$CHECKSUM_FILE"
	exit 1 
fi 

echo -e " ${GREEN} Backup integrity verified successfully ${NC} "







