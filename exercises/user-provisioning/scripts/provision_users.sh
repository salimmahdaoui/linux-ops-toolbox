#!/bin/bash

set -o pipefail

# Resolve paths relative to this script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/config/users.yaml"


# Logging
log() {
    printf '[INFO] %s\n' "$*"
}

error() {
    printf '[ERROR] %s\n' "$*" >&2
}

# Check dependencies
check_dependencies() {

	if ! command -v yq >/dev/null 2>&1 ; then
		error " yq is not installed."
		return 1
	fi 
	
	if [[ ! -f "$CONFIG_FILE" ]]; then
		error "Configuration file not found: $CONFIG_FILE"
		return 1
	fi
	}

# Validate YAML configuration
validate_config() {

	log " Validating configuration "

	if ! yq -e ' .users | type == "!!seq" and length > 0 ' "$CONFIG_FILE" >/dev/null; then
		error "The YAML file must contain a non-empty users list."
		return 1
	fi 
	
	local count
    	count="$(yq '.users | length' "$CONFIG_FILE")" || return 1

    	log "Found $count user(s) in configuration."

    	local username shell_name

    	while IFS= read -r username; do
       		 [[ -n "$username" ]] || {
     		 error "A user has an empty username."
        	    return 1
	    	}

		 shell_name="$(yq -r \
        	    ".users[] | select(.username == \"$username\") | .shell" \
	            "$CONFIG_FILE")" || return 1

	 	if [[ -z "$shell_name" || "$shell_name" == "null" ]]; then
            	error "Missing shell for user: $username"
            	return 1
         	fi
     	
		 log "Validated user: $username"
   	 done < <(yq -r '.users[].username' "$CONFIG_FILE")

   	
    log "Configuration validation passed."	 
    
    }

validate_usernames(){
	local usernames
	local username
	local invalid=0
	local -A seen=()

	while IFS= read -r username; do 
		if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then 
			error " Invalid Linux username: $username "
			invalid=1
			continue
		fi
		
		if [[ -n "${seen[$username]+exists}" ]]; then
            		error "Duplicate username: $username"
            		invalid=1
            		continue
        	fi		

		seen["$username"]=1
	   	done < <(yq -r '.users[].username // ""' "$CONFIG_FILE")


    		(( invalid == 0 )) || return 1

}

# Valider les shells et les groupes
#

