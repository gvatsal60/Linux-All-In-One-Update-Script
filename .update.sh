#!/bin/sh

##########################################################################################
# File: .update.sh
# Author: Vatsal Gupta
# Date: 11-Jul-2024
# Description: This script provides functions to update Linux distributions using their
#              respective package managers.
##########################################################################################

##########################################################################################
# License
##########################################################################################
# This script is licensed under the Apache 2.0 License.

##########################################################################################
# Global Variables & Constants
##########################################################################################
ADJUSTED_ID=""

##########################################################################################
# Functions
##########################################################################################
# Function: clean_up
# Description: Performs system cleanup tasks based on the detected Linux distribution.
#              Executes commands to clean package cache and remove unnecessary packages.
#              Provides output to indicate the cleanup process and handles errors gracefully.
# Usage: Call this function to automate system cleanup tasks after updating the system.
clean_up() {
    case ${ADJUSTED_ID} in
        debian)
            rm -rf /var/lib/apt/lists/*
            ;;
        rhel)
            rm -rf /var/cache/dnf/* /var/cache/yum/*
            rm -rf /tmp/yum.log
            ;;
        alpine)
            rm -rf /var/cache/apk/*
            ;;
        arch)
            rm -rf /var/cache/pacman/pkg/*
            ;;
        *)
            printf "\n%sError: Clean up not implemented for Linux distro: ${ADJUSTED_ID}%s\n" "${RED}" "${CLEAR}"
            ;;
    esac
}

# Function: os_pkg_update
# Description: Updates the system package cache and performs necessary updates based on the detected Linux distribution.
#              Supports Debian-based (apt-get), RPM-based (dnf/yum/microdnf), and Alpine (apk) package managers.
#              Prints messages indicating the update process and handles errors gracefully.
os_pkg_update() {
    case $ADJUSTED_ID in
        debian)
            if [ "$(find /var/lib/apt/lists/* -maxdepth 1 -type f 2>/dev/null | wc -l)" -eq 0 ]; then
                printf "\n%sUpdating ${PKG_MGR_CMD} based packages...%s\n" "${GREEN}" "${CLEAR}"
                if ! (${PKG_MGR_CMD} update -y && ${PKG_MGR_CMD} upgrade -y && ${PKG_MGR_CMD} autoremove -y); then
                    printf "\n%sError: Update failed.%s\n" "${RED}" "${CLEAR}"
                fi
            fi
            ;;
        rhel)
            if [ "${PKG_MGR_CMD}" = "microdnf" ]; then
                if [ "$(find /var/cache/yum/* -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null | wc -l)" -eq 0 ]; then
                    printf "\n%sRunning ${PKG_MGR_CMD} makecache...%s\n" "${GREEN}" "${CLEAR}"
                    ${PKG_MGR_CMD} makecache
                fi
            else
                if [ "$(find "/var/cache/${PKG_MGR_CMD}"/* -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null | wc -l)" -eq 0 ]; then
                    printf "\n%sRunning ${PKG_MGR_CMD} check-update...%s\n" "${GREEN}" "${CLEAR}"
                    set +e
                    ${PKG_MGR_CMD} check-update
                    rc=$?
                    if [ $rc -ne 0 ] && [ $rc -ne 100 ]; then
                        exit 1
                    fi
                    set -e
                fi
            fi

            printf "\n%sUpdating ${PKG_MGR_CMD} based packages...%s\n" "${GREEN}" "${CLEAR}"
            if ! (${PKG_MGR_CMD} update -y && ${PKG_MGR_CMD} upgrade -y && ${PKG_MGR_CMD} autoremove -y); then
                printf "\n%sError: Update failed.%s\n" "${RED}" "${CLEAR}"
            fi
            ;;
        alpine)
            if [ "$(find /var/cache/apk/* 2>/dev/null | wc -l)" -eq 0 ]; then
                printf "\n%sUpdating ${PKG_MGR_CMD} based packages...%s\n" "${GREEN}" "${CLEAR}"
                if ! (${PKG_MGR_CMD} update && ${PKG_MGR_CMD} upgrade); then
                    printf "\n%sError: Update failed.%s\n" "${RED}" "${CLEAR}"
                fi
            fi
            ;;
        arch)
            if [ "$(find /var/cache/pacman/pkg/* 2>/dev/null | wc -l)" -eq 0 ]; then
                printf "\n%sUpdating ${PKG_MGR_CMD} based packages...%s\n" "${GREEN}" "${CLEAR}"
                if ! (${PKG_MGR_CMD} -Syu --noconfirm && ${PKG_MGR_CMD} -Rns "$(${PKG_MGR_CMD} -Qdtq)"); then
                    printf "\n%sError: Update failed.%s\n" "${RED}" "${CLEAR}"
                fi
            fi
            ;;
        *)
            printf "\n%sError: Unsupported or unrecognized Linux distribution: ${ADJUSTED_ID}%s\n" "${RED}" "${CLEAR}"
            exit 1
            ;;
    esac
}

# Function: update_brew
# Description: Updates Homebrew formulas and casks, performs cleanup, and runs diagnostics.
update_brew() {
    printf "\n%sUpdate Brew Formula's%s\n" "${GREEN}" "${CLEAR}"

    if ! command -v brew >/dev/null 2>&1; then
        printf "\n%brew is not installed.%s\n" "${RED}" "${CLEAR}"
        return
    fi

    brew update && brew upgrade && brew cleanup -s

    printf "\n%sUpdate Brew Casks%s\n" "${GREEN}" "${CLEAR}"
    brew outdated --cask && brew upgrade --cask && brew cleanup -s

    printf "\n%sBrew Diagnostics%s\n" "${GREEN}" "${CLEAR}"
    brew doctor && brew missing
}

# Function: update_vscode_ext
# Description: Updates Visual Studio Code extensions if VSCode is installed.
update_vscode_ext() {
    printf "\n%sUpdating VSCode Extensions%s\n" "${GREEN}" "${CLEAR}"

    if ! command -v code >/dev/null 2>&1; then
        printf "\n%sVSCode is not installed.%s\n" "${RED}" "${CLEAR}"
        return
    fi

    code --update-extensions
}

# Function: update_gem
# Description: Updates RubyGems if the 'gem' command is installed.
update_gem() {
    printf "\n%sUpdating Gems%s\n" "${GREEN}" "${CLEAR}"

    if ! command -v gem >/dev/null 2>&1; then
        printf "\n%sGem is not installed.%s\n" "${RED}" "${CLEAR}"
        return
    fi

    gem update --user-install && gem cleanup --user-install
}

# Function: update_npm
# Description: Updates Npm packages if the 'npm' command is installed.
update_npm() {
    printf "\n%sUpdating Npm Packages%s\n" "${GREEN}" "${CLEAR}"

    if ! command -v npm >/dev/null 2>&1; then
        printf "\n%sNpm is not installed.%s\n" "${RED}" "${CLEAR}"
        return
    fi

    npm update -g
}

# Function: update_yarn
# Description: Updates Yarn packages if the 'yarn' command is installed.
update_yarn() {
    printf "\n%sUpdating Yarn Packages%s\n" "${GREEN}" "${CLEAR}"

    if ! command -v yarn >/dev/null 2>&1; then
        printf "\n%sYarn is not installed.%s\n" "${RED}" "${CLEAR}"
        return
    fi

    yarn upgrade --latest
}

# Function: update_pip3
# Description: Updates pip packages if the 'pip3' command is installed.
update_pip3() {
    printf "\n%sUpdating Python 3.x pips%s\n" "${GREEN}" "${CLEAR}"

    if ! command -v python3 >/dev/null 2>&1 || ! command -v pip3 >/dev/null 2>&1; then
        printf "\n%sPython 3 or pip3 is not installed.%s\n" "${RED}" "${CLEAR}"
        return
    fi

    # Running with a non-root user
    python3 -m pip list --outdated --format=columns | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 python3 -m pip install -U # FIXME
}

# Function: check_ping_support
# Description: Checks if the system can ping an external IP address (8.8.8.8) to verify network connectivity.
#              Attempts to ping without sudo first, then retries with sudo if necessary.
#              Prints messages indicating the status of ping support and returns appropriate exit codes.
# Returns:
#   0 - Success, ping is supported.
check_ping_support() {
    if ! command -v ping >/dev/null 2>&1; then
        printf "\n%sError: ping is not installed.%s\n" "${RED}" "${CLEAR}"
        exit 1
    fi

    readonly _PING_IP=8.8.8.8
    if ping -q -W 1 -c 1 ${_PING_IP} >/dev/null 2>&1; then
        return 0
    else
        printf "\n%sError: Network connectivity issue.%s\n" "${RED}" "${CLEAR}"
        exit 1
    fi
}

##########################################################################################
# Main Script
##########################################################################################

# Text Color Variables
# Check if the 'tput' command is available
# - '/dev/null 2>&1' redirects standard output (stdout) and standard error (stderr) to /dev/null, suppressing output.
# - If 'tput' is found, it likely indicates that color support is available.
if command -v tput >/dev/null 2>&1; then
    RED=$(tput setaf 1)   # Set text color to red
    GREEN=$(tput setaf 2) # Set text color to green
    CLEAR=$(tput sgr0)    # Reset text formatting
# If 'tput' is not available, check if color support is available by other means:
# - If file descriptor 1 (stdout) is associated with a terminal, then color support is assumed.
# - This check is performed using the '-t' test, which verifies if the file descriptor is connected to a terminal.
elif [ -t 1 ]; then
    RED=$(printf '\033[31m')   # Set text color to red using ANSI escape code
    GREEN=$(printf '\033[32m') # Set text color to green using ANSI escape code
    CLEAR=$(printf '\033[0m')  # Reset text formatting using ANSI escape code
else
    # If neither 'tput' nor the '-t' test is available, default to empty strings for color variables.
    RED=''
    GREEN=''
    CLEAR=''
fi

# Check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    printf "\n%sError: Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script..%s\n" "${RED}" "${CLEAR}"
    exit 1
fi

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
    printf "\n%sError: Linux distro ${ID} not supported.%s\n" "${RED}" "${CLEAR}"
    exit 1
fi

# Setup PKG_MGR_CMD
if type apt-get > /dev/null 2>&1; then
    PKG_MGR_CMD=apt-get
elif type apk > /dev/null 2>&1; then
    PKG_MGR_CMD=apk
elif type pacman > /dev/null 2>&1; then
    PKG_MGR_CMD=pacman
elif type microdnf > /dev/null 2>&1; then
    PKG_MGR_CMD=microdnf
elif type dnf > /dev/null 2>&1; then
    PKG_MGR_CMD=dnf
else
    PKG_MGR_CMD=yum
fi

if check_ping_support; then
    clean_up
    os_pkg_update
    update_brew
    update_vscode_ext
    update_gem
    update_npm
    update_yarn
    update_pip3
    printf "\n"
fi
