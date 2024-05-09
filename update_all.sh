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

# Function to update Ubuntu
update_ubuntu() {
    echo "Updating Ubuntu..."
    apt update -y
    apt upgrade -y
    apt autoremove -y
    echo "Update completed."
}

# Function to update CentOS
update_centos() {
    echo "Updating CentOS..."
    yum update -y
    yum upgrade -y
    yum autoremove -y
    echo "Update completed."
}

# Function to update Debian
update_debian() {
    echo "Updating Debian..."
    apt-get update -y
    apt-get upgrade -y
    apt-get autoremove -y
    echo "Update completed."
}

# Check if the OS is Ubuntu
if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    if [ "$DISTRIB_ID" == "Ubuntu" ]; then
        update_ubuntu
        exit 0
    fi
fi

# Check if the OS is CentOS
if [ -f /etc/centos-release ]; then
    update_centos
    exit 0
fi

# Check if the OS is Debian
if [ -f /etc/debian_version ]; then
    update_debian
    exit 0
fi