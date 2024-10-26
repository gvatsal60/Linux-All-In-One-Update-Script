#!/bin/sh

###################################################################################################
# File: install.sh
# Author: [Vatsal Gupta (gvatsal60)]
# Date: 11-Jul-2024
# Description: This script updates shell configuration files based on the
#              adjusted Linux distribution ID determined from /etc/os-release.
###################################################################################################

###################################################################################################
# License
###################################################################################################
# This script is licensed under the Apache 2.0 License.

###################################################################################################
# Global Variables & Constants
###################################################################################################
# Exit the script immediately if any command fails
set -e

readonly FILE_NAME=".update.sh"
readonly UPDATE_SCRIPT_SOURCE_URL="https://raw.githubusercontent.com/gvatsal60/Linux-All-In-One-Update-Script/HEAD/${FILE_NAME}"

readonly UPDATE_ALIAS_SEARCH_STR="alias update='curl -fsSL ${UPDATE_SCRIPT_SOURCE_URL} | ${SHELL}'"

UPDATE_ALIAS_SOURCE_STR=$(
    cat <<EOF

# Alias for Update
${UPDATE_ALIAS_SEARCH_STR}
EOF
)

###################################################################################################
# Functions
###################################################################################################

# Function: println
# Description: Prints a message to the console, followed by a newline.
# Usage: println "Your message here"
println() {
    printf "\n%s\n" "$*" 2>/dev/null
}

# Function: print_err
# Description: Prints an error message to the console, followed by a newline.
# Usage: print_err "Your error message here"
print_err() {
    printf "\n%s\n" "$*" >&2
}

# Function: update_rc
# Description: Update shell configuration files
update_rc() {
    _rc=""
    case $ADJUSTED_ID in
    debian | rhel)
        _rc="${HOME}/.bashrc"
        ;;
    alpine | arch)
        _rc="${HOME}/.profile"
        ;;
    *)
        print_err "Error: Unsupported or unrecognized Linux distribution ${ADJUSTED_ID}"
        exit 1
        ;;
    esac

    # Check if `alias update='sudo sh ${HOME}/.update.sh'` is already defined, if not then append it
    if [ -f "${_rc}" ]; then
        if ! grep -qxF "${UPDATE_ALIAS_SEARCH_STR}" "${_rc}"; then
            println "=> Updating ${_rc} for ${ADJUSTED_ID}..."
            println "${UPDATE_ALIAS_SOURCE_STR}" >>"${_rc}"
        fi
    else
        # Notify if the rc file does not exist
        println "=> Profile not found. ${_rc} does not exist."
        println "=> Creating the file ${_rc}... Please note that this may not work as expected."
        # Create the rc file
        touch "${_rc}"
        # Append the sourcing block to the newly created rc file
        println "${UPDATE_ALIAS_SOURCE_STR}" >>"${_rc}"
    fi

    println ""
    println "=> Close and reopen your terminal to start using 'update' alias"
    println "   OR"
    println "=> Run the following to use it now:"
    println ">>> source ${_rc} # This loads update alias"
}

###################################################################################################
# Main Script
###################################################################################################

OS=$(uname)

case ${OS} in
Linux)
    # Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
    # shellcheck source=/dev/null
    . /etc/os-release

    # Get an adjusted ID independent of distro variants
    if [ "${ID}" = "debian" ] || [ "${ID_LIKE#*debian}" != "${ID_LIKE}" ]; then
        ADJUSTED_ID="debian"
    elif [ "${ID}" = "arch" ] || [ "${ID_LIKE#*arch}" != "${ID_LIKE}" ]; then
        ADJUSTED_ID="arch"
    elif [ "${ID}" = "rhel" ] || [ "${ID}" = "fedora" ] || [ "${ID}" = "mariner" ] || [ "${ID_LIKE#*rhel}" != "${ID_LIKE}" ] || [ "${ID_LIKE#*fedora}" != "${ID_LIKE}" ] || [ "${ID_LIKE#*mariner}" != "${ID_LIKE}" ]; then
        ADJUSTED_ID="rhel"
    elif [ "${ID}" = "alpine" ]; then
        ADJUSTED_ID="alpine"
    else
        print_err "Error: Linux distro ${ID} not supported."
        exit 1
    fi
    ;;
*)
    print_err "Error: Unsupported or unrecognized OS distribution ${ADJUSTED_ID}"
    exit 1
    ;;
esac

# Check if curl is available
if ! command -v curl >/dev/null 2>&1; then
    print_err "Error: curl is required but not installed. Please install curl."
    exit 1
fi

# Update the rc (.bashrc, .profile ...) file for `update` alias
update_rc
