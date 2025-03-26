#!/bin/bash
CI_INSTALL_DIR="/var/lib/vz"
export CI_INSTALL_DIR
export CI_TEMPLATE_DIR="$CI_INSTALL_DIR/template/raw"
CI_MAIN_DIR="$CI_INSTALL_DIR/cloudinit"
export CI_MAIN_DIR
export CI_SCRIPTS="$CI_MAIN_DIR/scripts"

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