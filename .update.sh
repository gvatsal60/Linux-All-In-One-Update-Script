#!/bin/sh

###################################################################################################
# File: .update.sh
# Author: Vatsal Gupta(@gvatsal60)
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

NON_ROOT_USER=$(logname 2>/dev/null || echo "nobody")

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

# Function: check_cmd
# Description: Checks if a specified command is available in the system.
# Usage: check_cmd "command_name"
check_cmd() {
    command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        return 1
    fi

    return 0
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

# Function: cleanup_snapd
# Description: Performs cleanup tasks for Snap packages by removing old revisions,
#              purging unused dependencies, and freeing up disk space.
#              Provides feedback on the cleanup process and handles errors gracefully.
# Usage: Call this function to automate Snap-related cleanup tasks.
cleanup_snapd() {
    if ! check_command snap; then
        return
    fi

    rm -rf /var/lib/snapd/cache/*

    # Get snap list output once and store it
    if ! snap_output=$(snap list --all); then
        print_err "Error: Failed to retrieve snap list."
        return
    fi

    # Check if no snaps are installed
    if echo "${snap_output}" | grep -q "No snaps are installed"; then
        return
    fi

    # Process the stored output to find disabled snaps
    echo "${snap_output}" | awk '/disabled/{print $1, $3}' | while read -r snap_name revision; do
        # Check if variables are set and not empty
        if [ -z "${snap_name}" ] || [ -z "${revision}" ]; then
            print_err "Error: Snap name or revision is empty. Skipping..."
            continue
        fi

        # Attempt to remove the snap revision
        if ! snap remove "${snap_name}" --revision="${revision}"; then
            print_err "Error: Failed to remove ${snap_name} (revision ${revision})."
        fi
    done
}

# Function: clean_up
# Description: Performs system cleanup tasks based on the detected Linux distribution.
#              Executes commands to clean package cache and remove unnecessary packages.
#              Provides output to indicate the cleanup process and handles errors gracefully.
# Usage: Call this function to automate system cleanup tasks after updating the system.
clean_up() {
    case ${ADJUSTED_ID} in
    debian)
        # rm -rf /var/lib/apt/lists/*
        cleanup_snapd
        ;;
    rhel)
        # rm -rf /var/cache/dnf/* /var/cache/yum/*
        rm -rf /tmp/yum.log
        ;;
    alpine)
        # rm -rf /var/cache/apk/*
        ;;
    arch)
        # rm -rf /var/cache/pacman/pkg/*
        ;;
    *)
        print_err "Error: Clean up not implemented for Linux distro: ${ADJUSTED_ID}"
        ;;
    esac
}

# Function: update_snapd
# Description: Updates Snap packages if the `snap` command is installed.
update_snapd() {
    if ! check_command snap; then
        return
    fi

    if ! snap refresh; then
        print_err "Error: Failed to refresh Snap packages."
    fi
}

# Function: update_os_pkg
# Description: Updates the system package cache and performs necessary updates based on the detected Linux distribution.
#              Supports Debian-based (apt-get), RPM-based (dnf/yum/microdnf), and Alpine (apk) package managers.
#              Prints messages indicating the update process and handles errors gracefully.
update_os_pkg() {
    case ${ADJUSTED_ID} in
    debian)
        if [ "$(find /var/lib/apt/lists/* -maxdepth 1 -check_cmd f 2>/dev/null | wc -l)" -eq 0 ]; then
            println "Updating ${PKG_MGR_CMD} based packages..."
            if ! (${PKG_MGR_CMD} update -y &&
                ${PKG_MGR_CMD} upgrade -y &&
                ${PKG_MGR_CMD} dist-upgrade -y &&
                ${PKG_MGR_CMD} autoremove -y &&
                ${PKG_MGR_CMD} autoclean -y); then
                print_err "Error: Update failed."
            fi
        fi

        update_snapd
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
        if ! (${PKG_MGR_CMD} update -y &&
            ${PKG_MGR_CMD} upgrade -y &&
            ${PKG_MGR_CMD} autoremove -y); then
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
            if ! (${PKG_MGR_CMD} -Syu --noconfirm &&
                ${PKG_MGR_CMD} -Rns "$(${PKG_MGR_CMD} -Qdtq)"); then
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

    if ! check_command brew; then
        return
    fi

    brew update && brew upgrade && brew cleanup -s
    println "Brew Diagnostics"
    brew doctor && brew missing
}

# Function: update_vscode_ext
# Description: Updates Visual Studio Code extensions if `VSCode` is installed.
update_vscode_ext() {
    println "Updating VSCode Extensions"

    if ! check_command code; then
        return
    fi

    # Ensure `NON_ROOT_USER` is defined and valid
    if [ -z "${NON_ROOT_USER}" ] || ! id "${NON_ROOT_USER}" >/dev/null 2>&1; then
        print_err "Error: Non-root user '${NON_ROOT_USER}' is invalid or not found."
        return
    fi

    su - "${NON_ROOT_USER}" -c "code --update-extensions"
}

# Function: update_gem
# Description: Updates RubyGems if the 'gem' command is installed.
update_gem() {
    println "Updating Gems"

    if ! check_command gem; then
        return
    fi

    gem update --user-install && gem cleanup --user-install
}

# Function: update_npm
# Description: Updates Npm packages if the 'npm' command is installed.
update_npm() {
    println "Updating Npm Packages"

    if ! check_command npm; then
        return
    fi

    npm update -g
}

# Function: update_yarn
# Description: Updates Yarn packages if the 'yarn' command is installed.
update_yarn() {
    println "Updating Yarn Packages"

    if ! check_command yarn; then
        return
    fi

    yarn upgrade --latest
}

# Function: update_node_pkgs
# Description: Updates Node.js packages if the 'node' command is installed.
update_node_pkgs() {
    println "Updating Node Packages"
    if ! check_command node; then
        return
    fi

    update_npm
    update_yarn
}

# Function: update_cargo
# Description: Updates cargo packages if the 'cargo' command is installed.
update_cargo() {
    println "Updating Rust Cargo Crates"

    if ! check_command cargo; then
        return
    fi

    cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ' | xargs cargo install
}

# Function: install_pkg
# Description: Installs a specified package using the appropriate package manager
#              if the system's package manager is available.
install_pkg() {
    pkg_name="$1"

    if ! check_command "${pkg_name}"; then
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

# Function: check_internet
# Description: Checks if internet is available
check_internet() {
    if ! check_command curl; then
        print_err "Error: curl is required but not installed. Please install curl."
        return 1
    fi

    # Check internet connection by pinging a reliable server
    TEST_URL="https://www.google.com"

    # Use curl to check the connection
    TEST_RESP=$(curl -Is --connect-timeout 2 --max-time 5 "${TEST_URL}" 2>/dev/null | head -n 1)

    # Check if response is empty
    if [ -z "${TEST_RESP}" ]; then
        print_err "No Internet Connection!!!"
        return 1
    fi

    # Check for "200" in the response
    if ! printf "%s" "${TEST_RESP}" | grep -q "200"; then
        print_err "Internet is not working!!!"
        return 1
    fi

    return 0
}

###################################################################################################
# Main Script
###################################################################################################

# Text Color Variables
# Check if the 'tput' command is available
# - If 'tput' is found, it likely indicates that color support is available.
if check_cmd tput; then
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
    print_err "Error: Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script..."
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
if check_cmd apt-get; then
    PKG_MGR_CMD=apt-get
    INSTALL_CMD="${PKG_MGR_CMD} -y install --no-install-recommends"
elif check_cmd apk; then
    PKG_MGR_CMD=apk
    INSTALL_CMD="${PKG_MGR_CMD} add --no-cache"
elif check_cmd pacman; then
    PKG_MGR_CMD=pacman
    INSTALL_CMD="${PKG_MGR_CMD} -S --noconfirm --needed"
elif check_cmd microdnf; then
    PKG_MGR_CMD=microdnf
    INSTALL_CMD="${PKG_MGR_CMD} -y install --refresh --best --nodocs --noplugins --setopt=install_weak_deps=0"
elif check_cmd dnf; then
    PKG_MGR_CMD=dnf
    INSTALL_CMD="${PKG_MGR_CMD} -y install"
elif check_cmd yum; then
    PKG_MGR_CMD=yum
    INSTALL_CMD="${PKG_MGR_CMD} -y install"
else
    print_err "Error: Unsupported or unrecognized package manager"
    exit 1
fi

if check_internet; then
    clean_up
    update_os_pkg
    update_brew
    update_vscode_ext
    update_gem
    update_node_pkgs
    update_cargo
fi
