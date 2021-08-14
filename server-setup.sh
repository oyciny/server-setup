#!/bin/bash

# This script aids in the initial server setup process.
# To use it simply download it to your root directory
# upon logging in as root for the first time and run the
# following command to make it executable:
#
# > chmod +x server-setup.sh
#
# Then run the following command to run the setup and you're
# done! Hope you enjoy.

ORANGE='\033[0;33m'
NC='\033[0m'

function isRoot() {
    if [ "${EUID}" -ne 0 ]; then
        echo -e "${RED}You need to run this script as root!${NC}"
        exit 1
    fi
}

function initialCheck() {
    isRoot
}

function installQuestions() {
    echo -e "${ORANGE} Welcome to the Initial Server Setup Script!${NC}"
    echo ""
    echo "I need to ask you a few questions before starting the setup."
    echo "If you are okay with the default options just hit enter."

    until [[ -z ${REMOVE_UPON_COMPLETION} ]]; do
        read -rp "First, would you like to remove the script after completion [Y/n]: " -i -n REMOVE_UPON_COMPLETION
        clear
    done

    # Get new user profile name
    until [[ -z ${SERVER_USER_NAME} ]]; do
        read -rp "What should we call your new user: " -e -i "sammy" SERVER_USER_NAME
        clear
    done

    # Get new user password
    until [[ -z ${USER_PASSWORD} ]]; do
        read -rp "What should we set the password for ${SERVER_USER_NAME} to: " -s -i -n USER_PASSWORD
        clear
    done

    echo " "

    # SSH Keys?
    read -rp "Are you currently using a SSH Key to log into this server? [Y/n]: " -i -n SSH_KEYS
    clear
    
    if [[ $SSH_KEYS == 'Y' || $SSH_KEYS == 'y' ]]; then
        SSH_KEY_OPTION=true
    elif [[ -z $SSH_KEYS ]]; then
        SSH_KEY_OPTION=true
    else
        SSH_KEY_OPTION=false
    fi

    echo "Okay that is all I needed to know! We are ready to do the initial setup of your server."
    echo "Once I have everything done you will be logged into your new user."
    read -n1 -r -p "Press any key to continue..."
}

function serverSetup() {
    # Gather details from user
    installQuestions

    clear
    
    # Create User
    useradd -m -s /usr/bin/bash ${SERVER_USER_NAME}
    echo "${SERVER_USER_NAME}:${USER_PASSWORD}" | chpasswd


    # Make user sudo user
    usermod -aG sudo ${SERVER_USER_NAME}

    # Setup Basic Firewall
    ufw allow OpenSSH
    echo "y" | ufw enable

    if [[ ${SSH_KEY_OPTION} == true ]]; then
        rsync --archive --chown=${SERVER_USER_NAME}:${SERVER_USER_NAME} ~/.ssh /home/${SERVER_USER_NAME}
    fi

    if [[ ${REMOVE_UPON_COMPLETION} == true ]]; then
        rm -- "$0"
    fi

    clear

    su ${SERVER_USER_NAME}

}

initialCheck
serverSetup