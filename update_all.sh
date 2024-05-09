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

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Text Color Variables
readonly RED='\033[31m'      # Red
readonly GREEN='\033[32m'    # Green
readonly CLEAR='\033[0m'     # Clear color and formatting

# Function to update Ubuntu
update_ubuntu() {
    echo -e "${GREEN}Updating Ubuntu...${CLEAR}"
    apt update -y && apt upgrade -y && apt autoremove -y
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Update completed.${CLEAR}"
    else
        echo -e "${RED}Update failed.${CLEAR}"
        exit 1
    fi
}

# Function to update CentOS or Fedora
update_centos() {
    echo -e "${GREEN}Updating CentOS...${CLEAR}"
    if command -v dnf &>/dev/null; then
        dnf upgrade -y && dnf autoremove -y
    else
        yum update -y && yum autoremove -y
    fi
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Update completed.${CLEAR}"
    else
        echo -e "${RED}Update failed.${CLEAR}"
        exit 1
    fi
}

# Function to update Debian
update_debian() {
    echo -e "${GREEN}Updating Debian...${CLEAR}"
    apt-get update -y && apt-get upgrade -y && apt-get autoremove -y
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Update completed.${CLEAR}"
    else
        echo -e "${RED}Update failed.${CLEAR}"
        exit 1
    fi
}

# Check if the OS is Ubuntu
if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    if [ "$DISTRIB_ID" == "Ubuntu" ]; then
        update_ubuntu
        exit 0
    fi
fi

# Check if the OS is CentOS or Fedora
if [ -f /etc/redhat-release ] || [ -f /etc/centos-release ]; then
    update_centos
    exit 0
fi

# Check if the OS is Debian
if [ -f /etc/debian_version ]; then
    update_debian
    exit 0
fi

echo "Unsupported Linux distribution."
exit 1

