#!/bin/sh

##########################################################################################
# File: install.sh
# Author: Vatsal Gupta
# Date: 11-Jul-2024
# Description: This script updates shell configuration files based on the
#              adjusted Linux distribution ID determined from /etc/os-release.
##########################################################################################

##########################################################################################
# License
##########################################################################################
# This script is licensed under the Apache 2.0 License.

##########################################################################################
# Constants
##########################################################################################
readonly FILE_NAME=".update.sh"
readonly FILE_LINK="https://raw.githubusercontent.com/gvatsal60/Linux-All-In-One-Update-Script/HEAD/${FILE_NAME}"

UPDATE_RC="${UPDATE_RC:-"true"}"

##########################################################################################
# Functions
##########################################################################################

# Function: updaterc
# Description: Update shell configuration files
updaterc() {
    _rc=""
    if [ "${UPDATE_RC}" = "true" ]; then
        case $ADJUSTED_ID in
        debian | rhel)
            echo "Updating ~/.bashrc for ${ADJUSTED_ID}..."
            _rc=~/.bashrc
            ;;
        alpine | arch)
            echo "Updating ~/.profile for ${ADJUSTED_ID}..."
            _rc=~/.profile
            ;;
        *)
            echo "Error: Unsupported or unrecognized Linux distribution ${ADJUSTED_ID}"
            exit 1
            ;;
        esac

        # Check if alias update='sudo sh ~/.update.sh' is already defined, if not then append it
        if ! grep -qxF "alias update='sudo sh ~/.update.sh'" "${_rc}"; then
            printf "\n# Alias for Update\nalias update='sudo sh ~/.update.sh'\n" >>"${_rc}"
        fi
    fi
}

# Function: dw_file
# Description: Download alias file using wget or curl if available
dw_file() {
    # Check if wget is available
    if command -v wget >/dev/null 2>&1; then
        wget -O "${HOME}/${FILE_NAME}" ${FILE_LINK}
    # Check if curl is available
    elif command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "${HOME}/${FILE_NAME}" ${FILE_LINK}
    else
        printf "Either install wget or curl"
        exit 1
    fi
}

##########################################################################################
# Main Script
##########################################################################################

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
# shellcheck source=/dev/null
. /etc/os-release

# Get an adjusted ID independent of distro variants
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
elif [ "${ID}" = "alpine" ]; then
    ADJUSTED_ID="alpine"
elif [ "${ID}" = "arch" ] || [ "${ID_LIKE}" = "arch" ] || (echo "${ID_LIKE}" | grep -q "arch"); then
    ADJUSTED_ID="arch"
elif [ "${ID}" = "rhel" ] || [ "${ID}" = "fedora" ] || [ "${ID}" = "mariner" ] || (echo "${ID_LIKE}" | grep -q "rhel") || (echo "${ID_LIKE}" | grep -q "fedora") || (echo "${ID_LIKE}" | grep -q "mariner"); then
    ADJUSTED_ID="rhel"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

if [ -f "${HOME}/${FILE_NAME}" ]; then
    printf "File already exists: %s\n" "$HOME/${FILE_NAME}"
    printf "Do you want to replace it? [y/n]: "
    read -r rp_conf
    rp_conf="${rp_conf:-y}"
    if [ "$rp_conf" = "y" ]; then
        # Replace the existing file
        printf "\nReplacing %s...\n" "$HOME/${FILE_NAME}"
        dw_file
        updaterc
    else
        printf "\nKeeping existing file: %s\n" "$HOME/${FILE_NAME}"
    fi
else
    dw_file
    updaterc
fi
