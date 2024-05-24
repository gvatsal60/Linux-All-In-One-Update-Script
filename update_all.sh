#!/bin/sh

# Text Color Variables
RED=$(tput setaf 1)   # Red
GREEN=$(tput setaf 2) # Green
CLEAR=$(tput sgr0)    # Clear color and formatting

# OS Update Functions

# Function to update Debian based
update_debian() {
    printf "\n%sUpdating Debian based...\n%s" "${GREEN}" "${CLEAR}"
    if ! sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get autoremove -y; then
        printf "\n%sUpdate failed.\n%s" "${RED}" "${CLEAR}"
    fi
}

# Function to update RPM based
update_rpm() {
    printf "\n%sUpdating RPM based...\n%s" "${GREEN}" "${CLEAR}"
    if command -v dnf >/dev/null 2>&1; then
        if ! sudo dnf update -y && sudo dnf upgrade -y && sudo dnf autoremove -y; then
            printf "\n%sUpdate failed.\n%s" "${RED}" "${CLEAR}"
        fi
    elif command -v yum >/dev/null 2>&1; then
        if ! sudo yum update -y && sudo yum upgrade -y && sudo yum autoremove -y; then
            printf "\n%sUpdate failed.\n%s" "${RED}" "${CLEAR}"
        fi
    else
        printf "\n%sUpdate failed unknown package manager\n%s" "${RED}" "${CLEAR}"
    fi
}

# Function to update Pacman based
update_pacman() {
    printf "\n%sUpdating Pacman based...\n%s" "${GREEN}" "${CLEAR}"
    if command -v pacman >/dev/null 2>&1; then
        if ! sudo pacman -Syu --noconfirm; then
            printf "\n%sUpdate failed.\n%s" "${RED}" "${CLEAR}"
        fi
    fi
}

# Function to update APK based
update_apk() {
    printf "\n%sUpdating APK based...\n%s" "${GREEN}" "${CLEAR}"
    if command -v apk >/dev/null 2>&1; then
        if ! sudo apk update && sudo apk upgrade; then
            printf "\n%sUpdate failed.\n%s" "${RED}" "${CLEAR}"
        fi
    fi
}

# Function to update os based on their type
update_os() {
    printf "\n%sUpdate OS Packages\n%s" "${GREEN}" "${CLEAR}"

    # Check if the OS is Debian
    if [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
        update_debian
    # Check if the OS is RPM based
    elif [ -f /etc/redhat-release ] || [ -f /etc/centos-release ]; then
        update_rpm
    # Check if the OS is Pacman based
    elif [ -f /etc/arch-release ]; then
        update_pacman
    # Check if the OS is Alpine based
    elif [ -f /etc/alpine-release ]; then
        update_apk
    else
        printf "\n%sUnsupported Linux distribution.%s\n" "${RED}" "${CLEAR}"
    fi
}

# Function to update vscode extensions
update_vscode_ext() {
    printf "\n%sUpdating VSCode Extensions%s\n" "${GREEN}" "${CLEAR}"

    if ! command -v code >/dev/null 2>&1; then
        printf "\n%sVSCode is not installed.%s" "${RED}" "${CLEAR}"
        return
    fi

    code --update-extensions --no-sandbox
}

# Function to update gem packages
update_gem() {
    printf "\n%sUpdating Gems%s" "${GREEN}" "${CLEAR}"

    if ! command -v gem >/dev/null 2>&1; then
        printf "\n%s" "${RED}Gem is not installed.${CLEAR}"
        return
    fi

    gem update --user-install && gem cleanup --user-install
}

# Function to update npm packages
update_npm() {
    printf "\n%sUpdating Npm Packages%s" "${GREEN}" "${CLEAR}"

    if ! command -v npm >/dev/null 2>&1; then
        printf "\n%s" "${RED}Npm is not installed.${CLEAR}"
        return
    fi

    npm update -g
}

# Function to update yarn packages
update_yarn() {
    printf "\n%sUpdating Yarn Packages%s" "${GREEN}" "${CLEAR}"

    if ! command -v yarn >/dev/null 2>&1; then
        printf "\n%s" "${RED}Yarn is not installed.${CLEAR}"
        return
    fi

    yarn upgrade --latest
}

# Function to update pip3 packages
update_pip3() {
    printf "\n%sUpdating Python 3.x pips%s" "${GREEN}" "${CLEAR}"

    if ! command -v python3 >/dev/null 2>&1 || ! command -v pip3 >/dev/null 2>&1; then
        printf "\n%sPython 3 or pip3 is not installed.%s" "${RED}" "${CLEAR}"
        return
    fi

    # Running with a non-root user
    python3 -m pip list --outdated --format=columns | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 python3 -m pip install -U
}

# Function to update all in one shot
update_all() {
    readonly PING_IP=8.8.8.8
    if ping -q -W 1 -c 1 $PING_IP >/dev/null 2>&1; then
        update_os
        update_vscode_ext
        update_gem
        update_npm
        update_yarn
        update_pip3
        printf "\n"
    else
        printf "\n%sInternet Disabled!!!%s\n" "${RED}" "${CLEAR}"
    fi
}

# COMMENT OUT IF SOURCING
update_all
