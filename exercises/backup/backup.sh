#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -o pipefail

# Resolve paths relative to this script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/source"
BACKUP_DIR="$SCRIPT_DIR/backups"


# i wanna stock backups in 3 categories " Daily, week , month"
DAILY_DIR="$BACKUP_DIR/daily"
WEEKLY_DIR="$BACKUP_DIR/weekly"
MONTHLY_DIR="$BACKUP_DIR/monthly"
mkdir -p "$DAILY_DIR" "$WEEKLY_DIR" "$MONTHLY_DIR" # this command to check and assure the direcetories day,week, month are created

# Retention policies
DAILY_KEEP=7 # save last last 7 backups days
WEEKLY_KEEP=4 # save last 4 backups weeks
MONTHLY_KEEP=12 #save last 12 backup months

#-----------  BACKUP_FILE="$BACKUP_DIR/backup-$TIMESTAMP.tar.gz"



echo -e " ${YELLOW}================================"
echo "       BACKUP SCRIPT"
echo -e "================================${NC} "


rotate_backups() {
    local backup_dir="$1"
    local keep_count="$2"

    mapfile -t backups < <(
        find "$backup_dir" -maxdepth 1 -type f -name 'backup-*.tar.gz' \
            -printf '%f\n' | sort -r
    )
    #### Cherche uniquement dans le dossier cible (-maxdepth 1) les fichiers de type fichier (-type f) dont le nom commence par backup- et se termine par .tar.gz.
    #-printf '%f\n' : Extrait uniquement le nom du fichier (sans le chemin complet) suivi d'un retour à la ligne.
    # sort -r : Trie la liste par ordre décroissan
    # mapfile -t backups : Stocke chaque ligne du résultat dans un tableau Bash nommé backups.

    if [ "${#backups[@]}" -le "$keep_count" ]; then
        echo "Rotation: nothing to delete in $backup_dir"
        return 0
    fi

    for ((i = keep_count; i < ${#backups[@]}; i++)); do
        echo "Removing old backup: ${backups[$i]}"
        rm -f -- "$backup_dir/${backups[$i]}" \
                  "$backup_dir/${backups[$i]}.sha256"
    done
}
#   rotate_backups "$DAILY_DIR" "$Daily_keep"

#================================================================================================
create_backup() {
    local backup_dir="$1"
    local timestamp
    local backup_file
    local checksum_file

    timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    backup_file="$backup_dir/backup-$timestamp.tar.gz"
    checksum_file="$backup_file.sha256"
	
#    Create the compressed backup

    if ! tar -czf "$backup_file" \
        -C "$(dirname "$SOURCE_DIR")" \
        "$(basename "$SOURCE_DIR")"; then
        echo -e "${RED}ERROR: Failed to create backup"
        rm -f -- "$backup_file" "$checksum_file"
        return 1
    fi

#	Verify the backup

    if ! gzip -t "$backup_file"; then
        echo -e "${RED}ERROR: Archive integrity check failed"
        rm -f -- "$backup_file" "$checksum_file"
        return 1
    fi

#	SHA-256 checksum

    if ! sha256sum "$backup_file" > "$checksum_file"; then
        echo -e "${RED}ERROR: Failed to generate checksum"
        rm -f -- "$backup_file" "$checksum_file"
        return 1
    fi
#	Check checksum " Emprainte" 
    if ! sha256sum -c "$checksum_file"; then
        echo -e "${RED}ERROR: Checksum verification failed ${NC}"
        rm -f -- "$backup_file" "$checksum_file"
        return 1
    fi
    
    echo -e "${YELLOW}===================****=================="
    echo -e "${GREEN} DAILY Backup CREATED AND SHA VERIFIED \n File name :  $backup_file ${NC}"
    echo -e " ${YELLOW}==============================${NC}"
    return 0
}

# 1. Create and verify the daily backup
if create_backup "$DAILY_DIR";then
		echo -e "${GREEN} Daily Backup ALL is completed succesfully ${NC}"
		rotate_backups "$DAILY_DIR" "$DAILY_KEEP"
	else 
		echo -e "${RED} Daily BAckup FAILED ${NC}"
		exit 1
fi

# 2. Determine the current date
DAY_OF_WEEK=$(date +%u)   # Monday=1, Sunday=7
DAY_OF_MONTH=$(date +%d)  # First day of month=01

# 3. Create a weekly backup every Sunday
if [ "$DAY_OF_WEEK" -eq 7 ]; then
    if create_backup "$WEEKLY_DIR"; then
        echo -e "${GREEN}Weekly backup completed successfully${NC}"
        rotate_backups "$WEEKLY_DIR" "$WEEKLY_KEEP"
    else
        echo -e "${RED}Weekly backup failed${NC}"
        exit 1
    fi
fi


# 4. Create a monthly backup on the first day of the month
if [ "$DAY_OF_MONTH" -eq 1 ]; then
    if create_backup "$MONTHLY_DIR"; then
        echo -e "${GREEN}Monthly backup completed successfully${NC}"
        rotate_backups "$MONTHLY_DIR" "$MONTHLY_KEEP"
    else
        echo -e "${RED}Monthly backup failed${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}Backup process finished${NC}"

#=========================================================================================




