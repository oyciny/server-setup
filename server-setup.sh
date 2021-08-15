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

DEFAULT_USERNAME="sammy"
DEFAULT_PASSWORD="password"

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
    clear
    echo -e "${ORANGE} Welcome to the Initial Server Setup Script!${NC}"
    echo ""
    echo "I need to ask you a few questions before starting the setup."
    echo "If you are okay with the default options just hit enter."

    until [[ ${REMOVE_OPTION} == true || ${REMOVE_OPTION} == false ]]; do
        read -rp "First, would you like to remove the script after completion [Y/n]: " -i -n1 REMOVE_UPON_COMPLETION
        if [[ $REMOVE_UPON_COMPLETION == 'Y' || $REMOVE_UPON_COMPLETION == 'y' ]]; then
            REMOVE_OPTION=true
        elif [[ -z $REMOVE_UPON_COMPLETION ]]; then
            REMOVE_OPTION=true
        else
            REMOVE_OPTION=false
        fi
    done

    # Get new user profile name
    # until [[ ${SERVER_USERNAME} =~ ^[a-zA-Z0-9_]+$ ]]; do
    #    clear
    #    read -rp "What should we call your new user [${DEFAULT_USERNAME}]: " -i SERVER_USERNAME
    # done
    clear
    read -rp "What should we call your new user [${DEFAULT_USERNAME}]: " -i DEFAULT_USERNAME

    # Get new user password
    # until [[ ${USER_PASSWORD} =~ ^([a-zA-Z].*)+$ ]]; do
    #    clear
    #    echo "Password must start with any character a-z upper or lowercase!"
    #    read -rp "What should ${SERVER_USER_NAME}\'s be? [${DEFAULT_PASSWORD}]: " -s -i USER_PASSWORD
    # done
    clear
    read -rp "What should ${DEFAULT_USERNAME}'s password be? [${DEFAULT_PASSWORD}]: " -s -i DEFAULT_PASSWORD

    # SSH Keys?
    clear
    read -rp "Are you currently using a SSH Key to log into this server? [Y/n]: " -i -n1 SSH_KEYS
    
    if [[ $SSH_KEYS == 'Y' || $SSH_KEYS == 'y' ]]; then
        SSH_KEY_OPTION=true
    elif [[ -z $SSH_KEYS ]]; then
        SSH_KEY_OPTION=true
    else
        SSH_KEY_OPTION=false
    fi

    clear

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
    echo "${DEFAULT_USERNAME}:${DEFAULT_PASSWORD}" | chpasswd


    # Make user sudo user
    usermod -aG sudo ${DEFAULT_USERNAME}

    # Setup Basic Firewall
    ufw allow OpenSSH
    echo "y" | ufw enable

    if [[ ${SSH_KEY_OPTION} == true ]]; then
        rsync --archive --chown=${DEFAULT_USERNAME}:${DEFAULT_USERNAME} ~/.ssh /home/${DEFAULT_USERNAME}
    fi

    if [[ ${REMOVE_OPTION} == true ]]; then
        rm -- "$0"
    fi

    clear

    su ${DEFAULT_USERNAME}

}

initialCheck
serverSetup