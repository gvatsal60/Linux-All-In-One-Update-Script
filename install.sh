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

UPDATE_SOURCE_STR=$(
    cat <<EOF

# System Update
update() {
    # Check if curl is available
    if ! command -v curl >/dev/null 2>&1; then
        echo "Error: curl is required but not installed. Please install curl." >&2
        return
    fi

    # Check internet connection by pinging a reliable server
    TEST_URL="https://www.google.com"

    # Use curl to check the connection
    TEST_RESP=\$(curl -Is --connect-timeout 5 --max-time 10 "\${TEST_URL}" 2>/dev/null | head -n 1)

    # Check if response is empty
    if [ -z "\${TEST_RESP}" ]; then
        echo "No Internet Connection!!!" >&2
        return
    fi

    # Check for "200" in the response
    if ! printf "%s" "\${TEST_RESP}" | grep -q "200"; then
        echo "Internet is not working!!!" >&2
        return
    fi

    curl -fsSL ${UPDATE_SCRIPT_SOURCE_URL} | \${SHELL}
}

EOF
)

###################################################################################################
# Functions
###################################################################################################

# Function: println
# Description: Prints a message to the console, followed by a newline.
# Usage: println "Your message here"
println() {
    printf "%s\n" "$*" 2>/dev/null
}

# Function: print_err
# Description: Prints an error message to the console, followed by a newline.
# Usage: print_err "Your error message here"
print_err() {
    printf "%s\n" "$*" >&2
}

# Function: check_command
# Description: Checks if a specified command is available in the system.
#              Prints a message indicating whether the command is installed.
# Usage: check_command "command_name"
check_command() {
    command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        print_err "${command_name} is not installed."
        return 1
    fi

    return 0
}

# Function: install_pkg
# Description: Installs a specified package using the appropriate package manager
#              if the system's package manager is available.
install_pkg() {
    pkg_name="$1"

    if ! check_command "${pkg_name}"; then
        # Setup INSTALL_CMD & PKG_MGR_CMD
        if type apt-get >/dev/null 2>&1; then
            PKG_MGR_CMD=apt-get
            INSTALL_CMD="${PKG_MGR_CMD} -y install --no-install-recommends"
        elif type apk >/dev/null 2>&1; then
            PKG_MGR_CMD=apk
            INSTALL_CMD="${PKG_MGR_CMD} add --no-cache"
        elif type pacman >/dev/null 2>&1; then
            PKG_MGR_CMD=pacman
            INSTALL_CMD="${PKG_MGR_CMD} -S --noconfirm --needed"
        elif type microdnf >/dev/null 2>&1; then
            PKG_MGR_CMD=microdnf
            INSTALL_CMD="${PKG_MGR_CMD} -y install --refresh --best --nodocs --noplugins --setopt=install_weak_deps=0"
        elif type dnf >/dev/null 2>&1; then
            PKG_MGR_CMD=dnf
            INSTALL_CMD="${PKG_MGR_CMD} -y install"
        elif type yum >/dev/null 2>&1; then
            PKG_MGR_CMD=yum
            INSTALL_CMD="${PKG_MGR_CMD} -y install"
        else
            print_err "Error: Unsupported or unrecognized package manager"
            exit 1
        fi

        case ${ADJUSTED_ID} in
        debian)
            ${PKG_MGR_CMD} update && ${INSTALL_CMD} "${pkg_name}"
            ;;
        rhel)
            ${PKG_MGR_CMD} update && ${INSTALL_CMD} "${pkg_name}"
            ;;
        alpine)
            ${PKG_MGR_CMD} update && ${INSTALL_CMD} "${pkg_name}"
            ;;
        arch)
            ${INSTALL_CMD} "${pkg_name}"
            ;;
        *)
            print_err "Error: Unable to install ${pkg_name} for distro ${ID}"
            ;;
        esac
    fi
}

# Function: update_rc
# Description: Update shell configuration files
update_rc() {
    _rc=""
    case ${ADJUSTED_ID} in
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
        if ! awk '/^update\(\) {/,/^}/' "${_rc}" | grep -q 'curl'; then
            println "=> Updating ${_rc} for ${ADJUSTED_ID}..."
            println "${UPDATE_SOURCE_STR}" >>"${_rc}"
        fi
    else
        # Notify if the rc file does not exist
        println "=> Profile not found. ${_rc} does not exist."
        println "=> Creating the file ${_rc}... Please note that this may not work as expected."
        # Create the rc file
        touch "${_rc}"
        # Append the sourcing block to the newly created rc file
        println "${UPDATE_SOURCE_STR}" >>"${_rc}"
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
if ! check_command curl; then
    # Install curl
    install_pkg curl
fi

# Update the rc (.bashrc, .profile ...) file for `update` alias
update_rc
