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
# Global Variables & Constants
##########################################################################################
readonly FILE_NAME=".update.sh"
readonly FILE_PATH="${HOME}/${FILE_NAME}"
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
            _rc="${HOME}/.bashrc"
            ;;
        alpine | arch)
            _rc="${HOME}/.profile"
            ;;
        *)
            echo "Error: Unsupported or unrecognized Linux distribution ${ADJUSTED_ID}"
            exit 1
            ;;
        esac

        # Check if alias update='sudo sh ${HOME}/.update.sh' is already defined, if not then append it
        if [ -f "${_rc}" ]; then
            if ! grep -qxF "alias update='sudo sh ${FILE_PATH}'" "${_rc}"; then
                echo "Updating ${_rc} for ${ADJUSTED_ID}..."
                printf "\n# Alias for Update\nalias update='sudo sh %s'\n" "${FILE_PATH}" >> "${_rc}"
            fi
        else
            # Notify if the rc file does not exist
            echo "Error: File ${_rc} does not exist."
            echo "Creating the ${_rc} file... although not sure if it will work."
            # Create the rc file
            touch "${_rc}"
            # Append the sourcing block to the newly created rc file
            printf "\n# Alias for Update\nalias update='sudo sh %s'\n" "${FILE_PATH}" >> "${_rc}"
        fi

        if [ -f "${_rc}" ]; then
            # shellcheck source=/dev/null
            . "${_rc}"
        fi
    fi
}

# Function: dw_file
# Description: Download file using wget or curl if available
dw_file() {
    # Check if curl is available
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "${HOME}/${FILE_NAME}" ${FILE_LINK}
    # Check if wget is available
    elif command -v wget >/dev/null 2>&1; then
        wget -O "${HOME}/${FILE_NAME}" ${FILE_LINK}
    else
        echo "Error: Either install wget or curl"
        exit 1
    fi
}

##########################################################################################
# Main Script
##########################################################################################

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
        echo "Error: Linux distro ${ID} not supported."
        exit 1
    fi
    ;;
*)
    echo "Error: Unsupported or unrecognized os distribution ${ADJUSTED_ID}"
    exit 1
    ;;
esac

if [ -f "${HOME}/${FILE_NAME}" ]; then
    echo "File already exists: ${HOME}/${FILE_NAME}"
    echo "Do you want to replace it (default: y)? [y/n]: "
    read -r rp_conf
    rp_conf="${rp_conf:-y}"
    if [ "${rp_conf}" = "y" ]; then
        # Replace the existing file
        echo "Replacing ${HOME}/${FILE_NAME}..."
        dw_file
        updaterc
    else
        echo "Keeping existing file: ${HOME}/${FILE_NAME}"
    fi
else
    dw_file
    updaterc
fi
