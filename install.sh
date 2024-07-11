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

updaterc
