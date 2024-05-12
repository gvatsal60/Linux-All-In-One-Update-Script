# shellcheck shell=sh

# Text Color Variables
readonly RED='\033[31m'   # Red
readonly GREEN='\033[32m' # Green
readonly CLEAR='\033[0m'  # Clear color and formatting

# Global Variables
readonly SUDO_USER
SUDO_USER=$(logname)

# Function to check if script is run with sudo
check_sudo() {
    if [ "$(id -u)" -ne 0 ]; then
        printf "\n%sPlease run this script with sudo!!!%s" "${RED}" "${CLEAR}"
        return 255
    fi
}

# OS Update Function

# Function to update Debian based
update_debian() {
    printf "\n%sUpdating Debian based...%s" "${GREEN}" "${CLEAR}"
    if apt-get update -y && apt-get upgrade -y && apt-get autoremove -y; then
        printf "\n%s" "${GREEN}Update completed.${CLEAR}"
    else
        printf "\n%s" "${RED}Update failed.${CLEAR}"
        return
    fi
}

# Function to update RPM based
update_rpm() {
    printf "\n%s" "${GREEN}Updating RPM based...${CLEAR}"
    if command -v dnf >/dev/null 2>&1; then
        if dnf upgrade -y && dnf autoremove -y; then
            printf "\n%s" "${GREEN}Update completed.${CLEAR}"
        else
            printf "\n%s" "${RED}Update failed.${CLEAR}"
            return
        fi
    else
        if yum update -y && yum autoremove -y; then
            printf "\n%s" "${GREEN}Update completed.${CLEAR}"
        else
            printf "\n%s" "${RED}Update failed.${CLEAR}"
            return
        fi
    fi
}

# Function to update Pacman based
update_pacman() {
    printf "\n%s" "${GREEN}Updating Pacman based...${CLEAR}"

    # Check if pacman is available
    if ! command -v pacman >/dev/null 2>&1; then
        printf "\n%s" "${RED}Pacman is not installed.${CLEAR}"
        return 1
    fi

    # Update pacman packages and check if the update was successful
    if pacman -Syu --noconfirm; then
        printf "\n%s" "${GREEN}Update completed.${CLEAR}"
    else
        printf "\n%s" "${RED}Update failed.${CLEAR}"
        return
    fi
}

# Function to update os based on their type
update_os() {
    printf "\n%s" "${GREEN}Update OS Packages${CLEAR}"

    # Check if script is run with sudo
    if check_sudo; then
        # Check if the OS is Debian
        if [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
            update_debian
        # Check if the OS is RPM based
        elif [ -f /etc/redhat-release ] || [ -f /etc/centos-release ]; then
            update_rpm
        # Check if the OS is Pacman based
        elif [ -f /etc/arch-release ]; then
            update_pacman
        else
            echo "Unsupported Linux distribution."
        fi
    fi
}

# Function to update vscode extensions
update_vscode_ext() {
    printf "\n\n%sUpdating VSCode Extensions%s" "${GREEN}" "${CLEAR}"

    if ! command -v code >/dev/null 2>&1; then
        printf "\n%sVSCode is not installed.%s" "${RED}" "${CLEAR}"
        return
    fi

    readonly CODE_DIR
    CODE_DIR=$(dirname "$(command -v code)")

    sudo -u "$SUDO_USER" code --update-extensions --no-sandbox --user-data-dir="$CODE_DIR"
}

# Function to update gem packages
update_gem() {
    printf "\n\n%s" "${GREEN}Updating Gems${CLEAR}"

    if ! command -v gem >/dev/null 2>&1; then
        printf "\n%s" "${RED}Gem is not installed.${CLEAR}"
        return
    fi

    gem update --user-install && gem cleanup --user-install
}

# Function to update npm packages
update_npm() {
    printf "\n\n%s" "${GREEN}Updating Npm Packages${CLEAR}"

    if ! command -v npm >/dev/null 2>&1; then
        printf "\n%s" "${RED}Npm is not installed.${CLEAR}"
        return
    fi

    npm update -g
}

# Function to update yarn packages
update_yarn() {
    printf "\n\n%s" "${GREEN}Updating Yarn Packages${CLEAR}"

    if ! command -v yarn >/dev/null 2>&1; then
        printf "\n%s" "${RED}Yarn is not installed.${CLEAR}"
        return
    fi

    yarn upgrade --latest
}

# Function to update pip3 packages
update_pip3() {
    printf "\n\n%s" "${GREEN}Updating Python 3.x pips${CLEAR}"

    if ! command -v python3 >/dev/null 2>&1 || ! command -v pip3 >/dev/null 2>&1; then
        printf "\n%sPython 3 or pip3 is not installed.%s" "${RED}" "${CLEAR}"
        return
    fi

    # Running with a non-root user
    sudo -u "$SUDO_USER" pip3 list --outdated --format=columns | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U
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
    else
        printf "\n%sInternet Disabled!!!%s" "${RED}" "${CLEAR}"
    fi
}

# COMMENT OUT IF SOURCING
update_all
