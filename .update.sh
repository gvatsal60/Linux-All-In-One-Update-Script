#!/bin/sh

###################################################################################################
# File: .update.sh
# Author: [Vatsal Gupta (gvatsal60)]
# Date: 11-Jul-2024
# Description: This script provides functions to update Linux distributions using their
#              respective package managers.
###################################################################################################

###################################################################################################
# License
###################################################################################################
# This script is licensed under the Apache 2.0 License.

###################################################################################################
# Global Variables & Constants
###################################################################################################
# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

ADJUSTED_ID="None"

###################################################################################################
# Functions
###################################################################################################

# Function: println
# Description: Prints a message to the console in green color, followed by a newline.
# Usage: println "Your message here"
println() {
    printf "\n${GREEN}%s${CLEAR}\n" "$*" 2>/dev/null
}

# Function: print_err
# Description: Prints an error message to the console in red color, followed by a newline.
# Usage: print_err "Your error message here"
print_err() {
    printf "\n${RED}%s${CLEAR}\n" "$*" >&2
}

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
        print_err "Error: Clean up not implemented for Linux distro: ${ADJUSTED_ID}"
        ;;
    esac
}

# Function: os_pkg_update
# Description: Updates the system package cache and performs necessary updates based on the detected Linux distribution.
#              Supports Debian-based (apt-get), RPM-based (dnf/yum/microdnf), and Alpine (apk) package managers.
#              Prints messages indicating the update process and handles errors gracefully.
os_pkg_update() {
    case ${ADJUSTED_ID} in
    debian)
        if [ "$(find /var/lib/apt/lists/* -maxdepth 1 -type f 2>/dev/null | wc -l)" -eq 0 ]; then
            println "Updating ${PKG_MGR_CMD} based packages..."
            if ! (${PKG_MGR_CMD} update -y && ${PKG_MGR_CMD} upgrade -y && ${PKG_MGR_CMD} autoremove -y && ${PKG_MGR_CMD} dist-upgrade -y); then
                print_err "Error: Update failed."
            fi
        fi
        ;;
    rhel)
        if [ "${PKG_MGR_CMD}" = "microdnf" ]; then
            if [ "$(find /var/cache/yum/* -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null | wc -l)" -eq 0 ]; then
                println "Running ${PKG_MGR_CMD} makecache..."
                ${PKG_MGR_CMD} makecache
            fi
        else
            if [ "$(find "/var/cache/${PKG_MGR_CMD}"/* -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null | wc -l)" -eq 0 ]; then
                println "Running ${PKG_MGR_CMD} check-update..."
                set +e
                ${PKG_MGR_CMD} check-update
                rc=$?
                if [ $rc -ne 0 ] && [ $rc -ne 100 ]; then
                    exit 1
                fi
                set -e
            fi
        fi

        println "Updating ${PKG_MGR_CMD} based packages..."
        if ! (${PKG_MGR_CMD} update -y && ${PKG_MGR_CMD} upgrade -y && ${PKG_MGR_CMD} autoremove -y); then
            print_err "Error: Update failed."
        fi
        ;;
    alpine)
        if [ "$(find /var/cache/apk/* 2>/dev/null | wc -l)" -eq 0 ]; then
            println "Updating ${PKG_MGR_CMD} based packages..."
            if ! (${PKG_MGR_CMD} update && ${PKG_MGR_CMD} upgrade); then
                print_err "Error: Update failed."
            fi
        fi
        ;;
    arch)
        if [ "$(find /var/cache/pacman/pkg/* 2>/dev/null | wc -l)" -eq 0 ]; then
            println "Updating ${PKG_MGR_CMD} based packages..."
            if ! (${PKG_MGR_CMD} -Syu --noconfirm && ${PKG_MGR_CMD} -Rns "$(${PKG_MGR_CMD} -Qdtq)"); then
                print_err "Error: Update failed."
            fi
        fi
        ;;
    *)
        print_err "Error: Unsupported or unrecognized Linux distribution: ${ADJUSTED_ID}"
        exit 1
        ;;
    esac
}

# Function: update_brew
# Description: Updates Homebrew formulas and casks, performs cleanup, and runs diagnostics.
update_brew() {
    println "Update Brew Formula's"

    if ! command -v brew >/dev/null 2>&1; then
        print_err "Brew is not installed."
        return
    fi

    brew update && brew upgrade && brew cleanup -s

    println "Brew Diagnostics"
    brew doctor && brew missing
}

# Function: update_vscode_ext
# Description: Updates Visual Studio Code extensions if VSCode is installed.
update_vscode_ext() {
    println "Updating VSCode Extensions"

    if ! command -v code >/dev/null 2>&1; then
        print_err "VSCode is not installed."
        return
    fi

    code --update-extensions
}

