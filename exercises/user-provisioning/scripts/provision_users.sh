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

        # Reject placeholders and unsupported key formats
        case "$ssh_key" in
            ssh-ed25519\ *|ssh-rsa\ *|ecdsa-sha2-nistp256\ *|ecdsa-sha2-nistp384\ *|ecdsa-sha2-nistp521\ *)
                ;;
            *)
                error "Invalid SSH public key format for user: $username"
                return 1
                ;;
        esac

        log "* Security settings validated for user: $username"
    done < <(yq -r '.users[].username' "$CONFIG_FILE")

    log "Security settings validation passed."
}

main() {
    check_dependencies || exit 1
    validate_config || exit 1
    validate_usernames || exit 1
    validate_user_settings || exit 1
    validate_security_settings || exit 1
    log "Validation stage completed. No system changes were made."
}

main "$@"
