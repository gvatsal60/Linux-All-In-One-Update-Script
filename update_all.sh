#!/bin/bash

# To execute run:
#
#    sh update_all.sh
#
# To source and then use individual update-* functions
# first comment out the command at the bottom of the file
# and run:
#
#    source ./update_all.sh
#
# If you want to use this command often copy it to directory
# that you have in PATH (check with `echo $PATH`) like this:
#
#       USER_SCRIPTS="${HOME}/.local/bin"
#       mkdir -p $USER_SCRIPTS
#       cp ./update_all.sh $USER_SCRIPTS/update_all
#       chmod +x $USER_SCRIPTS/update_all
#  and now you can call the script any time :)

# Text Color Variables
readonly RED='\033[31m'   # Red
readonly GREEN='\033[32m' # Green
readonly CLEAR='\033[0m'  # Clear color and formatting

# Global Variables
readonly SUDO_USER=$(logname)

# Function to check if script is run with sudo
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run this script with sudo!!!${CLEAR}"
        return 255
    fi
}

# OS Update Function

# Function to update Debian based
update_debian() {
    echo -e "${GREEN}Updating Debian based...${CLEAR}"
    apt-get update -y && apt-get upgrade -y && apt-get autoremove -y
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Update completed.${CLEAR}"
    else
        echo -e "${RED}Update failed.${CLEAR}"
        return
    fi
}

# Function to update RPM based
update_rpm() {
    echo -e "${GREEN}Updating RPM based...${CLEAR}"
    if command -v dnf &>/dev/null; then
        dnf upgrade -y && dnf autoremove -y
    else
        yum update -y && yum autoremove -y
    fi
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Update completed.${CLEAR}"
    else
        echo -e "${RED}Update failed.${CLEAR}"
        return
    fi
}

# Function to update Pacman based
update_pacman() {
    echo -e "${GREEN}Updating Pacman based...${CLEAR}"
    
    # Check if pacman is available
    if ! command -v pacman &>/dev/null; then
        echo -e "${RED}Pacman is not installed.${CLEAR}"
        return 1
    fi
    
    # Update pacman packages
    pacman -Syu --noconfirm
    
    # Check if update was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Update completed.${CLEAR}"
    else
        echo -e "${RED}Update failed.${CLEAR}"
        return
    fi
}

# Function to update os based on their type
update_os() {
    echo -e "${GREEN}Update OS Packages${CLEAR}"

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
    echo -e "\n${GREEN}Updating VSCode Extensions${CLEAR}"

    if ! command -v code &>/dev/null; then
        echo -e "${RED}VSCode is not installed.${CLEAR}"
        return
    fi
    
    local CODE_DIR=$(dirname which code)
    sudo -u $SUDO_USER code --update-extensions --no-sandbox --user-data-dir=$CODE_DIR
}

# Function to update gem packages
update_gem() {
    echo -e "\n${GREEN}Updating Gems${CLEAR}"

    if ! command -v gem &>/dev/null; then
        echo -e "${RED}Gem is not installed.${CLEAR}"
        return
    fi

    gem update --user-install && gem cleanup --user-install
}

# Function to update npm packages
update_npm() {
    echo -e "\n${GREEN}Updating Npm Packages${CLEAR}"

    if ! command -v npm &>/dev/null; then
        echo -e "${RED}Npm is not installed.${CLEAR}"
        return
    fi

    npm update -g
}

# Function to update yarn packages
update_yarn() {
    echo -e "\n${GREEN}Updating Yarn Packages${CLEAR}"

    if ! command -v yarn &>/dev/null; then
        echo -e "${RED}Yarn is not installed.${CLEAR}"
        return
    fi

    yarn upgrade --latest
}

# Function to update pip3 packages
update_pip3() {
    echo -e "\n${GREEN}Updating Python 3.x pips${CLEAR}"

    if ! command -v python3 &>/dev/null || ! command -v pip3 &>/dev/null; then
        echo -e "${RED}Python 3 or pip3 is not installed.${CLEAR}"
        return
    fi

    # Running with a non-root user
    sudo -u $SUDO_USER pip3 list --outdated --format=columns | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U
}

# Function to update all in one shot
update_all() {
    local PING_IP=8.8.8.8
    if ping -q -W 1 -c 1 $PING_IP &>/dev/null; then
        update_os
        update_vscode_ext
        update_gem
        update_npm
        update_yarn
        update_pip3
    else
        echo -e "${RED}Internet Disabled!!!${CLEAR}"
    fi
}

# COMMENT OUT IF SOURCING
update_all
