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
UPDATE_RC="${UPDATE_RC:-"true"}"

##########################################################################################
# Functions
##########################################################################################

# Function to update shell configuration files
updaterc() {
    local _rc
    if [ "${UPDATE_RC}" = "true" ]; then
        case $ADJUSTED_ID in
            debian | rhel)
                echo "Updating ~/.bashrc for ${ADJUSTED_ID}..."
                _rc=~/.bashrc
                ;;
            alpine)
                echo "Updating ~/.profile for ${ADJUSTED_ID}..."
                _rc=~/.profile
                ;;
            *)
                echo "Updating shell configuration files for ${ADJUSTED_ID}..."
                echo "Unsupported or unrecognized Linux distribution."
                exit 1
                ;;
        esac

        # Check if alias update='sudo sh ~/.update.sh' is already defined, if not then append it
        if ! grep -qxF "alias update='sudo sh ~/.update.sh'" "${_rc}"; then
            printf "\n# Alias for Update\nalias update='sudo sh ~/.update.sh'\n" >> "${_rc}"
        fi
    fi
}

##########################################################################################
# Main Script
##########################################################################################

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release

# Get an adjusted ID independent of distro variants
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
elif [ "${ID}" = "alpine" ]; then
    ADJUSTED_ID="alpine"
elif [[ "${ID}" = "rhel" || "${ID}" = "fedora" || "${ID}" = "mariner" || "${ID_LIKE}" = *"rhel"* || "${ID_LIKE}" = *"fedora"* || "${ID_LIKE}" = *"mariner"* ]]; then
    ADJUSTED_ID="rhel"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

updaterc