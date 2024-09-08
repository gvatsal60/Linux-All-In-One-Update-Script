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
readonly FILE_PATH="${HOME}/${FILE_NAME}"
readonly UPDATE_SCRIPT_SOURCE_URL="https://raw.githubusercontent.com/gvatsal60/Linux-All-In-One-Update-Script/HEAD/${FILE_NAME}"

readonly UPDATE_ALIAS_SEARCH_STR="alias update='sudo sh ${FILE_PATH}'"

UPDATE_ALIAS_SOURCE_STR=$(
    cat <<EOF

# Alias for Update
alias update='sudo sh ${FILE_PATH}'
EOF
)

###################################################################################################
# Functions
###################################################################################################

# Function: println
# Description: Prints each argument on a new line, suppressing any error messages.
println() {
    command printf %s\\n "$*" 2>/dev/null
}

# Function: updaterc
# Description: Update shell configuration files
updaterc() {
    _rc=""
    case $ADJUSTED_ID in
    debian | rhel)
        _rc="${HOME}/.bashrc"
        ;;
    alpine | arch)
        _rc="${HOME}/.profile"
        ;;
    *)
        println >&2 "Error: Unsupported or unrecognized Linux distribution ${ADJUSTED_ID}"
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

# Function: dw_file
# Description: Download file using wget or curl if available
dw_file() {
    # Check if curl is available
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "${FILE_PATH}" ${UPDATE_SCRIPT_SOURCE_URL}
    # Check if wget is available
    elif command -v wget >/dev/null 2>&1; then
        wget -O "${FILE_PATH}" ${UPDATE_SCRIPT_SOURCE_URL}
    else
        println >&2 "Error: Either install wget or curl"
        exit 1
    fi
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
        println >&2 "Error: Linux distro ${ID} not supported."
        exit 1
    fi
    ;;
*)
    println >&2 "Error: Unsupported or unrecognized OS distribution ${ADJUSTED_ID}"
    exit 1
    ;;
esac

# Default behavior
_action="y"

# Check if the script is running in interactive mode, for non-interactive mode `_action` defaults to 'y'
if [ -t 0 ]; then
    # Interactive mode
    if [ -f "${FILE_PATH}" ]; then
        println "=> File already exists: ${FILE_PATH}"
        println "=> Do you want to replace it (default: y)? [y/n]: "
        # Read input, use default value if no input is given
        read -r _rp_conf
        _rp_conf="${_rp_conf:-${_action}}"
        _action="${_rp_conf}"
    fi
fi

if [ "${_action}" = "y" ]; then
    println "=> Updating the file: ${FILE_PATH}"
    # Download the necessary file from the specified source
    dw_file
    # Update the configuration file with the latest changes
    updaterc
elif [ "${_action}" = "n" ]; then
    println "=> Keeping existing file: ${FILE_PATH}"
else
    println >&2 "Error: Invalid input. Please check your entry and try again."
    exit 1
fi