validate_user_settings(){
	local username shell_name group
	
	while IFS= read -r username; do
		shell_name="$(yq -r \
            	".users[] | select(.username == \"$username\") | .shell" \
            	"$CONFIG_FILE")" || return 1

        # Check that the shell is an absolute path and is allowed
		if [[ ! "$shell_name" =~ ^/ ]]; then
           		 error "Shell must be an absolute path for user: $username"
            		 return 1
        	fi

		if ! grep -Fxq "$shell_name" /etc/shells; then
            		error "Shell is not listed in /etc/shells: $shell_name"
            		return 1
        	fi

		if [[ ! -x "$shell_name" ]]; then
            		error "Shell does not exist or is not executable: $shell_name"
            		return 1
        	fi
# Check that groups is a YAML list

		if ! yq -e \
            		".users[] | select(.username == \"$username\") | (.groups | tag == \"!!seq\")" \
            		"$CONFIG_FILE" >/dev/null; then
            		error "Groups must be a list for user: $username"
            		return 1
        	fi

 # Check that each group name is valid
	 while IFS= read -r group; do
            		[[ -n "$group" ]] || {
                	error "Empty group for user: $username"
                	return 1
            		}

            if [[ ! "$group" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
                	error "Invalid group name '$group' for user: $username"
                	return 1
            fi
        	#log " username : $username => group : $group  "
    	 done < <(yq -r \
            	 ".users[] | select(.username == \"$username\") | .groups[]" \
           	 "$CONFIG_FILE")

	
	done < <(yq -r '.users[].username' "$CONFIG_FILE")
 	
	log "User settings validation passed."
	
}

validate_security_settings() {
    local username ssh_key sudo_value

    while IFS= read -r username; do
        ssh_key="$(yq -r \
            ".users[] | select(.username == \"$username\") | .ssh_key // \"\"" \
            "$CONFIG_FILE")" || return 1

        sudo_value="$(yq -r \
            ".users[] | select(.username == \"$username\") | .sudo" \
            "$CONFIG_FILE")" || return 1

        # Validate the sudo field
        if [[ "$sudo_value" != "true" && "$sudo_value" != "false" ]]; then
            error "The sudo field must be true or false for user: $username"
            return 1
        fi

        # Validate that an SSH public key is provided
        if [[ -z "$ssh_key" || "$ssh_key" == "null" ]]; then
            error "Missing SSH public key for user: $username"
            return 1
        fi

#        # Reject placeholders and unsupported key formats
#        case "$ssh_key" in
#            ssh-ed25519\ *|ssh-rsa\ *|ecdsa-sha2-nistp256\ *|ecdsa-sha2-nistp384\ *|ecdsa-sha2-nistp521\ *)
#                ;;
#            *)
#                error "Invalid SSH public key format for user: $username"
#                return 1
#               ;;
#        esac

	local key_file
        key_file="$(mktemp)" || {
            error "Could not create temporary file for SSH key validation."
            return 1
        }
	if ! printf '%s\n' "$ssh_key" > "$key_file"; then
            rm -f "$key_file"
            error "Could not write temporary SSH key for user: $username"
            return 1
        fi
	if ! ssh-keygen -l -f "$key_file" >/dev/null 2>&1; then
            rm -f "$key_file"
            error "Invalid SSH public key for user: $username"
            return 1
        fi
	#echo "this is the file key => $key_file"
	#cat "$key_file"
	rm -f "$key_file"

        log "* Security settings validated for user: $username"
    done < <(yq -r '.users[].username' "$CONFIG_FILE")

    log "Security settings validation passed."
}

# Il bloque toutes les actions destructrices ou modificatrices sur le système. Le script lit le fichier de configuration, fait toutes ses vérifications, mais au moment d'agir (créer un utilisateur, modifier un groupe, ajouter une clé SSH), il s'arrête, simule l'action et affiche simplement ce qu'il aurait fait à l'écran (souvent préfixé par [DRY-RUN])
# Tester sans risque
# Auditer les changements
#
DRY_RUN=false
parse_arguments() {
     case "${1:-}" in
        "")
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --help|-h)
            echo "Usage: $0 [--dry-run]"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            echo "Usage: $0 [--dry-run]"
            exit 2
            ;;
    esac
}

# Implémenter ensure_group()
# Si le groupe existe déjà : ne rien modifier.
# S'il n'existe pas : le créer avec groupadd.
# Si --dry-run est activé : afficher l'action prévue sans créer le groupe.

# la criation des groups et des users necessite les provoléges ADMIN sudo
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        error "This script must be run as root."
        return 1
    fi
}

ensure_group() {
    local group="$1"

    if getent group "$group" >/dev/null 2>&1; then
        log "Group already exists: $group"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] Would create group: $group"
        return 0
    fi

    log "Creating group: $group"

    if ! groupadd "$group"; then
        error "Failed to create group: $group"
        return 1
    fi

    log "Group created successfully: $group"
}
provision_groups() {
    local group

    log "Starting group provisioning..."

    while IFS= read -r group; do
        ensure_group "$group" || return 1
    done < <(yq -r '.users[].groups[]' "$CONFIG_FILE")

    log "Group provisioning completed."
}

# add user 
# mannuelement useradd -m -s /bin/bash -G developers lab_Salim

