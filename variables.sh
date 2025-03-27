#!/bin/bash
CI_INSTALL_DIR="/var/lib/vz"
export CI_INSTALL_DIR
export CI_TEMPLATE_DIR="$CI_INSTALL_DIR/template/raw"
CI_MAIN_DIR="$CI_INSTALL_DIR/cloudinit"
export CI_MAIN_DIR
export CI_SCRIPTS="$CI_MAIN_DIR/scripts"
export CI_VM_NETWORKS

export CI_VM_NAME="unnamed-vm"

export CI_CIDR=24
export CI_GATEWAY="192.168.1.1"
export CI_DNS="1.1.1.1 1.0.0.1"

export CI_OS="debian12"

export CI_ROOT_PASSWORD="root"
export CI_USER_NAME="user"
export CI_USER_PASSWORD="user"

export CI_CPU=1
export CI_RAM=2048
export CI_DISK="20G"

export CI_STORAGE="local-lvm"

CI_CUSTOM_VARIABLES="/etc/cloudinit/custom.sh"
if [[ -e $CI_CUSTOM_VARIABLES ]]; then
    if [[ "$CI_VERBOSE" -eq 1 ]]; then
        echo "Importing /etc/cloudinit/custom.sh"
    fi
    chmod +x $CI_CUSTOM_VARIABLES
    source $CI_CUSTOM_VARIABLES
else
    if [[ "$CI_VERBOSE" -eq 1 ]]; then
        echo "/etc/cloudinit/custom.sh not found, no custom variables imported"
    fi
fi