# Function: update_gem
# Description: Updates RubyGems if the 'gem' command is installed.
update_gem() {
    println "Updating Gems"

    if ! command -v gem >/dev/null 2>&1; then
        print_err "Gem is not installed."
        return
    fi

    gem update --user-install && gem cleanup --user-install
}

# Function: update_npm
# Description: Updates Npm packages if the 'npm' command is installed.
update_npm() {
    println "Updating Npm Packages"

    if ! command -v npm >/dev/null 2>&1; then
        print_err "Npm is not installed."
        return
    fi

    npm update -g
}

# Function: update_yarn
# Description: Updates Yarn packages if the 'yarn' command is installed.
update_yarn() {
    println "Updating Yarn Packages"

    if ! command -v yarn >/dev/null 2>&1; then
        print_err "Yarn is not installed."
        return
    fi

    yarn upgrade --latest
}

# Function: update_pip3
# Description: Updates pip packages if the 'pip3' command is installed.
update_pip3() {
    println "Updating Python 3.x pips"

    if ! command -v python3 >/dev/null 2>&1 || ! command -v pip3 >/dev/null 2>&1; then
        print_err "Python3 or pip3 is not installed."
        return
    fi

    # Running with a non-root user
    python3 -m pip list --outdated --format=columns | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 python3 -m pip install -U # FIXME
}

# Function: update_cargo
# Description: Updates cargo packages if the 'cargo' command is installed.
update_cargo() {
    println "Updating Rust Cargo Crates"

    if ! command -v cargo >/dev/null 2>&1; then
        print_err "Rust/Cargo is not installed."
        return
    fi

    cargo install "$(cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ')"
}

# Function: check_ping_support
# Description: Checks if the system can ping an external IP address (8.8.8.8) to verify network connectivity.
#              Attempts to ping without sudo first, then retries with sudo if necessary.
#              Prints messages indicating the status of ping support and returns appropriate exit codes.
# Returns:
#   0 - Success, ping is supported.
check_ping_support() {
    if ! command -v ping >/dev/null 2>&1; then
        case ${ADJUSTED_ID} in
        debian)
            ${PKG_MGR_CMD} update && ${INSTALL_CMD} iputils-ping
            ;;
        rhel)
            ${PKG_MGR_CMD} update && ${INSTALL_CMD} iputils
            ;;
        alpine)
            ${PKG_MGR_CMD} update && ${INSTALL_CMD} iputils
            ;;
        arch)
            ${INSTALL_CMD} iputils
            ;;
        *)
            print_err "Error: Unable to install ping for distro ${ID}"
            print_err "Skipping ping installation..."
            ;;
        esac
    fi

    readonly _PING_IP=8.8.8.8
    if ping -q -W 1 -c 1 ${_PING_IP} >/dev/null 2>&1; then
        return 0
    else
        print_err "Error: Network connectivity issue."
        exit 1
    fi
}

###################################################################################################
# Main Script
###################################################################################################

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
    print_err "Error: Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.."
    exit 1
fi

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
# shellcheck source=/dev/null
. /etc/os-release

# Get an adjusted ID independent of distro variants
MAJOR_VERSION_ID=$(echo "${VERSION_ID}" | cut -d . -f 1)

# Get an adjusted ID independent of distro variants
if [ "${ID}" = "debian" ] || [ "${ID_LIKE#*debian}" != "${ID_LIKE}" ]; then
    ADJUSTED_ID="debian"
elif [ "${ID}" = "arch" ] || [ "${ID_LIKE#*arch}" != "${ID_LIKE}" ]; then
    ADJUSTED_ID="arch"
elif [ "${ID}" = "rhel" ] || [ "${ID}" = "fedora" ] || [ "${ID}" = "mariner" ] || [ "${ID_LIKE#*rhel}" != "${ID_LIKE}" ] || [ "${ID_LIKE#*fedora}" != "${ID_LIKE}" ] || [ "${ID_LIKE#*mariner}" != "${ID_LIKE}" ]; then
    ADJUSTED_ID="rhel"
    if [ "${ID}" = "rhel" ] || [ "${ID#*alma}" != "${ID}" ] || [ "${ID#*rocky}" != "${ID}" ]; then
        VERSION_CODENAME="rhel${MAJOR_VERSION_ID}"
    else
        VERSION_CODENAME="${ID}${MAJOR_VERSION_ID}"
    fi
elif [ "${ID}" = "alpine" ]; then
    ADJUSTED_ID="alpine"
else
    print_err "Error: Linux distro ${ID} not supported."
    exit 1
fi

if [ "${ADJUSTED_ID}" = "rhel" ] && [ "${VERSION_CODENAME-}" = "centos7" ]; then
    # As of 1 July 2024, mirrorlist.centos.org no longer exists.
    # Update the repo files to reference vault.centos.org.
    sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
    sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
    sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo
fi

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

if check_ping_support; then
    clean_up
    os_pkg_update
    update_brew
    update_vscode_ext
    update_gem
    update_npm
    update_yarn
    update_pip3
    update_cargo
fi