ensure_user() {
	local username="$1"
	local shell_name="$2"
	local groups="$3"
	
	if id "$username" >/dev/null 2>&1; then
        	log "User already exists: $username"
        	return 0
	fi
	if [[ "$DRY_RUN" == true ]]; then
        	log "[DRY-RUN] Would create user: $username"
        	log "[DRY-RUN] Shell: $shell_name"
        	log "[DRY-RUN] Groups: $groups"
        	return 0
	fi
	log "Creating user: $username"

	if ! useradd -m -s "$shell_name" -G "$groups" "$username"; then
        	error "Failed to create user: $username"
        	return 1
    	fi
	log "User created successfully: $username"
}

provision_users() {
	local username
    	local shell_name
    	local groups

	log "Starting user provisioning..."
	
	while IFS= read -r username; do

        	shell_name="$(yq -r \
            		".users[] | select(.username == \"$username\") | .shell" \
            		"$CONFIG_FILE")" || return 1

        	groups="$(yq -r \
            		".users[] | select(.username == \"$username\") | .groups | join(\",\")" \
            		"$CONFIG_FILE")" || return 1

        	ensure_user "$username" "$shell_name" "$groups" || return 1

	done < <(yq -r '.users[].username' "$CONFIG_FILE")
	log "User provisioning completed."
}

# permettre à chaque utilisateur de se connecter avec sa clé publique SSH. 
ensure_ssh_key() {
	
	local username="$1"
    	local ssh_key="$2"
    	local primary_group
    	local ssh_dir="/home/$username/.ssh"
    	local authorized_keys="$ssh_dir/authorized_keys"

#    	primary_group="$(id -gn "$username")" || {
		# ============ NOTE ===========
			# should this condition or variable's extraction happen after the condition
			#  of ======  DRY-RUN ============
#        	error "Cannot determine primary group for $username"
#        	return 1
#    	}

    	if [[ "$DRY_RUN" == true ]]; then
        	log "[DRY-RUN] Would install SSH key for: $username"
        	log "[DRY-RUN] SSH directory: $ssh_dir (700)"
        	log "[DRY-RUN] authorized_keys: (600)"
        	return 0
    	fi

        primary_group="$(id -gn "$username")" || {
                error "Cannot determine primary group for $username"
                return 1
        }

	# Create the SSH directory with secure permissions
    	install -d -m 700 -o "$username" -g "$primary_group" "$ssh_dir" || {
        	error "Failed to create SSH directory for $username"
        	return 1
    		}
	# Create authorized_keys if it does not exist
    	if [[ ! -e "$authorized_keys" ]]; then
        	install -m 600 -o "$username" -g "$primary_group" \
            	/dev/null "$authorized_keys" || return 1
    	fi

	# Avoid installing the same key twice
    	if grep -Fqx -- "$ssh_key" "$authorized_keys"; then
        	log "SSH key already installed for: $username"
        	return 0
    	fi

	if ! printf '%s\n' "$ssh_key" >> "$authorized_keys"; then
        	error "Failed to install SSH key for: $username"
        	return 1
    	fi

    	chown "$username:$primary_group" "$authorized_keys" || return 1
    	chmod 600 "$authorized_keys" || return 1

    	log "SSH key installed for: $username"
	
}

provision_ssh_keys() { 
	
	local username
    	local ssh_key

    	log "Starting SSH key provisioning..."

    	while IFS= read -r username; do

        	ssh_key="$(yq -r \
            	".users[] | select(.username == \"$username\") | .ssh_key" \
            	"$CONFIG_FILE")" || return 1

        	ensure_ssh_key "$username" "$ssh_key" || return 1

    	done < <(yq -r '.users[].username' "$CONFIG_FILE")

    	log "SSH key provisioning completed."

}

ensure_sudo_rule() {

	local username="$1"
    	local sudo_file="/etc/sudoers.d/$username"
    	local rule="$username ALL=(ALL:ALL) ALL"
	local temp_file

	if [[ "$DRY_RUN" == true ]]; then
        	log "[DRY-RUN] Would configure sudo for: $username"
        	return 0
    	fi
	temp_file="$(mktemp)" || {
        error "Could not create temporary sudoers file."
        return 1
    		}

	{
    	echo '# Managed by provision_users.sh'
    	echo "$rule" 
	} > "$temp_file" || {
        rm -f "$temp_file"
        return 1
    	}
	chmod 0440 "$temp_file"
	
	# we use visudo -c to check the syntax of permissions is ok or not, to avoid craching our server 
	if ! visudo -cf "$temp_file" >/dev/null; then
        	rm -f "$temp_file"
        	error "Invalid sudo rule for: $username"
        	return 1
    	fi

	if ! install -o root -g root -m 0440 "$temp_file" "$sudo_file"; then
        	rm -f "$temp_file"
        	error "Failed to install sudo rule for: $username"
        	return 1
    	fi
	rm -f "$temp_file"
	
	if ! visudo -c >/dev/null; then
        	error "Global sudoers validation failed."
        	return 1
    	fi
	log "Sudo configured for: $username"

}

remove_sudo_rule() {
    local username="$1"
    local sudo_file="/etc/sudoers.d/$username"
    local backup_file

    # Nothing to remove
   	if [[ ! -f "$sudo_file" ]]; then
		log "No sudo (False) rule found for: $username"
        	return 0
    	fi

    # Only remove files managed by this script
    	if ! grep -Fqx '# Managed by provision_users.sh' "$sudo_file"; then
        	error "Refusing to remove unmanaged sudoers file: $sudo_file"
        	return 1
    	fi

    	if [[ "$DRY_RUN" == true ]]; then
        	log "[DRY-RUN] Would remove sudo for: $username"
        	return 0
    	fi

    # Keep a backup in case global validation fails
   	 backup_file="$(mktemp)" || {
        error "Could not create sudoers backup."
        return 1
    }

    	cp -p "$sudo_file" "$backup_file" || {
        rm -f "$backup_file"
        error "Could not back up sudo rule for: $username"
        return 1
    }

   	if ! rm -f -- "$sudo_file"; then
        	rm -f "$backup_file"
        	error "Failed to remove sudo rule for: $username"
        	return 1
    	fi

    # Validate the complete sudoers configuration
    	if ! visudo -c >/dev/null; then
        	error "Global sudoers validation failed. Restoring previous rule."

        	install -o root -g root -m 0440 "$backup_file" "$sudo_file" || {
            	error "CRITICAL: Could not restore sudo rule for: $username"
            	rm -f "$backup_file"
            	return 1
        }

        	rm -f "$backup_file"
        	return 1
    	fi

    	rm -f "$backup_file"
    	log "Sudo removed for: $username"
}

provision_sudo() {

	local username
    	local sudo_value

	log "Starting sudo provisioning..."

	while IFS= read -r username; do
        	sudo_value="$(yq -r \
            	".users[] | select(.username == \"$username\") | .sudo" \
            	"$CONFIG_FILE")" || return 1

        	if [[ "$sudo_value" == "true" ]]; then
            		ensure_sudo_rule "$username" || return 1
        	elif [[ "$sudo_value" == "false" ]]; then
    			remove_sudo_rule "$username" || return 1
		else
        		error "Invalid sudo value for: $username"
    			return 1
		fi

    	done < <(yq -r '.users[].username' "$CONFIG_FILE")

    	log "Sudo provisioning completed."
}

main() {
	parse_arguments "$@" || exit $?
    	check_dependencies || exit 1
	validate_config || exit 1
	validate_usernames || exit 1
	validate_user_settings || exit 1
	validate_security_settings || exit 1
	#log "Validation stage completed. No system changes were made."
	if [[ "$DRY_RUN" != true ]]; then
        	check_root || exit 1
	fi 	
	provision_groups || exit 1
	provision_users || exit 1
	provision_ssh_keys || exit 1
	provision_sudo || exit 1
	log "Provisioning stage completed."
}

main "$@"
